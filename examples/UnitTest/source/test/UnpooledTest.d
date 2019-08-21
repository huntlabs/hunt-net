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
module test.UnpooledTest;

import hunt.Assert;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.collection;
import hunt.io.Common;

import hunt.net.buffer;

// alias copiedBuffer = Unpooled.copiedBuffer;
// alias copyInt = Unpooled.copyInt;
// alias copyShort = Unpooled.copyShort;
// alias copyMedium = Unpooled.copyMedium;
// alias copyLong = Unpooled.copyLong;
// alias copyBoolean = Unpooled.copyBoolean;
// alias copyFloat = Unpooled.copyFloat;
// alias copyDouble = Unpooled.copyDouble;
// alias EMPTY_BUFFER = Unpooled.EMPTY_BUFFER;
// alias wrappedUnmodifiableBuffer = Unpooled.wrappedUnmodifiableBuffer;
// alias wrappedBuffer = Unpooled.wrappedBuffer;

enum ByteBuffer[] EMPTY_BYTE_BUFFERS = [];
enum byte[] EMPTY_BYTES = [];

/**
 * Tests channel buffers
 */
class UnpooledTest {

    private __gshared ByteBuf[] EMPTY_BYTE_BUFS = [];
    private __gshared byte[][] EMPTY_BYTES_2D;

    shared static this() {

    }

    @Test
    void testCompositeWrappedBuffer() {
        ByteBuf header = Unpooled.buffer(12);
        ByteBuf payload = Unpooled.buffer(512);

        header.writeBytes(new byte[12]);
        payload.writeBytes(new byte[512]);

        ByteBuf buffer = wrappedBuffer(header, payload);

        assertEquals(12, header.readableBytes());
        assertEquals(512, payload.readableBytes());

        assertEquals(12 + 512, buffer.readableBytes());
        assertEquals(2, buffer.nioBufferCount());

        buffer.release();
    }

    @Test
    void testHashCode() {
        Map!(const(byte)[], int) map = new LinkedHashMap!(const(byte)[], int)();
        map.put([], 1);
        map.put(cast(byte[])[ 1 ], 32);
        map.put(cast(byte[])[ 2 ], 33);
        map.put(cast(byte[])[ 0, 1 ], 962);
        map.put(cast(byte[])[ 1, 2 ], 994);
        map.put(cast(byte[])[ 0, 1, 2, 3, 4, 5 ], 63504931);
        map.put(cast(byte[])[ 6, 7, 8, 9, 0, 1 ], cast(int) 97180294697L);
        map.put(cast(byte[])[ -1, -1, -1, 0xE1 ], 1);

        foreach(const(byte)[] key, int value; map) {
            ByteBuf buffer = wrappedBuffer(cast(byte[])key);
            assertEquals(
                    value,
                    ByteBufUtil.toHash(buffer));
            buffer.release();
        }
    }

