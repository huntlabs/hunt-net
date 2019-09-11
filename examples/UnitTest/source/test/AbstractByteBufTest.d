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
module test.AbstractByteBufTest;

import hunt.Assert;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.collection;
import hunt.io.Common;

import hunt.net.buffer;

/**
 * An abstract test class for channel buffers
 */
abstract class AbstractByteBufTest {

    private enum int CAPACITY = 4096; // Must be even
    private enum int BLOCK_SIZE = 128;
    private enum int JAVA_BYTEBUFFER_CONSISTENCY_ITERATIONS = 100;

    // private long seed;
    // private Random random;
    // private ByteBuf buffer;

    protected final ByteBuf newBuffer(int capacity) {
        return newBuffer(capacity, int.max);
    }

    protected abstract ByteBuf newBuffer(int capacity, int maxCapacity);

    // protected boolean discardReadBytesDoesNotMoveWritableBytes() {
    //     return true;
    // }

    // @Before
    // void init() {
    //     buffer = newBuffer(CAPACITY);
    //     seed = System.currentTimeMillis();
    //     random = new Random(seed);
    // }

    // @After
    // void dispose() {
    //     if (buffer !is null) {
    //         assertThat(buffer.release(), is(true));
    //         assertThat(buffer.refCnt(), is(0));

    //         try {
    //             buffer.release();
    //         } catch (Exception e) {
    //             // Ignore.
    //         }
    //         buffer = null;
    //     }
    // }

    // @Test
    // void comparableInterfaceNotViolated() {
    //     assumeFalse(buffer.isReadOnly());
    //     buffer.writerIndex(buffer.readerIndex());
    //     assumeTrue(buffer.writableBytes() >= 4);

    //     buffer.writeLong(0);
    //     ByteBuf buffer2 = newBuffer(CAPACITY);
    //     assumeFalse(buffer2.isReadOnly());
    //     buffer2.writerIndex(buffer2.readerIndex());
    //     // Write an unsigned integer that will cause buffer.getUnsignedInt() - buffer2.getUnsignedInt() to underflow the
    //     // int type and wrap around on the negative side.
    //     buffer2.writeLong(0xF0000000L);
    //     assertTrue(buffer.compareTo(buffer2) < 0);
    //     assertTrue(buffer2.compareTo(buffer) > 0);
    //     buffer2.release();
    // }

    // @Test
    // void initialState() {
    //     assertEquals(CAPACITY, buffer.capacity());
    //     assertEquals(0, buffer.readerIndex());
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void readerIndexBoundaryCheck1() {
    //     try {
    //         buffer.writerIndex(0);
    //     } catch (IndexOutOfBoundsException e) {
    //         fail();
    //     }
    //     buffer.readerIndex(-1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void readerIndexBoundaryCheck2() {
    //     try {
    //         buffer.writerIndex(buffer.capacity());
    //     } catch (IndexOutOfBoundsException e) {
    //         fail();
    //     }
    //     buffer.readerIndex(buffer.capacity() + 1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void readerIndexBoundaryCheck3() {
    //     try {
    //         buffer.writerIndex(CAPACITY / 2);
    //     } catch (IndexOutOfBoundsException e) {
    //         fail();
    //     }
    //     buffer.readerIndex(CAPACITY * 3 / 2);
    // }

    // @Test
    // void readerIndexBoundaryCheck4() {
    //     buffer.writerIndex(0);
    //     buffer.readerIndex(0);
    //     buffer.writerIndex(buffer.capacity());
    //     buffer.readerIndex(buffer.capacity());
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void writerIndexBoundaryCheck1() {
    //     buffer.writerIndex(-1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void writerIndexBoundaryCheck2() {
    //     try {
    //         buffer.writerIndex(CAPACITY);
    //         buffer.readerIndex(CAPACITY);
    //     } catch (IndexOutOfBoundsException e) {
    //         fail();
    //     }
    //     buffer.writerIndex(buffer.capacity() + 1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void writerIndexBoundaryCheck3() {
    //     try {
    //         buffer.writerIndex(CAPACITY);
    //         buffer.readerIndex(CAPACITY / 2);
    //     } catch (IndexOutOfBoundsException e) {
    //         fail();
    //     }
    //     buffer.writerIndex(CAPACITY / 4);
    // }

    // @Test
    // void writerIndexBoundaryCheck4() {
    //     buffer.writerIndex(0);
    //     buffer.readerIndex(0);
    //     buffer.writerIndex(CAPACITY);

    //     buffer.writeBytes(ByteBuffer.wrap(EMPTY_BYTES));
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getBooleanBoundaryCheck1() {
    //     buffer.getBoolean(-1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getBooleanBoundaryCheck2() {
    //     buffer.getBoolean(buffer.capacity());
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getByteBoundaryCheck1() {
    //     buffer.getByte(-1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getByteBoundaryCheck2() {
    //     buffer.getByte(buffer.capacity());
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getShortBoundaryCheck1() {
    //     buffer.getShort(-1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getShortBoundaryCheck2() {
    //     buffer.getShort(buffer.capacity() - 1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getMediumBoundaryCheck1() {
    //     buffer.getMedium(-1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getMediumBoundaryCheck2() {
    //     buffer.getMedium(buffer.capacity() - 2);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getIntBoundaryCheck1() {
    //     buffer.getInt(-1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getIntBoundaryCheck2() {
    //     buffer.getInt(buffer.capacity() - 3);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getLongBoundaryCheck1() {
    //     buffer.getLong(-1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getLongBoundaryCheck2() {
    //     buffer.getLong(buffer.capacity() - 7);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getByteArrayBoundaryCheck1() {
    //     buffer.getBytes(-1, EMPTY_BYTES);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getByteArrayBoundaryCheck2() {
    //     buffer.getBytes(-1, EMPTY_BYTES, 0, 0);
    // }

    // @Test
    // void getByteArrayBoundaryCheck3() {
    //     byte[] dst = new byte[4];
    //     buffer.setInt(0, 0x01020304);
    //     try {
    //         buffer.getBytes(0, dst, -1, 4);
    //         fail();
    //     } catch (IndexOutOfBoundsException e) {
    //         // Success
    //     }

    //     // No partial copy is expected.
    //     assertEquals(0, dst[0]);
    //     assertEquals(0, dst[1]);
    //     assertEquals(0, dst[2]);
    //     assertEquals(0, dst[3]);
    // }

    // @Test
    // void getByteArrayBoundaryCheck4() {
    //     byte[] dst = new byte[4];
    //     buffer.setInt(0, 0x01020304);
    //     try {
    //         buffer.getBytes(0, dst, 1, 4);
    //         fail();
    //     } catch (IndexOutOfBoundsException e) {
    //         // Success
    //     }

    //     // No partial copy is expected.
    //     assertEquals(0, dst[0]);
    //     assertEquals(0, dst[1]);
    //     assertEquals(0, dst[2]);
    //     assertEquals(0, dst[3]);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getByteBufferBoundaryCheck() {
    //     buffer.getBytes(-1, ByteBuffer.allocate(0));
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void copyBoundaryCheck1() {
    //     buffer.copy(-1, 0);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void copyBoundaryCheck2() {
    //     buffer.copy(0, buffer.capacity() + 1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void copyBoundaryCheck3() {
    //     buffer.copy(buffer.capacity() + 1, 0);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void copyBoundaryCheck4() {
    //     buffer.copy(buffer.capacity(), 1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void setIndexBoundaryCheck1() {
    //     buffer.setIndex(-1, CAPACITY);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void setIndexBoundaryCheck2() {
    //     buffer.setIndex(CAPACITY / 2, CAPACITY / 4);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void setIndexBoundaryCheck3() {
    //     buffer.setIndex(0, CAPACITY + 1);
    // }

    // @Test
    // void getByteBufferState() {
    //     ByteBuffer dst = ByteBuffer.allocate(4);
    //     dst.position(1);
    //     dst.limit(3);

    //     buffer.setByte(0, (byte) 1);
    //     buffer.setByte(1, (byte) 2);
    //     buffer.setByte(2, (byte) 3);
    //     buffer.setByte(3, (byte) 4);
    //     buffer.getBytes(1, dst);

    //     assertEquals(3, dst.position());
    //     assertEquals(3, dst.limit());

    //     dst.clear();
    //     assertEquals(0, dst.get(0));
    //     assertEquals(2, dst.get(1));
    //     assertEquals(3, dst.get(2));
    //     assertEquals(0, dst.get(3));
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void getDirectByteBufferBoundaryCheck() {
    //     buffer.getBytes(-1, ByteBuffer.allocateDirect(0));
    // }

    // @Test
    // void getDirectByteBufferState() {
    //     ByteBuffer dst = ByteBuffer.allocateDirect(4);
    //     dst.position(1);
    //     dst.limit(3);

    //     buffer.setByte(0, (byte) 1);
    //     buffer.setByte(1, (byte) 2);
    //     buffer.setByte(2, (byte) 3);
    //     buffer.setByte(3, (byte) 4);
    //     buffer.getBytes(1, dst);

    //     assertEquals(3, dst.position());
    //     assertEquals(3, dst.limit());

    //     dst.clear();
    //     assertEquals(0, dst.get(0));
    //     assertEquals(2, dst.get(1));
    //     assertEquals(3, dst.get(2));
    //     assertEquals(0, dst.get(3));
    // }

    // @Test
    // void testRandomByteAccess() {
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         byte value = (byte) random.nextInt();
    //         buffer.setByte(i, value);
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         byte value = (byte) random.nextInt();
    //         assertEquals(value, buffer.getByte(i));
    //     }
    // }

    // @Test
    // void testRandomUnsignedByteAccess() {
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         byte value = (byte) random.nextInt();
    //         buffer.setByte(i, value);
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         int value = random.nextInt() & 0xFF;
    //         assertEquals(value, buffer.getUnsignedByte(i));
    //     }
    // }

    // @Test
    // void testRandomShortAccess() {
    //     testRandomShortAccess(true);
    // }
    // @Test
    // void testRandomShortLEAccess() {
    //     testRandomShortAccess(false);
    // }

    // private void testRandomShortAccess(boolean testBigEndian) {
    //     for (int i = 0; i < buffer.capacity() - 1; i += 2) {
    //         short value = (short) random.nextInt();
    //         if (testBigEndian) {
    //             buffer.setShort(i, value);
    //         } else {
    //             buffer.setShortLE(i, value);
    //         }
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() - 1; i += 2) {
    //         short value = (short) random.nextInt();
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.getShort(i));
    //         } else {
    //             assertEquals(value, buffer.getShortLE(i));
    //         }
    //     }
    // }

    // @Test
    // void testShortConsistentWithByteBuffer() {
    //     testShortConsistentWithByteBuffer(true, true);
    //     testShortConsistentWithByteBuffer(true, false);
    //     testShortConsistentWithByteBuffer(false, true);
    //     testShortConsistentWithByteBuffer(false, false);
    // }

    // private void testShortConsistentWithByteBuffer(boolean direct, boolean testBigEndian) {
    //     for (int i = 0; i < JAVA_BYTEBUFFER_CONSISTENCY_ITERATIONS; ++i) {
    //         ByteBuffer javaBuffer = direct ? ByteBuffer.allocateDirect(buffer.capacity())
    //                                        : ByteBuffer.allocate(buffer.capacity());
    //         if (!testBigEndian) {
    //             javaBuffer = javaBuffer.order(ByteOrder.LITTLE_ENDIAN);
    //         }

    //         short expected = (short) (random.nextInt() & 0xFFFF);
    //         javaBuffer.putShort(expected);

    //         final int bufferIndex = buffer.capacity() - 2;
    //         if (testBigEndian) {
    //             buffer.setShort(bufferIndex, expected);
    //         } else {
    //             buffer.setShortLE(bufferIndex, expected);
    //         }
    //         javaBuffer.flip();

    //         short javaActual = javaBuffer.getShort();
    //         assertEquals(expected, javaActual);
    //         assertEquals(javaActual, testBigEndian ? buffer.getShort(bufferIndex)
    //                                                : buffer.getShortLE(bufferIndex));
    //     }
    // }

    // @Test
    // void testRandomUnsignedShortAccess() {
    //     testRandomUnsignedShortAccess(true);
    // }

    // @Test
    // void testRandomUnsignedShortLEAccess() {
    //     testRandomUnsignedShortAccess(false);
    // }

    // private void testRandomUnsignedShortAccess(boolean testBigEndian) {
    //     for (int i = 0; i < buffer.capacity() - 1; i += 2) {
    //         short value = (short) random.nextInt();
    //         if (testBigEndian) {
    //             buffer.setShort(i, value);
    //         } else {
    //             buffer.setShortLE(i, value);
    //         }
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() - 1; i += 2) {
    //         int value = random.nextInt() & 0xFFFF;
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.getUnsignedShort(i));
    //         } else {
    //             assertEquals(value, buffer.getUnsignedShortLE(i));
    //         }
    //     }
    // }

    // @Test
    // void testRandomMediumAccess() {
    //     testRandomMediumAccess(true);
    // }

    // @Test
    // void testRandomMediumLEAccess() {
    //     testRandomMediumAccess(false);
    // }

    // private void testRandomMediumAccess(boolean testBigEndian) {
    //     for (int i = 0; i < buffer.capacity() - 2; i += 3) {
    //         int value = random.nextInt();
    //         if (testBigEndian) {
    //             buffer.setMedium(i, value);
    //         } else {
    //             buffer.setMediumLE(i, value);
    //         }
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() - 2; i += 3) {
    //         int value = random.nextInt() << 8 >> 8;
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.getMedium(i));
    //         } else {
    //             assertEquals(value, buffer.getMediumLE(i));
    //         }
    //     }
    // }

    // @Test
    // void testRandomUnsignedMediumAccess() {
    //     testRandomUnsignedMediumAccess(true);
    // }

    // @Test
    // void testRandomUnsignedMediumLEAccess() {
    //     testRandomUnsignedMediumAccess(false);
    // }

    // private void testRandomUnsignedMediumAccess(boolean testBigEndian) {
    //     for (int i = 0; i < buffer.capacity() - 2; i += 3) {
    //         int value = random.nextInt();
    //         if (testBigEndian) {
    //             buffer.setMedium(i, value);
    //         } else {
    //             buffer.setMediumLE(i, value);
    //         }
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() - 2; i += 3) {
    //         int value = random.nextInt() & 0x00FFFFFF;
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.getUnsignedMedium(i));
    //         } else {
    //             assertEquals(value, buffer.getUnsignedMediumLE(i));
    //         }
    //     }
    // }

    // @Test
    // void testMediumConsistentWithByteBuffer() {
    //     testMediumConsistentWithByteBuffer(true, true);
    //     testMediumConsistentWithByteBuffer(true, false);
    //     testMediumConsistentWithByteBuffer(false, true);
    //     testMediumConsistentWithByteBuffer(false, false);
    // }

    // private void testMediumConsistentWithByteBuffer(boolean direct, boolean testBigEndian) {
    //     for (int i = 0; i < JAVA_BYTEBUFFER_CONSISTENCY_ITERATIONS; ++i) {
    //         ByteBuffer javaBuffer = direct ? ByteBuffer.allocateDirect(buffer.capacity())
    //                                        : ByteBuffer.allocate(buffer.capacity());
    //         if (!testBigEndian) {
    //             javaBuffer = javaBuffer.order(ByteOrder.LITTLE_ENDIAN);
    //         }

    //         int expected = random.nextInt() & 0x00FFFFFF;
    //         javaBuffer.putInt(expected);

    //         final int bufferIndex = buffer.capacity() - 3;
    //         if (testBigEndian) {
    //             buffer.setMedium(bufferIndex, expected);
    //         } else {
    //             buffer.setMediumLE(bufferIndex, expected);
    //         }
    //         javaBuffer.flip();

    //         int javaActual = javaBuffer.getInt();
    //         assertEquals(expected, javaActual);
    //         assertEquals(javaActual, testBigEndian ? buffer.getUnsignedMedium(bufferIndex)
    //                                                : buffer.getUnsignedMediumLE(bufferIndex));
    //     }
    // }

    // @Test
    // void testRandomIntAccess() {
    //     testRandomIntAccess(true);
    // }

    // @Test
    // void testRandomIntLEAccess() {
    //     testRandomIntAccess(false);
    // }

    // private void testRandomIntAccess(boolean testBigEndian) {
    //     for (int i = 0; i < buffer.capacity() - 3; i += 4) {
    //         int value = random.nextInt();
    //         if (testBigEndian) {
    //             buffer.setInt(i, value);
    //         } else {
    //             buffer.setIntLE(i, value);
    //         }
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() - 3; i += 4) {
    //         int value = random.nextInt();
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.getInt(i));
    //         } else {
    //             assertEquals(value, buffer.getIntLE(i));
    //         }
    //     }
    // }

    // @Test
    // void testIntConsistentWithByteBuffer() {
    //     testIntConsistentWithByteBuffer(true, true);
    //     testIntConsistentWithByteBuffer(true, false);
    //     testIntConsistentWithByteBuffer(false, true);
    //     testIntConsistentWithByteBuffer(false, false);
    // }

    // private void testIntConsistentWithByteBuffer(boolean direct, boolean testBigEndian) {
    //     for (int i = 0; i < JAVA_BYTEBUFFER_CONSISTENCY_ITERATIONS; ++i) {
    //         ByteBuffer javaBuffer = direct ? ByteBuffer.allocateDirect(buffer.capacity())
    //                                        : ByteBuffer.allocate(buffer.capacity());
    //         if (!testBigEndian) {
    //             javaBuffer = javaBuffer.order(ByteOrder.LITTLE_ENDIAN);
    //         }

    //         int expected = random.nextInt();
    //         javaBuffer.putInt(expected);

    //         final int bufferIndex = buffer.capacity() - 4;
    //         if (testBigEndian) {
    //             buffer.setInt(bufferIndex, expected);
    //         } else {
    //             buffer.setIntLE(bufferIndex, expected);
    //         }
    //         javaBuffer.flip();

    //         int javaActual = javaBuffer.getInt();
    //         assertEquals(expected, javaActual);
    //         assertEquals(javaActual, testBigEndian ? buffer.getInt(bufferIndex)
    //                                                : buffer.getIntLE(bufferIndex));
    //     }
    // }

    // @Test
    // void testRandomUnsignedIntAccess() {
    //     testRandomUnsignedIntAccess(true);
    // }

    // @Test
    // void testRandomUnsignedIntLEAccess() {
    //     testRandomUnsignedIntAccess(false);
    // }

    // private void testRandomUnsignedIntAccess(boolean testBigEndian) {
    //     for (int i = 0; i < buffer.capacity() - 3; i += 4) {
    //         int value = random.nextInt();
    //         if (testBigEndian) {
    //             buffer.setInt(i, value);
    //         } else {
    //             buffer.setIntLE(i, value);
    //         }
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() - 3; i += 4) {
    //         long value = random.nextInt() & 0xFFFFFFFFL;
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.getUnsignedInt(i));
    //         } else {
    //             assertEquals(value, buffer.getUnsignedIntLE(i));
    //         }
    //     }
    // }

    // @Test
    // void testRandomLongAccess() {
    //     testRandomLongAccess(true);
    // }

    // @Test
    // void testRandomLongLEAccess() {
    //     testRandomLongAccess(false);
    // }

    // private void testRandomLongAccess(boolean testBigEndian) {
    //     for (int i = 0; i < buffer.capacity() - 7; i += 8) {
    //         long value = random.nextLong();
    //         if (testBigEndian) {
    //             buffer.setLong(i, value);
    //         } else {
    //             buffer.setLongLE(i, value);
    //         }
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() - 7; i += 8) {
    //         long value = random.nextLong();
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.getLong(i));
    //         } else {
    //             assertEquals(value, buffer.getLongLE(i));
    //         }
    //     }
    // }

