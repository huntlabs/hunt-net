module test.CompositeByteBufTest;

import test.AbstractByteBufTest;


import hunt.Assert;
import hunt.Byte;
import hunt.collection;
import hunt.Exceptions;
import hunt.stream.Common;
import hunt.logging;
import hunt.net.buffer;
import hunt.text.Charset;
import hunt.util.ByteOrder;
import hunt.util.Common;
import hunt.util.UnitTest;


/**
 * An abstract test class for composite channel buffers
 */
class CompositeByteBufTest : AbstractByteBufTest {

    private static ByteBufAllocator ALLOC() {
        return UnpooledByteBufAllocator.DEFAULT;
    } 

    private ByteOrder order;

    this() {
        this.order = ByteOrder.LittleEndian;
    }

    override
    protected ByteBuf newBuffer(int length, int maxCapacity) {
        assert(maxCapacity == int.max);

        List!(ByteBuf) buffers = new ArrayList!(ByteBuf)();
        for (int i = 0; i < length + 45; i += 45) {
            buffers.add(EMPTY_BUFFER);
            buffers.add(wrappedBuffer(new byte[1]));
            buffers.add(EMPTY_BUFFER);
            buffers.add(wrappedBuffer(new byte[2]));
            buffers.add(EMPTY_BUFFER);
            buffers.add(wrappedBuffer(new byte[3]));
            buffers.add(EMPTY_BUFFER);
            buffers.add(wrappedBuffer(new byte[4]));
            buffers.add(EMPTY_BUFFER);
            buffers.add(wrappedBuffer(new byte[5]));
            buffers.add(EMPTY_BUFFER);
            buffers.add(wrappedBuffer(new byte[6]));
            buffers.add(EMPTY_BUFFER);
            buffers.add(wrappedBuffer(new byte[7]));
            buffers.add(EMPTY_BUFFER);
            buffers.add(wrappedBuffer(new byte[8]));
            buffers.add(EMPTY_BUFFER);
            buffers.add(wrappedBuffer(new byte[9]));
            buffers.add(EMPTY_BUFFER);
        }

        ByteBuf buffer = wrappedBuffer(int.max, buffers.toArray()); // .order(order);

        // Truncate to the requested capacity.
        buffer.capacity(length);

        assertEquals(length, buffer.capacity());
        assertEquals(length, buffer.readableBytes());
        assertFalse(buffer.isWritable());
        buffer.writerIndex(0);
        return buffer;
    }

    // @Test
    // void testBytesBefore() {
    //     // byte[] data = [0x63, 0x6C, 0x69, 0x65, 0x6E, 0x74, 0x5F, 0x65, 0x6E, 0x63, 0x6F, 0x64, 0x69, 0x6E, 0x67, 0x00, 0x55, 0x54, 0x46, 0x38, 0x00];
    //     byte[] data1 = [0x63, 0x6C, 0x69, 0x65, 0x6E, 0x74, 0x5F, 0x65, 0x6E, 0x63, 0x6F, 0x64, 0x69];
    //     byte[] data2 = [0x6E, 0x67, 0x00, 0x55, 0x54, 0x46, 0x38, 0x00];

    //     CompositeByteBuf buf = cast(CompositeByteBuf) wrappedBuffer(data1, data2);
    //     int len = buf.bytesBefore(0);

    //     warningf("len: %d", len);
    //     assert(len == 15);

    // }


    // Composite buffer does not waste bandwidth on discardReadBytes, but
    // the test will fail in strict mode.
    // override
    // protected bool discardReadBytesDoesNotMoveWritableBytes() {
    //     return false;
    // }

    // /**
    //  * Tests the "getBufferFor" ~method
    //  */
    // @Test
    // void testComponentAtOffset() {
    //     CompositeByteBuf buf = cast(CompositeByteBuf) wrappedBuffer(cast(byte[])[1, 2, 3, 4, 5],
    //             cast(byte[])[4, 5, 6, 7, 8, 9, 26]);

    //     //Ensure that a random place will be fine
    //     assertEquals(5, buf.componentAtOffset(2).capacity());

    //     //Loop through each byte

    //     byte index = 0;

    //     while (index < buf.capacity()) {
    //         ByteBuf _buf = buf.componentAtOffset(index++);
    //         assertNotNull(_buf);
    //         assertTrue(_buf.capacity() > 0);
    //         assertNotNull(_buf.getByte(0));
    //         assertNotNull(_buf.getByte(_buf.readableBytes() - 1));
    //     }

    //     buf.release();
    // }

    // @Test
    // void testToComponentIndex() {
    //     CompositeByteBuf buf = cast(CompositeByteBuf) wrappedBuffer(cast(byte[])[1, 2, 3, 4, 5],
    //             cast(byte[])[4, 5, 6, 7, 8, 9, 26], cast(byte[])[10, 9, 8, 7, 6, 5, 33]);

    //     // spot checks
    //     assertEquals(0, buf.toComponentIndex(4));
    //     assertEquals(1, buf.toComponentIndex(5));
    //     assertEquals(2, buf.toComponentIndex(15));

    //     //Loop through each byte

    //     byte index = 0;

    //     while (index < buf.capacity()) {
    //         int cindex = buf.toComponentIndex(index++);
    //         assertTrue(cindex >= 0 && cindex < buf.numComponents());
    //     }

    //     buf.release();
    // }

    // @Test
    // void testToByteIndex() {
    //     CompositeByteBuf buf = cast(CompositeByteBuf) wrappedBuffer(cast(byte[])[1, 2, 3, 4, 5],
    //             cast(byte[])[4, 5, 6, 7, 8, 9, 26], cast(byte[])[10, 9, 8, 7, 6, 5, 33]);

    //     // spot checks
    //     assertEquals(0, buf.toByteIndex(0));
    //     assertEquals(5, buf.toByteIndex(1));
    //     assertEquals(12, buf.toByteIndex(2));

    //     buf.release();
    // }

