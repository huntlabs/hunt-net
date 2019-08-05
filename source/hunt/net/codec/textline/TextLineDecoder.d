/*
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 *
 */
module hunt.net.codec.textline.TextLineDecoder;

import hunt.net.codec.textline.LineDelimiter;
import hunt.net.codec.Decoder;
import hunt.net.Connection;
import hunt.net.Exceptions;

import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.String;

import std.algorithm;
import std.conv;


/**
 * A {@link ProtocolDecoder} which decodes a text line into a string.
 *
 * @author <a href="http://mina.apache.org">Apache MINA Project</a>
 */
class TextLineDecoder : DecoderChain {
    private enum string CONTEXT = "context";

    // private final Charset charset;

    /** The delimiter used to determinate when a line has been fully decoded */
    private LineDelimiter delimiter;

    /** An ByteBuffer containing the delimiter */
    private ByteBuffer delimBuf;

    /** The default maximum Line length. Default to 1024. */
    private int maxLineLength = 1024;

    /** The default maximum buffer length. Default to 128 chars. */
    private int bufferLength = 128;

    this() {
        this(cast(DecoderChain)null);
    }

    /**
     * Creates a new instance with the current default {@link Charset}
     * and {@link LineDelimiter#AUTO} delimiter.
     */
    this(DecoderChain nextDecoder) {
        this(LineDelimiter.AUTO, nextDecoder);
    }

    /**
     * Creates a new instance with the current default {@link Charset}
     * and the specified <tt>delimiter</tt>.
     * 
     * @param delimiter The line delimiter to use
     */
    this(string delimiter, DecoderChain nextDecoder = null) {
        this(LineDelimiter(delimiter), nextDecoder);
    }

    /**
     * Creates a new instance with the current default {@link Charset}
     * and the specified <tt>delimiter</tt>.
     * 
     * @param delimiter The line delimiter to use
     */
    this(LineDelimiter delimiter, DecoderChain nextDecoder = null) {
        // this(Charset.defaultCharset(), delimiter);
        super(nextDecoder);
        this.delimiter = delimiter;

        // Convert delimiter to ByteBuffer if not done yet.
        if (delimBuf is null) {
            ByteBuffer tmp = BufferUtils.allocate(2);//  ByteBuffer.allocate(2).setAutoExpand(true);

            try {
                tmp.put(cast(byte[])delimiter.getValue());
            } catch (CharacterCodingException cce) {
                warning(cce);
            }

            tmp.flip();
            delimBuf = tmp;
        }        
    }

    /**
     * @return the allowed maximum size of the line to be decoded.
     * If the size of the line to be decoded exceeds this value, the
     * decoder will throw a {@link BufferDataException}.  The default
     * value is <tt>1024</tt> (1KB).
     */
    int getMaxLineLength() {
        return maxLineLength;
    }

    /**
     * Sets the allowed maximum size of the line to be decoded.
     * If the size of the line to be decoded exceeds this value, the
     * decoder will throw a {@link BufferDataException}.  The default
     * value is <tt>1024</tt> (1KB).
     * 
     * @param maxLineLength The maximum line length
     */
    void setMaxLineLength(int maxLineLength) {
        if (maxLineLength <= 0) {
            throw new IllegalArgumentException("maxLineLength (" ~ 
                maxLineLength.to!string() ~ ") should be a positive value");
        }

        this.maxLineLength = maxLineLength;
    }

    /**
     * Sets the default buffer size. This buffer is used in the Context
     * to store the decoded line.
     *
     * @param bufferLength The default bufer size
     */
    void setBufferLength(int bufferLength) {
        if (bufferLength <= 0) {
            throw new IllegalArgumentException("bufferLength (" ~ 
                maxLineLength.to!string() ~ ") should be a positive value");

        }

        this.bufferLength = bufferLength;
    }

    /**
     * @return the allowed buffer size used to store the decoded line
     * in the Context instance.
     */
    int getBufferLength() {
        return bufferLength;
    }

    /**
     * {@inheritDoc}
     */
    override
    void decode(ByteBuffer buf, Connection connection) { // , ProtocolDecoderOutput out
        Context ctx = getContext(connection);

        if (LineDelimiter.AUTO == delimiter) {
            decodeAuto(ctx, connection, buf);
        } else {
            decodeNormal(ctx, connection, buf);
        }
    }

    /**
     * @return the context for this connection
     * 
     * @param connection The connection for which we want the context
     */
    private Context getContext(Connection connection) {
        Context ctx;
        ctx = cast(Context) connection.getAttribute(CONTEXT);

        if (ctx is null) {
            ctx = new Context(bufferLength);
            connection.setAttribute(CONTEXT, ctx);
        }

        return ctx;
    }


    /**
     * {@inheritDoc}
     */
    void dispose(Connection connection) {
        Context ctx = cast(Context) connection.getAttribute(CONTEXT);

        if (ctx !is null) {
            connection.removeAttribute(CONTEXT);
        }
    }