    // @Test
    // void testLongConsistentWithByteBuffer() {
    //     testLongConsistentWithByteBuffer(true, true);
    //     testLongConsistentWithByteBuffer(true, false);
    //     testLongConsistentWithByteBuffer(false, true);
    //     testLongConsistentWithByteBuffer(false, false);
    // }

    // private void testLongConsistentWithByteBuffer(boolean direct, boolean testBigEndian) {
    //     for (int i = 0; i < JAVA_BYTEBUFFER_CONSISTENCY_ITERATIONS; ++i) {
    //         ByteBuffer javaBuffer = direct ? ByteBuffer.allocateDirect(buffer.capacity())
    //                                        : ByteBuffer.allocate(buffer.capacity());
    //         if (!testBigEndian) {
    //             javaBuffer = javaBuffer.order(ByteOrder.LITTLE_ENDIAN);
    //         }

    //         long expected = random.nextLong();
    //         javaBuffer.putLong(expected);

    //         final int bufferIndex = buffer.capacity() - 8;
    //         if (testBigEndian) {
    //             buffer.setLong(bufferIndex, expected);
    //         } else {
    //             buffer.setLongLE(bufferIndex, expected);
    //         }
    //         javaBuffer.flip();

    //         long javaActual = javaBuffer.getLong();
    //         assertEquals(expected, javaActual);
    //         assertEquals(javaActual, testBigEndian ? buffer.getLong(bufferIndex)
    //                                                : buffer.getLongLE(bufferIndex));
    //     }
    // }

    // @Test
    // void testRandomFloatAccess() {
    //     testRandomFloatAccess(true);
    // }

    // @Test
    // void testRandomFloatLEAccess() {
    //     testRandomFloatAccess(false);
    // }

