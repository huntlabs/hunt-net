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
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
module hunt.net.buffer.UnpooledHeapByteBuf;

import hunt.net.buffer.AbstractByteBuf;
import hunt.net.buffer.AbstractReferenceCountedByteBuf;
import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufAllocator;
import hunt.net.buffer.ByteBufUtil;
import hunt.net.buffer.HeapByteBufUtil;

import hunt.Byte;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.Exceptions;
import hunt.net.Exceptions;
import hunt.io.Common;
import hunt.text.StringBuilder;

import std.conv;
import std.format;

// import io.netty.util.internal.EmptyArrays;
// import io.netty.util.internal.PlatformDependent;

// import java.io.IOException;
// import java.io.InputStream;
// import java.io.OutputStream;
// import java.nio.ByteBuffer;
// import java.nio.ByteOrder;
// import java.nio.channels.ClosedChannelException;
// import java.nio.channels.FileChannel;
// import java.nio.channels.GatheringByteChannel;
// import java.nio.channels.ScatteringByteChannel;


/**
 * Big endian Java heap buffer implementation. It is recommended to use
 * {@link UnpooledByteBufAllocator#heapBuffer(int, int)}, {@link Unpooled#buffer(int)} and
 * {@link Unpooled#wrappedBuffer(byte[])} instead of calling the constructor explicitly.
 */
class UnpooledHeapByteBuf : AbstractReferenceCountedByteBuf {

    private ByteBufAllocator _alloc;
    byte[] _array;
    private ByteBuffer tmpNioBuf;

    /**
     * Creates a new heap buffer with a newly allocated byte array.
     *
     * @param initialCapacity the initial capacity of the underlying byte array
     * @param maxCapacity the max capacity of the underlying byte array
     */
    this(ByteBufAllocator alloc, int initialCapacity, int maxCapacity) {
        super(maxCapacity);

        checkNotNull(alloc, "alloc");

        if (initialCapacity > maxCapacity) {
            throw new IllegalArgumentException(format(
                    "initialCapacity(%d) > maxCapacity(%d)", initialCapacity, maxCapacity));
        }

        this._alloc = alloc;
        setArray(allocateArray(initialCapacity));
        setIndex(0, 0);
    }

    /**
     * Creates a new heap buffer with an existing byte array.
     *
     * @param initialArray the initial underlying byte array
     * @param maxCapacity the max capacity of the underlying byte array
     */
    this(ByteBufAllocator alloc, byte[] initialArray, int maxCapacity) {
        super(maxCapacity);

        checkNotNull(alloc, "alloc");
        checkNotNull(initialArray, "initialArray");

        if (initialArray.length > maxCapacity) {
            throw new IllegalArgumentException(format(
                    "initialCapacity(%d) > maxCapacity(%d)", initialArray.length, maxCapacity));
        }

        this._alloc = alloc;
        setArray(initialArray);
        setIndex(0, cast(int)initialArray.length);
    }

    protected byte[] allocateArray(int initialCapacity) {
        return new byte[initialCapacity];
    }

    protected void freeArray(byte[]) {
        // NOOP
    }

    private void setArray(byte[] initialArray) {
        _array = initialArray;
        tmpNioBuf = null;
    }

    override
    ByteBufAllocator alloc() {
        return _alloc;
    }

    override
    ByteOrder order() {
        return ByteOrder.BigEndian;
    }

    override
    bool isDirect() {
        return false;
    }

    override
    int capacity() {
        return cast(int)_array.length;
    }