    // @Test
    // void testDiscardReadBytes3() {
    //     ByteBuf a, b;
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ], 0, 5).order(order),
    //             wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ], 5, 5).order(order));
    //     a.skipBytes(6);
    //     a.markReaderIndex();
    //     b.skipBytes(6);
    //     b.markReaderIndex();
    //     assertEquals(a.readerIndex(), b.readerIndex());
    //     a.readerIndex(a.readerIndex() - 1);
    //     b.readerIndex(b.readerIndex() - 1);
    //     assertEquals(a.readerIndex(), b.readerIndex());
    //     a.writerIndex(a.writerIndex() - 1);
    //     a.markWriterIndex();
    //     b.writerIndex(b.writerIndex() - 1);
    //     b.markWriterIndex();
    //     assertEquals(a.writerIndex(), b.writerIndex());
    //     a.writerIndex(a.writerIndex() + 1);
    //     b.writerIndex(b.writerIndex() + 1);
    //     assertEquals(a.writerIndex(), b.writerIndex());
    //     assertTrue(ByteBufUtil.equals(a, b));
    //     // now discard
    //     a.discardReadBytes();
    //     b.discardReadBytes();
    //     assertEquals(a.readerIndex(), b.readerIndex());
    //     assertEquals(a.writerIndex(), b.writerIndex());
    //     assertTrue(ByteBufUtil.equals(a, b));
    //     a.resetReaderIndex();
    //     b.resetReaderIndex();
    //     assertEquals(a.readerIndex(), b.readerIndex());
    //     a.resetWriterIndex();
    //     b.resetWriterIndex();
    //     assertEquals(a.writerIndex(), b.writerIndex());
    //     assertTrue(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    // }

    @Test
    void testAutoConsolidation() {
        CompositeByteBuf buf = Unpooled.compositeBuffer(2);

        buf.addComponent(wrappedBuffer(cast(byte[])[ 1 ]));
        assertEquals(1, buf.numComponents());

        buf.addComponent(wrappedBuffer(cast(byte[])[ 2, 3 ]));
        assertEquals(2, buf.numComponents());

        buf.addComponent(wrappedBuffer(cast(byte[])[ 4, 5, 6 ]));

        assertEquals(1, buf.numComponents());
        assertTrue(buf.hasArray());
        assertNotNull(buf.array());
        assertEquals(0, buf.arrayOffset());

        buf.release();
    }

    // @Test
    // void testCompositeToSingleBuffer() {
    //     CompositeByteBuf buf = compositeBuffer(3);

    //     buf.addComponent(wrappedBuffer(cast(byte[])[1, 2, 3]));
    //     assertEquals(1, buf.numComponents());

    //     buf.addComponent(wrappedBuffer(cast(byte[])[4]));
    //     assertEquals(2, buf.numComponents());

    //     buf.addComponent(wrappedBuffer(cast(byte[])[5, 6]));
    //     assertEquals(3, buf.numComponents());

    //     // NOTE: hard-coding 6 here, since it seems like addComponent doesn't bump the writer index.
    //     // I'm unsure as to whether or not this is correct behavior
    //     ByteBuffer nioBuffer = buf.nioBuffer(0, 6);
    //     byte[] bytes = nioBuffer.array();
    //     assertEquals(6, bytes.length);
    //     assertArrayEquals(cast(byte[])[1, 2, 3, 4, 5, 6], bytes);

    //     buf.release();
    // }

    // @Test
    // void testFullConsolidation() {
    //     CompositeByteBuf buf = compositeBuffer(int.max);
    //     buf.addComponent(wrappedBuffer(cast(byte[])[ 1 ]));
    //     buf.addComponent(wrappedBuffer(cast(byte[])[ 2, 3 ]));
    //     buf.addComponent(wrappedBuffer(cast(byte[])[ 4, 5, 6 ]));
    //     buf.consolidate();

    //     assertEquals(1, buf.numComponents());
    //     assertTrue(buf.hasArray());
    //     assertNotNull(buf.array());
    //     assertEquals(0, buf.arrayOffset());

    //     buf.release();
    // }

    // @Test
    // void testRangedConsolidation() {
    //     CompositeByteBuf buf = Unpooled.compositeBuffer(int.max);
    //     buf.addComponent(wrappedBuffer(cast(byte[])[ 1 ]));
    //     buf.addComponent(wrappedBuffer(cast(byte[])[ 2, 3 ]));
    //     buf.addComponent(wrappedBuffer(cast(byte[])[ 4, 5, 6 ]));
    //     buf.addComponent(wrappedBuffer(cast(byte[])[ 7, 8, 9, 10 ]));
    //     buf.consolidate(1, 2);

    //     assertEquals(3, buf.numComponents());
    //     assertEquals(wrappedBuffer(cast(byte[])[ 1 ]), buf.component(0));
    //     assertEquals(wrappedBuffer(cast(byte[])[ 2, 3, 4, 5, 6 ]), buf.component(1));
    //     assertEquals(wrappedBuffer(cast(byte[])[ 7, 8, 9, 10 ]), buf.component(2));

    //     buf.release();
    // }

    // @Test
    // void testCompositeWrappedBuffer() {
    //     ByteBuf header = Unpooled.buffer(12); //.order(order);
    //     ByteBuf payload = Unpooled.buffer(512); //.order(order);

    //     header.writeBytes(new byte[12]);
    //     payload.writeBytes(new byte[512]);

    //     ByteBuf buffer = wrappedBuffer(header, payload);

    //     assertEquals(12, header.readableBytes());
    //     assertEquals(512, payload.readableBytes());

    //     assertEquals(12 + 512, buffer.readableBytes());
    //     assertEquals(2, buffer.nioBufferCount());

    //     buffer.release();
    // }

    // @Test
    // void testSeveralBuffersEquals() {
    //     ByteBuf a, b;
    //     // XXX Same tests with several buffers in wrappedCheckedBuffer
    //     // Different length.
    //     a = wrappedBuffer(cast(byte[])[ 1 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 1 ]).order(order),
    //             wrappedBuffer(cast(byte[])[ 2 ]).order(order));
    //     assertFalse(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();

    //     // Same content, same firstIndex, short length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[1]).order(order),
    //             wrappedBuffer(cast(byte[])[2]).order(order),
    //             wrappedBuffer(cast(byte[])[3]).order(order));
    //     assertTrue(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();

    //     // Same content, different firstIndex, short length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4 ], 1, 2).order(order),
    //             wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4 ], 3, 1).order(order));
    //     assertTrue(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();

    //     // Different content, same firstIndex, short length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 1, 2 ]).order(order),
    //             wrappedBuffer(cast(byte[])[ 4 ]).order(order));
    //     assertFalse(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();

    //     // Different content, different firstIndex, short length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 0, 1, 2, 4, 5 ], 1, 2).order(order),
    //             wrappedBuffer(cast(byte[])[ 0, 1, 2, 4, 5 ], 3, 1).order(order));
    //     assertFalse(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();

    //     // Same content, same firstIndex, long length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order),
    //             wrappedBuffer(cast(byte[])[ 4, 5, 6 ]).order(order),
    //             wrappedBuffer(cast(byte[])[ 7, 8, 9, 10 ]).order(order));
    //     assertTrue(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();

    //     // Same content, different firstIndex, long length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], 1, 5).order(order),
    //             wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], 6, 5).order(order));
    //     assertTrue(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();

    //     // Different content, same firstIndex, long length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 6 ]).order(order),
    //             wrappedBuffer(cast(byte[])[ 7, 8, 5, 9, 10 ]).order(order));
    //     assertFalse(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();

    //     // Different content, different firstIndex, long length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4, 6, 7, 8, 5, 9, 10, 11 ], 1, 5).order(order),
    //             wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4, 6, 7, 8, 5, 9, 10, 11 ], 6, 5).order(order));
    //     assertFalse(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    // }

    // @Test
    // void testWrappedBuffer() {

    //     ByteBuf a = wrappedBuffer(wrappedBuffer(ByteBuffer.allocateDirect(16)));
    //     assertEquals(16, a.capacity());
    //     a.release();

    //     a = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order));
    //     ByteBuf b = wrappedBuffer(wrappedBuffer(new byte[][] { cast(byte[])[ 1, 2, 3 } ]).order(order));
    //     assertEquals(a, b);

    //     a.release();
    //     b.release();

    //     a = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order));
    //     b = wrappedBuffer(wrappedBuffer(
    //             cast(byte[])[ 1 ],
    //             cast(byte[])[ 2 ],
    //             cast(byte[])[ 3 ]).order(order));
    //     assertEquals(a, b);

    //     a.release();
    //     b.release();

    //     a = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order));
    //     b = wrappedBuffer(new ByteBuf[] {
    //             wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order)
    //     ]);
    //     assertEquals(a, b);

    //     a.release();
    //     b.release();

    //     a = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order));
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 1 ]).order(order),
    //             wrappedBuffer(cast(byte[])[ 2 ]).order(order),
    //             wrappedBuffer(cast(byte[])[ 3 ]).order(order));
    //     assertEquals(a, b);

    //     a.release();
    //     b.release();

    //     a = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1, 2, 3 ])).order(order);
    //     b = wrappedBuffer(wrappedBuffer(new ByteBuffer[] {
    //             ByteBuffer.wrap(cast(byte[])[ 1, 2, 3 ])
    //     ]));
    //     assertEquals(a, b);

    //     a.release();
    //     b.release();

    //     a = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order));
    //     b = wrappedBuffer(wrappedBuffer(
    //             ByteBuffer.wrap(cast(byte[])[ 1 ]),
    //             ByteBuffer.wrap(cast(byte[])[ 2 ]),
    //             ByteBuffer.wrap(cast(byte[])[ 3 ])));
    //     assertEquals(a, b);

    //     a.release();
    //     b.release();
    // }

    // @Test
    // void testWrittenBuffersEquals() {
    //     //XXX Same tests than testEquals with written AggregateChannelBuffers
    //     ByteBuf a, b, c;
    //     // Different length.
    //     a = wrappedBuffer(cast(byte[])[ 1  ]).order(order);
    //     b = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1 ], new byte[1])).order(order);
    //     c = wrappedBuffer(cast(byte[])[ 2 ]).order(order);

    //     // to enable writeBytes
    //     b.writerIndex(b.writerIndex() - 1);
    //     b.writeBytes(c);
    //     assertFalse(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    //     c.release();

    //     // Same content, same firstIndex, short length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order);
    //     b = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1 ], new byte[2])).order(order);
    //     c = wrappedBuffer(cast(byte[])[ 2 ]).order(order);

    //     // to enable writeBytes
    //     b.writerIndex(b.writerIndex() - 2);
    //     b.writeBytes(c);
    //     c.release();
    //     c = wrappedBuffer(cast(byte[])[ 3 ]).order(order);

    //     b.writeBytes(c);
    //     assertTrue(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    //     c.release();

    //     // Same content, different firstIndex, short length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order);
    //     b = wrappedBuffer(wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4 ], 1, 3)).order(order);
    //     c = wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4 ], 3, 1).order(order);
    //     // to enable writeBytes
    //     b.writerIndex(b.writerIndex() - 1);
    //     b.writeBytes(c);
    //     assertTrue(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    //     c.release();

    //     // Different content, same firstIndex, short length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order);
    //     b = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1, 2 ], new byte[1])).order(order);
    //     c = wrappedBuffer(cast(byte[])[ 4 ]).order(order);
    //     // to enable writeBytes
    //     b.writerIndex(b.writerIndex() - 1);
    //     b.writeBytes(c);
    //     assertFalse(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    //     c.release();

    //     // Different content, different firstIndex, short length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3 ]).order(order);
    //     b = wrappedBuffer(wrappedBuffer(cast(byte[])[ 0, 1, 2, 4, 5 ], 1, 3)).order(order);
    //     c = wrappedBuffer(cast(byte[])[ 0, 1, 2, 4, 5 ], 3, 1).order(order);
    //     // to enable writeBytes
    //     b.writerIndex(b.writerIndex() - 1);
    //     b.writeBytes(c);
    //     assertFalse(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    //     c.release();

    //     // Same content, same firstIndex, long length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]).order(order);
    //     b = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1, 2, 3 ], new byte[7])).order(order);
    //     c = wrappedBuffer(cast(byte[])[ 4, 5, 6 ]).order(order);

    //     // to enable writeBytes
    //     b.writerIndex(b.writerIndex() - 7);
    //     b.writeBytes(c);
    //     c.release();
    //     c = wrappedBuffer(cast(byte[])[ 7, 8, 9, 10 ]).order(order);
    //     b.writeBytes(c);
    //     assertTrue(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    //     c.release();

    //     // Same content, different firstIndex, long length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], 1, 10)).order(order);
    //     c = wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], 6, 5).order(order);
    //     // to enable writeBytes
    //     b.writerIndex(b.writerIndex() - 5);
    //     b.writeBytes(c);
    //     assertTrue(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    //     c.release();

    //     // Different content, same firstIndex, long length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]).order(order);
    //     b = wrappedBuffer(wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 6 ], new byte[5])).order(order);
    //     c = wrappedBuffer(cast(byte[])[ 7, 8, 5, 9, 10 ]).order(order);
    //     // to enable writeBytes
    //     b.writerIndex(b.writerIndex() - 5);
    //     b.writeBytes(c);
    //     assertFalse(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    //     c.release();

    //     // Different content, different firstIndex, long length.
    //     a = wrappedBuffer(cast(byte[])[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]).order(order);
    //     b = wrappedBuffer(
    //             wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4, 6, 7, 8, 5, 9, 10, 11 ], 1, 10)).order(order);
    //     c = wrappedBuffer(cast(byte[])[ 0, 1, 2, 3, 4, 6, 7, 8, 5, 9, 10, 11 ], 6, 5).order(order);
    //     // to enable writeBytes
    //     b.writerIndex(b.writerIndex() - 5);
    //     b.writeBytes(c);
    //     assertFalse(ByteBufUtil.equals(a, b));

    //     a.release();
    //     b.release();
    //     c.release();
    // }

    // @Test
    // void testEmptyBuffer() {
    //     ByteBuf b = wrappedBuffer(cast(byte[])[1, 2], cast(byte[])[3, 4]);
    //     b.readBytes(new byte[4]);
    //     b.readBytes(EMPTY_BYTES);
    //     b.release();
    // }

    // // Test for https://github.com/netty/netty/issues/1060
    // @Test
    // void testReadWithEmptyCompositeBuffer() {
    //     ByteBuf buf = compositeBuffer();
    //     int n = 65;
    //     for (int i = 0; i < n; i ++) {
    //         buf.writeByte(1);
    //         assertEquals(1, buf.readByte());
    //     }
    //     buf.release();
    // }

    // @SuppressWarnings("deprecation")
    // @Test
    // void testComponentMustBeDuplicate() {
    //     CompositeByteBuf buf = compositeBuffer();
    //     buf.addComponent(buffer(4, 6).setIndex(1, 3));
    //     assertThat(buf.component(0), is(instanceOf(AbstractDerivedByteBuf.class)));
    //     assertThat(buf.component(0).capacity(), is(4));
    //     assertThat(buf.component(0).maxCapacity(), is(6));
    //     assertThat(buf.component(0).readableBytes(), is(2));
    //     buf.release();
    // }

    // @Test
    // void testReferenceCounts1() {
    //     ByteBuf c1 = buffer().writeByte(1);
    //     ByteBuf c2 = buffer().writeByte(2).retain();
    //     ByteBuf c3 = buffer().writeByte(3).retain(2);

    //     CompositeByteBuf buf = compositeBuffer();
    //     assertThat(buf.refCnt(), is(1));
    //     buf.addComponents(c1, c2, c3);

    //     assertThat(buf.refCnt(), is(1));

    //     // Ensure that c[123]'s refCount did not change.
    //     assertThat(c1.refCnt(), is(1));
    //     assertThat(c2.refCnt(), is(2));
    //     assertThat(c3.refCnt(), is(3));

    //     assertThat(buf.component(0).refCnt(), is(1));
    //     assertThat(buf.component(1).refCnt(), is(2));
    //     assertThat(buf.component(2).refCnt(), is(3));

    //     c3.release(2);
    //     c2.release();
    //     buf.release();
    // }

    // @Test
    // void testReferenceCounts2() {
    //     ByteBuf c1 = buffer().writeByte(1);
    //     ByteBuf c2 = buffer().writeByte(2).retain();
    //     ByteBuf c3 = buffer().writeByte(3).retain(2);

    //     CompositeByteBuf bufA = compositeBuffer();
    //     bufA.addComponents(c1, c2, c3).writerIndex(3);

    //     CompositeByteBuf bufB = compositeBuffer();
    //     bufB.addComponents(bufA);

    //     // Ensure that bufA.refCnt() did not change.
    //     assertThat(bufA.refCnt(), is(1));

    //     // Ensure that c[123]'s refCnt did not change.
    //     assertThat(c1.refCnt(), is(1));
    //     assertThat(c2.refCnt(), is(2));
    //     assertThat(c3.refCnt(), is(3));

    //     // This should decrease bufA.refCnt().
    //     bufB.release();
    //     assertThat(bufB.refCnt(), is(0));

    //     // Ensure bufA.refCnt() changed.
    //     assertThat(bufA.refCnt(), is(0));

    //     // Ensure that c[123]'s refCnt also changed due to the deallocation of bufA.
    //     assertThat(c1.refCnt(), is(0));
    //     assertThat(c2.refCnt(), is(1));
    //     assertThat(c3.refCnt(), is(2));

    //     c3.release(2);
    //     c2.release();
    // }

    // @Test
    // void testReferenceCounts3() {
    //     ByteBuf c1 = buffer().writeByte(1);
    //     ByteBuf c2 = buffer().writeByte(2).retain();
    //     ByteBuf c3 = buffer().writeByte(3).retain(2);

    //     CompositeByteBuf buf = compositeBuffer();
    //     assertThat(buf.refCnt(), is(1));

    //     List!(ByteBuf) components = new ArrayList!(ByteBuf)();
    //     Collections.addAll(components, c1, c2, c3);
    //     buf.addComponents(components);

    //     // Ensure that c[123]'s refCount did not change.
    //     assertThat(c1.refCnt(), is(1));
    //     assertThat(c2.refCnt(), is(2));
    //     assertThat(c3.refCnt(), is(3));

    //     assertThat(buf.component(0).refCnt(), is(1));
    //     assertThat(buf.component(1).refCnt(), is(2));
    //     assertThat(buf.component(2).refCnt(), is(3));

    //     c3.release(2);
    //     c2.release();
    //     buf.release();
    // }

    // @Test
    // void testNestedLayout() {
    //     CompositeByteBuf buf = compositeBuffer();
    //     buf.addComponent(
    //             compositeBuffer()
    //                     .addComponent(wrappedBuffer(cast(byte[])[1, 2]))
    //                     .addComponent(wrappedBuffer(cast(byte[])[3, 4])).slice(1, 2));

    //     ByteBuffer[] nioBuffers = buf.nioBuffers(0, 2);
    //     assertThat(nioBuffers.length, is(2));
    //     assertThat(nioBuffers[0].remaining(), is(1));
    //     assertThat(nioBuffers[0].get(), is((byte) 2));
    //     assertThat(nioBuffers[1].remaining(), is(1));
    //     assertThat(nioBuffers[1].get(), is((byte) 3));

    //     buf.release();
    // }

    // @Test
    // void testRemoveLastComponent() {
    //     CompositeByteBuf buf = compositeBuffer();
    //     buf.addComponent(wrappedBuffer(cast(byte[])[1, 2]));
    //     assertEquals(1, buf.numComponents());
    //     buf.removeComponent(0);
    //     assertEquals(0, buf.numComponents());
    //     buf.release();
    // }

    // @Test
    // void testCopyEmpty() {
    //     CompositeByteBuf buf = compositeBuffer();
    //     assertEquals(0, buf.numComponents());

    //     ByteBuf copy = buf.copy();
    //     assertEquals(0, copy.readableBytes());

    //     buf.release();
    //     copy.release();
    // }

    // @Test
    // void testDuplicateEmpty() {
    //     CompositeByteBuf buf = compositeBuffer();
    //     assertEquals(0, buf.numComponents());
    //     assertEquals(0, buf.duplicate().readableBytes());

    //     buf.release();
    // }

    // @Test
    // void testRemoveLastComponentWithOthersLeft() {
    //     CompositeByteBuf buf = compositeBuffer();
    //     buf.addComponent(wrappedBuffer(cast(byte[])[1, 2]));
    //     buf.addComponent(wrappedBuffer(cast(byte[])[1, 2]));
    //     assertEquals(2, buf.numComponents());
    //     buf.removeComponent(1);
    //     assertEquals(1, buf.numComponents());
    //     buf.release();
    // }

    // @Test
    // void testRemoveComponents() {
    //     CompositeByteBuf buf = compositeBuffer();
    //     for (int i = 0; i < 10; i++) {
    //         buf.addComponent(wrappedBuffer(cast(byte[])[1, 2]));
    //     }
    //     assertEquals(10, buf.numComponents());
    //     assertEquals(20, buf.capacity());
    //     buf.removeComponents(4, 3);
    //     assertEquals(7, buf.numComponents());
    //     assertEquals(14, buf.capacity());
    //     buf.release();
    // }

    // @Test
    // void testGatheringWritesHeap() {
    //     testGatheringWrites(buffer().order(order), buffer().order(order));
    // }

    // @Test
    // void testGatheringWritesDirect() {
    //     testGatheringWrites(directBuffer().order(order), directBuffer().order(order));
    // }

    // @Test
    // void testGatheringWritesMixes() {
    //     testGatheringWrites(buffer().order(order), directBuffer().order(order));
    // }

    // @Test
    // void testGatheringWritesHeapPooled() {
    //     testGatheringWrites(PooledByteBufAllocator.DEFAULT.heapBuffer().order(order),
    //             PooledByteBufAllocator.DEFAULT.heapBuffer().order(order));
    // }

    // @Test
    // void testGatheringWritesDirectPooled() {
    //     testGatheringWrites(PooledByteBufAllocator.DEFAULT.directBuffer().order(order),
    //             PooledByteBufAllocator.DEFAULT.directBuffer().order(order));
    // }

    // @Test
    // void testGatheringWritesMixesPooled() {
    //     testGatheringWrites(PooledByteBufAllocator.DEFAULT.heapBuffer().order(order),
    //             PooledByteBufAllocator.DEFAULT.directBuffer().order(order));
    // }

    // private static void testGatheringWrites(ByteBuf buf1, ByteBuf buf2) {
    //     CompositeByteBuf buf = compositeBuffer();
    //     buf.addComponent(buf1.writeBytes(cast(byte[])[1, 2]));
    //     buf.addComponent(buf2.writeBytes(cast(byte[])[1, 2]));
    //     buf.writerIndex(3);
    //     buf.readerIndex(1);

    //     TestGatheringByteChannel channel = new TestGatheringByteChannel();

    //     buf.readBytes(channel, 2);

    //     byte[] data = new byte[2];
    //     buf.getBytes(1, data);
    //     assertArrayEquals(data, channel.writtenBytes());

    //     buf.release();
    // }

    // @Test
    // void testGatheringWritesPartialHeap() {
    //     testGatheringWritesPartial(buffer().order(order), buffer().order(order), false);
    // }

    // @Test
    // void testGatheringWritesPartialDirect() {
    //     testGatheringWritesPartial(directBuffer().order(order), directBuffer().order(order), false);
    // }

    // @Test
    // void testGatheringWritesPartialMixes() {
    //     testGatheringWritesPartial(buffer().order(order), directBuffer().order(order), false);
    // }

    // @Test
    // void testGatheringWritesPartialHeapSlice() {
    //     testGatheringWritesPartial(buffer().order(order), buffer().order(order), true);
    // }

    // @Test
    // void testGatheringWritesPartialDirectSlice() {
    //     testGatheringWritesPartial(directBuffer().order(order), directBuffer().order(order), true);
    // }

    // @Test
    // void testGatheringWritesPartialMixesSlice() {
    //     testGatheringWritesPartial(buffer().order(order), directBuffer().order(order), true);
    // }

    // @Test
    // void testGatheringWritesPartialHeapPooled() {
    //     testGatheringWritesPartial(PooledByteBufAllocator.DEFAULT.heapBuffer().order(order),
    //             PooledByteBufAllocator.DEFAULT.heapBuffer().order(order), false);
    // }

    // @Test
    // void testGatheringWritesPartialDirectPooled() {
    //     testGatheringWritesPartial(PooledByteBufAllocator.DEFAULT.directBuffer().order(order),
    //             PooledByteBufAllocator.DEFAULT.directBuffer().order(order), false);
    // }

    // @Test
    // void testGatheringWritesPartialMixesPooled() {
    //     testGatheringWritesPartial(PooledByteBufAllocator.DEFAULT.heapBuffer().order(order),
    //             PooledByteBufAllocator.DEFAULT.directBuffer().order(order), false);
    // }

    // @Test
    // void testGatheringWritesPartialHeapPooledSliced() {
    //     testGatheringWritesPartial(PooledByteBufAllocator.DEFAULT.heapBuffer().order(order),
    //             PooledByteBufAllocator.DEFAULT.heapBuffer().order(order), true);
    // }

    // @Test
    // void testGatheringWritesPartialDirectPooledSliced() {
    //     testGatheringWritesPartial(PooledByteBufAllocator.DEFAULT.directBuffer().order(order),
    //             PooledByteBufAllocator.DEFAULT.directBuffer().order(order), true);
    // }

    // @Test
    // void testGatheringWritesPartialMixesPooledSliced() {
    //     testGatheringWritesPartial(PooledByteBufAllocator.DEFAULT.heapBuffer().order(order),
    //             PooledByteBufAllocator.DEFAULT.directBuffer().order(order), true);
    // }

    // private static void testGatheringWritesPartial(ByteBuf buf1, ByteBuf buf2, bool slice) {
    //     CompositeByteBuf buf = compositeBuffer();
    //     buf1.writeBytes(cast(byte[])[1, 2, 3, 4]);
    //     buf2.writeBytes(cast(byte[])[1, 2, 3, 4]);
    //     if (slice) {
    //         buf1 = buf1.readerIndex(1).slice();
    //         buf2 = buf2.writerIndex(3).slice();
    //         buf.addComponent(buf1);
    //         buf.addComponent(buf2);
    //         buf.writerIndex(6);
    //     } else {
    //         buf.addComponent(buf1);
    //         buf.addComponent(buf2);
    //         buf.writerIndex(7);
    //         buf.readerIndex(1);
    //     }

    //     TestGatheringByteChannel channel = new TestGatheringByteChannel(1);

    //     while (buf.isReadable()) {
    //         buf.readBytes(channel, buf.readableBytes());
    //     }

    //     byte[] data = new byte[6];

    //     if (slice) {
    //         buf.getBytes(0, data);
    //     } else {
    //         buf.getBytes(1, data);
    //     }
    //     assertArrayEquals(data, channel.writtenBytes());

    //     buf.release();
    // }

    // @Test
    // void testGatheringWritesSingleHeap() {
    //     testGatheringWritesSingleBuf(buffer().order(order));
    // }

    // @Test
    // void testGatheringWritesSingleDirect() {
    //     testGatheringWritesSingleBuf(directBuffer().order(order));
    // }

    // private static void testGatheringWritesSingleBuf(ByteBuf buf1) {
    //     CompositeByteBuf buf = compositeBuffer();
    //     buf.addComponent(buf1.writeBytes(cast(byte[])[1, 2, 3, 4]));
    //     buf.writerIndex(3);
    //     buf.readerIndex(1);

    //     TestGatheringByteChannel channel = new TestGatheringByteChannel();
    //     buf.readBytes(channel, 2);

    //     byte[] data = new byte[2];
    //     buf.getBytes(1, data);
    //     assertArrayEquals(data, channel.writtenBytes());

    //     buf.release();
    // }

    // override
    // @Test
    // void testInternalNioBuffer() {
    //     CompositeByteBuf buf = compositeBuffer();
    //     assertEquals(0, buf.internalNioBuffer(0, 0).remaining());

    //     // If non-derived buffer is added, its internal buffer should be returned
    //     ByteBuf concreteBuffer = directBuffer().writeByte(1);
    //     buf.addComponent(concreteBuffer);
    //     assertSame(concreteBuffer.internalNioBuffer(0, 1), buf.internalNioBuffer(0, 1));
    //     buf.release();

    //     // In derived cases, the original internal buffer must not be used
    //     buf = compositeBuffer();
    //     concreteBuffer = directBuffer().writeByte(1);
    //     buf.addComponent(concreteBuffer.slice());
    //     assertNotSame(concreteBuffer.internalNioBuffer(0, 1), buf.internalNioBuffer(0, 1));
    //     buf.release();

    //     buf = compositeBuffer();
    //     concreteBuffer = directBuffer().writeByte(1);
    //     buf.addComponent(concreteBuffer.duplicate());
    //     assertNotSame(concreteBuffer.internalNioBuffer(0, 1), buf.internalNioBuffer(0, 1));
    //     buf.release();
    // }

    // @Test
    // void testisDirectMultipleBufs() {
    //     CompositeByteBuf buf = compositeBuffer();
    //     assertFalse(buf.isDirect());

    //     buf.addComponent(directBuffer().writeByte(1));

    //     assertTrue(buf.isDirect());
    //     buf.addComponent(directBuffer().writeByte(1));
    //     assertTrue(buf.isDirect());

    //     buf.addComponent(buffer().writeByte(1));
    //     assertFalse(buf.isDirect());

    //     buf.release();
    // }

    // // See https://github.com/netty/netty/issues/1976
    // @Test
    // void testDiscardSomeReadBytes() {
    //     CompositeByteBuf cbuf = compositeBuffer();
    //     int len = 8 * 4;
    //     for (int i = 0; i < len; i += 4) {
    //         ByteBuf buf = buffer().writeInt(i);
    //         cbuf.capacity(cbuf.writerIndex()).addComponent(buf).writerIndex(i + 4);
    //     }
    //     cbuf.writeByte(1);

    //     byte[] me = new byte[len];
    //     cbuf.readBytes(me);
    //     cbuf.readByte();

    //     cbuf.discardSomeReadBytes();

    //     cbuf.release();
    // }

    // @Test
    // void testAddEmptyBufferRelease() {
    //     CompositeByteBuf cbuf = compositeBuffer();
    //     ByteBuf buf = buffer();
    //     assertEquals(1, buf.refCnt());
    //     cbuf.addComponent(buf);
    //     assertEquals(1, buf.refCnt());

    //     cbuf.release();
    //     assertEquals(0, buf.refCnt());
    // }

    // @Test
    // void testAddEmptyBuffersRelease() {
    //     CompositeByteBuf cbuf = compositeBuffer();
    //     ByteBuf buf = buffer();
    //     ByteBuf buf2 = buffer().writeInt(1);
    //     ByteBuf buf3 = buffer();

    //     assertEquals(1, buf.refCnt());
    //     assertEquals(1, buf2.refCnt());
    //     assertEquals(1, buf3.refCnt());

    //     cbuf.addComponents(buf, buf2, buf3);
    //     assertEquals(1, buf.refCnt());
    //     assertEquals(1, buf2.refCnt());
    //     assertEquals(1, buf3.refCnt());

    //     cbuf.release();
    //     assertEquals(0, buf.refCnt());
    //     assertEquals(0, buf2.refCnt());
    //     assertEquals(0, buf3.refCnt());
    // }

    // @Test
    // void testAddEmptyBufferInMiddle() {
    //     CompositeByteBuf cbuf = compositeBuffer();
    //     ByteBuf buf1 = buffer().writeByte((byte) 1);
    //     cbuf.addComponent(true, buf1);
    //     cbuf.addComponent(true, EMPTY_BUFFER);
    //     ByteBuf buf3 = buffer().writeByte((byte) 2);
    //     cbuf.addComponent(true, buf3);

    //     assertEquals(2, cbuf.readableBytes());
    //     assertEquals((byte) 1, cbuf.readByte());
    //     assertEquals((byte) 2, cbuf.readByte());

    //     assertSame(EMPTY_BUFFER, cbuf.internalComponent(1));
    //     assertNotSame(EMPTY_BUFFER, cbuf.internalComponentAtOffset(1));
    //     cbuf.release();
    // }

    // @Test
    // void testInsertEmptyBufferInMiddle() {
    //     CompositeByteBuf cbuf = compositeBuffer();
    //     ByteBuf buf1 = buffer().writeByte((byte) 1);
    //     cbuf.addComponent(true, buf1);
    //     ByteBuf buf2 = buffer().writeByte((byte) 2);
    //     cbuf.addComponent(true, buf2);

    //     // insert empty one between the first two
    //     cbuf.addComponent(true, 1, EMPTY_BUFFER);

    //     assertEquals(2, cbuf.readableBytes());
    //     assertEquals((byte) 1, cbuf.readByte());
    //     assertEquals((byte) 2, cbuf.readByte());

    //     assertEquals(2, cbuf.capacity());
    //     assertEquals(3, cbuf.numComponents());

    //     byte[] dest = new byte[2];
    //     // should skip over the empty one, not throw a java.lang.Error :)
    //     cbuf.getBytes(0, dest);

    //     assertArrayEquals(cast(byte[])[1, 2], dest);

    //     cbuf.release();
    // }

    // @Test
    // void testAddFlattenedComponents() {
    //     ByteBuf b1 = Unpooled.wrappedBuffer(cast(byte[])[ 1, 2, 3 ]);
    //     CompositeByteBuf newComposite = Unpooled.compositeBuffer()
    //             .addComponent(true, b1)
    //             .addFlattenedComponents(true, b1.retain())
    //             .addFlattenedComponents(true, Unpooled.EMPTY_BUFFER);

    //     assertEquals(2, newComposite.numComponents());
    //     assertEquals(6, newComposite.capacity());
    //     assertEquals(6, newComposite.writerIndex());

    //     // It is important to use a pooled allocator here to ensure
    //     // the slices returned by readRetainedSlice are of type
    //     // PooledSlicedByteBuf, which maintains an independent refcount
    //     // (so that we can be sure to cover this case)
    //     ByteBuf buffer = PooledByteBufAllocator.DEFAULT.buffer()
    //           .writeBytes(cast(byte[])[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

    //     // use mixture of slice and retained slice
    //     ByteBuf s1 = buffer.readRetainedSlice(2);
    //     ByteBuf s2 = s1.retainedSlice(0, 2);
    //     ByteBuf s3 = buffer.slice(0, 2).retain();
    //     ByteBuf s4 = s2.retainedSlice(0, 2);
    //     buffer.release();

    //     ByteBuf compositeToAdd = Unpooled.compositeBuffer()
    //         .addComponent(s1)
    //         .addComponent(Unpooled.EMPTY_BUFFER)
    //         .addComponents(s2, s3, s4);
    //     // set readable range to be from middle of first component
    //     // to middle of penultimate component
    //     compositeToAdd.setIndex(1, 5);

    //     assertEquals(1, compositeToAdd.refCnt());
    //     assertEquals(1, s4.refCnt());

    //     ByteBuf compositeCopy = compositeToAdd.copy();

    //     newComposite.addFlattenedComponents(true, compositeToAdd);

    //     // verify that added range matches
    //     ByteBufUtil.equals(compositeCopy, 0,
    //             newComposite, 6, compositeCopy.readableBytes());

    //     // should not include empty component or last component
    //     // (latter outside of the readable range)
    //     assertEquals(5, newComposite.numComponents());
    //     assertEquals(10, newComposite.capacity());
    //     assertEquals(10, newComposite.writerIndex());

    //     assertEquals(0, compositeToAdd.refCnt());
    //     // s4 wasn't in added range so should have been jettisoned
    //     assertEquals(0, s4.refCnt());
    //     assertEquals(1, newComposite.refCnt());

    //     // releasing composite should release the remaining components
    //     newComposite.release();
    //     assertEquals(0, newComposite.refCnt());
    //     assertEquals(0, s1.refCnt());
    //     assertEquals(0, s2.refCnt());
    //     assertEquals(0, s3.refCnt());
    //     assertEquals(0, b1.refCnt());
    // }

    // @Test
    // void testIterator() {
    //     CompositeByteBuf cbuf = compositeBuffer();
    //     cbuf.addComponent(EMPTY_BUFFER);
    //     cbuf.addComponent(EMPTY_BUFFER);

    //     Iterator!(ByteBuf) it = cbuf.iterator();
    //     assertTrue(it.hasNext());
    //     assertSame(EMPTY_BUFFER, it.next());
    //     assertTrue(it.hasNext());
    //     assertSame(EMPTY_BUFFER, it.next());
    //     assertFalse(it.hasNext());

    //     try {
    //         it.next();
    //         fail();
    //     } catch (NoSuchElementException e) {
    //         //Expected
    //     }
    //     cbuf.release();
    // }

    // @Test
    // void testEmptyIterator() {
    //     CompositeByteBuf cbuf = compositeBuffer();

    //     Iterator!(ByteBuf) it = cbuf.iterator();
    //     assertFalse(it.hasNext());

    //     try {
    //         it.next();
    //         fail();
    //     } catch (NoSuchElementException e) {
    //         //Expected
    //     }
    //     cbuf.release();
    // }

    // @Test(expected = ConcurrentModificationException.class)
    // void testIteratorConcurrentModificationAdd() {
    //     CompositeByteBuf cbuf = compositeBuffer();
    //     cbuf.addComponent(EMPTY_BUFFER);

    //     Iterator!(ByteBuf) it = cbuf.iterator();
    //     cbuf.addComponent(EMPTY_BUFFER);

    //     assertTrue(it.hasNext());
    //     try {
    //         it.next();
    //     } finally {
    //         cbuf.release();
    //     }
    // }

    // @Test(expected = ConcurrentModificationException.class)
    // void testIteratorConcurrentModificationRemove() {
    //     CompositeByteBuf cbuf = compositeBuffer();
    //     cbuf.addComponent(EMPTY_BUFFER);

    //     Iterator!(ByteBuf) it = cbuf.iterator();
    //     cbuf.removeComponent(0);

    //     assertTrue(it.hasNext());
    //     try {
    //         it.next();
    //     } finally {
    //         cbuf.release();
    //     }
    // }

    // @Test
    // void testReleasesItsComponents() {
    //     ByteBuf buffer = PooledByteBufAllocator.DEFAULT.buffer(); // 1

    //     buffer.writeBytes(cast(byte[])[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

    //     ByteBuf s1 = buffer.readSlice(2).retain(); // 2
    //     ByteBuf s2 = s1.readSlice(2).retain(); // 3
    //     ByteBuf s3 = s2.readSlice(2).retain(); // 4
    //     ByteBuf s4 = s3.readSlice(2).retain(); // 5

    //     ByteBuf composite = PooledByteBufAllocator.DEFAULT.compositeBuffer()
    //         .addComponent(s1)
    //         .addComponents(s2, s3, s4)
    //         .order(ByteOrder.LITTLE_ENDIAN);

    //     assertEquals(1, composite.refCnt());
    //     assertEquals(5, buffer.refCnt());

    //     // releasing composite should release the 4 components
    //     ReferenceCountUtil.release(composite);
    //     assertEquals(0, composite.refCnt());
    //     assertEquals(1, buffer.refCnt());

    //     // last remaining ref to buffer
    //     ReferenceCountUtil.release(buffer);
    //     assertEquals(0, buffer.refCnt());
    // }

    // @Test
    // void testReleasesItsComponents2() {
    //     // It is important to use a pooled allocator here to ensure
    //     // the slices returned by readRetainedSlice are of type
    //     // PooledSlicedByteBuf, which maintains an independent refcount
    //     // (so that we can be sure to cover this case)
    //     ByteBuf buffer = PooledByteBufAllocator.DEFAULT.buffer(); // 1

    //     buffer.writeBytes(cast(byte[])[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

    //     // use readRetainedSlice this time - produces different kind of slices
    //     ByteBuf s1 = buffer.readRetainedSlice(2); // 2
    //     ByteBuf s2 = s1.readRetainedSlice(2); // 3
    //     ByteBuf s3 = s2.readRetainedSlice(2); // 4
    //     ByteBuf s4 = s3.readRetainedSlice(2); // 5

    //     ByteBuf composite = Unpooled.compositeBuffer()
    //         .addComponent(s1)
    //         .addComponents(s2, s3, s4)
    //         .order(ByteOrder.LITTLE_ENDIAN);

    //     assertEquals(1, composite.refCnt());
    //     assertEquals(2, buffer.refCnt());

    //     // releasing composite should release the 4 components
    //     composite.release();
    //     assertEquals(0, composite.refCnt());
    //     assertEquals(1, buffer.refCnt());

    //     // last remaining ref to buffer
    //     buffer.release();
    //     assertEquals(0, buffer.refCnt());
    // }

    // @Test
    // void testReleasesOnShrink() {

    //     ByteBuf b1 = Unpooled.buffer(2).writeShort(1);
    //     ByteBuf b2 = Unpooled.buffer(2).writeShort(2);

    //     // composite takes ownership of s1 and s2
    //     ByteBuf composite = Unpooled.compositeBuffer()
    //         .addComponents(b1, b2);

    //     assertEquals(4, composite.capacity());

    //     // reduce capacity down to two, will drop the second component
    //     composite.capacity(2);
    //     assertEquals(2, composite.capacity());

    //     // releasing composite should release the components
    //     composite.release();
    //     assertEquals(0, composite.refCnt());
    //     assertEquals(0, b1.refCnt());
    //     assertEquals(0, b2.refCnt());
    // }

    // @Test
    // void testReleasesOnShrink2() {
    //     // It is important to use a pooled allocator here to ensure
    //     // the slices returned by readRetainedSlice are of type
    //     // PooledSlicedByteBuf, which maintains an independent refcount
    //     // (so that we can be sure to cover this case)
    //     ByteBuf buffer = PooledByteBufAllocator.DEFAULT.buffer();

    //     buffer.writeShort(1).writeShort(2);

    //     ByteBuf b1 = buffer.readRetainedSlice(2);
    //     ByteBuf b2 = b1.retainedSlice(b1.readerIndex(), 2);

    //     // composite takes ownership of b1 and b2
    //     ByteBuf composite = Unpooled.compositeBuffer()
    //         .addComponents(b1, b2);

    //     assertEquals(4, composite.capacity());

    //     // reduce capacity down to two, will drop the second component
    //     composite.capacity(2);
    //     assertEquals(2, composite.capacity());

    //     // releasing composite should release the components
    //     composite.release();
    //     assertEquals(0, composite.refCnt());
    //     assertEquals(0, b1.refCnt());
    //     assertEquals(0, b2.refCnt());

    //     // release last remaining ref to buffer
    //     buffer.release();
    //     assertEquals(0, buffer.refCnt());
    // }

    // @Test
    // void testAllocatorIsSameWhenCopy() {
    //     testAllocatorIsSameWhenCopy(false);
    // }

    // @Test
    // void testAllocatorIsSameWhenCopyUsingIndexAndLength() {
    //     testAllocatorIsSameWhenCopy(true);
    // }

    // private void testAllocatorIsSameWhenCopy(bool withIndexAndLength) {
    //     ByteBuf buffer = newBuffer(8);
    //     buffer.writeZero(4);
    //     ByteBuf copy = withIndexAndLength ? buffer.copy(0, 4) : buffer.copy();
    //     assertEquals(buffer, copy);
    //     assertEquals(buffer.isDirect(), copy.isDirect());
    //     assertSame(buffer.alloc(), copy.alloc());
    //     buffer.release();
    //     copy.release();
    // }

    // @Test
    // void testDecomposeMultiple() {
    //     testDecompose(150, 500, 3);
    // }

    // @Test
    // void testDecomposeOne() {
    //     testDecompose(310, 50, 1);
    // }

    // @Test
    // void testDecomposeNone() {
    //     testDecompose(310, 0, 0);
    // }

    // private static void testDecompose(int offset, int length, int expectedListSize) {
    //     byte[] bytes = new byte[1024];
    //     PlatformDependent.threadLocalRandom().nextBytes(bytes);
    //     ByteBuf buf = wrappedBuffer(bytes);

    //     CompositeByteBuf composite = compositeBuffer();
    //     composite.addComponents(true,
    //                             buf.retainedSlice(100, 200),
    //                             buf.retainedSlice(300, 400),
    //                             buf.retainedSlice(700, 100));

    //     ByteBuf slice = composite.slice(offset, length);
    //     List!(ByteBuf) bufferList = composite.decompose(offset, length);
    //     assertEquals(expectedListSize, bufferList.size());
    //     ByteBuf wrapped = wrappedBuffer(bufferList.toArray(new ByteBuf[0]));

    //     assertEquals(slice, wrapped);
    //     composite.release();
    //     buf.release();

    //     foreach(ByteBuf buffer; bufferList) {
    //         assertEquals(0, buffer.refCnt());
    //     }
    // }

    // @Test
    // void testComponentsLessThanLowerBound() {
    //     try {
    //         new CompositeByteBuf(ALLOC, true, 0);
    //         fail();
    //     } catch (IllegalArgumentException e) {
    //         assertEquals("maxNumComponents: 0 (expected: >= 1)", e.getMessage());
    //     }
    // }

    // @Test
    // void testComponentsEqualToLowerBound() {
    //     assertCompositeBufCreated(1);
    // }

    // @Test
    // void testComponentsGreaterThanLowerBound() {
    //     assertCompositeBufCreated(5);
    // }

    // /**
    //  * Assert that a new {@linkplain CompositeByteBuf} was created successfully with the desired number of max
    //  * components.
    //  */
    // private static void assertCompositeBufCreated(int expectedMaxComponents) {
    //     CompositeByteBuf buf = new CompositeByteBuf(ALLOC, true, expectedMaxComponents);

    //     assertEquals(expectedMaxComponents, buf.maxNumComponents());
    //     assertTrue(buf.release());
    // }

    // @Test
    // void testDiscardSomeReadBytesCorrectlyUpdatesLastAccessed() {
    //     testDiscardCorrectlyUpdatesLastAccessed(true);
    // }

    // @Test
    // void testDiscardReadBytesCorrectlyUpdatesLastAccessed() {
    //     testDiscardCorrectlyUpdatesLastAccessed(false);
    // }

    // private static void testDiscardCorrectlyUpdatesLastAccessed(bool discardSome) {
    //     CompositeByteBuf cbuf = compositeBuffer();
    //     List!(ByteBuf) buffers = new ArrayList!(ByteBuf)(4);
    //     for (int i = 0; i < 4; i++) {
    //         ByteBuf buf = buffer().writeInt(i);
    //         cbuf.addComponent(true, buf);
    //         buffers.add(buf);
    //     }

    //     // Skip the first 2 bytes which means even if we call discard*ReadBytes() later we can no drop the first
    //     // component as it is still used.
    //     cbuf.skipBytes(2);
    //     if (discardSome) {
    //         cbuf.discardSomeReadBytes();
    //     } else {
    //         cbuf.discardReadBytes();
    //     }
    //     assertEquals(4, cbuf.numComponents());

    //     // Now skip 3 bytes which means we should be able to drop the first component on the next discard*ReadBytes()
    //     // call.
    //     cbuf.skipBytes(3);

    //     if (discardSome) {
    //         cbuf.discardSomeReadBytes();
    //     } else {
    //         cbuf.discardReadBytes();
    //     }
    //     assertEquals(3, cbuf.numComponents());
    //     // Now skip again 3 bytes which should bring our readerIndex == start of the 3 component.
    //     cbuf.skipBytes(3);

    //     // Read one int (4 bytes) which should bring our readerIndex == start of the 4 component.
    //     assertEquals(2, cbuf.readInt());
    //     if (discardSome) {
    //         cbuf.discardSomeReadBytes();
    //     } else {
    //         cbuf.discardReadBytes();
    //     }

    //     // Now all except the last component should have been dropped / released.
    //     assertEquals(1, cbuf.numComponents());
    //     assertEquals(3, cbuf.readInt());
    //     if (discardSome) {
    //         cbuf.discardSomeReadBytes();
    //     } else {
    //         cbuf.discardReadBytes();
    //     }
    //     assertEquals(0, cbuf.numComponents());

    //     // These should have been released already.
    //     foreach(ByteBuf buffer; buffers) {
    //         assertEquals(0, buffer.refCnt());
    //     }
    //     assertTrue(cbuf.release());
    // }
}
