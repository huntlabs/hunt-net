/*
 * Copyright 2013 The Netty Project
 *
 * The Netty Project licenses this file to you under the Apache License,
 * version 2.0 (the "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at:
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
module hunt.net.buffer.ReadOnlyByteBufferBuf;

import hunt.net.buffer.AbstractByteBuf;
import hunt.net.buffer.AbstractReferenceCountedByteBuf;
import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufAllocator;
import hunt.net.buffer.ByteBufUtil;

import hunt.Byte;
import hunt.collection.ByteBuffer;
import hunt.Exceptions;
import hunt.net.Exceptions;
import hunt.io.Common;
import hunt.text.StringBuilder;

import std.conv;
import std.format;

// import io.netty.util.internal.StringUtil;

// import java.io.IOException;
// import java.io.InputStream;
// import java.io.OutputStream;
// import java.nio.ByteBuffer;
// import java.nio.ByteOrder;
// import java.nio.ReadOnlyBufferException;
// import java.nio.channels.FileChannel;
// import java.nio.channels.GatheringByteChannel;
// import java.nio.channels.ScatteringByteChannel;


/**
 * Read-only ByteBuf which wraps a read-only ByteBuffer.
 */
class ReadOnlyByteBufferBuf : AbstractReferenceCountedByteBuf {

    protected ByteBuffer buffer;
    private ByteBufAllocator allocator;
    private ByteBuffer tmpNioBuf;

    this(ByteBufAllocator allocator, ByteBuffer buffer) {
        super(buffer.remaining());
        if (!buffer.isReadOnly()) {
            throw new IllegalArgumentException("must be a readonly buffer: " ~ typeid(buffer).name);
        }

        this.allocator = allocator;
        this.buffer = buffer.slice().order(ByteOrder.BigEndian);
        writerIndex(this.buffer.limit());
    }

    override
    protected void deallocate() { }

    override
    bool isWritable() {
        return false;
    }

    override
    bool isWritable(int numBytes) {
        return false;
    }

    override
    ByteBuf ensureWritable(int minWritableBytes) {
        throw new ReadOnlyBufferException();
    }

    override
    int ensureWritable(int minWritableBytes, bool force) {
        return 1;
    }

    override
    byte getByte(int index) {
        ensureAccessible();
        return _getByte(index);
    }

    override
    protected byte _getByte(int index) {
        return buffer.get(index);
    }

    override
    short getShort(int index) {
        ensureAccessible();
        return _getShort(index);
    }

    override
    protected short _getShort(int index) {
        return buffer.getShort(index);
    }

    override
    short getShortLE(int index) {
        ensureAccessible();
        return _getShortLE(index);
    }

    override
    protected short _getShortLE(int index) {
        return ByteBufUtil.swapShort(buffer.getShort(index));
    }

    override
    int getUnsignedMedium(int index) {
        ensureAccessible();
        return _getUnsignedMedium(index);
    }

    override
    protected int _getUnsignedMedium(int index) {
        return (getByte(index) & 0xff)     << 16 |
               (getByte(index + 1) & 0xff) << 8  |
               getByte(index + 2) & 0xff;
    }

    override
    int getUnsignedMediumLE(int index) {
        ensureAccessible();
        return _getUnsignedMediumLE(index);
    }

    override
    protected int _getUnsignedMediumLE(int index) {
        return getByte(index)      & 0xff       |
               (getByte(index + 1) & 0xff) << 8 |
               (getByte(index + 2) & 0xff) << 16;
    }

    override
    int getInt(int index) {
        ensureAccessible();
        return _getInt(index);
    }

    override
    protected int _getInt(int index) {
        return buffer.getInt(index);
    }

    override
    int getIntLE(int index) {
        ensureAccessible();
        return _getIntLE(index);
    }

    override
    protected int _getIntLE(int index) {
        return ByteBufUtil.swapInt(buffer.getInt(index));
    }

    override
    long getLong(int index) {
        ensureAccessible();
        return _getLong(index);
    }

    override
    protected long _getLong(int index) {
        return buffer.getLong(index);
    }

    override
    long getLongLE(int index) {
        ensureAccessible();
        return _getLongLE(index);
    }

    override
    protected long _getLongLE(int index) {
        return ByteBufUtil.swapLong(buffer.getLong(index));
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst, int dstIndex, int length) {
        checkDstIndex(index, length, dstIndex, dst.capacity());
        if (dst.hasArray()) {
            getBytes(index, dst.array(), dst.arrayOffset() + dstIndex, length);
        } else if (dst.nioBufferCount() > 0) {
            foreach(ByteBuffer bb; dst.nioBuffers(dstIndex, length)) {
                int bbLen = bb.remaining();
                getBytes(index, bb);
                index += bbLen;
            }
        } else {
            dst.setBytes(dstIndex, this, index, length);
        }
        return this;
    }

    override
    ByteBuf getBytes(int index, byte[] dst, int dstIndex, int length) {
        checkDstIndex(index, length, dstIndex, cast(int)dst.length);

        ByteBuffer tmpBuf = internalNioBuffer();
        tmpBuf.clear().position(index).limit(index + length);
        tmpBuf.get(dst, dstIndex, length);
        return this;
    }

