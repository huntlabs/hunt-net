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
module test.HeapByteBufTest;

import test.AbstractByteBufTest;

import hunt.Assert;
import hunt.Byte;
import hunt.collection;
import hunt.Exceptions;
import hunt.io.Common;
import hunt.logging.ConsoleLogger;
import hunt.net.buffer;
import hunt.text.Charset;
import hunt.util.Common;
import hunt.util.UnitTest;

/**
 * Tests little-endian heap channel buffers
 */
class HeapByteBufTest : AbstractByteBufTest {

    override
    protected ByteBuf newBuffer(int length, int maxCapacity) {
        ByteBuf buffer = Unpooled.buffer(length, maxCapacity); // .order(ByteOrder.LittleEndian);
        assertEquals(0, buffer.writerIndex());
        return buffer;
    }
}