    // private void testRandomFloatAccess(boolean testBigEndian) {
    //     for (int i = 0; i < buffer.capacity() - 7; i += 8) {
    //         float value = random.nextFloat();
    //         if (testBigEndian) {
    //             buffer.setFloat(i, value);
    //         } else {
    //             buffer.setFloatLE(i, value);
    //         }
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() - 7; i += 8) {
    //         float expected = random.nextFloat();
    //         float actual = testBigEndian? buffer.getFloat(i) : buffer.getFloatLE(i);
    //         assertEquals(expected, actual, 0.01);
    //     }
    // }

    // @Test
    // void testRandomDoubleAccess() {
    //     testRandomDoubleAccess(true);
    // }

    // @Test
    // void testRandomDoubleLEAccess() {
    //     testRandomDoubleAccess(false);
    // }

    // private void testRandomDoubleAccess(boolean testBigEndian) {
    //     for (int i = 0; i < buffer.capacity() - 7; i += 8) {
    //         double value = random.nextDouble();
    //         if (testBigEndian) {
    //             buffer.setDouble(i, value);
    //         } else {
    //             buffer.setDoubleLE(i, value);
    //         }
    //     }

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() - 7; i += 8) {
    //         double expected = random.nextDouble();
    //         double actual = testBigEndian? buffer.getDouble(i) : buffer.getDoubleLE(i);
    //         assertEquals(expected, actual, 0.01);
    //     }
    // }

    // @Test
    // void testSetZero() {
    //     buffer.clear();
    //     while (buffer.isWritable()) {
    //         buffer.writeByte((byte) 0xFF);
    //     }

    //     for (int i = 0; i < buffer.capacity();) {
    //         int length = Math.min(buffer.capacity() - i, random.nextInt(32));
    //         buffer.setZero(i, length);
    //         i += length;
    //     }

    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         assertEquals(0, buffer.getByte(i));
    //     }
    // }

    // @Test
    // void testSequentialByteAccess() {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         byte value = (byte) random.nextInt();
    //         assertEquals(i, buffer.writerIndex());
    //         assertTrue(buffer.isWritable());
    //         buffer.writeByte(value);
    //     }

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isWritable());

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         byte value = (byte) random.nextInt();
    //         assertEquals(i, buffer.readerIndex());
    //         assertTrue(buffer.isReadable());
    //         assertEquals(value, buffer.readByte());
    //     }

    //     assertEquals(buffer.capacity(), buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isReadable());
    //     assertFalse(buffer.isWritable());
    // }

    // @Test
    // void testSequentialUnsignedByteAccess() {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         byte value = (byte) random.nextInt();
    //         assertEquals(i, buffer.writerIndex());
    //         assertTrue(buffer.isWritable());
    //         buffer.writeByte(value);
    //     }

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isWritable());

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         int value = random.nextInt() & 0xFF;
    //         assertEquals(i, buffer.readerIndex());
    //         assertTrue(buffer.isReadable());
    //         assertEquals(value, buffer.readUnsignedByte());
    //     }

    //     assertEquals(buffer.capacity(), buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isReadable());
    //     assertFalse(buffer.isWritable());
    // }

    // @Test
    // void testSequentialShortAccess() {
    //     testSequentialShortAccess(true);
    // }

    // @Test
    // void testSequentialShortLEAccess() {
    //     testSequentialShortAccess(false);
    // }

    // private void testSequentialShortAccess(boolean testBigEndian) {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity(); i += 2) {
    //         short value = (short) random.nextInt();
    //         assertEquals(i, buffer.writerIndex());
    //         assertTrue(buffer.isWritable());
    //         if (testBigEndian) {
    //             buffer.writeShort(value);
    //         } else {
    //             buffer.writeShortLE(value);
    //         }
    //     }

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isWritable());

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity(); i += 2) {
    //         short value = (short) random.nextInt();
    //         assertEquals(i, buffer.readerIndex());
    //         assertTrue(buffer.isReadable());
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.readShort());
    //         } else {
    //             assertEquals(value, buffer.readShortLE());
    //         }
    //     }

    //     assertEquals(buffer.capacity(), buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isReadable());
    //     assertFalse(buffer.isWritable());
    // }

    // @Test
    // void testSequentialUnsignedShortAccess() {
    //     testSequentialUnsignedShortAccess(true);
    // }

    // @Test
    // void testSequentialUnsignedShortLEAccess() {
    //     testSequentialUnsignedShortAccess(true);
    // }

    // private void testSequentialUnsignedShortAccess(boolean testBigEndian) {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity(); i += 2) {
    //         short value = (short) random.nextInt();
    //         assertEquals(i, buffer.writerIndex());
    //         assertTrue(buffer.isWritable());
    //         if (testBigEndian) {
    //             buffer.writeShort(value);
    //         } else {
    //             buffer.writeShortLE(value);
    //         }
    //     }

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isWritable());

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity(); i += 2) {
    //         int value = random.nextInt() & 0xFFFF;
    //         assertEquals(i, buffer.readerIndex());
    //         assertTrue(buffer.isReadable());
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.readUnsignedShort());
    //         } else {
    //             assertEquals(value, buffer.readUnsignedShortLE());
    //         }
    //     }

    //     assertEquals(buffer.capacity(), buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isReadable());
    //     assertFalse(buffer.isWritable());
    // }

    // @Test
    // void testSequentialMediumAccess() {
    //     testSequentialMediumAccess(true);
    // }
    // @Test
    // void testSequentialMediumLEAccess() {
    //     testSequentialMediumAccess(false);
    // }

    // private void testSequentialMediumAccess(boolean testBigEndian) {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() / 3 * 3; i += 3) {
    //         int value = random.nextInt();
    //         assertEquals(i, buffer.writerIndex());
    //         assertTrue(buffer.isWritable());
    //         if (testBigEndian) {
    //             buffer.writeMedium(value);
    //         } else {
    //             buffer.writeMediumLE(value);
    //         }
    //     }

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(buffer.capacity() / 3 * 3, buffer.writerIndex());
    //     assertEquals(buffer.capacity() % 3, buffer.writableBytes());

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() / 3 * 3; i += 3) {
    //         int value = random.nextInt() << 8 >> 8;
    //         assertEquals(i, buffer.readerIndex());
    //         assertTrue(buffer.isReadable());
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.readMedium());
    //         } else {
    //             assertEquals(value, buffer.readMediumLE());
    //         }
    //     }

    //     assertEquals(buffer.capacity() / 3 * 3, buffer.readerIndex());
    //     assertEquals(buffer.capacity() / 3 * 3, buffer.writerIndex());
    //     assertEquals(0, buffer.readableBytes());
    //     assertEquals(buffer.capacity() % 3, buffer.writableBytes());
    // }

    // @Test
    // void testSequentialUnsignedMediumAccess() {
    //     testSequentialUnsignedMediumAccess(true);
    // }

    // @Test
    // void testSequentialUnsignedMediumLEAccess() {
    //     testSequentialUnsignedMediumAccess(false);
    // }

    // private void testSequentialUnsignedMediumAccess(boolean testBigEndian) {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() / 3 * 3; i += 3) {
    //         int value = random.nextInt() & 0x00FFFFFF;
    //         assertEquals(i, buffer.writerIndex());
    //         assertTrue(buffer.isWritable());
    //         if (testBigEndian) {
    //             buffer.writeMedium(value);
    //         } else {
    //             buffer.writeMediumLE(value);
    //         }
    //     }

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(buffer.capacity() / 3 * 3, buffer.writerIndex());
    //     assertEquals(buffer.capacity() % 3, buffer.writableBytes());

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity() / 3 * 3; i += 3) {
    //         int value = random.nextInt() & 0x00FFFFFF;
    //         assertEquals(i, buffer.readerIndex());
    //         assertTrue(buffer.isReadable());
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.readUnsignedMedium());
    //         } else {
    //             assertEquals(value, buffer.readUnsignedMediumLE());
    //         }
    //     }

    //     assertEquals(buffer.capacity() / 3 * 3, buffer.readerIndex());
    //     assertEquals(buffer.capacity() / 3 * 3, buffer.writerIndex());
    //     assertEquals(0, buffer.readableBytes());
    //     assertEquals(buffer.capacity() % 3, buffer.writableBytes());
    // }

    // @Test
    // void testSequentialIntAccess() {
    //     testSequentialIntAccess(true);
    // }

    // @Test
    // void testSequentialIntLEAccess() {
    //     testSequentialIntAccess(false);
    // }

    // private void testSequentialIntAccess(boolean testBigEndian) {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity(); i += 4) {
    //         int value = random.nextInt();
    //         assertEquals(i, buffer.writerIndex());
    //         assertTrue(buffer.isWritable());
    //         if (testBigEndian) {
    //             buffer.writeInt(value);
    //         } else {
    //             buffer.writeIntLE(value);
    //         }
    //     }

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isWritable());

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity(); i += 4) {
    //         int value = random.nextInt();
    //         assertEquals(i, buffer.readerIndex());
    //         assertTrue(buffer.isReadable());
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.readInt());
    //         } else {
    //             assertEquals(value, buffer.readIntLE());
    //         }
    //     }

    //     assertEquals(buffer.capacity(), buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isReadable());
    //     assertFalse(buffer.isWritable());
    // }

    // @Test
    // void testSequentialUnsignedIntAccess() {
    //     testSequentialUnsignedIntAccess(true);
    // }

    // @Test
    // void testSequentialUnsignedIntLEAccess() {
    //     testSequentialUnsignedIntAccess(false);
    // }

    // private void testSequentialUnsignedIntAccess(boolean testBigEndian) {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity(); i += 4) {
    //         int value = random.nextInt();
    //         assertEquals(i, buffer.writerIndex());
    //         assertTrue(buffer.isWritable());
    //         if (testBigEndian) {
    //             buffer.writeInt(value);
    //         } else {
    //             buffer.writeIntLE(value);
    //         }
    //     }

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isWritable());

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity(); i += 4) {
    //         long value = random.nextInt() & 0xFFFFFFFFL;
    //         assertEquals(i, buffer.readerIndex());
    //         assertTrue(buffer.isReadable());
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.readUnsignedInt());
    //         } else {
    //             assertEquals(value, buffer.readUnsignedIntLE());
    //         }
    //     }

    //     assertEquals(buffer.capacity(), buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isReadable());
    //     assertFalse(buffer.isWritable());
    // }

    // @Test
    // void testSequentialLongAccess() {
    //     testSequentialLongAccess(true);
    // }

    // @Test
    // void testSequentialLongLEAccess() {
    //     testSequentialLongAccess(false);
    // }

    // private void testSequentialLongAccess(boolean testBigEndian) {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity(); i += 8) {
    //         long value = random.nextLong();
    //         assertEquals(i, buffer.writerIndex());
    //         assertTrue(buffer.isWritable());
    //         if (testBigEndian) {
    //             buffer.writeLong(value);
    //         } else {
    //             buffer.writeLongLE(value);
    //         }
    //     }

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isWritable());

    //     random.setSeed(seed);
    //     for (int i = 0; i < buffer.capacity(); i += 8) {
    //         long value = random.nextLong();
    //         assertEquals(i, buffer.readerIndex());
    //         assertTrue(buffer.isReadable());
    //         if (testBigEndian) {
    //             assertEquals(value, buffer.readLong());
    //         } else {
    //             assertEquals(value, buffer.readLongLE());
    //         }
    //     }

    //     assertEquals(buffer.capacity(), buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());
    //     assertFalse(buffer.isReadable());
    //     assertFalse(buffer.isWritable());
    // }

    // @Test
    // void testByteArrayTransfer() {
    //     byte[] value = new byte[BLOCK_SIZE * 2];
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(value);
    //         buffer.setBytes(i, value, random.nextInt(BLOCK_SIZE), BLOCK_SIZE);
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValue = new byte[BLOCK_SIZE * 2];
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValue);
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         buffer.getBytes(i, value, valueOffset, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue[j], value[j]);
    //         }
    //     }
    // }

    // @Test
    // void testRandomByteArrayTransfer1() {
    //     byte[] value = new byte[BLOCK_SIZE];
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(value);
    //         buffer.setBytes(i, value);
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValueContent = new byte[BLOCK_SIZE];
    //     ByteBuf expectedValue = wrappedBuffer(expectedValueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValueContent);
    //         buffer.getBytes(i, value);
    //         for (int j = 0; j < BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value[j]);
    //         }
    //     }
    // }

    // @Test
    // void testRandomByteArrayTransfer2() {
    //     byte[] value = new byte[BLOCK_SIZE * 2];
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(value);
    //         buffer.setBytes(i, value, random.nextInt(BLOCK_SIZE), BLOCK_SIZE);
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf expectedValue = wrappedBuffer(expectedValueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValueContent);
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         buffer.getBytes(i, value, valueOffset, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value[j]);
    //         }
    //     }
    // }

    // @Test
    // void testRandomHeapBufferTransfer1() {
    //     byte[] valueContent = new byte[BLOCK_SIZE];
    //     ByteBuf value = wrappedBuffer(valueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(valueContent);
    //         value.setIndex(0, BLOCK_SIZE);
    //         buffer.setBytes(i, value);
    //         assertEquals(BLOCK_SIZE, value.readerIndex());
    //         assertEquals(BLOCK_SIZE, value.writerIndex());
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValueContent = new byte[BLOCK_SIZE];
    //     ByteBuf expectedValue = wrappedBuffer(expectedValueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValueContent);
    //         value.clear();
    //         buffer.getBytes(i, value);
    //         assertEquals(0, value.readerIndex());
    //         assertEquals(BLOCK_SIZE, value.writerIndex());
    //         for (int j = 0; j < BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value.getByte(j));
    //         }
    //     }
    // }

    // @Test
    // void testRandomHeapBufferTransfer2() {
    //     byte[] valueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf value = wrappedBuffer(valueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(valueContent);
    //         buffer.setBytes(i, value, random.nextInt(BLOCK_SIZE), BLOCK_SIZE);
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf expectedValue = wrappedBuffer(expectedValueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValueContent);
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         buffer.getBytes(i, value, valueOffset, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value.getByte(j));
    //         }
    //     }
    // }

    // @Test
    // void testRandomDirectBufferTransfer() {
    //     byte[] tmp = new byte[BLOCK_SIZE * 2];
    //     ByteBuf value = directBuffer(BLOCK_SIZE * 2);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(tmp);
    //         value.setBytes(0, tmp, 0, value.capacity());
    //         buffer.setBytes(i, value, random.nextInt(BLOCK_SIZE), BLOCK_SIZE);
    //     }

    //     random.setSeed(seed);
    //     ByteBuf expectedValue = directBuffer(BLOCK_SIZE * 2);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(tmp);
    //         expectedValue.setBytes(0, tmp, 0, expectedValue.capacity());
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         buffer.getBytes(i, value, valueOffset, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value.getByte(j));
    //         }
    //     }
    //     value.release();
    //     expectedValue.release();
    // }

    // @Test
    // void testRandomByteBufferTransfer() {
    //     ByteBuffer value = ByteBuffer.allocate(BLOCK_SIZE * 2);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(value.array());
    //         value.clear().position(random.nextInt(BLOCK_SIZE));
    //         value.limit(value.position() + BLOCK_SIZE);
    //         buffer.setBytes(i, value);
    //     }

    //     random.setSeed(seed);
    //     ByteBuffer expectedValue = ByteBuffer.allocate(BLOCK_SIZE * 2);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValue.array());
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         value.clear().position(valueOffset).limit(valueOffset + BLOCK_SIZE);
    //         buffer.getBytes(i, value);
    //         assertEquals(valueOffset + BLOCK_SIZE, value.position());
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.get(j), value.get(j));
    //         }
    //     }
    // }

    // @Test
    // void testSequentialByteArrayTransfer1() {
    //     byte[] value = new byte[BLOCK_SIZE];
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(value);
    //         assertEquals(0, buffer.readerIndex());
    //         assertEquals(i, buffer.writerIndex());
    //         buffer.writeBytes(value);
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValue = new byte[BLOCK_SIZE];
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValue);
    //         assertEquals(i, buffer.readerIndex());
    //         assertEquals(CAPACITY, buffer.writerIndex());
    //         buffer.readBytes(value);
    //         for (int j = 0; j < BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue[j], value[j]);
    //         }
    //     }
    // }

    // @Test
    // void testSequentialByteArrayTransfer2() {
    //     byte[] value = new byte[BLOCK_SIZE * 2];
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(value);
    //         assertEquals(0, buffer.readerIndex());
    //         assertEquals(i, buffer.writerIndex());
    //         int readerIndex = random.nextInt(BLOCK_SIZE);
    //         buffer.writeBytes(value, readerIndex, BLOCK_SIZE);
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValue = new byte[BLOCK_SIZE * 2];
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValue);
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         assertEquals(i, buffer.readerIndex());
    //         assertEquals(CAPACITY, buffer.writerIndex());
    //         buffer.readBytes(value, valueOffset, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue[j], value[j]);
    //         }
    //     }
    // }

    // @Test
    // void testSequentialHeapBufferTransfer1() {
    //     byte[] valueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf value = wrappedBuffer(valueContent);
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(valueContent);
    //         assertEquals(0, buffer.readerIndex());
    //         assertEquals(i, buffer.writerIndex());
    //         buffer.writeBytes(value, random.nextInt(BLOCK_SIZE), BLOCK_SIZE);
    //         assertEquals(0, value.readerIndex());
    //         assertEquals(valueContent.length, value.writerIndex());
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf expectedValue = wrappedBuffer(expectedValueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValueContent);
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         assertEquals(i, buffer.readerIndex());
    //         assertEquals(CAPACITY, buffer.writerIndex());
    //         buffer.readBytes(value, valueOffset, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value.getByte(j));
    //         }
    //         assertEquals(0, value.readerIndex());
    //         assertEquals(valueContent.length, value.writerIndex());
    //     }
    // }

    // @Test
    // void testSequentialHeapBufferTransfer2() {
    //     byte[] valueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf value = wrappedBuffer(valueContent);
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(valueContent);
    //         assertEquals(0, buffer.readerIndex());
    //         assertEquals(i, buffer.writerIndex());
    //         int readerIndex = random.nextInt(BLOCK_SIZE);
    //         value.readerIndex(readerIndex);
    //         value.writerIndex(readerIndex + BLOCK_SIZE);
    //         buffer.writeBytes(value);
    //         assertEquals(readerIndex + BLOCK_SIZE, value.writerIndex());
    //         assertEquals(value.writerIndex(), value.readerIndex());
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf expectedValue = wrappedBuffer(expectedValueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValueContent);
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         assertEquals(i, buffer.readerIndex());
    //         assertEquals(CAPACITY, buffer.writerIndex());
    //         value.readerIndex(valueOffset);
    //         value.writerIndex(valueOffset);
    //         buffer.readBytes(value, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value.getByte(j));
    //         }
    //         assertEquals(valueOffset, value.readerIndex());
    //         assertEquals(valueOffset + BLOCK_SIZE, value.writerIndex());
    //     }
    // }

    // @Test
    // void testSequentialDirectBufferTransfer1() {
    //     byte[] valueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf value = directBuffer(BLOCK_SIZE * 2);
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(valueContent);
    //         value.setBytes(0, valueContent);
    //         assertEquals(0, buffer.readerIndex());
    //         assertEquals(i, buffer.writerIndex());
    //         buffer.writeBytes(value, random.nextInt(BLOCK_SIZE), BLOCK_SIZE);
    //         assertEquals(0, value.readerIndex());
    //         assertEquals(0, value.writerIndex());
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf expectedValue = wrappedBuffer(expectedValueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValueContent);
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         value.setBytes(0, valueContent);
    //         assertEquals(i, buffer.readerIndex());
    //         assertEquals(CAPACITY, buffer.writerIndex());
    //         buffer.readBytes(value, valueOffset, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value.getByte(j));
    //         }
    //         assertEquals(0, value.readerIndex());
    //         assertEquals(0, value.writerIndex());
    //     }
    //     value.release();
    //     expectedValue.release();
    // }

    // @Test
    // void testSequentialDirectBufferTransfer2() {
    //     byte[] valueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf value = directBuffer(BLOCK_SIZE * 2);
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(valueContent);
    //         value.setBytes(0, valueContent);
    //         assertEquals(0, buffer.readerIndex());
    //         assertEquals(i, buffer.writerIndex());
    //         int readerIndex = random.nextInt(BLOCK_SIZE);
    //         value.readerIndex(0);
    //         value.writerIndex(readerIndex + BLOCK_SIZE);
    //         value.readerIndex(readerIndex);
    //         buffer.writeBytes(value);
    //         assertEquals(readerIndex + BLOCK_SIZE, value.writerIndex());
    //         assertEquals(value.writerIndex(), value.readerIndex());
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf expectedValue = wrappedBuffer(expectedValueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValueContent);
    //         value.setBytes(0, valueContent);
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         assertEquals(i, buffer.readerIndex());
    //         assertEquals(CAPACITY, buffer.writerIndex());
    //         value.readerIndex(valueOffset);
    //         value.writerIndex(valueOffset);
    //         buffer.readBytes(value, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value.getByte(j));
    //         }
    //         assertEquals(valueOffset, value.readerIndex());
    //         assertEquals(valueOffset + BLOCK_SIZE, value.writerIndex());
    //     }
    //     value.release();
    //     expectedValue.release();
    // }

    // @Test
    // void testSequentialByteBufferBackedHeapBufferTransfer1() {
    //     byte[] valueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf value = wrappedBuffer(ByteBuffer.allocate(BLOCK_SIZE * 2));
    //     value.writerIndex(0);
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(valueContent);
    //         value.setBytes(0, valueContent);
    //         assertEquals(0, buffer.readerIndex());
    //         assertEquals(i, buffer.writerIndex());
    //         buffer.writeBytes(value, random.nextInt(BLOCK_SIZE), BLOCK_SIZE);
    //         assertEquals(0, value.readerIndex());
    //         assertEquals(0, value.writerIndex());
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf expectedValue = wrappedBuffer(expectedValueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValueContent);
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         value.setBytes(0, valueContent);
    //         assertEquals(i, buffer.readerIndex());
    //         assertEquals(CAPACITY, buffer.writerIndex());
    //         buffer.readBytes(value, valueOffset, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value.getByte(j));
    //         }
    //         assertEquals(0, value.readerIndex());
    //         assertEquals(0, value.writerIndex());
    //     }
    // }

    // @Test
    // void testSequentialByteBufferBackedHeapBufferTransfer2() {
    //     byte[] valueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf value = wrappedBuffer(ByteBuffer.allocate(BLOCK_SIZE * 2));
    //     value.writerIndex(0);
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(valueContent);
    //         value.setBytes(0, valueContent);
    //         assertEquals(0, buffer.readerIndex());
    //         assertEquals(i, buffer.writerIndex());
    //         int readerIndex = random.nextInt(BLOCK_SIZE);
    //         value.readerIndex(0);
    //         value.writerIndex(readerIndex + BLOCK_SIZE);
    //         value.readerIndex(readerIndex);
    //         buffer.writeBytes(value);
    //         assertEquals(readerIndex + BLOCK_SIZE, value.writerIndex());
    //         assertEquals(value.writerIndex(), value.readerIndex());
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValueContent = new byte[BLOCK_SIZE * 2];
    //     ByteBuf expectedValue = wrappedBuffer(expectedValueContent);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValueContent);
    //         value.setBytes(0, valueContent);
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         assertEquals(i, buffer.readerIndex());
    //         assertEquals(CAPACITY, buffer.writerIndex());
    //         value.readerIndex(valueOffset);
    //         value.writerIndex(valueOffset);
    //         buffer.readBytes(value, BLOCK_SIZE);
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.getByte(j), value.getByte(j));
    //         }
    //         assertEquals(valueOffset, value.readerIndex());
    //         assertEquals(valueOffset + BLOCK_SIZE, value.writerIndex());
    //     }
    // }

    // @Test
    // void testSequentialByteBufferTransfer() {
    //     buffer.writerIndex(0);
    //     ByteBuffer value = ByteBuffer.allocate(BLOCK_SIZE * 2);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(value.array());
    //         value.clear().position(random.nextInt(BLOCK_SIZE));
    //         value.limit(value.position() + BLOCK_SIZE);
    //         buffer.writeBytes(value);
    //     }

    //     random.setSeed(seed);
    //     ByteBuffer expectedValue = ByteBuffer.allocate(BLOCK_SIZE * 2);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValue.array());
    //         int valueOffset = random.nextInt(BLOCK_SIZE);
    //         value.clear().position(valueOffset).limit(valueOffset + BLOCK_SIZE);
    //         buffer.readBytes(value);
    //         assertEquals(valueOffset + BLOCK_SIZE, value.position());
    //         for (int j = valueOffset; j < valueOffset + BLOCK_SIZE; j ++) {
    //             assertEquals(expectedValue.get(j), value.get(j));
    //         }
    //     }
    // }

    // @Test
    // void testSequentialCopiedBufferTransfer1() {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         byte[] value = new byte[BLOCK_SIZE];
    //         random.nextBytes(value);
    //         assertEquals(0, buffer.readerIndex());
    //         assertEquals(i, buffer.writerIndex());
    //         buffer.writeBytes(value);
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValue = new byte[BLOCK_SIZE];
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValue);
    //         assertEquals(i, buffer.readerIndex());
    //         assertEquals(CAPACITY, buffer.writerIndex());
    //         ByteBuf actualValue = buffer.readBytes(BLOCK_SIZE);
    //         assertEquals(wrappedBuffer(expectedValue), actualValue);

    //         // Make sure if it is a copied buffer.
    //         actualValue.setByte(0, (byte) (actualValue.getByte(0) + 1));
    //         assertFalse(buffer.getByte(i) == actualValue.getByte(0));
    //         actualValue.release();
    //     }
    // }

    // @Test
    // void testSequentialSlice1() {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         byte[] value = new byte[BLOCK_SIZE];
    //         random.nextBytes(value);
    //         assertEquals(0, buffer.readerIndex());
    //         assertEquals(i, buffer.writerIndex());
    //         buffer.writeBytes(value);
    //     }

    //     random.setSeed(seed);
    //     byte[] expectedValue = new byte[BLOCK_SIZE];
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         random.nextBytes(expectedValue);
    //         assertEquals(i, buffer.readerIndex());
    //         assertEquals(CAPACITY, buffer.writerIndex());
    //         ByteBuf actualValue = buffer.readSlice(BLOCK_SIZE);
    //         assertEquals(buffer.order(), actualValue.order());
    //         assertEquals(wrappedBuffer(expectedValue), actualValue);

    //         // Make sure if it is a sliced buffer.
    //         actualValue.setByte(0, (byte) (actualValue.getByte(0) + 1));
    //         assertEquals(buffer.getByte(i), actualValue.getByte(0));
    //     }
    // }

    // @Test
    // void testWriteZero() {
    //     try {
    //         buffer.writeZero(-1);
    //         fail();
    //     } catch (IllegalArgumentException e) {
    //         // Expected
    //     }

    //     buffer.clear();
    //     while (buffer.isWritable()) {
    //         buffer.writeByte((byte) 0xFF);
    //     }

    //     buffer.clear();
    //     for (int i = 0; i < buffer.capacity();) {
    //         int length = Math.min(buffer.capacity() - i, random.nextInt(32));
    //         buffer.writeZero(length);
    //         i += length;
    //     }

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(buffer.capacity(), buffer.writerIndex());

    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         assertEquals(0, buffer.getByte(i));
    //     }
    // }

    // @Test
    // void testDiscardReadBytes() {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity(); i += 4) {
    //         buffer.writeInt(i);
    //     }
    //     ByteBuf copy = copiedBuffer(buffer);

    //     // Make sure there's no effect if called when readerIndex is 0.
    //     buffer.readerIndex(CAPACITY / 4);
    //     buffer.markReaderIndex();
    //     buffer.writerIndex(CAPACITY / 3);
    //     buffer.markWriterIndex();
    //     buffer.readerIndex(0);
    //     buffer.writerIndex(CAPACITY / 2);
    //     buffer.discardReadBytes();

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(CAPACITY / 2, buffer.writerIndex());
    //     assertEquals(copy.slice(0, CAPACITY / 2), buffer.slice(0, CAPACITY / 2));
    //     buffer.resetReaderIndex();
    //     assertEquals(CAPACITY / 4, buffer.readerIndex());
    //     buffer.resetWriterIndex();
    //     assertEquals(CAPACITY / 3, buffer.writerIndex());

    //     // Make sure bytes after writerIndex is not copied.
    //     buffer.readerIndex(1);
    //     buffer.writerIndex(CAPACITY / 2);
    //     buffer.discardReadBytes();

    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(CAPACITY / 2 - 1, buffer.writerIndex());
    //     assertEquals(copy.slice(1, CAPACITY / 2 - 1), buffer.slice(0, CAPACITY / 2 - 1));

    //     if (discardReadBytesDoesNotMoveWritableBytes()) {
    //         // If writable bytes were copied, the test should fail to avoid unnecessary memory bandwidth consumption.
    //         assertFalse(copy.slice(CAPACITY / 2, CAPACITY / 2).equals(buffer.slice(CAPACITY / 2 - 1, CAPACITY / 2)));
    //     } else {
    //         assertEquals(copy.slice(CAPACITY / 2, CAPACITY / 2), buffer.slice(CAPACITY / 2 - 1, CAPACITY / 2));
    //     }

    //     // Marks also should be relocated.
    //     buffer.resetReaderIndex();
    //     assertEquals(CAPACITY / 4 - 1, buffer.readerIndex());
    //     buffer.resetWriterIndex();
    //     assertEquals(CAPACITY / 3 - 1, buffer.writerIndex());
    //     copy.release();
    // }

    // /**
    //  * The similar test case with {@link #testDiscardReadBytes()} but this one
    //  * discards a large chunk at once.
    //  */
    // @Test
    // void testDiscardReadBytes2() {
    //     buffer.writerIndex(0);
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         buffer.writeByte((byte) i);
    //     }
    //     ByteBuf copy = copiedBuffer(buffer);

    //     // Discard the first (CAPACITY / 2 - 1) bytes.
    //     buffer.setIndex(CAPACITY / 2 - 1, CAPACITY - 1);
    //     buffer.discardReadBytes();
    //     assertEquals(0, buffer.readerIndex());
    //     assertEquals(CAPACITY / 2, buffer.writerIndex());
    //     for (int i = 0; i < CAPACITY / 2; i ++) {
    //         assertEquals(copy.slice(CAPACITY / 2 - 1 + i, CAPACITY / 2 - i), buffer.slice(i, CAPACITY / 2 - i));
    //     }
    //     copy.release();
    // }

    // @Test
    // void testStreamTransfer1() {
    //     byte[] expected = new byte[buffer.capacity()];
    //     random.nextBytes(expected);

    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         ByteArrayInputStream in = new ByteArrayInputStream(expected, i, BLOCK_SIZE);
    //         assertEquals(BLOCK_SIZE, buffer.setBytes(i, in, BLOCK_SIZE));
    //         assertEquals(-1, buffer.setBytes(i, in, 0));
    //     }

    //     ByteArrayOutputStream out = new ByteArrayOutputStream();
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         buffer.getBytes(i, out, BLOCK_SIZE);
    //     }

    //     assertTrue(Arrays.equals(expected, out.toByteArray()));
    // }

    // @Test
    // void testStreamTransfer2() {
    //     byte[] expected = new byte[buffer.capacity()];
    //     random.nextBytes(expected);
    //     buffer.clear();

    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         ByteArrayInputStream in = new ByteArrayInputStream(expected, i, BLOCK_SIZE);
    //         assertEquals(i, buffer.writerIndex());
    //         buffer.writeBytes(in, BLOCK_SIZE);
    //         assertEquals(i + BLOCK_SIZE, buffer.writerIndex());
    //     }

    //     ByteArrayOutputStream out = new ByteArrayOutputStream();
    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         assertEquals(i, buffer.readerIndex());
    //         buffer.readBytes(out, BLOCK_SIZE);
    //         assertEquals(i + BLOCK_SIZE, buffer.readerIndex());
    //     }

    //     assertTrue(Arrays.equals(expected, out.toByteArray()));
    // }

    // @Test
    // void testCopy() {
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         byte value = (byte) random.nextInt();
    //         buffer.setByte(i, value);
    //     }

    //     final int readerIndex = CAPACITY / 3;
    //     final int writerIndex = CAPACITY * 2 / 3;
    //     buffer.setIndex(readerIndex, writerIndex);

    //     // Make sure all properties are copied.
    //     ByteBuf copy = buffer.copy();
    //     assertEquals(0, copy.readerIndex());
    //     assertEquals(buffer.readableBytes(), copy.writerIndex());
    //     assertEquals(buffer.readableBytes(), copy.capacity());
    //     assertSame(buffer.order(), copy.order());
    //     for (int i = 0; i < copy.capacity(); i ++) {
    //         assertEquals(buffer.getByte(i + readerIndex), copy.getByte(i));
    //     }

    //     // Make sure the buffer content is independent from each other.
    //     buffer.setByte(readerIndex, (byte) (buffer.getByte(readerIndex) + 1));
    //     assertTrue(buffer.getByte(readerIndex) != copy.getByte(0));
    //     copy.setByte(1, (byte) (copy.getByte(1) + 1));
    //     assertTrue(buffer.getByte(readerIndex + 1) != copy.getByte(1));
    //     copy.release();
    // }

    // @Test
    // void testDuplicate() {
    //     for (int i = 0; i < buffer.capacity(); i ++) {
    //         byte value = (byte) random.nextInt();
    //         buffer.setByte(i, value);
    //     }

    //     final int readerIndex = CAPACITY / 3;
    //     final int writerIndex = CAPACITY * 2 / 3;
    //     buffer.setIndex(readerIndex, writerIndex);

    //     // Make sure all properties are copied.
    //     ByteBuf duplicate = buffer.duplicate();
    //     assertSame(buffer.order(), duplicate.order());
    //     assertEquals(buffer.readableBytes(), duplicate.readableBytes());
    //     assertEquals(0, buffer.compareTo(duplicate));

    //     // Make sure the buffer content is shared.
    //     buffer.setByte(readerIndex, (byte) (buffer.getByte(readerIndex) + 1));
    //     assertEquals(buffer.getByte(readerIndex), duplicate.getByte(duplicate.readerIndex()));
    //     duplicate.setByte(duplicate.readerIndex(), (byte) (duplicate.getByte(duplicate.readerIndex()) + 1));
    //     assertEquals(buffer.getByte(readerIndex), duplicate.getByte(duplicate.readerIndex()));
    // }

    // @Test
    // void testSliceEndianness() {
    //     assertEquals(buffer.order(), buffer.slice(0, buffer.capacity()).order());
    //     assertEquals(buffer.order(), buffer.slice(0, buffer.capacity() - 1).order());
    //     assertEquals(buffer.order(), buffer.slice(1, buffer.capacity() - 1).order());
    //     assertEquals(buffer.order(), buffer.slice(1, buffer.capacity() - 2).order());
    // }

    // @Test
    // void testSliceIndex() {
    //     assertEquals(0, buffer.slice(0, buffer.capacity()).readerIndex());
    //     assertEquals(0, buffer.slice(0, buffer.capacity() - 1).readerIndex());
    //     assertEquals(0, buffer.slice(1, buffer.capacity() - 1).readerIndex());
    //     assertEquals(0, buffer.slice(1, buffer.capacity() - 2).readerIndex());

    //     assertEquals(buffer.capacity(), buffer.slice(0, buffer.capacity()).writerIndex());
    //     assertEquals(buffer.capacity() - 1, buffer.slice(0, buffer.capacity() - 1).writerIndex());
    //     assertEquals(buffer.capacity() - 1, buffer.slice(1, buffer.capacity() - 1).writerIndex());
    //     assertEquals(buffer.capacity() - 2, buffer.slice(1, buffer.capacity() - 2).writerIndex());
    // }

    // @Test
    // void testRetainedSliceIndex() {
    //     ByteBuf retainedSlice = buffer.retainedSlice(0, buffer.capacity());
    //     assertEquals(0, retainedSlice.readerIndex());
    //     retainedSlice.release();

    //     retainedSlice = buffer.retainedSlice(0, buffer.capacity() - 1);
    //     assertEquals(0, retainedSlice.readerIndex());
    //     retainedSlice.release();

    //     retainedSlice = buffer.retainedSlice(1, buffer.capacity() - 1);
    //     assertEquals(0, retainedSlice.readerIndex());
    //     retainedSlice.release();

    //     retainedSlice = buffer.retainedSlice(1, buffer.capacity() - 2);
    //     assertEquals(0, retainedSlice.readerIndex());
    //     retainedSlice.release();

    //     retainedSlice = buffer.retainedSlice(0, buffer.capacity());
    //     assertEquals(buffer.capacity(), retainedSlice.writerIndex());
    //     retainedSlice.release();

    //     retainedSlice = buffer.retainedSlice(0, buffer.capacity() - 1);
    //     assertEquals(buffer.capacity() - 1, retainedSlice.writerIndex());
    //     retainedSlice.release();

    //     retainedSlice = buffer.retainedSlice(1, buffer.capacity() - 1);
    //     assertEquals(buffer.capacity() - 1, retainedSlice.writerIndex());
    //     retainedSlice.release();

    //     retainedSlice = buffer.retainedSlice(1, buffer.capacity() - 2);
    //     assertEquals(buffer.capacity() - 2, retainedSlice.writerIndex());
    //     retainedSlice.release();
    // }

    // @Test
    // @SuppressWarnings("ObjectEqualsNull")
    // void testEquals() {
    //     assertFalse(buffer is null);
    //     assertFalse(buffer.equals(new Object()));

    //     byte[] value = new byte[32];
    //     buffer.setIndex(0, value.length);
    //     random.nextBytes(value);
    //     buffer.setBytes(0, value);

    //     assertEquals(buffer, wrappedBuffer(value));
    //     assertEquals(buffer, wrappedBuffer(value).order(LITTLE_ENDIAN));

    //     value[0] ++;
    //     assertFalse(buffer == wrappedBuffer(value));
    //     assertFalse(buffer == wrappedBuffer(value).order(LITTLE_ENDIAN));
    // }

    // @Test
    // void testCompareTo() {
    //     try {
    //         buffer.compareTo(null);
    //         fail();
    //     } catch (NullPointerException e) {
    //         // Expected
    //     }

    //     // Fill the random stuff
    //     byte[] value = new byte[32];
    //     random.nextBytes(value);
    //     // Prevent overflow / underflow
    //     if (value[0] == 0) {
    //         value[0] ++;
    //     } else if (value[0] == -1) {
    //         value[0] --;
    //     }

    //     buffer.setIndex(0, value.length);
    //     buffer.setBytes(0, value);

    //     assertEquals(0, buffer.compareTo(wrappedBuffer(value)));
    //     assertEquals(0, buffer.compareTo(wrappedBuffer(value).order(LITTLE_ENDIAN)));

    //     value[0] ++;
    //     assertTrue(buffer.compareTo(wrappedBuffer(value)) < 0);
    //     assertTrue(buffer.compareTo(wrappedBuffer(value).order(LITTLE_ENDIAN)) < 0);
    //     value[0] -= 2;
    //     assertTrue(buffer.compareTo(wrappedBuffer(value)) > 0);
    //     assertTrue(buffer.compareTo(wrappedBuffer(value).order(LITTLE_ENDIAN)) > 0);
    //     value[0] ++;

    //     assertTrue(buffer.compareTo(wrappedBuffer(value, 0, 31)) > 0);
    //     assertTrue(buffer.compareTo(wrappedBuffer(value, 0, 31).order(LITTLE_ENDIAN)) > 0);
    //     assertTrue(buffer.slice(0, 31).compareTo(wrappedBuffer(value)) < 0);
    //     assertTrue(buffer.slice(0, 31).compareTo(wrappedBuffer(value).order(LITTLE_ENDIAN)) < 0);

    //     ByteBuf retainedSlice = buffer.retainedSlice(0, 31);
    //     assertTrue(retainedSlice.compareTo(wrappedBuffer(value)) < 0);
    //     retainedSlice.release();

    //     retainedSlice = buffer.retainedSlice(0, 31);
    //     assertTrue(retainedSlice.compareTo(wrappedBuffer(value).order(LITTLE_ENDIAN)) < 0);
    //     retainedSlice.release();
    // }

    // @Test
    // void testCompareTo2() {
    //     byte[] bytes = {1, 2, 3, 4};
    //     byte[] bytesReversed = {4, 3, 2, 1};

    //     ByteBuf buf1 = newBuffer(4).clear().writeBytes(bytes).order(ByteOrder.LITTLE_ENDIAN);
    //     ByteBuf buf2 = newBuffer(4).clear().writeBytes(bytesReversed).order(ByteOrder.LITTLE_ENDIAN);
    //     ByteBuf buf3 = newBuffer(4).clear().writeBytes(bytes).order(ByteOrder.BIG_ENDIAN);
    //     ByteBuf buf4 = newBuffer(4).clear().writeBytes(bytesReversed).order(ByteOrder.BIG_ENDIAN);
    //     try {
    //         assertEquals(buf1.compareTo(buf2), buf3.compareTo(buf4));
    //         assertEquals(buf2.compareTo(buf1), buf4.compareTo(buf3));
    //         assertEquals(buf1.compareTo(buf3), buf2.compareTo(buf4));
    //         assertEquals(buf3.compareTo(buf1), buf4.compareTo(buf2));
    //     } finally {
    //         buf1.release();
    //         buf2.release();
    //         buf3.release();
    //         buf4.release();
    //     }
    // }

    // @Test
    // void testToString() {
    //     ByteBuf copied = copiedBuffer("Hello, World!", CharsetUtil.ISO_8859_1);
    //     buffer.clear();
    //     buffer.writeBytes(copied);
    //     assertEquals("Hello, World!", buffer.toString(CharsetUtil.ISO_8859_1));
    //     copied.release();
    // }

    // @Test(timeout = 10000)
    // void testToStringMultipleThreads() {
    //     buffer.clear();
    //     buffer.writeBytes("Hello, World!".getBytes(CharsetUtil.ISO_8859_1));

    //     final AtomicInteger counter = new AtomicInteger(30000);
    //     final AtomicReference!(Throwable) errorRef = new AtomicReference!(Throwable)();
    //     List!(Thread) threads = new ArrayList!(Thread)();
    //     for (int i = 0; i < 10; i++) {
    //         Thread thread = new Thread(new Runnable() {
    //             override
    //             void run() {
    //                 try {
    //                     while (errorRef.get() is null && counter.decrementAndGet() > 0) {
    //                         assertEquals("Hello, World!", buffer.toString(CharsetUtil.ISO_8859_1));
    //                     }
    //                 } catch (Throwable cause) {
    //                     errorRef.compareAndSet(null, cause);
    //                 }
    //             }
    //         });
    //         threads.add(thread);
    //     }
    //     foreach(Thread thread ; threads) {
    //         thread.start();
    //     }

    //     foreach(Thread thread ; threads) {
    //         thread.join();
    //     }

    //     Throwable error = errorRef.get();
    //     if (error !is null) {
    //         throw error;
    //     }
    // }

    // @Test
    // void testIndexOf() {
    //     buffer.clear();
    //     buffer.writeByte((byte) 1);
    //     buffer.writeByte((byte) 2);
    //     buffer.writeByte((byte) 3);
    //     buffer.writeByte((byte) 2);
    //     buffer.writeByte((byte) 1);

    //     assertEquals(-1, buffer.indexOf(1, 4, (byte) 1));
    //     assertEquals(-1, buffer.indexOf(4, 1, (byte) 1));
    //     assertEquals(1, buffer.indexOf(1, 4, (byte) 2));
    //     assertEquals(3, buffer.indexOf(4, 1, (byte) 2));
    // }

    // @Test
    // void testNioBuffer1() {
    //     assumeTrue(buffer.nioBufferCount() == 1);

    //     byte[] value = new byte[buffer.capacity()];
    //     random.nextBytes(value);
    //     buffer.clear();
    //     buffer.writeBytes(value);

    //     assertRemainingEquals(ByteBuffer.wrap(value), buffer.nioBuffer());
    // }

    // @Test
    // void testToByteBuffer2() {
    //     assumeTrue(buffer.nioBufferCount() == 1);

    //     byte[] value = new byte[buffer.capacity()];
    //     random.nextBytes(value);
    //     buffer.clear();
    //     buffer.writeBytes(value);

    //     for (int i = 0; i < buffer.capacity() - BLOCK_SIZE + 1; i += BLOCK_SIZE) {
    //         assertRemainingEquals(ByteBuffer.wrap(value, i, BLOCK_SIZE), buffer.nioBuffer(i, BLOCK_SIZE));
    //     }
    // }

    // private static void assertRemainingEquals(ByteBuffer expected, ByteBuffer actual) {
    //     int remaining = expected.remaining();
    //     int remaining2 = actual.remaining();

    //     assertEquals(remaining, remaining2);
    //     byte[] array1 = new byte[remaining];
    //     byte[] array2 = new byte[remaining2];
    //     expected.get(array1);
    //     actual.get(array2);
    //     assertArrayEquals(array1, array2);
    // }

    // @Test
    // void testToByteBuffer3() {
    //     assumeTrue(buffer.nioBufferCount() == 1);

    //     assertEquals(buffer.order(), buffer.nioBuffer().order());
    // }

    // @Test
    // void testSkipBytes1() {
    //     buffer.setIndex(CAPACITY / 4, CAPACITY / 2);

    //     buffer.skipBytes(CAPACITY / 4);
    //     assertEquals(CAPACITY / 4 * 2, buffer.readerIndex());

    //     try {
    //         buffer.skipBytes(CAPACITY / 4 + 1);
    //         fail();
    //     } catch (IndexOutOfBoundsException e) {
    //         // Expected
    //     }

    //     // Should remain unchanged.
    //     assertEquals(CAPACITY / 4 * 2, buffer.readerIndex());
    // }

    // @Test
    // void testHashCode() {
    //     ByteBuf elemA = buffer(15);
    //     ByteBuf elemB = directBuffer(15);
    //     elemA.writeBytes(new byte[] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5 });
    //     elemB.writeBytes(new byte[] { 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 9 });

    //     Set!(ByteBuf) set = new HashSet!(ByteBuf)();
    //     set.add(elemA);
    //     set.add(elemB);

    //     assertEquals(2, set.size());
    //     ByteBuf elemACopy = elemA.copy();
    //     assertTrue(set.contains(elemACopy));

    //     ByteBuf elemBCopy = elemB.copy();
    //     assertTrue(set.contains(elemBCopy));

    //     buffer.clear();
    //     buffer.writeBytes(elemA.duplicate());

    //     assertTrue(set.remove(buffer));
    //     assertFalse(set.contains(elemA));
    //     assertEquals(1, set.size());

    //     buffer.clear();
    //     buffer.writeBytes(elemB.duplicate());
    //     assertTrue(set.remove(buffer));
    //     assertFalse(set.contains(elemB));
    //     assertEquals(0, set.size());
    //     elemA.release();
    //     elemB.release();
    //     elemACopy.release();
    //     elemBCopy.release();
    // }

    // // Test case for https://github.com/netty/netty/issues/325
    // @Test
    // void testDiscardAllReadBytes() {
    //     buffer.writerIndex(buffer.capacity());
    //     buffer.readerIndex(buffer.writerIndex());
    //     buffer.discardReadBytes();
    // }

    // @Test
    // void testForEachByte() {
    //     buffer.clear();
    //     for (int i = 0; i < CAPACITY; i ++) {
    //         buffer.writeByte(i + 1);
    //     }

    //     final AtomicInteger lastIndex = new AtomicInteger();
    //     buffer.setIndex(CAPACITY / 4, CAPACITY * 3 / 4);
    //     assertThat(buffer.forEachByte(new ByteProcessor() {
    //         int i = CAPACITY / 4;

    //         override
    //         boolean process(byte value) {
    //             assertThat(value, is((byte) (i + 1)));
    //             lastIndex.set(i);
    //             i ++;
    //             return true;
    //         }
    //     }), is(-1));

    //     assertThat(lastIndex.get(), is(CAPACITY * 3 / 4 - 1));
    // }

    // @Test
    // void testForEachByteAbort() {
    //     buffer.clear();
    //     for (int i = 0; i < CAPACITY; i ++) {
    //         buffer.writeByte(i + 1);
    //     }

    //     final int stop = CAPACITY / 2;
    //     assertThat(buffer.forEachByte(CAPACITY / 3, CAPACITY / 3, new ByteProcessor() {
    //         int i = CAPACITY / 3;

    //         override
    //         boolean process(byte value) {
    //             assertThat(value, is((byte) (i + 1)));
    //             if (i == stop) {
    //                 return false;
    //             }

    //             i++;
    //             return true;
    //         }
    //     }), is(stop));
    // }

    // @Test
    // void testForEachByteDesc() {
    //     buffer.clear();
    //     for (int i = 0; i < CAPACITY; i ++) {
    //         buffer.writeByte(i + 1);
    //     }

    //     final AtomicInteger lastIndex = new AtomicInteger();
    //     assertThat(buffer.forEachByteDesc(CAPACITY / 4, CAPACITY * 2 / 4, new ByteProcessor() {
    //         int i = CAPACITY * 3 / 4 - 1;

    //         override
    //         boolean process(byte value) {
    //             assertThat(value, is((byte) (i + 1)));
    //             lastIndex.set(i);
    //             i --;
    //             return true;
    //         }
    //     }), is(-1));

    //     assertThat(lastIndex.get(), is(CAPACITY / 4));
    // }

    // @Test
    // void testInternalNioBuffer() {
    //     testInternalNioBuffer(128);
    //     testInternalNioBuffer(1024);
    //     testInternalNioBuffer(4 * 1024);
    //     testInternalNioBuffer(64 * 1024);
    //     testInternalNioBuffer(32 * 1024 * 1024);
    //     testInternalNioBuffer(64 * 1024 * 1024);
    // }

    // private void testInternalNioBuffer(int a) {
    //     ByteBuf buffer = newBuffer(2);
    //     ByteBuffer buf = buffer.internalNioBuffer(buffer.readerIndex(), 1);
    //     assertEquals(1, buf.remaining());

    //     byte[] data = new byte[a];
    //     PlatformDependent.threadLocalRandom().nextBytes(data);
    //     buffer.writeBytes(data);

    //     buf = buffer.internalNioBuffer(buffer.readerIndex(), a);
    //     assertEquals(a, buf.remaining());

    //     for (int i = 0; i < a; i++) {
    //         assertEquals(data[i], buf.get());
    //     }
    //     assertFalse(buf.hasRemaining());
    //     buffer.release();
    // }

    // @Test
    // void testDuplicateReadGatheringByteChannelMultipleThreads() {
    //     testReadGatheringByteChannelMultipleThreads(false);
    // }

    // @Test
    // void testSliceReadGatheringByteChannelMultipleThreads() {
    //     testReadGatheringByteChannelMultipleThreads(true);
    // }

    // private void testReadGatheringByteChannelMultipleThreads(final boolean slice) {
    //     final byte[] bytes = new byte[8];
    //     random.nextBytes(bytes);

    //     final ByteBuf buffer = newBuffer(8);
    //     buffer.writeBytes(bytes);
    //     final CountDownLatch latch = new CountDownLatch(60000);
    //     final CyclicBarrier barrier = new CyclicBarrier(11);
    //     for (int i = 0; i < 10; i++) {
    //         new Thread(new Runnable() {
    //             override
    //             void run() {
    //                 while (latch.getCount() > 0) {
    //                     ByteBuf buf;
    //                     if (slice) {
    //                        buf = buffer.slice();
    //                     } else {
    //                        buf = buffer.duplicate();
    //                     }
    //                     TestGatheringByteChannel channel = new TestGatheringByteChannel();

    //                     while (buf.isReadable()) {
    //                         try {
    //                             buf.readBytes(channel, buf.readableBytes());
    //                         } catch (IOException e) {
    //                             // Never happens
    //                             return;
    //                         }
    //                     }
    //                     assertArrayEquals(bytes, channel.writtenBytes());
    //                     latch.countDown();
    //                 }
    //                 try {
    //                     barrier.await();
    //                 } catch (Exception e) {
    //                     // ignore
    //                 }
    //             }
    //         }).start();
    //     }
    //     latch.await(10, TimeUnit.SECONDS);
    //     barrier.await(5, TimeUnit.SECONDS);
    //     buffer.release();
    // }

    // @Test
    // void testDuplicateReadOutputStreamMultipleThreads() {
    //     testReadOutputStreamMultipleThreads(false);
    // }

    // @Test
    // void testSliceReadOutputStreamMultipleThreads() {
    //     testReadOutputStreamMultipleThreads(true);
    // }

    // private void testReadOutputStreamMultipleThreads(final boolean slice) {
    //     final byte[] bytes = new byte[8];
    //     random.nextBytes(bytes);

    //     final ByteBuf buffer = newBuffer(8);
    //     buffer.writeBytes(bytes);
    //     final CountDownLatch latch = new CountDownLatch(60000);
    //     final CyclicBarrier barrier = new CyclicBarrier(11);
    //     for (int i = 0; i < 10; i++) {
    //         new Thread(new Runnable() {
    //             override
    //             void run() {
    //                 while (latch.getCount() > 0) {
    //                     ByteBuf buf;
    //                     if (slice) {
    //                         buf = buffer.slice();
    //                     } else {
    //                         buf = buffer.duplicate();
    //                     }
    //                     ByteArrayOutputStream out = new ByteArrayOutputStream();

    //                     while (buf.isReadable()) {
    //                         try {
    //                             buf.readBytes(out, buf.readableBytes());
    //                         } catch (IOException e) {
    //                             // Never happens
    //                             return;
    //                         }
    //                     }
    //                     assertArrayEquals(bytes, out.toByteArray());
    //                     latch.countDown();
    //                 }
    //                 try {
    //                     barrier.await();
    //                 } catch (Exception e) {
    //                     // ignore
    //                 }
    //             }
    //         }).start();
    //     }
    //     latch.await(10, TimeUnit.SECONDS);
    //     barrier.await(5, TimeUnit.SECONDS);
    //     buffer.release();
    // }

    // @Test
    // void testDuplicateBytesInArrayMultipleThreads() {
    //     testBytesInArrayMultipleThreads(false);
    // }

    // @Test
    // void testSliceBytesInArrayMultipleThreads() {
    //     testBytesInArrayMultipleThreads(true);
    // }

    // private void testBytesInArrayMultipleThreads(final boolean slice) {
    //     final byte[] bytes = new byte[8];
    //     random.nextBytes(bytes);

    //     final ByteBuf buffer = newBuffer(8);
    //     buffer.writeBytes(bytes);
    //     final AtomicReference!(Throwable) cause = new AtomicReference!(Throwable)();
    //     final CountDownLatch latch = new CountDownLatch(60000);
    //     final CyclicBarrier barrier = new CyclicBarrier(11);
    //     for (int i = 0; i < 10; i++) {
    //         new Thread(new Runnable() {
    //             override
    //             void run() {
    //                 while (cause.get() is null && latch.getCount() > 0) {
    //                     ByteBuf buf;
    //                     if (slice) {
    //                         buf = buffer.slice();
    //                     } else {
    //                         buf = buffer.duplicate();
    //                     }

    //                     byte[] array = new byte[8];
    //                     buf.readBytes(array);

    //                     assertArrayEquals(bytes, array);

    //                     Arrays.fill(array, (byte) 0);
    //                     buf.getBytes(0, array);
    //                     assertArrayEquals(bytes, array);

    //                     latch.countDown();
    //                 }
    //                 try {
    //                     barrier.await();
    //                 } catch (Exception e) {
    //                     // ignore
    //                 }
    //             }
    //         }).start();
    //     }
    //     latch.await(10, TimeUnit.SECONDS);
    //     barrier.await(5, TimeUnit.SECONDS);
    //     assertNull(cause.get());
    //     buffer.release();
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void readByteThrowsIndexOutOfBoundsException() {
    //     final ByteBuf buffer = newBuffer(8);
    //     try {
    //         buffer.writeByte(0);
    //         assertEquals((byte) 0, buffer.readByte());
    //         buffer.readByte();
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test
    // @SuppressWarnings("ForLoopThatDoesntUseLoopVariable")
    // void testNioBufferExposeOnlyRegion() {
    //     final ByteBuf buffer = newBuffer(8);
    //     byte[] data = new byte[8];
    //     random.nextBytes(data);
    //     buffer.writeBytes(data);

    //     ByteBuffer nioBuf = buffer.nioBuffer(1, data.length - 2);
    //     assertEquals(0, nioBuf.position());
    //     assertEquals(6, nioBuf.remaining());

    //     for (int i = 1; nioBuf.hasRemaining(); i++) {
    //         assertEquals(data[i], nioBuf.get());
    //     }
    //     buffer.release();
    // }

    // @Test
    // void ensureWritableWithForceDoesNotThrow() {
    //     ensureWritableDoesNotThrow(true);
    // }

    // @Test
    // void ensureWritableWithOutForceDoesNotThrow() {
    //     ensureWritableDoesNotThrow(false);
    // }

    // private void ensureWritableDoesNotThrow(boolean force) {
    //     final ByteBuf buffer = newBuffer(8);
    //     buffer.writerIndex(buffer.capacity());
    //     buffer.ensureWritable(8, force);
    //     buffer.release();
    // }

    // // See:
    // // - https://github.com/netty/netty/issues/2587
    // // - https://github.com/netty/netty/issues/2580
    // @Test
    // void testLittleEndianWithExpand() {
    //     ByteBuf buffer = newBuffer(0).order(LITTLE_ENDIAN);
    //     buffer.writeInt(0x12345678);
    //     assertEquals("78563412", ByteBufUtil.hexDump(buffer));
    //     buffer.release();
    // }

    // private ByteBuf releasedBuffer() {
    //     ByteBuf buffer = newBuffer(8);

    //     // Clear the buffer so we are sure the reader and writer indices are 0.
    //     // This is important as we may return a slice from newBuffer(...).
    //     buffer.clear();
    //     assertTrue(buffer.release());
    //     return buffer;
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testDiscardReadBytesAfterRelease() {
    //     releasedBuffer().discardReadBytes();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testDiscardSomeReadBytesAfterRelease() {
    //     releasedBuffer().discardSomeReadBytes();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testEnsureWritableAfterRelease() {
    //     releasedBuffer().ensureWritable(16);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetBooleanAfterRelease() {
    //     releasedBuffer().getBoolean(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetByteAfterRelease() {
    //     releasedBuffer().getByte(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetUnsignedByteAfterRelease() {
    //     releasedBuffer().getUnsignedByte(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetShortAfterRelease() {
    //     releasedBuffer().getShort(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetShortLEAfterRelease() {
    //     releasedBuffer().getShortLE(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetUnsignedShortAfterRelease() {
    //     releasedBuffer().getUnsignedShort(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetUnsignedShortLEAfterRelease() {
    //     releasedBuffer().getUnsignedShortLE(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetMediumAfterRelease() {
    //     releasedBuffer().getMedium(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetMediumLEAfterRelease() {
    //     releasedBuffer().getMediumLE(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetUnsignedMediumAfterRelease() {
    //     releasedBuffer().getUnsignedMedium(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetIntAfterRelease() {
    //     releasedBuffer().getInt(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetIntLEAfterRelease() {
    //     releasedBuffer().getIntLE(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetUnsignedIntAfterRelease() {
    //     releasedBuffer().getUnsignedInt(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetUnsignedIntLEAfterRelease() {
    //     releasedBuffer().getUnsignedIntLE(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetLongAfterRelease() {
    //     releasedBuffer().getLong(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetLongLEAfterRelease() {
    //     releasedBuffer().getLongLE(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetCharAfterRelease() {
    //     releasedBuffer().getChar(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetFloatAfterRelease() {
    //     releasedBuffer().getFloat(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetFloatLEAfterRelease() {
    //     releasedBuffer().getFloatLE(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetDoubleAfterRelease() {
    //     releasedBuffer().getDouble(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetDoubleLEAfterRelease() {
    //     releasedBuffer().getDoubleLE(0);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetBytesAfterRelease() {
    //     ByteBuf buffer = buffer(8);
    //     try {
    //         releasedBuffer().getBytes(0, buffer);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetBytesAfterRelease2() {
    //     ByteBuf buffer = buffer();
    //     try {
    //         releasedBuffer().getBytes(0, buffer, 1);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetBytesAfterRelease3() {
    //     ByteBuf buffer = buffer();
    //     try {
    //         releasedBuffer().getBytes(0, buffer, 0, 1);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetBytesAfterRelease4() {
    //     releasedBuffer().getBytes(0, new byte[8]);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetBytesAfterRelease5() {
    //     releasedBuffer().getBytes(0, new byte[8], 0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetBytesAfterRelease6() {
    //     releasedBuffer().getBytes(0, ByteBuffer.allocate(8));
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetBytesAfterRelease7() {
    //     releasedBuffer().getBytes(0, new ByteArrayOutputStream(), 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testGetBytesAfterRelease8() {
    //     releasedBuffer().getBytes(0, new DevNullGatheringByteChannel(), 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetBooleanAfterRelease() {
    //     releasedBuffer().setBoolean(0, true);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetByteAfterRelease() {
    //     releasedBuffer().setByte(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetShortAfterRelease() {
    //     releasedBuffer().setShort(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetShortLEAfterRelease() {
    //     releasedBuffer().setShortLE(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetMediumAfterRelease() {
    //     releasedBuffer().setMedium(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetMediumLEAfterRelease() {
    //     releasedBuffer().setMediumLE(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetIntAfterRelease() {
    //     releasedBuffer().setInt(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetIntLEAfterRelease() {
    //     releasedBuffer().setIntLE(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetLongAfterRelease() {
    //     releasedBuffer().setLong(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetLongLEAfterRelease() {
    //     releasedBuffer().setLongLE(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetCharAfterRelease() {
    //     releasedBuffer().setChar(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetFloatAfterRelease() {
    //     releasedBuffer().setFloat(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetDoubleAfterRelease() {
    //     releasedBuffer().setDouble(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetBytesAfterRelease() {
    //     ByteBuf buffer = buffer();
    //     try {
    //         releasedBuffer().setBytes(0, buffer);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetBytesAfterRelease2() {
    //     ByteBuf buffer = buffer();
    //     try {
    //         releasedBuffer().setBytes(0, buffer, 1);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetBytesAfterRelease3() {
    //     ByteBuf buffer = buffer();
    //     try {
    //         releasedBuffer().setBytes(0, buffer, 0, 1);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetUsAsciiCharSequenceAfterRelease() {
    //     testSetCharSequenceAfterRelease0(CharsetUtil.US_ASCII);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetIso88591CharSequenceAfterRelease() {
    //     testSetCharSequenceAfterRelease0(CharsetUtil.ISO_8859_1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetUtf8CharSequenceAfterRelease() {
    //     testSetCharSequenceAfterRelease0(CharsetUtil.UTF_8);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetUtf16CharSequenceAfterRelease() {
    //     testSetCharSequenceAfterRelease0(CharsetUtil.UTF_16);
    // }

    // private void testSetCharSequenceAfterRelease0(Charset charset) {
    //     releasedBuffer().setCharSequence(0, "x", charset);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetBytesAfterRelease4() {
    //     releasedBuffer().setBytes(0, new byte[8]);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetBytesAfterRelease5() {
    //     releasedBuffer().setBytes(0, new byte[8], 0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetBytesAfterRelease6() {
    //     releasedBuffer().setBytes(0, ByteBuffer.allocate(8));
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetBytesAfterRelease7() {
    //     releasedBuffer().setBytes(0, new ByteArrayInputStream(new byte[8]), 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetBytesAfterRelease8() {
    //     releasedBuffer().setBytes(0, new TestScatteringByteChannel(), 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSetZeroAfterRelease() {
    //     releasedBuffer().setZero(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBooleanAfterRelease() {
    //     releasedBuffer().readBoolean();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadByteAfterRelease() {
    //     releasedBuffer().readByte();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadUnsignedByteAfterRelease() {
    //     releasedBuffer().readUnsignedByte();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadShortAfterRelease() {
    //     releasedBuffer().readShort();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadShortLEAfterRelease() {
    //     releasedBuffer().readShortLE();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadUnsignedShortAfterRelease() {
    //     releasedBuffer().readUnsignedShort();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadUnsignedShortLEAfterRelease() {
    //     releasedBuffer().readUnsignedShortLE();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadMediumAfterRelease() {
    //     releasedBuffer().readMedium();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadMediumLEAfterRelease() {
    //     releasedBuffer().readMediumLE();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadUnsignedMediumAfterRelease() {
    //     releasedBuffer().readUnsignedMedium();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadUnsignedMediumLEAfterRelease() {
    //     releasedBuffer().readUnsignedMediumLE();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadIntAfterRelease() {
    //     releasedBuffer().readInt();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadIntLEAfterRelease() {
    //     releasedBuffer().readIntLE();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadUnsignedIntAfterRelease() {
    //     releasedBuffer().readUnsignedInt();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadUnsignedIntLEAfterRelease() {
    //     releasedBuffer().readUnsignedIntLE();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadLongAfterRelease() {
    //     releasedBuffer().readLong();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadLongLEAfterRelease() {
    //     releasedBuffer().readLongLE();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadCharAfterRelease() {
    //     releasedBuffer().readChar();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadFloatAfterRelease() {
    //     releasedBuffer().readFloat();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadFloatLEAfterRelease() {
    //     releasedBuffer().readFloatLE();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadDoubleAfterRelease() {
    //     releasedBuffer().readDouble();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadDoubleLEAfterRelease() {
    //     releasedBuffer().readDoubleLE();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBytesAfterRelease() {
    //     releasedBuffer().readBytes(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBytesAfterRelease2() {
    //     ByteBuf buffer = buffer(8);
    //     try {
    //         releasedBuffer().readBytes(buffer);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBytesAfterRelease3() {
    //     ByteBuf buffer = buffer(8);
    //     try {
    //         releasedBuffer().readBytes(buffer);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBytesAfterRelease4() {
    //     ByteBuf buffer = buffer(8);
    //     try {
    //         releasedBuffer().readBytes(buffer, 0, 1);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBytesAfterRelease5() {
    //     releasedBuffer().readBytes(new byte[8]);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBytesAfterRelease6() {
    //     releasedBuffer().readBytes(new byte[8], 0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBytesAfterRelease7() {
    //     releasedBuffer().readBytes(ByteBuffer.allocate(8));
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBytesAfterRelease8() {
    //     releasedBuffer().readBytes(new ByteArrayOutputStream(), 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBytesAfterRelease9() {
    //     releasedBuffer().readBytes(new ByteArrayOutputStream(), 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testReadBytesAfterRelease10() {
    //     releasedBuffer().readBytes(new DevNullGatheringByteChannel(), 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteBooleanAfterRelease() {
    //     releasedBuffer().writeBoolean(true);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteByteAfterRelease() {
    //     releasedBuffer().writeByte(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteShortAfterRelease() {
    //     releasedBuffer().writeShort(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteShortLEAfterRelease() {
    //     releasedBuffer().writeShortLE(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteMediumAfterRelease() {
    //     releasedBuffer().writeMedium(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteMediumLEAfterRelease() {
    //     releasedBuffer().writeMediumLE(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteIntAfterRelease() {
    //     releasedBuffer().writeInt(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteIntLEAfterRelease() {
    //     releasedBuffer().writeIntLE(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteLongAfterRelease() {
    //     releasedBuffer().writeLong(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteLongLEAfterRelease() {
    //     releasedBuffer().writeLongLE(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteCharAfterRelease() {
    //     releasedBuffer().writeChar(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteFloatAfterRelease() {
    //     releasedBuffer().writeFloat(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteFloatLEAfterRelease() {
    //     releasedBuffer().writeFloatLE(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteDoubleAfterRelease() {
    //     releasedBuffer().writeDouble(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteDoubleLEAfterRelease() {
    //     releasedBuffer().writeDoubleLE(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteBytesAfterRelease() {
    //     ByteBuf buffer = buffer(8);
    //     try {
    //         releasedBuffer().writeBytes(buffer);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteBytesAfterRelease2() {
    //     ByteBuf buffer = copiedBuffer(new byte[8]);
    //     try {
    //         releasedBuffer().writeBytes(buffer, 1);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteBytesAfterRelease3() {
    //     ByteBuf buffer = buffer(8);
    //     try {
    //         releasedBuffer().writeBytes(buffer, 0, 1);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteBytesAfterRelease4() {
    //     releasedBuffer().writeBytes(new byte[8]);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteBytesAfterRelease5() {
    //     releasedBuffer().writeBytes(new byte[8], 0 , 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteBytesAfterRelease6() {
    //     releasedBuffer().writeBytes(ByteBuffer.allocate(8));
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteBytesAfterRelease7() {
    //     releasedBuffer().writeBytes(new ByteArrayInputStream(new byte[8]), 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteBytesAfterRelease8() {
    //     releasedBuffer().writeBytes(new TestScatteringByteChannel(), 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteZeroAfterRelease() {
    //     releasedBuffer().writeZero(1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteUsAsciiCharSequenceAfterRelease() {
    //     testWriteCharSequenceAfterRelease0(CharsetUtil.US_ASCII);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteIso88591CharSequenceAfterRelease() {
    //     testWriteCharSequenceAfterRelease0(CharsetUtil.ISO_8859_1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteUtf8CharSequenceAfterRelease() {
    //     testWriteCharSequenceAfterRelease0(CharsetUtil.UTF_8);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testWriteUtf16CharSequenceAfterRelease() {
    //     testWriteCharSequenceAfterRelease0(CharsetUtil.UTF_16);
    // }

    // private void testWriteCharSequenceAfterRelease0(Charset charset) {
    //     releasedBuffer().writeCharSequence("x", charset);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testForEachByteAfterRelease() {
    //     releasedBuffer().forEachByte(new TestByteProcessor());
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testForEachByteAfterRelease1() {
    //     releasedBuffer().forEachByte(0, 1, new TestByteProcessor());
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testForEachByteDescAfterRelease() {
    //     releasedBuffer().forEachByteDesc(new TestByteProcessor());
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testForEachByteDescAfterRelease1() {
    //     releasedBuffer().forEachByteDesc(0, 1, new TestByteProcessor());
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testCopyAfterRelease() {
    //     releasedBuffer().copy();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testCopyAfterRelease1() {
    //     releasedBuffer().copy();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testNioBufferAfterRelease() {
    //     releasedBuffer().nioBuffer();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testNioBufferAfterRelease1() {
    //     releasedBuffer().nioBuffer(0, 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testInternalNioBufferAfterRelease() {
    //     ByteBuf releasedBuffer = releasedBuffer();
    //     releasedBuffer.internalNioBuffer(releasedBuffer.readerIndex(), 1);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testNioBuffersAfterRelease() {
    //     releasedBuffer().nioBuffers();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testNioBuffersAfterRelease2() {
    //     releasedBuffer().nioBuffers(0, 1);
    // }

    // @Test
    // void testArrayAfterRelease() {
    //     ByteBuf buf = releasedBuffer();
    //     if (buf.hasArray()) {
    //         try {
    //             buf.array();
    //             fail();
    //         } catch (IllegalReferenceCountException e) {
    //             // expected
    //         }
    //     }
    // }

    // @Test
    // void testMemoryAddressAfterRelease() {
    //     ByteBuf buf = releasedBuffer();
    //     if (buf.hasMemoryAddress()) {
    //         try {
    //             buf.memoryAddress();
    //             fail();
    //         } catch (IllegalReferenceCountException e) {
    //             // expected
    //         }
    //     }
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSliceAfterRelease() {
    //     releasedBuffer().slice();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testSliceAfterRelease2() {
    //     releasedBuffer().slice(0, 1);
    // }

    // private static void assertSliceFailAfterRelease(ByteBuf... bufs) {
    //     foreach(ByteBuf buf ; bufs) {
    //         if (buf.refCnt() > 0) {
    //             buf.release();
    //         }
    //     }
    //     foreach(ByteBuf buf ; bufs) {
    //         try {
    //             assertEquals(0, buf.refCnt());
    //             buf.slice();
    //             fail();
    //         } catch (IllegalReferenceCountException ignored) {
    //             // as expected
    //         }
    //     }
    // }

    // @Test
    // void testSliceAfterReleaseRetainedSlice() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedSlice(0, 1);
    //     assertSliceFailAfterRelease(buf, buf2);
    // }

    // @Test
    // void testSliceAfterReleaseRetainedSliceDuplicate() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedSlice(0, 1);
    //     ByteBuf buf3 = buf2.duplicate();
    //     assertSliceFailAfterRelease(buf, buf2, buf3);
    // }

    // @Test
    // void testSliceAfterReleaseRetainedSliceRetainedDuplicate() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedSlice(0, 1);
    //     ByteBuf buf3 = buf2.retainedDuplicate();
    //     assertSliceFailAfterRelease(buf, buf2, buf3);
    // }

    // @Test
    // void testSliceAfterReleaseRetainedDuplicate() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedDuplicate();
    //     assertSliceFailAfterRelease(buf, buf2);
    // }

    // @Test
    // void testSliceAfterReleaseRetainedDuplicateSlice() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedDuplicate();
    //     ByteBuf buf3 = buf2.slice(0, 1);
    //     assertSliceFailAfterRelease(buf, buf2, buf3);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testRetainedSliceAfterRelease() {
    //     releasedBuffer().retainedSlice();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testRetainedSliceAfterRelease2() {
    //     releasedBuffer().retainedSlice(0, 1);
    // }

    // private static void assertRetainedSliceFailAfterRelease(ByteBuf... bufs) {
    //     foreach(ByteBuf buf ; bufs) {
    //         if (buf.refCnt() > 0) {
    //             buf.release();
    //         }
    //     }
    //     foreach(ByteBuf buf ; bufs) {
    //         try {
    //             assertEquals(0, buf.refCnt());
    //             buf.retainedSlice();
    //             fail();
    //         } catch (IllegalReferenceCountException ignored) {
    //             // as expected
    //         }
    //     }
    // }

    // @Test
    // void testRetainedSliceAfterReleaseRetainedSlice() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedSlice(0, 1);
    //     assertRetainedSliceFailAfterRelease(buf, buf2);
    // }

    // @Test
    // void testRetainedSliceAfterReleaseRetainedSliceDuplicate() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedSlice(0, 1);
    //     ByteBuf buf3 = buf2.duplicate();
    //     assertRetainedSliceFailAfterRelease(buf, buf2, buf3);
    // }

    // @Test
    // void testRetainedSliceAfterReleaseRetainedSliceRetainedDuplicate() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedSlice(0, 1);
    //     ByteBuf buf3 = buf2.retainedDuplicate();
    //     assertRetainedSliceFailAfterRelease(buf, buf2, buf3);
    // }

    // @Test
    // void testRetainedSliceAfterReleaseRetainedDuplicate() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedDuplicate();
    //     assertRetainedSliceFailAfterRelease(buf, buf2);
    // }

    // @Test
    // void testRetainedSliceAfterReleaseRetainedDuplicateSlice() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedDuplicate();
    //     ByteBuf buf3 = buf2.slice(0, 1);
    //     assertRetainedSliceFailAfterRelease(buf, buf2, buf3);
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testDuplicateAfterRelease() {
    //     releasedBuffer().duplicate();
    // }

    // @Test(expected = IllegalReferenceCountException.class)
    // void testRetainedDuplicateAfterRelease() {
    //     releasedBuffer().retainedDuplicate();
    // }

    // private static void assertDuplicateFailAfterRelease(ByteBuf... bufs) {
    //     foreach(ByteBuf buf ; bufs) {
    //         if (buf.refCnt() > 0) {
    //             buf.release();
    //         }
    //     }
    //     foreach(ByteBuf buf ; bufs) {
    //         try {
    //             assertEquals(0, buf.refCnt());
    //             buf.duplicate();
    //             fail();
    //         } catch (IllegalReferenceCountException ignored) {
    //             // as expected
    //         }
    //     }
    // }

    // @Test
    // void testDuplicateAfterReleaseRetainedSliceDuplicate() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedSlice(0, 1);
    //     ByteBuf buf3 = buf2.duplicate();
    //     assertDuplicateFailAfterRelease(buf, buf2, buf3);
    // }

    // @Test
    // void testDuplicateAfterReleaseRetainedDuplicate() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedDuplicate();
    //     assertDuplicateFailAfterRelease(buf, buf2);
    // }

    // @Test
    // void testDuplicateAfterReleaseRetainedDuplicateSlice() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedDuplicate();
    //     ByteBuf buf3 = buf2.slice(0, 1);
    //     assertDuplicateFailAfterRelease(buf, buf2, buf3);
    // }

    // private static void assertRetainedDuplicateFailAfterRelease(ByteBuf... bufs) {
    //     foreach(ByteBuf buf ; bufs) {
    //         if (buf.refCnt() > 0) {
    //             buf.release();
    //         }
    //     }
    //     foreach(ByteBuf buf ; bufs) {
    //         try {
    //             assertEquals(0, buf.refCnt());
    //             buf.retainedDuplicate();
    //             fail();
    //         } catch (IllegalReferenceCountException ignored) {
    //             // as expected
    //         }
    //     }
    // }

    // @Test
    // void testRetainedDuplicateAfterReleaseRetainedDuplicate() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedDuplicate();
    //     assertRetainedDuplicateFailAfterRelease(buf, buf2);
    // }

    // @Test
    // void testRetainedDuplicateAfterReleaseDuplicate() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.duplicate();
    //     assertRetainedDuplicateFailAfterRelease(buf, buf2);
    // }

    // @Test
    // void testRetainedDuplicateAfterReleaseRetainedSlice() {
    //     ByteBuf buf = newBuffer(1);
    //     ByteBuf buf2 = buf.retainedSlice(0, 1);
    //     assertRetainedDuplicateFailAfterRelease(buf, buf2);
    // }

    // @Test
    // void testSliceRelease() {
    //     ByteBuf buf = newBuffer(8);
    //     assertEquals(1, buf.refCnt());
    //     assertTrue(buf.slice().release());
    //     assertEquals(0, buf.refCnt());
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testReadSliceOutOfBounds() {
    //     testReadSliceOutOfBounds(false);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testReadRetainedSliceOutOfBounds() {
    //     testReadSliceOutOfBounds(true);
    // }

    // private void testReadSliceOutOfBounds(boolean retainedSlice) {
    //     ByteBuf buf = newBuffer(100);
    //     try {
    //         buf.writeZero(50);
    //         if (retainedSlice) {
    //             buf.readRetainedSlice(51);
    //         } else {
    //             buf.readSlice(51);
    //         }
    //         fail();
    //     } finally {
    //         buf.release();
    //     }
    // }

    // @Test
    // void testWriteUsAsciiCharSequenceExpand() {
    //     testWriteCharSequenceExpand(CharsetUtil.US_ASCII);
    // }

    // @Test
    // void testWriteUtf8CharSequenceExpand() {
    //     testWriteCharSequenceExpand(CharsetUtil.UTF_8);
    // }

    // @Test
    // void testWriteIso88591CharSequenceExpand() {
    //     testWriteCharSequenceExpand(CharsetUtil.ISO_8859_1);
    // }
    // @Test
    // void testWriteUtf16CharSequenceExpand() {
    //     testWriteCharSequenceExpand(CharsetUtil.UTF_16);
    // }

    // private void testWriteCharSequenceExpand(Charset charset) {
    //     ByteBuf buf = newBuffer(1);
    //     try {
    //         int writerIndex = buf.capacity() - 1;
    //         buf.writerIndex(writerIndex);
    //         int written = buf.writeCharSequence("AB", charset);
    //         assertEquals(writerIndex, buf.writerIndex() - written);
    //     } finally {
    //         buf.release();
    //     }
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testSetUsAsciiCharSequenceNoExpand() {
    //     testSetCharSequenceNoExpand(CharsetUtil.US_ASCII);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testSetUtf8CharSequenceNoExpand() {
    //     testSetCharSequenceNoExpand(CharsetUtil.UTF_8);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testSetIso88591CharSequenceNoExpand() {
    //     testSetCharSequenceNoExpand(CharsetUtil.ISO_8859_1);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testSetUtf16CharSequenceNoExpand() {
    //     testSetCharSequenceNoExpand(CharsetUtil.UTF_16);
    // }

    // private void testSetCharSequenceNoExpand(Charset charset) {
    //     ByteBuf buf = newBuffer(1);
    //     try {
    //         buf.setCharSequence(0, "AB", charset);
    //     } finally {
    //         buf.release();
    //     }
    // }

    // @Test
    // void testSetUsAsciiCharSequence() {
    //     testSetGetCharSequence(CharsetUtil.US_ASCII);
    // }

    // @Test
    // void testSetUtf8CharSequence() {
    //     testSetGetCharSequence(CharsetUtil.UTF_8);
    // }

    // @Test
    // void testSetIso88591CharSequence() {
    //     testSetGetCharSequence(CharsetUtil.ISO_8859_1);
    // }

    // @Test
    // void testSetUtf16CharSequence() {
    //     testSetGetCharSequence(CharsetUtil.UTF_16);
    // }

    // private static final CharBuffer EXTENDED_ASCII_CHARS, ASCII_CHARS;

    // static {
    //     char[] chars = new char[256];
    //     for (char c = 0; c < chars.length; c++) {
    //         chars[c] = c;
    //     }
    //     EXTENDED_ASCII_CHARS = CharBuffer.wrap(chars);
    //     ASCII_CHARS = CharBuffer.wrap(chars, 0, 128);
    // }

    // private void testSetGetCharSequence(Charset charset) {
    //     ByteBuf buf = newBuffer(1024);
    //     CharBuffer sequence = CharsetUtil.US_ASCII == charset
    //             ? ASCII_CHARS : EXTENDED_ASCII_CHARS;
    //     int bytes = buf.setCharSequence(1, sequence, charset);
    //     assertEquals(sequence, CharBuffer.wrap(buf.getCharSequence(1, bytes, charset)));
    //     buf.release();
    // }

    // @Test
    // void testWriteReadUsAsciiCharSequence() {
    //     testWriteReadCharSequence(CharsetUtil.US_ASCII);
    // }

    // @Test
    // void testWriteReadUtf8CharSequence() {
    //     testWriteReadCharSequence(CharsetUtil.UTF_8);
    // }

    // @Test
    // void testWriteReadIso88591CharSequence() {
    //     testWriteReadCharSequence(CharsetUtil.ISO_8859_1);
    // }

    // @Test
    // void testWriteReadUtf16CharSequence() {
    //     testWriteReadCharSequence(CharsetUtil.UTF_16);
    // }

    // private void testWriteReadCharSequence(Charset charset) {
    //     ByteBuf buf = newBuffer(1024);
    //     CharBuffer sequence = CharsetUtil.US_ASCII == charset
    //             ? ASCII_CHARS : EXTENDED_ASCII_CHARS;
    //     buf.writerIndex(1);
    //     int bytes = buf.writeCharSequence(sequence, charset);
    //     buf.readerIndex(1);
    //     assertEquals(sequence, CharBuffer.wrap(buf.readCharSequence(bytes, charset)));
    //     buf.release();
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testRetainedSliceIndexOutOfBounds() {
    //     testSliceOutOfBounds(true, true, true);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testRetainedSliceLengthOutOfBounds() {
    //     testSliceOutOfBounds(true, true, false);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testMixedSliceAIndexOutOfBounds() {
    //     testSliceOutOfBounds(true, false, true);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testMixedSliceALengthOutOfBounds() {
    //     testSliceOutOfBounds(true, false, false);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testMixedSliceBIndexOutOfBounds() {
    //     testSliceOutOfBounds(false, true, true);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testMixedSliceBLengthOutOfBounds() {
    //     testSliceOutOfBounds(false, true, false);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testSliceIndexOutOfBounds() {
    //     testSliceOutOfBounds(false, false, true);
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testSliceLengthOutOfBounds() {
    //     testSliceOutOfBounds(false, false, false);
    // }

    // @Test
    // void testRetainedSliceAndRetainedDuplicateContentIsExpected() {
    //     ByteBuf buf = newBuffer(8).resetWriterIndex();
    //     ByteBuf expected1 = newBuffer(6).resetWriterIndex();
    //     ByteBuf expected2 = newBuffer(5).resetWriterIndex();
    //     ByteBuf expected3 = newBuffer(4).resetWriterIndex();
    //     ByteBuf expected4 = newBuffer(3).resetWriterIndex();
    //     buf.writeBytes(new byte[] {1, 2, 3, 4, 5, 6, 7, 8});
    //     expected1.writeBytes(new byte[] {2, 3, 4, 5, 6, 7});
    //     expected2.writeBytes(new byte[] {3, 4, 5, 6, 7});
    //     expected3.writeBytes(new byte[] {4, 5, 6, 7});
    //     expected4.writeBytes(new byte[] {5, 6, 7});

    //     ByteBuf slice1 = buf.retainedSlice(buf.readerIndex() + 1, 6);
    //     assertEquals(0, slice1.compareTo(expected1));
    //     assertEquals(0, slice1.compareTo(buf.slice(buf.readerIndex() + 1, 6)));
    //     // Simulate a handler that releases the original buffer, and propagates a slice.
    //     buf.release();

    //     // Advance the reader index on the slice.
    //     slice1.readByte();

    //     ByteBuf dup1 = slice1.retainedDuplicate();
    //     assertEquals(0, dup1.compareTo(expected2));
    //     assertEquals(0, dup1.compareTo(slice1.duplicate()));

    //     // Advance the reader index on dup1.
    //     dup1.readByte();

    //     ByteBuf dup2 = dup1.duplicate();
    //     assertEquals(0, dup2.compareTo(expected3));

    //     // Advance the reader index on dup2.
    //     dup2.readByte();

    //     ByteBuf slice2 = dup2.retainedSlice(dup2.readerIndex(), 3);
    //     assertEquals(0, slice2.compareTo(expected4));
    //     assertEquals(0, slice2.compareTo(dup2.slice(dup2.readerIndex(), 3)));

    //     // Cleanup the expected buffers used for testing.
    //     assertTrue(expected1.release());
    //     assertTrue(expected2.release());
    //     assertTrue(expected3.release());
    //     assertTrue(expected4.release());

    //     slice2.release();
    //     dup2.release();

    //     assertEquals(slice2.refCnt(), dup2.refCnt());
    //     assertEquals(dup2.refCnt(), dup1.refCnt());

    //     // The handler is now done with the original slice
    //     assertTrue(slice1.release());

    //     // Reference counting may be shared, or may be independently tracked, but at this point all buffers should
    //     // be deallocated and have a reference count of 0.
    //     assertEquals(0, buf.refCnt());
    //     assertEquals(0, slice1.refCnt());
    //     assertEquals(0, slice2.refCnt());
    //     assertEquals(0, dup1.refCnt());
    //     assertEquals(0, dup2.refCnt());
    // }

    // @Test
    // void testRetainedDuplicateAndRetainedSliceContentIsExpected() {
    //     ByteBuf buf = newBuffer(8).resetWriterIndex();
    //     ByteBuf expected1 = newBuffer(6).resetWriterIndex();
    //     ByteBuf expected2 = newBuffer(5).resetWriterIndex();
    //     ByteBuf expected3 = newBuffer(4).resetWriterIndex();
    //     buf.writeBytes(new byte[] {1, 2, 3, 4, 5, 6, 7, 8});
    //     expected1.writeBytes(new byte[] {2, 3, 4, 5, 6, 7});
    //     expected2.writeBytes(new byte[] {3, 4, 5, 6, 7});
    //     expected3.writeBytes(new byte[] {5, 6, 7});

    //     ByteBuf dup1 = buf.retainedDuplicate();
    //     assertEquals(0, dup1.compareTo(buf));
    //     assertEquals(0, dup1.compareTo(buf.slice()));
    //     // Simulate a handler that releases the original buffer, and propagates a slice.
    //     buf.release();

    //     // Advance the reader index on the dup.
    //     dup1.readByte();

    //     ByteBuf slice1 = dup1.retainedSlice(dup1.readerIndex(), 6);
    //     assertEquals(0, slice1.compareTo(expected1));
    //     assertEquals(0, slice1.compareTo(slice1.duplicate()));

    //     // Advance the reader index on slice1.
    //     slice1.readByte();

    //     ByteBuf dup2 = slice1.duplicate();
    //     assertEquals(0, dup2.compareTo(slice1));

    //     // Advance the reader index on dup2.
    //     dup2.readByte();

    //     ByteBuf slice2 = dup2.retainedSlice(dup2.readerIndex() + 1, 3);
    //     assertEquals(0, slice2.compareTo(expected3));
    //     assertEquals(0, slice2.compareTo(dup2.slice(dup2.readerIndex() + 1, 3)));

    //     // Cleanup the expected buffers used for testing.
    //     assertTrue(expected1.release());
    //     assertTrue(expected2.release());
    //     assertTrue(expected3.release());

    //     slice2.release();
    //     slice1.release();

    //     assertEquals(slice2.refCnt(), dup2.refCnt());
    //     assertEquals(dup2.refCnt(), slice1.refCnt());

    //     // The handler is now done with the original slice
    //     assertTrue(dup1.release());

    //     // Reference counting may be shared, or may be independently tracked, but at this point all buffers should
    //     // be deallocated and have a reference count of 0.
    //     assertEquals(0, buf.refCnt());
    //     assertEquals(0, slice1.refCnt());
    //     assertEquals(0, slice2.refCnt());
    //     assertEquals(0, dup1.refCnt());
    //     assertEquals(0, dup2.refCnt());
    // }

    // @Test
    // void testRetainedSliceContents() {
    //     testSliceContents(true);
    // }

    // @Test
    // void testMultipleLevelRetainedSlice1() {
    //     testMultipleLevelRetainedSliceWithNonRetained(true, true);
    // }

    // @Test
    // void testMultipleLevelRetainedSlice2() {
    //     testMultipleLevelRetainedSliceWithNonRetained(true, false);
    // }

    // @Test
    // void testMultipleLevelRetainedSlice3() {
    //     testMultipleLevelRetainedSliceWithNonRetained(false, true);
    // }

    // @Test
    // void testMultipleLevelRetainedSlice4() {
    //     testMultipleLevelRetainedSliceWithNonRetained(false, false);
    // }

    // @Test
    // void testRetainedSliceReleaseOriginal1() {
    //     testSliceReleaseOriginal(true, true);
    // }

    // @Test
    // void testRetainedSliceReleaseOriginal2() {
    //     testSliceReleaseOriginal(true, false);
    // }

    // @Test
    // void testRetainedSliceReleaseOriginal3() {
    //     testSliceReleaseOriginal(false, true);
    // }

    // @Test
    // void testRetainedSliceReleaseOriginal4() {
    //     testSliceReleaseOriginal(false, false);
    // }

    // @Test
    // void testRetainedDuplicateReleaseOriginal1() {
    //     testDuplicateReleaseOriginal(true, true);
    // }

    // @Test
    // void testRetainedDuplicateReleaseOriginal2() {
    //     testDuplicateReleaseOriginal(true, false);
    // }

    // @Test
    // void testRetainedDuplicateReleaseOriginal3() {
    //     testDuplicateReleaseOriginal(false, true);
    // }

    // @Test
    // void testRetainedDuplicateReleaseOriginal4() {
    //     testDuplicateReleaseOriginal(false, false);
    // }

    // @Test
    // void testMultipleRetainedSliceReleaseOriginal1() {
    //     testMultipleRetainedSliceReleaseOriginal(true, true);
    // }

    // @Test
    // void testMultipleRetainedSliceReleaseOriginal2() {
    //     testMultipleRetainedSliceReleaseOriginal(true, false);
    // }

    // @Test
    // void testMultipleRetainedSliceReleaseOriginal3() {
    //     testMultipleRetainedSliceReleaseOriginal(false, true);
    // }

    // @Test
    // void testMultipleRetainedSliceReleaseOriginal4() {
    //     testMultipleRetainedSliceReleaseOriginal(false, false);
    // }

    // @Test
    // void testMultipleRetainedDuplicateReleaseOriginal1() {
    //     testMultipleRetainedDuplicateReleaseOriginal(true, true);
    // }

    // @Test
    // void testMultipleRetainedDuplicateReleaseOriginal2() {
    //     testMultipleRetainedDuplicateReleaseOriginal(true, false);
    // }

    // @Test
    // void testMultipleRetainedDuplicateReleaseOriginal3() {
    //     testMultipleRetainedDuplicateReleaseOriginal(false, true);
    // }

    // @Test
    // void testMultipleRetainedDuplicateReleaseOriginal4() {
    //     testMultipleRetainedDuplicateReleaseOriginal(false, false);
    // }

    // @Test
    // void testSliceContents() {
    //     testSliceContents(false);
    // }

    // @Test
    // void testRetainedDuplicateContents() {
    //     testDuplicateContents(true);
    // }

    // @Test
    // void testDuplicateContents() {
    //     testDuplicateContents(false);
    // }

    // @Test
    // void testDuplicateCapacityChange() {
    //     testDuplicateCapacityChange(false);
    // }

    // @Test
    // void testRetainedDuplicateCapacityChange() {
    //     testDuplicateCapacityChange(true);
    // }

    // @Test(expected = UnsupportedOperationException.class)
    // void testSliceCapacityChange() {
    //     testSliceCapacityChange(false);
    // }

    // @Test(expected = UnsupportedOperationException.class)
    // void testRetainedSliceCapacityChange() {
    //     testSliceCapacityChange(true);
    // }

    // @Test
    // void testRetainedSliceUnreleasable1() {
    //     testRetainedSliceUnreleasable(true, true);
    // }

    // @Test
    // void testRetainedSliceUnreleasable2() {
    //     testRetainedSliceUnreleasable(true, false);
    // }

    // @Test
    // void testRetainedSliceUnreleasable3() {
    //     testRetainedSliceUnreleasable(false, true);
    // }

    // @Test
    // void testRetainedSliceUnreleasable4() {
    //     testRetainedSliceUnreleasable(false, false);
    // }

    // @Test
    // void testReadRetainedSliceUnreleasable1() {
    //     testReadRetainedSliceUnreleasable(true, true);
    // }

    // @Test
    // void testReadRetainedSliceUnreleasable2() {
    //     testReadRetainedSliceUnreleasable(true, false);
    // }

    // @Test
    // void testReadRetainedSliceUnreleasable3() {
    //     testReadRetainedSliceUnreleasable(false, true);
    // }

    // @Test
    // void testReadRetainedSliceUnreleasable4() {
    //     testReadRetainedSliceUnreleasable(false, false);
    // }

    // @Test
    // void testRetainedDuplicateUnreleasable1() {
    //     testRetainedDuplicateUnreleasable(true, true);
    // }

    // @Test
    // void testRetainedDuplicateUnreleasable2() {
    //     testRetainedDuplicateUnreleasable(true, false);
    // }

    // @Test
    // void testRetainedDuplicateUnreleasable3() {
    //     testRetainedDuplicateUnreleasable(false, true);
    // }

    // @Test
    // void testRetainedDuplicateUnreleasable4() {
    //     testRetainedDuplicateUnreleasable(false, false);
    // }

    // private void testRetainedSliceUnreleasable(boolean initRetainedSlice, boolean finalRetainedSlice) {
    //     ByteBuf buf = newBuffer(8);
    //     ByteBuf buf1 = initRetainedSlice ? buf.retainedSlice() : buf.slice().retain();
    //     ByteBuf buf2 = unreleasableBuffer(buf1);
    //     ByteBuf buf3 = finalRetainedSlice ? buf2.retainedSlice() : buf2.slice().retain();
    //     assertFalse(buf3.release());
    //     assertFalse(buf2.release());
    //     buf1.release();
    //     assertTrue(buf.release());
    //     assertEquals(0, buf1.refCnt());
    //     assertEquals(0, buf.refCnt());
    // }

    // private void testReadRetainedSliceUnreleasable(boolean initRetainedSlice, boolean finalRetainedSlice) {
    //     ByteBuf buf = newBuffer(8);
    //     ByteBuf buf1 = initRetainedSlice ? buf.retainedSlice() : buf.slice().retain();
    //     ByteBuf buf2 = unreleasableBuffer(buf1);
    //     ByteBuf buf3 = finalRetainedSlice ? buf2.readRetainedSlice(buf2.readableBytes())
    //                                       : buf2.readSlice(buf2.readableBytes()).retain();
    //     assertFalse(buf3.release());
    //     assertFalse(buf2.release());
    //     buf1.release();
    //     assertTrue(buf.release());
    //     assertEquals(0, buf1.refCnt());
    //     assertEquals(0, buf.refCnt());
    // }

    // private void testRetainedDuplicateUnreleasable(boolean initRetainedDuplicate, boolean finalRetainedDuplicate) {
    //     ByteBuf buf = newBuffer(8);
    //     ByteBuf buf1 = initRetainedDuplicate ? buf.retainedDuplicate() : buf.duplicate().retain();
    //     ByteBuf buf2 = unreleasableBuffer(buf1);
    //     ByteBuf buf3 = finalRetainedDuplicate ? buf2.retainedDuplicate() : buf2.duplicate().retain();
    //     assertFalse(buf3.release());
    //     assertFalse(buf2.release());
    //     buf1.release();
    //     assertTrue(buf.release());
    //     assertEquals(0, buf1.refCnt());
    //     assertEquals(0, buf.refCnt());
    // }

    // private void testDuplicateCapacityChange(boolean retainedDuplicate) {
    //     ByteBuf buf = newBuffer(8);
    //     ByteBuf dup = retainedDuplicate ? buf.retainedDuplicate() : buf.duplicate();
    //     try {
    //         dup.capacity(10);
    //         assertEquals(buf.capacity(), dup.capacity());
    //         dup.capacity(5);
    //         assertEquals(buf.capacity(), dup.capacity());
    //     } finally {
    //         if (retainedDuplicate) {
    //             dup.release();
    //         }
    //         buf.release();
    //     }
    // }

    // private void testSliceCapacityChange(boolean retainedSlice) {
    //     ByteBuf buf = newBuffer(8);
    //     ByteBuf slice = retainedSlice ? buf.retainedSlice(buf.readerIndex() + 1, 3)
    //                                   : buf.slice(buf.readerIndex() + 1, 3);
    //     try {
    //         slice.capacity(10);
    //     } finally {
    //         if (retainedSlice) {
    //             slice.release();
    //         }
    //         buf.release();
    //     }
    // }

    // private void testSliceOutOfBounds(boolean initRetainedSlice, boolean finalRetainedSlice, boolean indexOutOfBounds) {
    //     ByteBuf buf = newBuffer(8);
    //     ByteBuf slice = initRetainedSlice ? buf.retainedSlice(buf.readerIndex() + 1, 2)
    //                                       : buf.slice(buf.readerIndex() + 1, 2);
    //     try {
    //         assertEquals(2, slice.capacity());
    //         assertEquals(2, slice.maxCapacity());
    //         final int index = indexOutOfBounds ? 3 : 0;
    //         final int length = indexOutOfBounds ? 0 : 3;
    //         if (finalRetainedSlice) {
    //             // This is expected to fail ... so no need to release.
    //             slice.retainedSlice(index, length);
    //         } else {
    //             slice.slice(index, length);
    //         }
    //     } finally {
    //         if (initRetainedSlice) {
    //             slice.release();
    //         }
    //         buf.release();
    //     }
    // }

    // private void testSliceContents(boolean retainedSlice) {
    //     ByteBuf buf = newBuffer(8).resetWriterIndex();
    //     ByteBuf expected = newBuffer(3).resetWriterIndex();
    //     buf.writeBytes(new byte[] {1, 2, 3, 4, 5, 6, 7, 8});
    //     expected.writeBytes(new byte[] {4, 5, 6});
    //     ByteBuf slice = retainedSlice ? buf.retainedSlice(buf.readerIndex() + 3, 3)
    //                                   : buf.slice(buf.readerIndex() + 3, 3);
    //     try {
    //         assertEquals(0, slice.compareTo(expected));
    //         assertEquals(0, slice.compareTo(slice.duplicate()));
    //         ByteBuf b = slice.retainedDuplicate();
    //         assertEquals(0, slice.compareTo(b));
    //         b.release();
    //         assertEquals(0, slice.compareTo(slice.slice(0, slice.capacity())));
    //     } finally {
    //         if (retainedSlice) {
    //             slice.release();
    //         }
    //         buf.release();
    //         expected.release();
    //     }
    // }

    // private void testSliceReleaseOriginal(boolean retainedSlice1, boolean retainedSlice2) {
    //     ByteBuf buf = newBuffer(8).resetWriterIndex();
    //     ByteBuf expected1 = newBuffer(3).resetWriterIndex();
    //     ByteBuf expected2 = newBuffer(2).resetWriterIndex();
    //     buf.writeBytes(new byte[] {1, 2, 3, 4, 5, 6, 7, 8});
    //     expected1.writeBytes(new byte[] {6, 7, 8});
    //     expected2.writeBytes(new byte[] {7, 8});
    //     ByteBuf slice1 = retainedSlice1 ? buf.retainedSlice(buf.readerIndex() + 5, 3)
    //                                     : buf.slice(buf.readerIndex() + 5, 3).retain();
    //     assertEquals(0, slice1.compareTo(expected1));
    //     // Simulate a handler that releases the original buffer, and propagates a slice.
    //     buf.release();

    //     ByteBuf slice2 = retainedSlice2 ? slice1.retainedSlice(slice1.readerIndex() + 1, 2)
    //                                     : slice1.slice(slice1.readerIndex() + 1, 2).retain();
    //     assertEquals(0, slice2.compareTo(expected2));

    //     // Cleanup the expected buffers used for testing.
    //     assertTrue(expected1.release());
    //     assertTrue(expected2.release());

    //     // The handler created a slice of the slice and is now done with it.
    //     slice2.release();

    //     // The handler is now done with the original slice
    //     assertTrue(slice1.release());

    //     // Reference counting may be shared, or may be independently tracked, but at this point all buffers should
    //     // be deallocated and have a reference count of 0.
    //     assertEquals(0, buf.refCnt());
    //     assertEquals(0, slice1.refCnt());
    //     assertEquals(0, slice2.refCnt());
    // }

    // private void testMultipleLevelRetainedSliceWithNonRetained(boolean doSlice1, boolean doSlice2) {
    //     ByteBuf buf = newBuffer(8).resetWriterIndex();
    //     ByteBuf expected1 = newBuffer(6).resetWriterIndex();
    //     ByteBuf expected2 = newBuffer(4).resetWriterIndex();
    //     ByteBuf expected3 = newBuffer(2).resetWriterIndex();
    //     ByteBuf expected4SliceSlice = newBuffer(1).resetWriterIndex();
    //     ByteBuf expected4DupSlice = newBuffer(1).resetWriterIndex();
    //     buf.writeBytes(new byte[] {1, 2, 3, 4, 5, 6, 7, 8});
    //     expected1.writeBytes(new byte[] {2, 3, 4, 5, 6, 7});
    //     expected2.writeBytes(new byte[] {3, 4, 5, 6});
    //     expected3.writeBytes(new byte[] {4, 5});
    //     expected4SliceSlice.writeBytes(new byte[] {5});
    //     expected4DupSlice.writeBytes(new byte[] {4});

    //     ByteBuf slice1 = buf.retainedSlice(buf.readerIndex() + 1, 6);
    //     assertEquals(0, slice1.compareTo(expected1));
    //     // Simulate a handler that releases the original buffer, and propagates a slice.
    //     buf.release();

    //     ByteBuf slice2 = slice1.retainedSlice(slice1.readerIndex() + 1, 4);
    //     assertEquals(0, slice2.compareTo(expected2));
    //     assertEquals(0, slice2.compareTo(slice2.duplicate()));
    //     assertEquals(0, slice2.compareTo(slice2.slice()));

    //     ByteBuf tmpBuf = slice2.retainedDuplicate();
    //     assertEquals(0, slice2.compareTo(tmpBuf));
    //     tmpBuf.release();
    //     tmpBuf = slice2.retainedSlice();
    //     assertEquals(0, slice2.compareTo(tmpBuf));
    //     tmpBuf.release();

    //     ByteBuf slice3 = doSlice1 ? slice2.slice(slice2.readerIndex() + 1, 2) : slice2.duplicate();
    //     if (doSlice1) {
    //         assertEquals(0, slice3.compareTo(expected3));
    //     } else {
    //         assertEquals(0, slice3.compareTo(expected2));
    //     }

    //     ByteBuf slice4 = doSlice2 ? slice3.slice(slice3.readerIndex() + 1, 1) : slice3.duplicate();
    //     if (doSlice1 && doSlice2) {
    //         assertEquals(0, slice4.compareTo(expected4SliceSlice));
    //     } else if (doSlice2) {
    //         assertEquals(0, slice4.compareTo(expected4DupSlice));
    //     } else {
    //         assertEquals(0, slice3.compareTo(slice4));
    //     }

    //     // Cleanup the expected buffers used for testing.
    //     assertTrue(expected1.release());
    //     assertTrue(expected2.release());
    //     assertTrue(expected3.release());
    //     assertTrue(expected4SliceSlice.release());
    //     assertTrue(expected4DupSlice.release());

    //     // Slice 4, 3, and 2 should effectively "share" ~a reference count.
    //     slice4.release();
    //     assertEquals(slice3.refCnt(), slice2.refCnt());
    //     assertEquals(slice3.refCnt(), slice4.refCnt());

    //     // Slice 1 should also release the original underlying buffer without throwing exceptions
    //     assertTrue(slice1.release());

    //     // Reference counting may be shared, or may be independently tracked, but at this point all buffers should
    //     // be deallocated and have a reference count of 0.
    //     assertEquals(0, buf.refCnt());
    //     assertEquals(0, slice1.refCnt());
    //     assertEquals(0, slice2.refCnt());
    //     assertEquals(0, slice3.refCnt());
    // }

    // private void testDuplicateReleaseOriginal(boolean retainedDuplicate1, boolean retainedDuplicate2) {
    //     ByteBuf buf = newBuffer(8).resetWriterIndex();
    //     ByteBuf expected = newBuffer(8).resetWriterIndex();
    //     buf.writeBytes(new byte[] {1, 2, 3, 4, 5, 6, 7, 8});
    //     expected.writeBytes(buf, buf.readerIndex(), buf.readableBytes());
    //     ByteBuf dup1 = retainedDuplicate1 ? buf.retainedDuplicate()
    //                                       : buf.duplicate().retain();
    //     assertEquals(0, dup1.compareTo(expected));
    //     // Simulate a handler that releases the original buffer, and propagates a slice.
    //     buf.release();

    //     ByteBuf dup2 = retainedDuplicate2 ? dup1.retainedDuplicate()
    //                                       : dup1.duplicate().retain();
    //     assertEquals(0, dup2.compareTo(expected));

    //     // Cleanup the expected buffers used for testing.
    //     assertTrue(expected.release());

    //     // The handler created a slice of the slice and is now done with it.
    //     dup2.release();

    //     // The handler is now done with the original slice
    //     assertTrue(dup1.release());

    //     // Reference counting may be shared, or may be independently tracked, but at this point all buffers should
    //     // be deallocated and have a reference count of 0.
    //     assertEquals(0, buf.refCnt());
    //     assertEquals(0, dup1.refCnt());
    //     assertEquals(0, dup2.refCnt());
    // }

    // private void testMultipleRetainedSliceReleaseOriginal(boolean retainedSlice1, boolean retainedSlice2) {
    //     ByteBuf buf = newBuffer(8).resetWriterIndex();
    //     ByteBuf expected1 = newBuffer(3).resetWriterIndex();
    //     ByteBuf expected2 = newBuffer(2).resetWriterIndex();
    //     ByteBuf expected3 = newBuffer(2).resetWriterIndex();
    //     buf.writeBytes(new byte[] {1, 2, 3, 4, 5, 6, 7, 8});
    //     expected1.writeBytes(new byte[] {6, 7, 8});
    //     expected2.writeBytes(new byte[] {7, 8});
    //     expected3.writeBytes(new byte[] {6, 7});
    //     ByteBuf slice1 = retainedSlice1 ? buf.retainedSlice(buf.readerIndex() + 5, 3)
    //                                     : buf.slice(buf.readerIndex() + 5, 3).retain();
    //     assertEquals(0, slice1.compareTo(expected1));
    //     // Simulate a handler that releases the original buffer, and propagates a slice.
    //     buf.release();

    //     ByteBuf slice2 = retainedSlice2 ? slice1.retainedSlice(slice1.readerIndex() + 1, 2)
    //                                     : slice1.slice(slice1.readerIndex() + 1, 2).retain();
    //     assertEquals(0, slice2.compareTo(expected2));

    //     // The handler created a slice of the slice and is now done with it.
    //     slice2.release();

    //     ByteBuf slice3 = slice1.retainedSlice(slice1.readerIndex(), 2);
    //     assertEquals(0, slice3.compareTo(expected3));

    //     // The handler created another slice of the slice and is now done with it.
    //     slice3.release();

    //     // The handler is now done with the original slice
    //     assertTrue(slice1.release());

    //     // Cleanup the expected buffers used for testing.
    //     assertTrue(expected1.release());
    //     assertTrue(expected2.release());
    //     assertTrue(expected3.release());

    //     // Reference counting may be shared, or may be independently tracked, but at this point all buffers should
    //     // be deallocated and have a reference count of 0.
    //     assertEquals(0, buf.refCnt());
    //     assertEquals(0, slice1.refCnt());
    //     assertEquals(0, slice2.refCnt());
    //     assertEquals(0, slice3.refCnt());
    // }

    // private void testMultipleRetainedDuplicateReleaseOriginal(boolean retainedDuplicate1, boolean retainedDuplicate2) {
    //     ByteBuf buf = newBuffer(8).resetWriterIndex();
    //     ByteBuf expected = newBuffer(8).resetWriterIndex();
    //     buf.writeBytes(new byte[] {1, 2, 3, 4, 5, 6, 7, 8});
    //     expected.writeBytes(buf, buf.readerIndex(), buf.readableBytes());
    //     ByteBuf dup1 = retainedDuplicate1 ? buf.retainedDuplicate()
    //                                       : buf.duplicate().retain();
    //     assertEquals(0, dup1.compareTo(expected));
    //     // Simulate a handler that releases the original buffer, and propagates a slice.
    //     buf.release();

    //     ByteBuf dup2 = retainedDuplicate2 ? dup1.retainedDuplicate()
    //                                       : dup1.duplicate().retain();
    //     assertEquals(0, dup2.compareTo(expected));
    //     assertEquals(0, dup2.compareTo(dup2.duplicate()));
    //     assertEquals(0, dup2.compareTo(dup2.slice()));

    //     ByteBuf tmpBuf = dup2.retainedDuplicate();
    //     assertEquals(0, dup2.compareTo(tmpBuf));
    //     tmpBuf.release();
    //     tmpBuf = dup2.retainedSlice();
    //     assertEquals(0, dup2.compareTo(tmpBuf));
    //     tmpBuf.release();

    //     // The handler created a slice of the slice and is now done with it.
    //     dup2.release();

    //     ByteBuf dup3 = dup1.retainedDuplicate();
    //     assertEquals(0, dup3.compareTo(expected));

    //     // The handler created another slice of the slice and is now done with it.
    //     dup3.release();

    //     // The handler is now done with the original slice
    //     assertTrue(dup1.release());

    //     // Cleanup the expected buffers used for testing.
    //     assertTrue(expected.release());

    //     // Reference counting may be shared, or may be independently tracked, but at this point all buffers should
    //     // be deallocated and have a reference count of 0.
    //     assertEquals(0, buf.refCnt());
    //     assertEquals(0, dup1.refCnt());
    //     assertEquals(0, dup2.refCnt());
    //     assertEquals(0, dup3.refCnt());
    // }

    // private void testDuplicateContents(boolean retainedDuplicate) {
    //     ByteBuf buf = newBuffer(8).resetWriterIndex();
    //     buf.writeBytes(new byte[] {1, 2, 3, 4, 5, 6, 7, 8});
    //     ByteBuf dup = retainedDuplicate ? buf.retainedDuplicate() : buf.duplicate();
    //     try {
    //         assertEquals(0, dup.compareTo(buf));
    //         assertEquals(0, dup.compareTo(dup.duplicate()));
    //         ByteBuf b = dup.retainedDuplicate();
    //         assertEquals(0, dup.compareTo(b));
    //         b.release();
    //         assertEquals(0, dup.compareTo(dup.slice(dup.readerIndex(), dup.readableBytes())));
    //     } finally {
    //         if (retainedDuplicate) {
    //             dup.release();
    //         }
    //         buf.release();
    //     }
    // }

    // @Test
    // void testDuplicateRelease() {
    //     ByteBuf buf = newBuffer(8);
    //     assertEquals(1, buf.refCnt());
    //     assertTrue(buf.duplicate().release());
    //     assertEquals(0, buf.refCnt());
    // }

    // // Test-case trying to reproduce:
    // // https://github.com/netty/netty/issues/2843
    // @Test
    // void testRefCnt() {
    //     testRefCnt0(false);
    // }

    // // Test-case trying to reproduce:
    // // https://github.com/netty/netty/issues/2843
    // @Test
    // void testRefCnt2() {
    //     testRefCnt0(true);
    // }

    // @Test
    // void testEmptyNioBuffers() {
    //     ByteBuf buffer = newBuffer(8);
    //     buffer.clear();
    //     assertFalse(buffer.isReadable());
    //     ByteBuffer[] nioBuffers = buffer.nioBuffers();
    //     assertEquals(1, nioBuffers.length);
    //     assertFalse(nioBuffers[0].hasRemaining());
    //     buffer.release();
    // }

    // @Test
    // void testGetReadOnlyDirectDst() {
    //     testGetReadOnlyDst(true);
    // }

    // @Test
    // void testGetReadOnlyHeapDst() {
    //     testGetReadOnlyDst(false);
    // }

    // private void testGetReadOnlyDst(boolean direct) {
    //     byte[] bytes = { 'a', 'b', 'c', 'd' };

    //     ByteBuf buffer = newBuffer(bytes.length);
    //     buffer.writeBytes(bytes);

    //     ByteBuffer dst = direct ? ByteBuffer.allocateDirect(bytes.length) : ByteBuffer.allocate(bytes.length);
    //     ByteBuffer readOnlyDst = dst.asReadOnlyBuffer();
    //     try {
    //         buffer.getBytes(0, readOnlyDst);
    //         fail();
    //     } catch (ReadOnlyBufferException e) {
    //         // expected
    //     }
    //     assertEquals(0, readOnlyDst.position());
    //     buffer.release();
    // }

    // @Test
    // void testReadBytesAndWriteBytesWithFileChannel() {
    //     File file = File.createTempFile("file-channel", ".tmp");
    //     RandomAccessFile randomAccessFile = null;
    //     try {
    //         randomAccessFile = new RandomAccessFile(file, "rw");
    //         FileChannel channel = randomAccessFile.getChannel();
    //         // channelPosition should never be changed
    //         long channelPosition = channel.position();

    //         byte[] bytes = {'a', 'b', 'c', 'd'};
    //         int len = bytes.length;
    //         ByteBuf buffer = newBuffer(len);
    //         buffer.resetReaderIndex();
    //         buffer.resetWriterIndex();
    //         buffer.writeBytes(bytes);

    //         int oldReaderIndex = buffer.readerIndex();
    //         assertEquals(len, buffer.readBytes(channel, 10, len));
    //         assertEquals(oldReaderIndex + len, buffer.readerIndex());
    //         assertEquals(channelPosition, channel.position());

    //         ByteBuf buffer2 = newBuffer(len);
    //         buffer2.resetReaderIndex();
    //         buffer2.resetWriterIndex();
    //         int oldWriterIndex = buffer2.writerIndex();
    //         assertEquals(len, buffer2.writeBytes(channel, 10, len));
    //         assertEquals(channelPosition, channel.position());
    //         assertEquals(oldWriterIndex + len, buffer2.writerIndex());
    //         assertEquals('a', buffer2.getByte(0));
    //         assertEquals('b', buffer2.getByte(1));
    //         assertEquals('c', buffer2.getByte(2));
    //         assertEquals('d', buffer2.getByte(3));
    //         buffer.release();
    //         buffer2.release();
    //     } finally {
    //         if (randomAccessFile !is null) {
    //             randomAccessFile.close();
    //         }
    //         file.delete();
    //     }
    // }

    // @Test
    // void testGetBytesAndSetBytesWithFileChannel() {
    //     File file = File.createTempFile("file-channel", ".tmp");
    //     RandomAccessFile randomAccessFile = null;
    //     try {
    //         randomAccessFile = new RandomAccessFile(file, "rw");
    //         FileChannel channel = randomAccessFile.getChannel();
    //         // channelPosition should never be changed
    //         long channelPosition = channel.position();

    //         byte[] bytes = {'a', 'b', 'c', 'd'};
    //         int len = bytes.length;
    //         ByteBuf buffer = newBuffer(len);
    //         buffer.resetReaderIndex();
    //         buffer.resetWriterIndex();
    //         buffer.writeBytes(bytes);

    //         int oldReaderIndex = buffer.readerIndex();
    //         assertEquals(len, buffer.getBytes(oldReaderIndex, channel, 10, len));
    //         assertEquals(oldReaderIndex, buffer.readerIndex());
    //         assertEquals(channelPosition, channel.position());

    //         ByteBuf buffer2 = newBuffer(len);
    //         buffer2.resetReaderIndex();
    //         buffer2.resetWriterIndex();
    //         int oldWriterIndex = buffer2.writerIndex();
    //         assertEquals(buffer2.setBytes(oldWriterIndex, channel, 10, len), len);
    //         assertEquals(channelPosition, channel.position());

    //         assertEquals(oldWriterIndex, buffer2.writerIndex());
    //         assertEquals('a', buffer2.getByte(oldWriterIndex));
    //         assertEquals('b', buffer2.getByte(oldWriterIndex + 1));
    //         assertEquals('c', buffer2.getByte(oldWriterIndex + 2));
    //         assertEquals('d', buffer2.getByte(oldWriterIndex + 3));

    //         buffer.release();
    //         buffer2.release();
    //     } finally {
    //         if (randomAccessFile !is null) {
    //             randomAccessFile.close();
    //         }
    //         file.delete();
    //     }
    // }

    // @Test
    // void testReadBytes() {
    //     ByteBuf buffer = newBuffer(8);
    //     byte[] bytes = new byte[8];
    //     buffer.writeBytes(bytes);

    //     ByteBuf buffer2 = buffer.readBytes(4);
    //     assertSame(buffer.alloc(), buffer2.alloc());
    //     assertEquals(4, buffer.readerIndex());
    //     assertTrue(buffer.release());
    //     assertEquals(0, buffer.refCnt());
    //     assertTrue(buffer2.release());
    //     assertEquals(0, buffer2.refCnt());
    // }

    // @Test
    // void testForEachByteDesc2() {
    //     byte[] expected = {1, 2, 3, 4};
    //     ByteBuf buf = newBuffer(expected.length);
    //     try {
    //         buf.writeBytes(expected);
    //         final byte[] bytes = new byte[expected.length];
    //         int i = buf.forEachByteDesc(new ByteProcessor() {
    //             private int index = bytes.length - 1;

    //             override
    //             boolean process(byte value) {
    //                 bytes[index--] = value;
    //                 return true;
    //             }
    //         });
    //         assertEquals(-1, i);
    //         assertArrayEquals(expected, bytes);
    //     } finally {
    //         buf.release();
    //     }
    // }

    // @Test
    // void testForEachByte2() {
    //     byte[] expected = {1, 2, 3, 4};
    //     ByteBuf buf = newBuffer(expected.length);
    //     try {
    //         buf.writeBytes(expected);
    //         final byte[] bytes = new byte[expected.length];
    //         int i = buf.forEachByte(new ByteProcessor() {
    //             private int index;

    //             override
    //             boolean process(byte value) {
    //                 bytes[index++] = value;
    //                 return true;
    //             }
    //         });
    //         assertEquals(-1, i);
    //         assertArrayEquals(expected, bytes);
    //     } finally {
    //         buf.release();
    //     }
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testGetBytesByteBuffer() {
    //     byte[] bytes = {'a', 'b', 'c', 'd', 'e', 'f', 'g'};
    //     // Ensure destination buffer is bigger then what is in the ByteBuf.
    //     ByteBuffer nioBuffer = ByteBuffer.allocate(bytes.length + 1);
    //     ByteBuf buffer = newBuffer(bytes.length);
    //     try {
    //         buffer.writeBytes(bytes);
    //         buffer.getBytes(buffer.readerIndex(), nioBuffer);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // private void testRefCnt0(final boolean parameter) {
    //     for (int i = 0; i < 10; i++) {
    //         final CountDownLatch latch = new CountDownLatch(1);
    //         final CountDownLatch innerLatch = new CountDownLatch(1);

    //         final ByteBuf buffer = newBuffer(4);
    //         assertEquals(1, buffer.refCnt());
    //         final AtomicInteger cnt = new AtomicInteger(int.max);
    //         Thread t1 = new Thread(new Runnable() {
    //             override
    //             void run() {
    //                 boolean released;
    //                 if (parameter) {
    //                     released = buffer.release(buffer.refCnt());
    //                 } else {
    //                     released = buffer.release();
    //                 }
    //                 assertTrue(released);
    //                 Thread t2 = new Thread(new Runnable() {
    //                     override
    //                     void run() {
    //                         cnt.set(buffer.refCnt());
    //                         latch.countDown();
    //                     }
    //                 });
    //                 t2.start();
    //                 try {
    //                     // Keep Thread alive a bit so the ThreadLocal caches are not freed
    //                     innerLatch.await();
    //                 } catch (InterruptedException ignore) {
    //                     // ignore
    //                 }
    //             }
    //         });
    //         t1.start();

    //         latch.await();
    //         assertEquals(0, cnt.get());
    //         innerLatch.countDown();
    //     }
    // }

    // static final class TestGatheringByteChannel implements GatheringByteChannel {
    //     private final ByteArrayOutputStream out = new ByteArrayOutputStream();
    //     private final WritableByteChannel channel = Channels.newChannel(out);
    //     private final int limit;
    //     TestGatheringByteChannel(int limit) {
    //         this.limit = limit;
    //     }

    //     TestGatheringByteChannel() {
    //         this(int.max);
    //     }

    //     override
    //     long write(ByteBuffer[] srcs, int offset, int length) {
    //         long written = 0;
    //         for (; offset < length; offset++) {
    //             written += write(srcs[offset]);
    //             if (written >= limit) {
    //                 break;
    //             }
    //         }
    //         return written;
    //     }

    //     override
    //     long write(ByteBuffer[] srcs) {
    //         return write(srcs, 0, srcs.length);
    //     }

    //     override
    //     int write(ByteBuffer src) {
    //         int oldLimit = src.limit();
    //         if (limit < src.remaining()) {
    //             src.limit(src.position() + limit);
    //         }
    //         int w = channel.write(src);
    //         src.limit(oldLimit);
    //         return w;
    //     }

    //     override
    //     boolean isOpen() {
    //         return channel.isOpen();
    //     }

    //     override
    //     void close() {
    //         channel.close();
    //     }

    //     byte[] writtenBytes() {
    //         return out.toByteArray();
    //     }
    // }

    // private static final class DevNullGatheringByteChannel implements GatheringByteChannel {
    //     override
    //     long write(ByteBuffer[] srcs, int offset, int length) {
    //         throw new UnsupportedOperationException();
    //     }

    //     override
    //     long write(ByteBuffer[] srcs) {
    //         throw new UnsupportedOperationException();
    //     }

    //     override
    //     int write(ByteBuffer src) {
    //         throw new UnsupportedOperationException();
    //     }

    //     override
    //     boolean isOpen() {
    //         return false;
    //     }

    //     override
    //     void close() {
    //         throw new UnsupportedOperationException();
    //     }
    // }

    // private static final class TestScatteringByteChannel implements ScatteringByteChannel {
    //     override
    //     long read(ByteBuffer[] dsts, int offset, int length) {
    //         throw new UnsupportedOperationException();
    //     }

    //     override
    //     long read(ByteBuffer[] dsts) {
    //         throw new UnsupportedOperationException();
    //     }

    //     override
    //     int read(ByteBuffer dst) {
    //         throw new UnsupportedOperationException();
    //     }

    //     override
    //     boolean isOpen() {
    //         return false;
    //     }

    //     override
    //     void close() {
    //         throw new UnsupportedOperationException();
    //     }
    // }

    // private static final class TestByteProcessor implements ByteProcessor {
    //     override
    //     boolean process(byte value) {
    //         return true;
    //     }
    // }

    // @Test(expected = IllegalArgumentException.class)
    // void testCapacityEnforceMaxCapacity() {
    //     ByteBuf buffer = newBuffer(3, 13);
    //     assertEquals(13, buffer.maxCapacity());
    //     assertEquals(3, buffer.capacity());
    //     try {
    //         buffer.capacity(14);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IllegalArgumentException.class)
    // void testCapacityNegative() {
    //     ByteBuf buffer = newBuffer(3, 13);
    //     assertEquals(13, buffer.maxCapacity());
    //     assertEquals(3, buffer.capacity());
    //     try {
    //         buffer.capacity(-1);
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test
    // void testCapacityDecrease() {
    //     ByteBuf buffer = newBuffer(3, 13);
    //     assertEquals(13, buffer.maxCapacity());
    //     assertEquals(3, buffer.capacity());
    //     try {
    //         buffer.capacity(2);
    //         assertEquals(2, buffer.capacity());
    //         assertEquals(13, buffer.maxCapacity());
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test
    // void testCapacityIncrease() {
    //     ByteBuf buffer = newBuffer(3, 13);
    //     assertEquals(13, buffer.maxCapacity());
    //     assertEquals(3, buffer.capacity());
    //     try {
    //         buffer.capacity(4);
    //         assertEquals(4, buffer.capacity());
    //         assertEquals(13, buffer.maxCapacity());
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test(expected = IndexOutOfBoundsException.class)
    // void testReaderIndexLargerThanWriterIndex() {
    //     String content1 = "hello";
    //     String content2 = "world";
    //     int length = content1.length() + content2.length();
    //     ByteBuf buffer = newBuffer(length);
    //     buffer.setIndex(0, 0);
    //     buffer.writeCharSequence(content1, CharsetUtil.US_ASCII);
    //     buffer.markWriterIndex();
    //     buffer.skipBytes(content1.length());
    //     buffer.writeCharSequence(content2, CharsetUtil.US_ASCII);
    //     buffer.skipBytes(content2.length());
    //     assertTrue(buffer.readerIndex() <= buffer.writerIndex());

    //     try {
    //         buffer.resetWriterIndex();
    //     } finally {
    //         buffer.release();
    //     }
    // }

    // @Test
    // void testMaxFastWritableBytes() {
    //     ByteBuf buffer = newBuffer(150, 500).writerIndex(100);
    //     assertEquals(50, buffer.writableBytes());
    //     assertEquals(150, buffer.capacity());
    //     assertEquals(500, buffer.maxCapacity());
    //     assertEquals(400, buffer.maxWritableBytes());
    //     // Default implementation has fast writable == writable
    //     assertEquals(50, buffer.maxFastWritableBytes());
    //     buffer.release();
    // }
}