    override
    ByteBuf getBytes(int index, ByteBuffer dst) {
        checkIndex(index, dst.remaining());

        ByteBuffer tmpBuf = internalNioBuffer();
        tmpBuf.clear().position(index).limit(index + dst.remaining());
        dst.put(tmpBuf);
        return this;
    }

    override
    ByteBuf setByte(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    protected void _setByte(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBuf setShort(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    protected void _setShort(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBuf setShortLE(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    protected void _setShortLE(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBuf setMedium(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    protected void _setMedium(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBuf setMediumLE(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    protected void _setMediumLE(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBuf setInt(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    protected void _setInt(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBuf setIntLE(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    protected void _setIntLE(int index, int value) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBuf setLong(int index, long value) {
        throw new ReadOnlyBufferException();
    }

    override
    protected void _setLong(int index, long value) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBuf setLongLE(int index, long value) {
        throw new ReadOnlyBufferException();
    }

    override
    protected void _setLongLE(int index, long value) {
        throw new ReadOnlyBufferException();
    }

    override
    int capacity() {
        return maxCapacity();
    }

    override
    ByteBuf capacity(int newCapacity) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBufAllocator alloc() {
        return allocator;
    }

    override
    ByteOrder order() {
        return ByteOrder.BigEndian;
    }

    override
    ByteBuf unwrap() {
        return null;
    }

    override
    bool isReadOnly() {
        return buffer.isReadOnly();
    }

    override
    bool isDirect() {
        return buffer.isDirect();
    }

    override
    ByteBuf getBytes(int index, OutputStream output, int length) {
        ensureAccessible();
        if (length == 0) {
            return this;
        }

        if (buffer.hasArray()) {
            output.write(buffer.array(), index + buffer.arrayOffset(), length);
        } else {
            byte[] tmp = ByteBufUtil.threadLocalTempArray(length);
            ByteBuffer tmpBuf = internalNioBuffer();
            tmpBuf.clear().position(index);
            tmpBuf.get(tmp, 0, length);
            output.write(tmp, 0, length);
        }
        return this;
    }

    // override
    // int getBytes(int index, GatheringByteChannel output, int length) {
    //     ensureAccessible();
    //     if (length == 0) {
    //         return 0;
    //     }

    //     ByteBuffer tmpBuf = internalNioBuffer();
    //     tmpBuf.clear().position(index).limit(index + length);
    //     return output.write(tmpBuf);
    // }

    // override
    // int getBytes(int index, FileChannel output, long position, int length) {
    //     ensureAccessible();
    //     if (length == 0) {
    //         return 0;
    //     }

    //     ByteBuffer tmpBuf = internalNioBuffer();
    //     tmpBuf.clear().position(index).limit(index + length);
    //     return output.write(tmpBuf, position);
    // }

    override
    ByteBuf setBytes(int index, ByteBuf src, int srcIndex, int length) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBuf setBytes(int index, byte[] src, int srcIndex, int length) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBuf setBytes(int index, ByteBuffer src) {
        throw new ReadOnlyBufferException();
    }

    override
    int setBytes(int index, InputStream input, int length) {
        throw new ReadOnlyBufferException();
    }

    // override
    // int setBytes(int index, ScatteringByteChannel input, int length) {
    //     throw new ReadOnlyBufferException();
    // }

    // override
    // int setBytes(int index, FileChannel input, long position, int length) {
    //     throw new ReadOnlyBufferException();
    // }

    protected final ByteBuffer internalNioBuffer() {
        ByteBuffer tmpNioBuf = this.tmpNioBuf;
        if (tmpNioBuf is null) {
            this.tmpNioBuf = tmpNioBuf = buffer.duplicate();
        }
        return tmpNioBuf;
    }

    override
    ByteBuf copy(int index, int length) {
        ensureAccessible();
        ByteBuffer src;
        try {
            src = cast(ByteBuffer) internalNioBuffer().clear().position(index).limit(index + length);
        } catch (IllegalArgumentException ignored) {
            throw new IndexOutOfBoundsException("Too many bytes to read - Need " ~ to!string(index + length));
        }

        ByteBuf dst = src.isDirect() ? alloc().directBuffer(length) : alloc().heapBuffer(length);
        dst.writeBytes(src);
        return dst;
    }

    override
    int nioBufferCount() {
        return 1;
    }

    override
    ByteBuffer[] nioBuffers(int index, int length) {
        return [nioBuffer(index, length)];
    }

    override
    ByteBuffer nioBuffer(int index, int length) {
        checkIndex(index, length);
        return cast(ByteBuffer) buffer.duplicate().position(index).limit(index + length);
    }

    override
    ByteBuffer internalNioBuffer(int index, int length) {
        ensureAccessible();
        return cast(ByteBuffer) internalNioBuffer().clear().position(index).limit(index + length);
    }

    override
    bool hasArray() {
        return buffer.hasArray();
    }

    override
    byte[] array() {
        return buffer.array();
    }

    override
    int arrayOffset() {
        return buffer.arrayOffset();
    }

    override
    bool hasMemoryAddress() {
        return false;
    }

    override
    long memoryAddress() {
        throw new UnsupportedOperationException();
    }
}