    override
    ByteBuf capacity(int newCapacity) {
        checkNewCapacity(newCapacity);

        int oldCapacity = cast(int)_array.length;
        byte[] oldArray = _array;
        if (newCapacity > oldCapacity) {
            byte[] newArray = allocateArray(newCapacity);
            // System.arraycopy(oldArray, 0, newArray, 0, oldArray.length);
            newArray[0..oldArray.length] = oldArray[0 .. $];
            setArray(newArray);
            freeArray(oldArray);
        } else if (newCapacity < oldCapacity) {
            byte[] newArray = allocateArray(newCapacity);
            int rIndex = readerIndex();
            if (rIndex < newCapacity) {
                int wIndex = writerIndex();
                if (wIndex > newCapacity) {
                    wIndex = newCapacity;
                    writerIndex(wIndex);
                }
                // System.arraycopy(oldArray, rIndex, newArray, rIndex, wIndex - rIndex);
                newArray[rIndex .. wIndex] = oldArray[rIndex .. wIndex];
            } else {
                setIndex(newCapacity, newCapacity);
            }
            setArray(newArray);
            freeArray(oldArray);
        }
        return this;
    }

    override
    bool hasArray() {
        return true;
    }

    override
    byte[] array() {
        ensureAccessible();
        return _array;
    }

    override
    int arrayOffset() {
        return 0;
    }

    override
    bool hasMemoryAddress() {
        return false;
    }

    override
    long memoryAddress() {
        throw new UnsupportedOperationException();
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst, int dstIndex, int length) {
        checkDstIndex(index, length, dstIndex, dst.capacity());
        // if (dst.hasMemoryAddress()) {
        //     PlatformDependent.copyMemory(_array, index, dst.memoryAddress() + dstIndex, length);
        // } else if (dst.hasArray()) {
        //     getBytes(index, dst.array(), dst.arrayOffset() + dstIndex, length);
        // } else {
        //     dst.setBytes(dstIndex, _array, index, length);
        // }
        if (dst.hasArray()) {
            getBytes(index, dst.array(), dst.arrayOffset() + dstIndex, length);
        } else {
            dst.setBytes(dstIndex, _array, index, length);
        }        
        return this;
    }

    override
    ByteBuf getBytes(int index, byte[] dst, int dstIndex, int length) {
        checkDstIndex(index, length, dstIndex, cast(int)dst.length);
        // System.arraycopy(_array, index, dst, dstIndex, length);
        dst[dstIndex .. dstIndex + length] = _array[index .. index+length];
        return this;
    }

    override
    ByteBuf getBytes(int index, ByteBuffer dst) {
        ensureAccessible();
        dst.put(_array, index, dst.remaining());
        return this;
    }

    override
    ByteBuf getBytes(int index, OutputStream output, int length) {
        ensureAccessible();
        output.write(_array, index, length);
        return this;
    }

    // override
    // int getBytes(int index, GatheringByteChannel output, int length) {
    //     ensureAccessible();
    //     return getBytes(index, output, length, false);
    // }

    // override
    // int getBytes(int index, FileChannel output, long position, int length) {
    //     ensureAccessible();
    //     return getBytes(index, output, position, length, false);
    // }

    // private int getBytes(int index, GatheringByteChannel output, int length, bool internal) {
    //     ensureAccessible();
    //     ByteBuffer tmpBuf;
    //     if (internal) {
    //         tmpBuf = internalNioBuffer();
    //     } else {
    //         tmpBuf = ByteBuffer.wrap(_array);
    //     }
    //     return output.write(cast(ByteBuffer) tmpBuf.clear().position(index).limit(index + length));
    // }

    // private int getBytes(int index, FileChannel output, long position, int length, bool internal) {
    //     ensureAccessible();
    //     ByteBuffer tmpBuf = internal ? internalNioBuffer() : ByteBuffer.wrap(_array);
    //     return output.write(cast(ByteBuffer) tmpBuf.clear().position(index).limit(index + length), position);
    // }

    // override
    // int readBytes(GatheringByteChannel output, int length) {
    //     checkReadableBytes(length);
    //     int readBytes = getBytes(readerIndex, output, length, true);
    //     readerIndex += readBytes;
    //     return readBytes;
    // }

