/*
 * Copyright 2015 The Netty Project
 *
 * The Netty Project licenses this file to you under the Apache License, version 2.0 (the
 * "License"); you may not use this file except in compliance with the License. You may obtain a
 * copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" ~BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
module hunt.net.buffer.ByteProcessor;

import std.concurrency : initOnce;

/**
 * Provides a mechanism to iterate over a collection of bytes.
 */
interface ByteProcessor {

    enum byte SPACE = ' ';
    enum byte HTAB = '\t';
    enum byte CARRIAGE_RETURN = '\r';
    enum byte LINE_FEED = '\n';

    /**
     * Aborts on a {@code NUL (0x00)}.
     */
    static ByteProcessor FIND_NUL() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new IndexOfProcessor(cast(byte) 0));
    }

    /**
     * Aborts on a non-{@code NUL (0x00)}.
     */
    static ByteProcessor FIND_NON_NUL() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new IndexNotOfProcessor(cast(byte) 0));
    }

    /**
     * Aborts on a {@code CR ('\r')}.
     */
    static ByteProcessor FIND_CR() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new IndexOfProcessor(CARRIAGE_RETURN));
    }

    /**
     * Aborts on a non-{@code CR ('\r')}.
     */
    static ByteProcessor FIND_NON_CR() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new IndexNotOfProcessor(CARRIAGE_RETURN));
    }

    /**
     * Aborts on a {@code LF ('\n')}.
     */
    static ByteProcessor FIND_LF() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new IndexOfProcessor(LINE_FEED));
    }

    /**
     * Aborts on a non-{@code LF ('\n')}.
     */
    static ByteProcessor FIND_NON_LF() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new IndexNotOfProcessor(LINE_FEED));
    }

    /**
     * Aborts on a semicolon {@code (';')}.
     */
    static ByteProcessor FIND_SEMI_COLON() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new IndexOfProcessor(cast(byte) ';'));
    }

    /**
     * Aborts on a comma {@code (',')}.
     */
    static ByteProcessor FIND_COMMA() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new IndexOfProcessor(cast(byte) ','));
    }

    /**
     * Aborts on a ascii space character ({@code ' '}).
     */
    static ByteProcessor FIND_ASCII_SPACE() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new IndexOfProcessor(SPACE));
    }

    /**
     * Aborts on a {@code CR ('\r')} or a {@code LF ('\n')}.
     */
    static ByteProcessor FIND_CRLF() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new class ByteProcessor {
            bool process(byte value) {
                return value != CARRIAGE_RETURN && value != LINE_FEED;
            }
        });
    }

    /**
     * Aborts on a byte which is neither a {@code CR ('\r')} nor a {@code LF ('\n')}.
     */
    static ByteProcessor FIND_NON_CRLF() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new class ByteProcessor {
            bool process(byte value) {
                return value == CARRIAGE_RETURN || value == LINE_FEED;
            }
        });
    }

    /**
     * Aborts on a linear whitespace (a ({@code ' '} or a {@code '\t'}).
     */
    static ByteProcessor FIND_LINEAR_WHITESPACE() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new class ByteProcessor {
            bool process(byte value) {
                return value != SPACE && value != HTAB;
            }
        });
    }

    /**
     * Aborts on a byte which is not a linear whitespace (neither {@code ' '} nor {@code '\t'}).
     */
    static ByteProcessor FIND_NON_LINEAR_WHITESPACE() {
        __gshared ByteProcessor inst;
        return initOnce!inst(new class ByteProcessor {
            bool process(byte value) {
                return value == SPACE || value == HTAB;
            }
        });
    }

    /**
     * @return {@code true} if the processor wants to continue the loop and handle the next byte in the buffer.
     *         {@code false} if the processor wants to stop handling bytes and abort the loop.
     */
    bool process(byte value);
}


/**
 * A {@link ByteProcessor} which finds the first appearance of a specific byte.
 */
class IndexOfProcessor : ByteProcessor {
    private byte byteToFind;

    this(byte byteToFind) {
        this.byteToFind = byteToFind;
    }

    override
    bool process(byte value) {
        return value != byteToFind;
    }
}

/**
 * A {@link ByteProcessor} which finds the first appearance which is not of a specific byte.
 */
class IndexNotOfProcessor : ByteProcessor {
    private byte byteToNotFind;

    this(byte byteToNotFind) {
        this.byteToNotFind = byteToNotFind;
    }

    override
    bool process(byte value) {
        return value == byteToNotFind;
    }
}