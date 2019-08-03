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
module hunt.net.codec.textline.TextLineEncoder;

import hunt.net.codec.textline.LineDelimiter;
import hunt.net.codec.Encoder;
import hunt.net.Connection;

import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.Exceptions;

import std.conv;


/**
 * A {@link ProtocolEncoder} which encodes a string into a text line
 * which ends with the delimiter.
 *
 * @author <a href="http://mina.apache.org">Apache MINA Project</a>
 */
class TextLineEncoder : EncoderChain {
    private enum string ENCODER = "encoder";

    private LineDelimiter delimiter;

    private int maxLineLength = int.max;

    /**
     * Creates a new instance with the current default {@link Charset}
     * and {@link LineDelimiter#UNIX} delimiter.
     */
    this() {
        this(LineDelimiter.UNIX);
    }

    /**
     * Creates a new instance with the current default {@link Charset}
     * and the specified <tt>delimiter</tt>.
     * 
     * @param delimiter The line delimiter to use
     */
    this(string delimiter) {
        this(LineDelimiter(delimiter));
    }

    /**
     * Creates a new instance with the current default {@link Charset}
     * and the specified <tt>delimiter</tt>.
     * 
     * @param delimiter The line delimiter to use
     */
    this(LineDelimiter delimiter) {
        if (LineDelimiter.AUTO == delimiter) {
            throw new IllegalArgumentException("AUTO delimiter is not allowed for encoder.");
        }

        this.delimiter = delimiter;        
    }

    /**
     * @return the allowed maximum size of the encoded line.
     * If the size of the encoded line exceeds this value, the encoder
     * will throw a {@link IllegalArgumentException}.  The default value
     * is {@link Integer#MAX_VALUE}.
     */
    int getMaxLineLength() {
        return maxLineLength;
    }

    /**
     * Sets the allowed maximum size of the encoded line.
     * If the size of the encoded line exceeds this value, the encoder
     * will throw a {@link IllegalArgumentException}.  The default value
     * is {@link Integer#MAX_VALUE}.
     * 
     * @param maxLineLength The maximum line length
     */
    void setMaxLineLength(int maxLineLength) {
        if (maxLineLength <= 0) {
            throw new IllegalArgumentException("maxLineLength: " ~ maxLineLength.to!string());
        }

        this.maxLineLength = maxLineLength;
    }

    /**
     * {@inheritDoc}
     */
    override
    void encode(Object message, Connection session)  { // , ProtocolEncoderOutput out
    
        // string value = message is null ? "" : message.toString();
        // ByteBuffer buf = BufferUtils.allocate(value.length());
        // buf.put(value);

        // if (buf.position() > maxLineLength) {
        //     throw new IllegalArgumentException("Line length: " + buf.position());
        // }

        // buf.put(delimiter.getValue());
        // buf.flip();

        // // 

        // session.write();
    }

    /**
     * Dispose the encoder
     * 
     * @throws Exception If the dispose failed
     */
    void dispose()  {
        // Do nothing
    }
}