    // override
    // int readBytes(FileChannel output, long position, int length) {
    //     checkReadableBytes(length);
    //     int readBytes = getBytes(readerIndex, output, position, length, true);
    //     readerIndex += readBytes;
    //     return readBytes;
    // }

    override
    ByteBuf setBytes(int index, ByteBuf src, int srcIndex, int length) {
        checkSrcIndex(index, length, srcIndex, src.capacity());
        // if (src.hasMemoryAddress()) {
        //     PlatformDependent.copyMemory(src.memoryAddress() + srcIndex, _array, index, length);
        // } else  if (src.hasArray()) {
        //     setBytes(index, src.array(), src.arrayOffset() + srcIndex, length);
        // } else {
        //     src.getBytes(srcIndex, _array, index, length);
        // }
        
        if (src.hasArray()) {
            setBytes(index, src.array(), src.arrayOffset() + srcIndex, length);
        } else {
            src.getBytes(srcIndex, _array, index, length);
        }        
        return this;
    }

    override
    ByteBuf setBytes(int index, byte[] src, int srcIndex, int length) {
        checkSrcIndex(index, length, srcIndex, cast(int)src.length);
        // System.arraycopy(src, srcIndex, _array, index, length);
        _array[index .. index+length] = src[srcIndex .. srcIndex+length];
        return this;
    }

    override
    ByteBuf setBytes(int index, ByteBuffer src) {
        ensureAccessible();
        src.get(_array, index, src.remaining());
        return this;
    }

    override
    int setBytes(int index, InputStream input, int length) {
        ensureAccessible();
        return input.read(_array, index, length);
    }

    // override
    // int setBytes(int index, ScatteringByteChannel input, int length) {
    //     ensureAccessible();
    //     try {
    //         return input.read(cast(ByteBuffer) internalNioBuffer().clear().position(index).limit(index + length));
    //     } catch (ClosedChannelException ignored) {
    //         return -1;
    //     }
    // }

    // override
    // int setBytes(int index, FileChannel input, long position, int length) {
    //     ensureAccessible();
    //     try {
    //         return input.read(cast(ByteBuffer) internalNioBuffer().clear().position(index).limit(index + length), position);
    //     } catch (ClosedChannelException ignored) {
    //         return -1;
    //     }
    // }

    override
    int nioBufferCount() {
        return 1;
    }

    override
    ByteBuffer nioBuffer(int index, int length) {
        ensureAccessible();
        return BufferUtils.wrap(_array, index, length).slice();
    }

    override
    ByteBuffer[] nioBuffers(int index, int length) {
        return [nioBuffer(index, length)];
    }

    override
    ByteBuffer internalNioBuffer(int index, int length) {
        checkIndex(index, length);
        return cast(ByteBuffer) internalNioBuffer().clear().position(index).limit(index + length);
    }

    override
    byte getByte(int index) {
        ensureAccessible();
        return _getByte(index);
    }

    override
    protected byte _getByte(int index) {
        return HeapByteBufUtil.getByte(_array, index);
    }

    override
    short getShort(int index) {
        ensureAccessible();
        return _getShort(index);
    }

    override
    protected short _getShort(int index) {
        return HeapByteBufUtil.getShort(_array, index);
    }

    override
    short getShortLE(int index) {
        ensureAccessible();
        return _getShortLE(index);
    }

    override
    protected short _getShortLE(int index) {
        return HeapByteBufUtil.getShortLE(_array, index);
    }

    override
    int getUnsignedMedium(int index) {
        ensureAccessible();
        return _getUnsignedMedium(index);
    }

    override
    protected int _getUnsignedMedium(int index) {
        return HeapByteBufUtil.getUnsignedMedium(_array, index);
    }

    override
    int getUnsignedMediumLE(int index) {
        ensureAccessible();
        return _getUnsignedMediumLE(index);
    }

    override
    protected int _getUnsignedMediumLE(int index) {
        return HeapByteBufUtil.getUnsignedMediumLE(_array, index);
    }

