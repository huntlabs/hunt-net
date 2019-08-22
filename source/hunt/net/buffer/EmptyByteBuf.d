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

module hunt.net.buffer.EmptyByteBuf;

import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufAllocator;
import hunt.net.buffer.ByteBufUtil;
import hunt.net.buffer.ByteProcessor;
import hunt.net.buffer.Unpooled;

import hunt.Byte;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.Exceptions;
import hunt.io.Common;
import hunt.net.Exceptions;
import hunt.text.StringBuilder;
import hunt.text.Charset;

import std.conv;
import std.format;
import std.concurrency : initOnce;


/**
 * An empty {@link ByteBuf} whose capacity and maximum capacity are all {@code 0}.
 */
final class EmptyByteBuf : ByteBuf {

    enum int EMPTY_BYTE_BUF_HASH_CODE = 1;
    private static ByteBuffer EMPTY_BYTE_BUFFER() {
        __gshared ByteBuffer inst;
        return initOnce!inst(BufferUtils.allocateDirect(0));
    }
    private enum long EMPTY_BYTE_BUFFER_ADDRESS = 0;

    // static {
    //     long emptyByteBufferAddress = 0;
    //     try {
    //         if (PlatformDependent.hasUnsafe()) {
    //             emptyByteBufferAddress = PlatformDependent.directBufferAddress(EMPTY_BYTE_BUFFER);
    //         }
    //     } catch (Throwable t) {
    //         // Ignore
    //     }
    //     EMPTY_BYTE_BUFFER_ADDRESS = emptyByteBufferAddress;
    // }

    private ByteBufAllocator _alloc;
    private ByteOrder _order;
    private string str;
    private EmptyByteBuf swapped;

    this(ByteBufAllocator alloc) {
        this(alloc, ByteOrder.BigEndian);
    }

    private this(ByteBufAllocator alloc, ByteOrder order) {
        if (alloc is null) {
            throw new NullPointerException("alloc");
        }

        this._alloc = alloc;
        this._order = order;
        str = typeid(this).name ~ (order == ByteOrder.BigEndian? "BE" : "LE");
    }

    override
    int capacity() {
        return 0;
    }

    override
    ByteBuf capacity(int newCapacity) {
        throw new ReadOnlyBufferException();
    }

    override
    ByteBufAllocator alloc() {
        return _alloc;
    }

    override
    ByteOrder order() {
        return _order;
    }

    override
    ByteBuf unwrap() {
        return null;
    }

    override
    ByteBuf asReadOnly() {
        // return Unpooled.unmodifiableBuffer(this);
// FIXME: Needing refactor or cleanup -@zxp at 8/15/2019, 5:34:57 PM        
// 
        implementationMissing(false);
        return this;
    }

    override
    bool isReadOnly() {
        return false;
    }

    override
    bool isDirect() {
        return true;
    }

    override
    int maxCapacity() {
        return 0;
    }

    // override
    // ByteBuf order(ByteOrder endianness) {
    //     // if (endianness == null) {
    //     //     throw new NullPointerException("endianness");
    //     // }
    //     if (endianness == order()) {
    //         return this;
    //     }

    //     EmptyByteBuf swapped = this.swapped;
    //     if (swapped != null) {
    //         return swapped;
    //     }

    //     this.swapped = swapped = new EmptyByteBuf(alloc(), endianness);
    //     return swapped;
    // }

    override
    int readerIndex() {
        return 0;
    }

    override
    ByteBuf readerIndex(int readerIndex) {
        return checkIndex(readerIndex);
    }

    override
    int writerIndex() {
        return 0;
    }

    override
    ByteBuf writerIndex(int writerIndex) {
        return checkIndex(writerIndex);
    }

    override
    ByteBuf setIndex(int readerIndex, int writerIndex) {
        checkIndex(readerIndex);
        checkIndex(writerIndex);
        return this;
    }

    override
    int readableBytes() {
        return 0;
    }

    override
    int writableBytes() {
        return 0;
    }

    override
    int maxWritableBytes() {
        return 0;
    }

    override
    bool isReadable() {
        return false;
    }

    override
    bool isWritable() {
        return false;
    }

    override
    ByteBuf clear() {
        return this;
    }

    override
    ByteBuf markReaderIndex() {
        return this;
    }

    override
    ByteBuf resetReaderIndex() {
        return this;
    }

    override
    ByteBuf markWriterIndex() {
        return this;
    }

