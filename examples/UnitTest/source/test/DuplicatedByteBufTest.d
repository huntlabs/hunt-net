/*
 * Copyright 2012 The Netty Project
 *
 * The Netty Project licenses this file to you under the Apache License,
 * version 2.0 (the "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at:
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" ~BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
module test.DuplicatedByteBufTest;

import test.AbstractByteBufTest;

import hunt.Assert;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.collection;
import hunt.stream.Common;

import hunt.net.buffer;

/**
 * Tests duplicated channel buffers
 */
class DuplicatedByteBufTest : AbstractByteBufTest {

    override
    protected ByteBuf newBuffer(int length, int maxCapacity) {
        ByteBuf wrapped = Unpooled.buffer(length, maxCapacity);
        ByteBuf buffer = new DuplicatedByteBuf(wrapped);
        assertEquals(wrapped.writerIndex(), buffer.writerIndex());
        assertEquals(wrapped.readerIndex(), buffer.readerIndex());
        return buffer;
    }

    alias newBuffer = AbstractByteBufTest.newBuffer;

    // @Test(expected = NullPointerException.class)
    // void shouldNotAllowNullInConstructor() {
    //     new DuplicatedByteBuf(null);
    // }

    // See https://github.com/netty/netty/issues/1800
    @Test
    void testIncreaseCapacityWrapped() {
        ByteBuf buffer = newBuffer(8);
        ByteBuf wrapped = buffer.unwrap();
        wrapped.writeByte(0);
        wrapped.readerIndex(wrapped.readerIndex() + 1);
        buffer.writerIndex(buffer.writerIndex() + 1);
        wrapped.capacity(wrapped.capacity() * 2);

        assertEquals(cast(byte) 0, buffer.readByte());
    }

    @Test
    void testMarksInitialized() {
        ByteBuf wrapped = Unpooled.buffer(8);
        try {
            wrapped.writerIndex(6);
            wrapped.readerIndex(1);
            ByteBuf duplicate = new DuplicatedByteBuf(wrapped);

            // Test writer mark
            duplicate.writerIndex(duplicate.writerIndex() + 1);
            duplicate.resetWriterIndex();
            assertEquals(wrapped.writerIndex(), duplicate.writerIndex());

            // Test reader mark
            duplicate.readerIndex(duplicate.readerIndex() + 1);
            duplicate.resetReaderIndex();
            assertEquals(wrapped.readerIndex(), duplicate.readerIndex());
        } finally {
            wrapped.release();
        }
    }
}