    override
    int getInt(int index) {
        ensureAccessible();
        return _getInt(index);
    }

    override
    protected int _getInt(int index) {
        return HeapByteBufUtil.getInt(_array, index);
    }

    override
    int getIntLE(int index) {
        ensureAccessible();
        return _getIntLE(index);
    }

    override
    protected int _getIntLE(int index) {
        return HeapByteBufUtil.getIntLE(_array, index);
    }

    override
    long getLong(int index) {
        ensureAccessible();
        return _getLong(index);
    }

    override
    protected long _getLong(int index) {
        return HeapByteBufUtil.getLong(_array, index);
    }

    override
    long getLongLE(int index) {
        ensureAccessible();
        return _getLongLE(index);
    }

    override
    protected long _getLongLE(int index) {
        return HeapByteBufUtil.getLongLE(_array, index);
    }

    override
    ByteBuf setByte(int index, int value) {
        ensureAccessible();
        _setByte(index, value);
        return this;
    }

    override
    protected void _setByte(int index, int value) {
        HeapByteBufUtil.setByte(_array, index, value);
    }

    override
    ByteBuf setShort(int index, int value) {
        ensureAccessible();
        _setShort(index, value);
        return this;
    }

    override
    protected void _setShort(int index, int value) {
        HeapByteBufUtil.setShort(_array, index, value);
    }

    override
    ByteBuf setShortLE(int index, int value) {
        ensureAccessible();
        _setShortLE(index, value);
        return this;
    }

    override
    protected void _setShortLE(int index, int value) {
        HeapByteBufUtil.setShortLE(_array, index, value);
    }

    override
    ByteBuf setMedium(int index, int   value) {
        ensureAccessible();
        _setMedium(index, value);
        return this;
    }

    override
    protected void _setMedium(int index, int value) {
        HeapByteBufUtil.setMedium(_array, index, value);
    }

    override
    ByteBuf setMediumLE(int index, int   value) {
        ensureAccessible();
        _setMediumLE(index, value);
        return this;
    }

    override
    protected void _setMediumLE(int index, int value) {
        HeapByteBufUtil.setMediumLE(_array, index, value);
    }

    override
    ByteBuf setInt(int index, int   value) {
        ensureAccessible();
        _setInt(index, value);
        return this;
    }

    override
    protected void _setInt(int index, int value) {
        HeapByteBufUtil.setInt(_array, index, value);
    }

    override
    ByteBuf setIntLE(int index, int   value) {
        ensureAccessible();
        _setIntLE(index, value);
        return this;
    }

    override
    protected void _setIntLE(int index, int value) {
        HeapByteBufUtil.setIntLE(_array, index, value);
    }

    override
    ByteBuf setLong(int index, long  value) {
        ensureAccessible();
        _setLong(index, value);
        return this;
    }

    override
    protected void _setLong(int index, long value) {
        HeapByteBufUtil.setLong(_array, index, value);
    }

    override
    ByteBuf setLongLE(int index, long  value) {
        ensureAccessible();
        _setLongLE(index, value);
        return this;
    }

    override
    protected void _setLongLE(int index, long value) {
        HeapByteBufUtil.setLongLE(_array, index, value);
    }

    override
    ByteBuf copy(int index, int length) {
        checkIndex(index, length);
        return alloc().heapBuffer(length, maxCapacity()).writeBytes(_array, index, length);
    }

    private ByteBuffer internalNioBuffer() {
        ByteBuffer tmpNioBuf = this.tmpNioBuf;
        if (tmpNioBuf is null) {
            this.tmpNioBuf = tmpNioBuf = BufferUtils.wrap(_array);
        }
        return tmpNioBuf;
    }

    override
    protected void deallocate() {
        freeArray(_array);
        _array = [];
    }

    override
    ByteBuf unwrap() {
        return null;
    }
}