    override
    ByteBuf resetWriterIndex() {
        return this;
    }

    override
    ByteBuf discardReadBytes() {
        return this;
    }

    override
    ByteBuf discardSomeReadBytes() {
        return this;
    }

    override
    ByteBuf ensureWritable(int minWritableBytes) {
        checkPositiveOrZero(minWritableBytes, "minWritableBytes");
        if (minWritableBytes != 0) {
            throw new IndexOutOfBoundsException();
        }
        return this;
    }

    override
    int ensureWritable(int minWritableBytes, bool force) {
        checkPositiveOrZero(minWritableBytes, "minWritableBytes");

        if (minWritableBytes == 0) {
            return 0;
        }

        return 1;
    }

    override
    bool getBoolean(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    byte getByte(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    short getUnsignedByte(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    short getShort(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    short getShortLE(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    int getUnsignedShort(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    int getUnsignedShortLE(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    int getMedium(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    int getMediumLE(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    int getUnsignedMedium(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    int getUnsignedMediumLE(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    int getInt(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    int getIntLE(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    long getUnsignedInt(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    long getUnsignedIntLE(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    long getLong(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    long getLongLE(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    char getChar(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    float getFloat(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    double getDouble(int index) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst) {
        return checkIndex(index, dst.writableBytes());
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst, int length) {
        return checkIndex(index, length);
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst, int dstIndex, int length) {
        return checkIndex(index, length);
    }

    override
    ByteBuf getBytes(int index, byte[] dst) {
        return checkIndex(index, cast(int)dst.length);
    }

    override
    ByteBuf getBytes(int index, byte[] dst, int dstIndex, int length) {
        return checkIndex(index, length);
    }

    override
    ByteBuf getBytes(int index, ByteBuffer dst) {
        return checkIndex(index, dst.remaining());
    }

    override
    ByteBuf getBytes(int index, OutputStream output, int length) {
        return checkIndex(index, length);
    }

    // override
    // int getBytes(int index, GatheringByteChannel output, int length) {
    //     checkIndex(index, length);
    //     return 0;
    // }

    // override
    // int getBytes(int index, FileChannel output, long position, int length) {
    //     checkIndex(index, length);
    //     return 0;
    // }

    override
    CharSequence getCharSequence(int index, int length, Charset charset) {
        checkIndex(index, length);
        return null;
    }

    override
    ByteBuf setBoolean(int index, bool value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setByte(int index, int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setShort(int index, int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setShortLE(int index, int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setMedium(int index, int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setMediumLE(int index, int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setInt(int index, int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setIntLE(int index, int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setLong(int index, long value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setLongLE(int index, long value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setChar(int index, int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setFloat(int index, float value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setDouble(int index, double value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setBytes(int index, ByteBuf src) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf setBytes(int index, ByteBuf src, int length) {
        return checkIndex(index, length);
    }

    override
    ByteBuf setBytes(int index, ByteBuf src, int srcIndex, int length) {
        return checkIndex(index, length);
    }

    override
    ByteBuf setBytes(int index, byte[] src) {
        return checkIndex(index, cast(int)src.length);
    }

    override
    ByteBuf setBytes(int index, byte[] src, int srcIndex, int length) {
        return checkIndex(index, length);
    }

    override
    ByteBuf setBytes(int index, ByteBuffer src) {
        return checkIndex(index, src.remaining());
    }

    override
    int setBytes(int index, InputStream input, int length) {
        checkIndex(index, length);
        return 0;
    }

    // override
    // int setBytes(int index, ScatteringByteChannel input, int length) {
    //     checkIndex(index, length);
    //     return 0;
    // }

    // override
    // int setBytes(int index, FileChannel input, long position, int length) {
    //     checkIndex(index, length);
    //     return 0;
    // }

    override
    ByteBuf setZero(int index, int length) {
        return checkIndex(index, length);
    }

    override
    int setCharSequence(int index, CharSequence sequence, Charset charset) {
        throw new IndexOutOfBoundsException();
    }

    override
    bool readBoolean() {
        throw new IndexOutOfBoundsException();
    }

    override
    byte readByte() {
        throw new IndexOutOfBoundsException();
    }

    override
    short readUnsignedByte() {
        throw new IndexOutOfBoundsException();
    }

    override
    short readShort() {
        throw new IndexOutOfBoundsException();
    }

    override
    short readShortLE() {
        throw new IndexOutOfBoundsException();
    }

    override
    int readUnsignedShort() {
        throw new IndexOutOfBoundsException();
    }

    override
    int readUnsignedShortLE() {
        throw new IndexOutOfBoundsException();
    }

    override
    int readMedium() {
        throw new IndexOutOfBoundsException();
    }

    override
    int readMediumLE() {
        throw new IndexOutOfBoundsException();
    }

    override
    int readUnsignedMedium() {
        throw new IndexOutOfBoundsException();
    }

    override
    int readUnsignedMediumLE() {
        throw new IndexOutOfBoundsException();
    }

    override
    int readInt() {
        throw new IndexOutOfBoundsException();
    }

    override
    int readIntLE() {
        throw new IndexOutOfBoundsException();
    }

    override
    long readUnsignedInt() {
        throw new IndexOutOfBoundsException();
    }

    override
    long readUnsignedIntLE() {
        throw new IndexOutOfBoundsException();
    }

    override
    long readLong() {
        throw new IndexOutOfBoundsException();
    }

    override
    long readLongLE() {
        throw new IndexOutOfBoundsException();
    }

    override
    char readChar() {
        throw new IndexOutOfBoundsException();
    }

    override
    float readFloat() {
        throw new IndexOutOfBoundsException();
    }

    override
    double readDouble() {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf readBytes(int length) {
        return checkLength(length);
    }

    override
    ByteBuf readSlice(int length) {
        return checkLength(length);
    }

    override
    ByteBuf readRetainedSlice(int length) {
        return checkLength(length);
    }

    override
    ByteBuf readBytes(ByteBuf dst) {
        return checkLength(dst.writableBytes());
    }

    override
    ByteBuf readBytes(ByteBuf dst, int length) {
        return checkLength(length);
    }

    override
    ByteBuf readBytes(ByteBuf dst, int dstIndex, int length) {
        return checkLength(length);
    }

    override
    ByteBuf readBytes(byte[] dst) {
        return checkLength(cast(int)dst.length);
    }

    override
    ByteBuf readBytes(byte[] dst, int dstIndex, int length) {
        return checkLength(length);
    }

    override
    ByteBuf readBytes(ByteBuffer dst) {
        return checkLength(dst.remaining());
    }

    override
    ByteBuf readBytes(OutputStream output, int length) {
        return checkLength(length);
    }

    // override
    // int readBytes(GatheringByteChannel output, int length) {
    //     checkLength(length);
    //     return 0;
    // }

    // override
    // int readBytes(FileChannel output, long position, int length) {
    //     checkLength(length);
    //     return 0;
    // }

    override
    CharSequence readCharSequence(int length, Charset charset) {
        checkLength(length);
        return "";
    }

    override
    ByteBuf skipBytes(int length) {
        return checkLength(length);
    }

    override
    ByteBuf writeBoolean(bool value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeByte(int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeShort(int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeShortLE(int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeMedium(int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeMediumLE(int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeInt(int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeIntLE(int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeLong(long value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeLongLE(long value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeChar(int value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeFloat(float value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeDouble(double value) {
        throw new IndexOutOfBoundsException();
    }

    override
    ByteBuf writeBytes(ByteBuf src) {
        return checkLength(src.readableBytes());
    }

    override
    ByteBuf writeBytes(ByteBuf src, int length) {
        return checkLength(length);
    }

    override
    ByteBuf writeBytes(ByteBuf src, int srcIndex, int length) {
        return checkLength(length);
    }

    override
    ByteBuf writeBytes(byte[] src) {
        return checkLength(cast(int)src.length);
    }

    override
    ByteBuf writeBytes(byte[] src, int srcIndex, int length) {
        return checkLength(length);
    }

    override
    ByteBuf writeBytes(ByteBuffer src) {
        return checkLength(src.remaining());
    }

    override
    int writeBytes(InputStream input, int length) {
        checkLength(length);
        return 0;
    }

    // override
    // int writeBytes(ScatteringByteChannel input, int length) {
    //     checkLength(length);
    //     return 0;
    // }

    // override
    // int writeBytes(FileChannel input, long position, int length) {
    //     checkLength(length);
    //     return 0;
    // }

    override
    ByteBuf writeZero(int length) {
        return checkLength(length);
    }

    override
    int writeCharSequence(CharSequence sequence, Charset charset) {
        throw new IndexOutOfBoundsException();
    }

    override
    int indexOf(int fromIndex, int toIndex, byte value) {
        checkIndex(fromIndex);
        checkIndex(toIndex);
        return -1;
    }

    override
    int bytesBefore(byte value) {
        return -1;
    }

    override
    int bytesBefore(int length, byte value) {
        checkLength(length);
        return -1;
    }

    override
    int bytesBefore(int index, int length, byte value) {
        checkIndex(index, length);
        return -1;
    }

    override
    int forEachByte(ByteProcessor processor) {
        return -1;
    }

    override
    int forEachByte(int index, int length, ByteProcessor processor) {
        checkIndex(index, length);
        return -1;
    }

    override
    int forEachByteDesc(ByteProcessor processor) {
        return -1;
    }

    override
    int forEachByteDesc(int index, int length, ByteProcessor processor) {
        checkIndex(index, length);
        return -1;
    }

    override
    ByteBuf copy() {
        return this;
    }

    override
    ByteBuf copy(int index, int length) {
        return checkIndex(index, length);
    }

    override
    ByteBuf slice() {
        return this;
    }

    override
    ByteBuf retainedSlice() {
        return this;
    }

    override
    ByteBuf slice(int index, int length) {
        return checkIndex(index, length);
    }

    override
    ByteBuf retainedSlice(int index, int length) {
        return checkIndex(index, length);
    }

    override
    ByteBuf duplicate() {
        return this;
    }

    override
    ByteBuf retainedDuplicate() {
        return this;
    }

    override
    int nioBufferCount() {
        return 1;
    }

    override
    ByteBuffer nioBuffer() {
        return EMPTY_BYTE_BUFFER;
    }

    override
    ByteBuffer nioBuffer(int index, int length) {
        checkIndex(index, length);
        return nioBuffer();
    }

    override
    ByteBuffer[] nioBuffers() {
        return [EMPTY_BYTE_BUFFER];
    }

    override
    ByteBuffer[] nioBuffers(int index, int length) {
        checkIndex(index, length);
        return nioBuffers();
    }

    override
    ByteBuffer internalNioBuffer(int index, int length) {
        return EMPTY_BYTE_BUFFER;
    }

    override
    bool hasArray() {
        return true;
    }

    override
    byte[] array() {
        return [];
    }

    override byte[] getReadableBytes() {
        return [];
    }

    override
    int arrayOffset() {
        return 0;
    }

    override
    bool hasMemoryAddress() {
        return EMPTY_BYTE_BUFFER_ADDRESS != 0;
    }

    override
    long memoryAddress() {
        if (hasMemoryAddress()) {
            return EMPTY_BYTE_BUFFER_ADDRESS;
        } else {
            throw new UnsupportedOperationException();
        }
    }

    override
    string toString(Charset charset) {
        return "";
    }

    override
    string toString(int index, int length, Charset charset) {
        checkIndex(index, length);
        return toString(charset);
    }

    override
    size_t toHash() @trusted nothrow {
        return EMPTY_BYTE_BUF_HASH_CODE;
    }

    override
    bool opEquals(Object obj) {
        if(this is obj) return true;
        ByteBuf b = cast(ByteBuf) obj;
        if(b is null) return false;

        return !b.isReadable();
    }

    override
    int compareTo(ByteBuf buffer) {
        return buffer.isReadable()? -1 : 0;
    }

    override
    string toString() {
        return str;
    }

    override
    bool isReadable(int size) {
        return false;
    }

    override
    bool isWritable(int size) {
        return false;
    }

    // override
    int refCnt() {
        return 1;
    }

    override
    ByteBuf retain() {
        return this;
    }

    override
    ByteBuf retain(int increment) {
        return this;
    }

    override
    ByteBuf touch() {
        return this;
    }

    override
    ByteBuf touch(Object hint) {
        return this;
    }

    // override
    bool release() {
        return false;
    }

    // override
    bool release(int decrement) {
        return false;
    }

    private ByteBuf checkIndex(int index) {
        if (index != 0) {
            throw new IndexOutOfBoundsException();
        }
        return this;
    }

    private ByteBuf checkIndex(int index, int length) {
        checkPositiveOrZero(length, "length");
        if (index != 0 || length != 0) {
            throw new IndexOutOfBoundsException();
        }
        return this;
    }

    private ByteBuf checkLength(int length) {
        checkPositiveOrZero(length, "length");
        if (length != 0) {
            throw new IndexOutOfBoundsException();
        }
        return this;
    }
}
