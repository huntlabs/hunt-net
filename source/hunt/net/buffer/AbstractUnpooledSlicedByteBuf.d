/*
 * Copyright 2016 The Netty Project
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
module hunt.net.buffer.AbstractUnpooledSlicedByteBuf;

import hunt.net.buffer.AbstractByteBuf;
import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufAllocator;
import hunt.net.buffer.ByteBufUtil;
import hunt.net.buffer.ByteProcessor;

import hunt.Byte;
import hunt.collection.ByteBuffer;
import hunt.Exceptions;
import hunt.net.Exceptions;
import hunt.io.Common;
import hunt.text.StringBuilder;

import std.conv;
import std.format;


// import java.io.IOException;
// import java.io.InputStream;
// import java.io.OutputStream;
// import java.nio.ByteBuffer;
// import java.nio.ByteOrder;
// import java.nio.channels.FileChannel;
// import java.nio.channels.GatheringByteChannel;
// import java.nio.channels.ScatteringByteChannel;
// import java.nio.charset.Charset;

// import static io.netty.util.internal.MathUtil.isOutOfBounds;

abstract class AbstractUnpooledSlicedByteBuf : AbstractByteBuf {
    private ByteBuf buffer;
    private int adjustment;

    this(ByteBuf buffer, int index, int length) {
        super(length);
        checkSliceOutOfBounds(index, length, buffer);

        AbstractUnpooledSlicedByteBuf slicedBuffer = cast(AbstractUnpooledSlicedByteBuf) buffer;

        if (slicedBuffer !is null) {
            this.buffer = slicedBuffer.buffer;
            adjustment = slicedBuffer.adjustment + index;
        // } else {
        //     if (buffer instanceof DuplicatedByteBuf) {
        //         this.buffer = buffer.unwrap();
        //         adjustment = index;
        //     }
        } else {
            this.buffer = buffer;
            adjustment = index;
        }

        initLength(length);
        writerIndex(length);
    }

    /**
     * Called by the constructor before {@link #writerIndex(int)}.
     * @param length the {@code length} argument from the constructor.
     */
    void initLength(int length) {
    }

    int length() {
        return capacity();
    }

    override
    ByteBuf unwrap() {
        return buffer;
    }

    override
    ByteBufAllocator alloc() {
        return unwrap().alloc();
    }

    override
    ByteOrder order() {
        return unwrap().order();
    }

    override
    bool isDirect() {
        return unwrap().isDirect();
    }

    override
    ByteBuf capacity(int newCapacity) {
        throw new UnsupportedOperationException("sliced buffer");
    }

    alias capacity = ByteBuf.capacity;

    override
    bool hasArray() {
        return unwrap().hasArray();
    }

    override
    byte[] array() {
        return unwrap().array();
    }

    override
    int arrayOffset() {
        return idx(unwrap().arrayOffset());
    }

    override
    bool hasMemoryAddress() {
        return unwrap().hasMemoryAddress();
    }

    override
    long memoryAddress() {
        return unwrap().memoryAddress() + adjustment;
    }

    override
    byte getByte(int index) {
        checkIndex0(index, 1);
        return unwrap().getByte(idx(index));
    }

    override
    protected byte _getByte(int index) {
        return unwrap().getByte(idx(index));
    }

    override
    short getShort(int index) {
        checkIndex0(index, 2);
        return unwrap().getShort(idx(index));
    }

    override
    protected short _getShort(int index) {
        return unwrap().getShort(idx(index));
    }

    override
    short getShortLE(int index) {
        checkIndex0(index, 2);
        return unwrap().getShortLE(idx(index));
    }

    override
    protected short _getShortLE(int index) {
        return unwrap().getShortLE(idx(index));
    }

    override
    int getUnsignedMedium(int index) {
        checkIndex0(index, 3);
        return unwrap().getUnsignedMedium(idx(index));
    }

    override
    protected int _getUnsignedMedium(int index) {
        return unwrap().getUnsignedMedium(idx(index));
    }

    override
    int getUnsignedMediumLE(int index) {
        checkIndex0(index, 3);
        return unwrap().getUnsignedMediumLE(idx(index));
    }

    override
    protected int _getUnsignedMediumLE(int index) {
        return unwrap().getUnsignedMediumLE(idx(index));
    }

    override
    int getInt(int index) {
        checkIndex0(index, 4);
        return unwrap().getInt(idx(index));
    }

    override
    protected int _getInt(int index) {
        return unwrap().getInt(idx(index));
    }

    override
    int getIntLE(int index) {
        checkIndex0(index, 4);
        return unwrap().getIntLE(idx(index));
    }

    override
    protected int _getIntLE(int index) {
        return unwrap().getIntLE(idx(index));
    }

    override
    long getLong(int index) {
        checkIndex0(index, 8);
        return unwrap().getLong(idx(index));
    }

    override
    protected long _getLong(int index) {
        return unwrap().getLong(idx(index));
    }

    override
    long getLongLE(int index) {
        checkIndex0(index, 8);
        return unwrap().getLongLE(idx(index));
    }

    override
    protected long _getLongLE(int index) {
        return unwrap().getLongLE(idx(index));
    }

    override
    ByteBuf duplicate() {
        return unwrap().duplicate().setIndex(idx(readerIndex()), idx(writerIndex()));
    }

    override
    ByteBuf copy(int index, int length) {
        checkIndex0(index, length);
        return unwrap().copy(idx(index), length);
    }

    override
    ByteBuf slice(int index, int length) {
        checkIndex0(index, length);
        return unwrap().slice(idx(index), length);
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst, int dstIndex, int length) {
        checkIndex0(index, length);
        unwrap().getBytes(idx(index), dst, dstIndex, length);
        return this;
    }

    override
    ByteBuf getBytes(int index, byte[] dst, int dstIndex, int length) {
        checkIndex0(index, length);
        unwrap().getBytes(idx(index), dst, dstIndex, length);
        return this;
    }

    override
    ByteBuf getBytes(int index, ByteBuffer dst) {
        checkIndex0(index, dst.remaining());
        unwrap().getBytes(idx(index), dst);
        return this;
    }

    override
    ByteBuf setByte(int index, int value) {
        checkIndex0(index, 1);
        unwrap().setByte(idx(index), value);
        return this;
    }

    // override
    // CharSequence getCharSequence(int index, int length, Charset charset) {
    //     checkIndex0(index, length);
    //     return unwrap().getCharSequence(idx(index), length, charset);
    // }

    override
    protected void _setByte(int index, int value) {
        unwrap().setByte(idx(index), value);
    }

    override
    ByteBuf setShort(int index, int value) {
        checkIndex0(index, 2);
        unwrap().setShort(idx(index), value);
        return this;
    }

    override
    protected void _setShort(int index, int value) {
        unwrap().setShort(idx(index), value);
    }

    override
    ByteBuf setShortLE(int index, int value) {
        checkIndex0(index, 2);
        unwrap().setShortLE(idx(index), value);
        return this;
    }

    override
    protected void _setShortLE(int index, int value) {
        unwrap().setShortLE(idx(index), value);
    }

    override
    ByteBuf setMedium(int index, int value) {
        checkIndex0(index, 3);
        unwrap().setMedium(idx(index), value);
        return this;
    }

    override
    protected void _setMedium(int index, int value) {
        unwrap().setMedium(idx(index), value);
    }

    override
    ByteBuf setMediumLE(int index, int value) {
        checkIndex0(index, 3);
        unwrap().setMediumLE(idx(index), value);
        return this;
    }

    override
    protected void _setMediumLE(int index, int value) {
        unwrap().setMediumLE(idx(index), value);
    }

    override
    ByteBuf setInt(int index, int value) {
        checkIndex0(index, 4);
        unwrap().setInt(idx(index), value);
        return this;
    }

    override
    protected void _setInt(int index, int value) {
        unwrap().setInt(idx(index), value);
    }

    override
    ByteBuf setIntLE(int index, int value) {
        checkIndex0(index, 4);
        unwrap().setIntLE(idx(index), value);
        return this;
    }

    override
    protected void _setIntLE(int index, int value) {
        unwrap().setIntLE(idx(index), value);
    }

    override
    ByteBuf setLong(int index, long value) {
        checkIndex0(index, 8);
        unwrap().setLong(idx(index), value);
        return this;
    }

    override
    protected void _setLong(int index, long value) {
        unwrap().setLong(idx(index), value);
    }

    override
    ByteBuf setLongLE(int index, long value) {
        checkIndex0(index, 8);
        unwrap().setLongLE(idx(index), value);
        return this;
    }

    override
    protected void _setLongLE(int index, long value) {
        unwrap().setLongLE(idx(index), value);
    }

    override
    ByteBuf setBytes(int index, byte[] src, int srcIndex, int length) {
        checkIndex0(index, length);
        unwrap().setBytes(idx(index), src, srcIndex, length);
        return this;
    }

    override
    ByteBuf setBytes(int index, ByteBuf src, int srcIndex, int length) {
        checkIndex0(index, length);
        unwrap().setBytes(idx(index), src, srcIndex, length);
        return this;
    }

    override
    ByteBuf setBytes(int index, ByteBuffer src) {
        checkIndex0(index, src.remaining());
        unwrap().setBytes(idx(index), src);
        return this;
    }

    override
    ByteBuf getBytes(int index, OutputStream output, int length) {
        checkIndex0(index, length);
        unwrap().getBytes(idx(index), output, length);
        return this;
    }

    // override
    // int getBytes(int index, GatheringByteChannel output, int length) {
    //     checkIndex0(index, length);
    //     return unwrap().getBytes(idx(index), output, length);
    // }

    // override
    // int getBytes(int index, FileChannel output, long position, int length) {
    //     checkIndex0(index, length);
    //     return unwrap().getBytes(idx(index), output, position, length);
    // }

    override
    int setBytes(int index, InputStream input, int length) {
        checkIndex0(index, length);
        return unwrap().setBytes(idx(index), input, length);
    }

    // override
    // int setBytes(int index, ScatteringByteChannel input, int length) {
    //     checkIndex0(index, length);
    //     return unwrap().setBytes(idx(index), input, length);
    // }

    // override
    // int setBytes(int index, FileChannel input, long position, int length) {
    //     checkIndex0(index, length);
    //     return unwrap().setBytes(idx(index), input, position, length);
    // }

    // override
    final int refCnt() {
        return refCnt0();
    }

    int refCnt0() {
        return unwrap().refCnt();
    }

    override
    final ByteBuf retain() {
        return retain0();
    }

    ByteBuf retain0() {
        unwrap().retain();
        return this;
    }

    override
    final ByteBuf retain(int increment) {
        return retain0(increment);
    }

    ByteBuf retain0(int increment) {
        unwrap().retain(increment);
        return this;
    }

    override
    final ByteBuf touch() {
        return touch0();
    }

    ByteBuf touch0() {
        unwrap().touch();
        return this;
    }

    override
    final ByteBuf touch(Object hint) {
        return touch0(hint);
    }

    ByteBuf touch0(Object hint) {
        unwrap().touch(hint);
        return this;
    }    

    // override
    final bool release() {
        return release0();
    }

    bool release0() {
        return unwrap().release();
    }

    // override
    final bool release(int decrement) {
        return release0(decrement);
    }

    bool release0(int decrement) {
        return unwrap().release(decrement);
    }

    override
    int nioBufferCount() {
        return unwrap().nioBufferCount();
    }

    override
    ByteBuffer internalNioBuffer(int index, int length) {
        return nioBuffer(index, length);
    }

    override
    ByteBuffer nioBuffer(int index, int length) {
        checkIndex0(index, length);
        return unwrap().nioBuffer(idx(index), length);
    }

    override
    ByteBuffer[] nioBuffers(int index, int length) {
        checkIndex0(index, length);
        return unwrap().nioBuffers(idx(index), length);
    }

    override
    int forEachByte(int index, int length, ByteProcessor processor) {
        checkIndex0(index, length);
        int ret = unwrap().forEachByte(idx(index), length, processor);
        if (ret >= adjustment) {
            return ret - adjustment;
        } else {
            return -1;
        }
    }

    override
    int forEachByteDesc(int index, int length, ByteProcessor processor) {
        checkIndex0(index, length);
        int ret = unwrap().forEachByteDesc(idx(index), length, processor);
        if (ret >= adjustment) {
            return ret - adjustment;
        } else {
            return -1;
        }
    }

    /**
     * Returns the index with the needed adjustment.
     */
    final int idx(int index) {
        return index + adjustment;
    }

    static void checkSliceOutOfBounds(int index, int length, ByteBuf buffer) {
        if (isOutOfBounds(index, length, buffer.capacity())) {
            throw new IndexOutOfBoundsException(buffer.toString() ~ ".slice(" ~ 
                index.to!string() ~ ", " ~ length.to!string() ~ ")");
        }
    }
}