    @Test
    void testEquals() {
        ByteBuf a, b;

        // Different length.
        a = wrappedBuffer(cast(byte[])[ 1  ]);
        b = wrappedBuffer(cast(byte[])[ 1, 2 ]);
        assertFalse(ByteBufUtil.equals(a, b));
        a.release();
        b.release();

        // Same content, same firstIndex, short length.
        a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]);
        b = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]);
        assertTrue(ByteBufUtil.equals(a, b));
        a.release();
        b.release();

        // Same content, different firstIndex, short length.
        a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]);
        b = wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4 ], 1, 3);
        assertTrue(ByteBufUtil.equals(a, b));
        a.release();
        b.release();

        // Different content, same firstIndex, short length.
        a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]);
        b = wrappedBuffer(cast(byte[])[ 1, 2, 4 ]);
        assertFalse(ByteBufUtil.equals(a, b));
        a.release();
        b.release();

        // Different content, different firstIndex, short length.
        a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]);
        b = wrappedBuffer(cast(byte[])[ 0, 1, 2, 4, 5 ], 1, 3);
        assertFalse(ByteBufUtil.equals(a, b));
        a.release();
        b.release();

        // Same content, same firstIndex, long length.
        a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]);
        b = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]);
        assertTrue(ByteBufUtil.equals(a, b));
        a.release();
        b.release();

        // Same content, different firstIndex, long length.
        a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]);
        b = wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], 1, 10);
        assertTrue(ByteBufUtil.equals(a, b));
        a.release();
        b.release();

        // Different content, same firstIndex, long length.
        a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]);
        b = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 6, 7, 8, 5, 9, 10 ]);
        assertFalse(ByteBufUtil.equals(a, b));
        a.release();
        b.release();

        // Different content, different firstIndex, long length.
        a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]);
        b = wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4, 6, 7, 8, 5, 9, 10, 11 ], 1, 10);
        assertFalse(ByteBufUtil.equals(a, b));
        a.release();
        b.release();
    }

    @Test
    void testCompare() {
        List!(ByteBuf) expected = new ArrayList!(ByteBuf)();
        expected.add(wrappedBuffer(cast(byte[])[1]));
        expected.add(wrappedBuffer(cast(byte[])[1, 2]));
        expected.add(wrappedBuffer(cast(byte[])[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));
        expected.add(wrappedBuffer(cast(byte[])[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]));
        expected.add(wrappedBuffer(cast(byte[])[2]));
        expected.add(wrappedBuffer(cast(byte[])[2, 3]));
        expected.add(wrappedBuffer(cast(byte[])[2, 3, 4, 5, 6, 7, 8, 9, 10, 11]));
        expected.add(wrappedBuffer(cast(byte[])[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]));
        expected.add(wrappedBuffer(cast(byte[])[2, 3, 4], 1, 1));
        expected.add(wrappedBuffer(cast(byte[])[1, 2, 3, 4], 2, 2));
        expected.add(wrappedBuffer(cast(byte[])[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 1, 10));
        expected.add(wrappedBuffer(cast(byte[])[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 2, 12));
        expected.add(wrappedBuffer(cast(byte[])[2, 3, 4, 5], 2, 1));
        expected.add(wrappedBuffer(cast(byte[])[1, 2, 3, 4, 5], 3, 2));
        expected.add(wrappedBuffer(cast(byte[])[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 2, 10));
        expected.add(wrappedBuffer(cast(byte[])[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 3, 12));

        for (int i = 0; i < expected.size(); i ++) {
            for (int j = 0; j < expected.size(); j ++) {
                if (i == j) {
                    assertEquals(0, ByteBufUtil.compare(expected.get(i), expected.get(j)));
                } else if (i < j) {
                    assertTrue(ByteBufUtil.compare(expected.get(i), expected.get(j)) < 0);
                } else {
                    assertTrue(ByteBufUtil.compare(expected.get(i), expected.get(j)) > 0);
                }
            }
        }
        foreach(ByteBuf buffer; expected) {
            buffer.release();
        }
    }

    @Test
    void shouldReturnEmptyBufferWhenLengthIsZero() {
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer(EMPTY_BYTES));
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer(new byte[8], 0, 0));
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer(new byte[8], 8, 0));
        // assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer(BufferUtils.allocateDirect(0)));
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer(EMPTY_BUFFER));
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer(EMPTY_BYTES_2D));
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer([ EMPTY_BYTES ])); // cast(byte[][])
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer(EMPTY_BYTE_BUFFERS));
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer([BufferUtils.allocate(0)]));
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer(BufferUtils.allocate(0), BufferUtils.allocate(0)));
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer(EMPTY_BYTE_BUFS));
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer([ Unpooled.buffer(0) ]));
        assertSameAndRelease(EMPTY_BUFFER, wrappedBuffer(Unpooled.buffer(0), Unpooled.buffer(0)));

        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer(EMPTY_BYTES));
        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer(new byte[8], 0, 0));
        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer(new byte[8], 8, 0));
        // assertSameAndRelease(EMPTY_BUFFER, copiedBuffer(BufferUtils.allocateDirect(0)));
        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer(EMPTY_BUFFER));
        assertSame(EMPTY_BUFFER, copiedBuffer(EMPTY_BYTES_2D));
        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer([EMPTY_BYTES]));
        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer(EMPTY_BYTE_BUFFERS));
        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer([ BufferUtils.allocate(0) ]));
        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer(BufferUtils.allocate(0), BufferUtils.allocate(0)));
        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer(EMPTY_BYTE_BUFS));
        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer([ Unpooled.buffer(0) ]));
        assertSameAndRelease(EMPTY_BUFFER, copiedBuffer(Unpooled.buffer(0), Unpooled.buffer(0)));
    }

    @Test
    void testCompare2() {
        ByteBuf expected = wrappedBuffer(cast(byte[])[0xFF, 0xFF, 0xFF, 0xFF]);
        ByteBuf actual = wrappedBuffer(cast(byte[])[0x00, 0x00, 0x00, 0x00]);
        assertTrue(ByteBufUtil.compare(expected, actual) > 0);
        expected.release();
        actual.release();

        expected = wrappedBuffer(cast(byte[])[0xFF]);
        actual = wrappedBuffer(cast(byte[])[0x00]);
        assertTrue(ByteBufUtil.compare(expected, actual) > 0);
        expected.release();
        actual.release();
    }

    @Test
    void shouldAllowEmptyBufferToCreateCompositeBuffer() {
        import hunt.Byte;
        ByteBuf buf = wrappedBuffer(
                EMPTY_BUFFER,
                wrappedBuffer(new byte[16]), // .order(ByteOrder.LittleEndian)
                EMPTY_BUFFER);
        try {
            assertEquals(16, buf.capacity());
        } finally {
            buf.release();
        }
    }

    @Test
    void testWrappedBuffer() {
        ByteBuf buffer = wrappedBuffer(BufferUtils.allocateDirect(16));
        assertEquals(16, buffer.capacity());
        buffer.release();

        assertEqualsAndRelease(
                wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                wrappedBuffer([ cast(byte[])[ 1, 2, 3 ] ]));

        assertEqualsAndRelease(
                wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                wrappedBuffer(cast(byte[])[ 1 ], cast(byte[])[ 2 ], cast(byte[])[ 3 ]));

        assertEqualsAndRelease(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                wrappedBuffer([ wrappedBuffer(cast(byte[])[ 1, 2, 3 ]) ]));

        assertEqualsAndRelease(
                wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                wrappedBuffer(wrappedBuffer(cast(byte[])[ 1 ]),
                        wrappedBuffer(cast(byte[])[ 2 ]), wrappedBuffer(cast(byte[])[ 3 ])));

        assertEqualsAndRelease(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                wrappedBuffer([ BufferUtils.wrap(cast(byte[])[ 1, 2, 3 ]) ]));

        assertEqualsAndRelease(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                wrappedBuffer(BufferUtils.wrap(cast(byte[])[ 1 ]),
                BufferUtils.wrap(cast(byte[])[ 2 ]), BufferUtils.wrap(cast(byte[])[ 3 ])));
    }

    @Test
    void testSingleWrappedByteBufReleased() {
        ByteBuf buf = Unpooled.buffer(12).writeByte(0);
        ByteBuf wrapped = wrappedBuffer(buf);
        assertTrue(wrapped.release());
        assertEquals(0, buf.refCnt());
    }

    @Test
    void testSingleUnReadableWrappedByteBufReleased() {
        ByteBuf buf = Unpooled.buffer(12);
        ByteBuf wrapped = wrappedBuffer(buf);
        assertFalse(wrapped.release()); // EMPTY_BUFFER cannot be released
        assertEquals(0, buf.refCnt());
    }

    @Test
    void testMultiByteBufReleased() {
        ByteBuf buf1 = Unpooled.buffer(12).writeByte(0);
        ByteBuf buf2 = Unpooled.buffer(12).writeByte(0);
        ByteBuf wrapped = wrappedBuffer(16, buf1, buf2);
        assertTrue(wrapped.release());
        assertEquals(0, buf1.refCnt());
        assertEquals(0, buf2.refCnt());
    }

    @Test
    void testMultiUnReadableByteBufReleased() {
        ByteBuf buf1 = Unpooled.buffer(12);
        ByteBuf buf2 = Unpooled.buffer(12);
        ByteBuf wrapped = wrappedBuffer(16, buf1, buf2);
        assertFalse(wrapped.release()); // EMPTY_BUFFER cannot be released
        assertEquals(0, buf1.refCnt());
        assertEquals(0, buf2.refCnt());
    }

    @Test
    void testCopiedBuffer() {
        ByteBuf copied = copiedBuffer(BufferUtils.allocateDirect(16));
        assertEquals(16, copied.capacity());
        copied.release();

        assertEqualsAndRelease(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                copiedBuffer([ cast(byte[])[ 1, 2, 3 ] ]));

        assertEqualsAndRelease(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                copiedBuffer(cast(byte[])[ 1 ], cast(byte[])[ 2 ], cast(byte[])[ 3 ]));

        assertEqualsAndRelease(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                copiedBuffer([ wrappedBuffer(cast(byte[])[ 1, 2, 3 ])]));

        assertEqualsAndRelease(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                copiedBuffer(wrappedBuffer(cast(byte[])[ 1 ]),
                        wrappedBuffer(cast(byte[])[ 2 ]), wrappedBuffer(cast(byte[])[ 3 ])));

        assertEqualsAndRelease(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                copiedBuffer([ BufferUtils.wrap(cast(byte[])[ 1, 2, 3 ]) ]));

        assertEqualsAndRelease(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]),
                copiedBuffer(BufferUtils.wrap(cast(byte[])[ 1 ]),
                        BufferUtils.wrap(cast(byte[])[ 2 ]), BufferUtils.wrap(cast(byte[])[ 3 ])));
    }

    private static void assertEqualsAndRelease(ByteBuf expected, ByteBuf actual) {
        assertEquals(expected, actual);
        expected.release();
        actual.release();
    }

    private static void assertSameAndRelease(ByteBuf expected, ByteBuf actual) {
        assertEquals(expected, actual);
        expected.release();
        actual.release();
    }

    @Test
    void testHexDump() {
        assertEquals("", ByteBufUtil.hexDump(EMPTY_BUFFER));

        ByteBuf buffer = wrappedBuffer(cast(byte[])[ 0x12, 0x34, 0x56 ]);
        assertEquals("123456", ByteBufUtil.hexDump(buffer));
        buffer.release();

        buffer = wrappedBuffer(cast(byte[])[
                0x12, 0x34, 0x56, 0x78,
                0x90, 0xAB, 0xCD, 0xEF
        ]);
        assertEquals("1234567890abcdef", ByteBufUtil.hexDump(buffer));
        buffer.release();
    }

    @Test
    void testSwapMedium() {
        assertEquals(0x563412, ByteBufUtil.swapMedium(0x123456));
        assertEquals(0x80, ByteBufUtil.swapMedium(0x800000));
    }

    @Test
    void testUnmodifiableBuffer() {
        // ByteBuf buf = wrappedUnmodifiableBuffer(Unpooled.buffer(16));

        // try {
        //     buf.discardReadBytes();
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }

        // try {
        //     buf.setByte(0, cast(byte) 0);
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }

        // try {
        //     buf.setBytes(0, EMPTY_BUFFER, 0, 0);
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }

        // try {
        //     buf.setBytes(0, EMPTY_BYTES, 0, 0);
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }

        // try {
        //     buf.setBytes(0, BufferUtils.allocate(0));
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }

        // try {
        //     buf.setShort(0, cast(short) 0);
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }

        // try {
        //     buf.setMedium(0, 0);
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }

        // try {
        //     buf.setInt(0, 0);
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }

        // try {
        //     buf.setLong(0, 0);
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }

        // InputStream inputStream = Mockito.mock(InputStream.class);
        // try {
        //     buf.setBytes(0, inputStream, 0);
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }
        // Mockito.verifyZeroInteractions(inputStream);

        // ScatteringByteChannel scatteringByteChannel = Mockito.mock(ScatteringByteChannel.class);
        // try {
        //     buf.setBytes(0, scatteringByteChannel, 0);
        //     fail();
        // } catch (UnsupportedOperationException e) {
        //     // Expected
        // }
        // Mockito.verifyZeroInteractions(scatteringByteChannel);
        // buf.release();
    }

    @Test
    void testWrapSingleInt() {
        ByteBuf buffer = copyInt(42);
        assertEquals(4, buffer.capacity());
        assertEquals(42, buffer.readInt());
        assertFalse(buffer.isReadable());
        buffer.release();
    }

    @Test
    void testWrapInt() {
        ByteBuf buffer = copyInt(1, 4);
        assertEquals(8, buffer.capacity());
        assertEquals(1, buffer.readInt());
        assertEquals(4, buffer.readInt());
        assertFalse(buffer.isReadable());
        buffer.release();

        buffer = copyInt(null);
        assertEquals(0, buffer.capacity());
        buffer.release();

        buffer = copyInt([]);
        assertEquals(0, buffer.capacity());
        buffer.release();
    }

    @Test
    void testWrapSingleShort() {
        ByteBuf buffer = copyShort(42);
        assertEquals(2, buffer.capacity());
        assertEquals(42, buffer.readShort());
        assertFalse(buffer.isReadable());
        buffer.release();
    }

    @Test
    void testWrapShortFromShortArray() {
        ByteBuf buffer = copyShort(cast(short[])[1, 4]);
        assertEquals(4, buffer.capacity());
        assertEquals(1, buffer.readShort());
        assertEquals(4, buffer.readShort());
        assertFalse(buffer.isReadable());
        buffer.release();

        buffer = copyShort();
        assertEquals(0, buffer.capacity());
        buffer.release();

        buffer = copyShort(cast(short[])[]);
        assertEquals(0, buffer.capacity());
        buffer.release();
    }

    @Test
    void testWrapShortFromIntArray() {
        ByteBuf buffer = copyShort(cast(short)1, cast(short)4);
        assertEquals(4, buffer.capacity());
        assertEquals(1, buffer.readShort());
        assertEquals(4, buffer.readShort());
        assertFalse(buffer.isReadable());
        buffer.release();

        buffer = copyShort(cast(int[]) null);
        assertEquals(0, buffer.capacity());
        buffer.release();

        buffer = copyShort();
        assertEquals(0, buffer.capacity());
        buffer.release();
    }

    @Test
    void testWrapSingleMedium() {
        ByteBuf buffer = copyMedium(42);
        assertEquals(3, buffer.capacity());
        assertEquals(42, buffer.readMedium());
        assertFalse(buffer.isReadable());
        buffer.release();
    }

    @Test
    void testWrapMedium() {
        ByteBuf buffer = copyMedium(1, 4);
        assertEquals(6, buffer.capacity());
        assertEquals(1, buffer.readMedium());
        assertEquals(4, buffer.readMedium());
        assertFalse(buffer.isReadable());
        buffer.release();

        buffer = copyMedium(null);
        assertEquals(0, copyMedium(null).capacity());
        buffer.release();

        buffer = copyMedium([]);
        assertEquals(0, buffer.capacity());
        buffer.release();
    }

    @Test
    void testWrapSingleLong() {
        ByteBuf buffer = copyLong(42);
        assertEquals(8, buffer.capacity());
        assertEquals(42, buffer.readLong());
        assertFalse(buffer.isReadable());
        buffer.release();
    }

    @Test
    void testWrapLong() {
        ByteBuf buffer = copyLong(1, 4);
        assertEquals(16, buffer.capacity());
        assertEquals(1, buffer.readLong());
        assertEquals(4, buffer.readLong());
        assertFalse(buffer.isReadable());
        buffer.release();

        buffer = copyLong(null);
        assertEquals(0, buffer.capacity());
        buffer.release();

        buffer = copyLong();
        assertEquals(0, buffer.capacity());
        buffer.release();
    }

    @Test
    void testWrapSingleFloat() {
        ByteBuf buffer = copyFloat(42);
        assertEquals(cast(float)4, buffer.capacity());
        assertEquals(cast(float)42, buffer.readFloat(), 0.01f);
        assertFalse(buffer.isReadable());
        buffer.release();
    }

    @Test
    void testWrapFloat() {
        ByteBuf buffer = copyFloat(1, 4);
        assertEquals(cast(float)8, buffer.capacity());
        assertEquals(cast(float)1, buffer.readFloat(), 0.01f);
        assertEquals(cast(float)4, buffer.readFloat(), 0.01f);
        assertFalse(buffer.isReadable());
        buffer.release();

        buffer = copyFloat(null);
        assertEquals(0, buffer.capacity());
        buffer.release();

        buffer = copyFloat();
        assertEquals(0, buffer.capacity());
        buffer.release();
    }

    @Test
    void testWrapSingleDouble() {
        ByteBuf buffer = copyDouble(42);
        assertEquals(cast(double)8, buffer.capacity());
        assertEquals(cast(double)42, buffer.readDouble(), 0.01);
        assertFalse(buffer.isReadable());
        buffer.release();
    }

    @Test
    void testWrapDouble() {
        ByteBuf buffer = copyDouble(1, 4);
        assertEquals(cast(double)16, buffer.capacity());
        assertEquals(cast(double)1, buffer.readDouble(), 0.01);
        assertEquals(cast(double)4, buffer.readDouble(), 0.01);
        assertFalse(buffer.isReadable());
        buffer.release();

        buffer = copyDouble(null);
        assertEquals(0, buffer.capacity());
        buffer.release();

        buffer = copyDouble();
        assertEquals(0, buffer.capacity());
        buffer.release();
    }

    @Test
    void testWrapBoolean() {
        ByteBuf buffer = copyBoolean(true, false);
        assertEquals(2, buffer.capacity());
        assertTrue(buffer.readBoolean());
        assertFalse(buffer.readBoolean());
        assertFalse(buffer.isReadable());
        buffer.release();

        buffer = copyBoolean(null);
        assertEquals(0, buffer.capacity());
        buffer.release();

        buffer = copyBoolean();
        assertEquals(0, buffer.capacity());
        buffer.release();
    }

    @Test
    void wrappedReadOnlyDirectBuffer() {
        ByteBuffer buffer = BufferUtils.allocateDirect(12);
        for (int i = 0; i < 12; i++) {
            buffer.put(cast(byte) i);
        }
        buffer.flip();
        ByteBuf wrapped = wrappedBuffer(buffer.asReadOnlyBuffer());
        for (int i = 0; i < 12; i++) {
            assertEquals(cast(byte) i, wrapped.readByte());
        }
        wrapped.release();
    }

    @TestWith!(IllegalArgumentException)
    void skipBytesNegativeLength() {
        ByteBuf buf = Unpooled.buffer(8);
        try {
            buf.skipBytes(-1);
        } finally {
            buf.release();
        }
    }

    // See https://github.com/netty/netty/issues/5597
    @Test
    void testWrapByteBufArrayStartsWithNonReadable() {
        ByteBuf buffer1 = Unpooled.buffer(8);
        ByteBuf buffer2 = Unpooled.buffer(8).writeZero(8); // Ensure the ByteBuf is readable.
        ByteBuf buffer3 = Unpooled.buffer(8);
        ByteBuf buffer4 = Unpooled.buffer(8).writeZero(8); // Ensure the ByteBuf is readable.

        ByteBuf wrapped = wrappedBuffer(buffer1, buffer2, buffer3, buffer4);
        assertEquals(16, wrapped.readableBytes());
        assertTrue(wrapped.release());
        assertEquals(0, buffer1.refCnt());
        assertEquals(0, buffer2.refCnt());
        assertEquals(0, buffer3.refCnt());
        assertEquals(0, buffer4.refCnt());
        assertEquals(0, wrapped.refCnt());
    }

    @TestWith!(IndexOutOfBoundsException)
    void testGetBytesByteBuffer() {
        byte[] bytes = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
        // Ensure destination buffer is bigger then what is wrapped in the ByteBuf.
        ByteBuffer nioBuffer = BufferUtils.allocate(bytes.length + 1);
        ByteBuf wrappedBuffer = wrappedBuffer(bytes);
        try {
            wrappedBuffer.getBytes(wrappedBuffer.readerIndex(), nioBuffer);
        } finally {
            wrappedBuffer.release();
        }
    }

    @TestWith!(IndexOutOfBoundsException)
    void testGetBytesByteBuffer2() {
        byte[] bytes = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
        // Ensure destination buffer is bigger then what is wrapped in the ByteBuf.
        ByteBuffer nioBuffer = BufferUtils.allocate(bytes.length + 1);
        ByteBuf wrappedBuffer = wrappedBuffer(bytes, 0, cast(int)bytes.length);
        try {
            wrappedBuffer.getBytes(wrappedBuffer.readerIndex(), nioBuffer);
        } finally {
            wrappedBuffer.release();
        }
    }
}