    /**
     * Decode a line using the default delimiter on the current system
     */
    private void decodeAuto(Context ctx, Connection connection, ByteBuffer inBuffer) { // , ProtocolDecoderOutput out
        int matchCount = ctx.getMatchCount();

        // Try to find a match
        int oldPos = inBuffer.position();
        int oldLimit = inBuffer.limit();

        while (inBuffer.hasRemaining()) {
            byte b = inBuffer.get();
            bool matched = false;

            switch (b) {
            case '\r':
                // Might be Mac, but we don't auto-detect Mac EOL
                // to avoid confusion.
                matchCount++;
                break;

            case '\n':
                // UNIX
                matchCount++;
                matched = true;
                break;

            default:
                matchCount = 0;
            }

            if (matched) {
                // Found a match.
                int pos = inBuffer.position();
                inBuffer.limit(pos);
                inBuffer.position(oldPos);

                ctx.append(inBuffer);

                inBuffer.limit(oldLimit);
                inBuffer.position(pos);

                if (ctx.getOverflowPosition() == 0) {
                    ByteBuffer buf = ctx.getBuffer();
                    buf.flip();
                    buf.limit(buf.limit() - matchCount);

                    try {
                        byte[] data = new byte[buf.limit()];
                        buf.get(data);
                        string str = cast(string)data;

                        // call connection handler
                        ConnectionEventHandler handler = connection.getHandler();
                        if(handler !is null) {
                            handler.messageReceived(connection, new String(str));
                        }
                    } finally {
                        buf.clear();
                    }
                } else {
                    int overflowPosition = ctx.getOverflowPosition();
                    ctx.reset();
                    throw new RecoverableProtocolDecoderException("Line is too long: " ~ overflowPosition.to!string());
                }

                oldPos = pos;
                matchCount = 0;
            }
        }

        // Put remainder to buf.
        inBuffer.position(oldPos);
        ctx.append(inBuffer);

        ctx.setMatchCount(matchCount);
    }

    /**
     * Decode a line using the delimiter defined by the caller
     */
    private void decodeNormal(Context ctx, Connection connection, ByteBuffer inBuffer) { // , ProtocolDecoderOutput out
        int matchCount = ctx.getMatchCount();

        // Try to find a match
        int oldPos = inBuffer.position();
        int oldLimit = inBuffer.limit();

        while (inBuffer.hasRemaining()) {
            byte b = inBuffer.get();

            if (delimBuf.get(matchCount) == b) {
                matchCount++;

                if (matchCount == delimBuf.limit()) {
                    // Found a match.
                    int pos = inBuffer.position();
                    inBuffer.limit(pos);
                    inBuffer.position(oldPos);

                    ctx.append(inBuffer);

                    inBuffer.limit(oldLimit);
                    inBuffer.position(pos);

                    if (ctx.getOverflowPosition() == 0) {
                        ByteBuffer buf = ctx.getBuffer();
                        buf.flip();
                        buf.limit(buf.limit() - matchCount);

                        try {
                            // writeText(connection, buf.getString(ctx.getDecoder()), out);

                            byte[] data = new byte[buf.limit()];
                            buf.get(data);
                            string str = cast(string)data;

                            // call connection handler
                            ConnectionEventHandler handler = connection.getHandler();
                            if(handler !is null) {
                                handler.messageReceived(connection, new String(str));
                            }                            
                        } finally {
                            buf.clear();
                        }
                    } else {
                        int overflowPosition = ctx.getOverflowPosition();
                        ctx.reset();
                        throw new RecoverableProtocolDecoderException("Line is too long: " ~ overflowPosition.to!string());
                    }

                    oldPos = pos;
                    matchCount = 0;
                }
            } else {
                // fix for DIRMINA-506 & DIRMINA-536
                inBuffer.position(max(0, inBuffer.position() - matchCount));
                matchCount = 0;
            }
        }

        // Put remainder to buf.
        inBuffer.position(oldPos);
        ctx.append(inBuffer);

        ctx.setMatchCount(matchCount);
    }


    /**
     * A Context used during the decoding of a lin. It stores the decoder,
     * the temporary buffer containing the decoded line, and other status flags.
     *
     * @author <a href="mailto:dev@directory.apache.org">Apache Directory Project</a>
     * @version $Rev$, $Date$
     */
    private class Context {
        /** The decoder */
        // private final CharsetDecoder decoder;

        /** The temporary buffer containing the decoded line */
        private ByteBuffer buf;

        /** The number of lines found so far */
        private int matchCount = 0;

        /** A counter to signal that the line is too long */
        private int overflowPosition = 0;

        /** Create a new Context object with a default buffer */
        private this(int bufferLength) {
            // decoder = charset.newDecoder();
            // buf = ByteBuffer.allocate(bufferLength).setAutoExpand(true);
            buf = BufferUtils.allocate(bufferLength);
        }

        // CharsetDecoder getDecoder() {
        //     return decoder;
        // }

        ByteBuffer getBuffer() {
            return buf;
        }

        int getOverflowPosition() {
            return overflowPosition;
        }

        int getMatchCount() {
            return matchCount;
        }

        void setMatchCount(int matchCount) {
            this.matchCount = matchCount;
        }

        void reset() {
            overflowPosition = 0;
            matchCount = 0;
            // decoder.reset();
        }

        void append(ByteBuffer buffer) {
            if (overflowPosition != 0) {
                discard(buffer);
            } else if (buf.position() > maxLineLength - buffer.remaining()) {
                overflowPosition = buf.position();
                buf.clear();
                discard(buffer);
            } else {
                getBuffer().put(buffer);
            }
        }

        private void discard(ByteBuffer buffer) {
            if (int.max - buffer.remaining() < overflowPosition) {
                overflowPosition = int.max;
            } else {
                overflowPosition += buffer.remaining();
            }

            buffer.position(buffer.limit());
        }
    }
}