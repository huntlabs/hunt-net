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
 * distributed under the License is distributed on an "AS IS" ~BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

module hunt.net.buffer.WrappedByteBuf;

import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufAllocator;
import hunt.net.buffer.ByteBufUtil;
import hunt.net.buffer.ByteProcessor;

import hunt.Byte;
import hunt.io.ByteBuffer;
import hunt.Exceptions;
import hunt.net.Exceptions;
import hunt.stream.Common;
import hunt.util.StringBuilder;

// import io.netty.util.ByteProcessor;
// import io.netty.util.internal.StringUtil;

// import java.io.IOException;
// import java.io.InputStream;
// import java.io.OutputStream;
// import java.nio.ByteBuffer;
// import java.nio.ByteOrder;
// import java.nio.channels.FileChannel;
// import java.nio.channels.GatheringByteChannel;
// import java.nio.channels.ScatteringByteChannel;
// import java.nio.charset.Charset;

/**
 * Wraps another {@link ByteBuf}.
 *
 * It's important that the {@link #readerIndex()} and {@link #writerIndex()} will not do any adjustments on the
 * indices on the fly because of internal optimizations made by {@link ByteBufUtil#writeAscii(ByteBuf, CharSequence)}
 * and {@link ByteBufUtil#writeUtf8(ByteBuf, CharSequence)}.
 */
class WrappedByteBuf : ByteBuf {

    protected ByteBuf buf;

    protected this(ByteBuf buf) {
        if (buf is null) {
            throw new NullPointerException("buf");
        }
        this.buf = buf;
    }

    override
    final bool hasMemoryAddress() {
        return buf.hasMemoryAddress();
    }

    override
    final long memoryAddress() {
        return buf.memoryAddress();
    }

    override
    final int capacity() {
        return buf.capacity();
    }

    override
    ByteBuf capacity(int newCapacity) {
        buf.capacity(newCapacity);
        return this;
    }

    override
    final int maxCapacity() {
        return buf.maxCapacity();
    }

    override
    final ByteBufAllocator alloc() {
        return buf.alloc();
    }

    // override
    // final ByteOrder order() {
    //     return buf.order();
    // }

    // override
    // ByteBuf order(ByteOrder endianness) {
    //     return buf.order(endianness);
    // }

    override
    final ByteBuf unwrap() {
        return buf;
    }

    override
    ByteBuf asReadOnly() {
        return buf.asReadOnly();
    }

    override
    bool isReadOnly() {
        return buf.isReadOnly();
    }

    override
    final bool isDirect() {
        return buf.isDirect();
    }

    override
    final int readerIndex() {
        return buf.readerIndex();
    }

    override
    final ByteBuf readerIndex(int readerIndex) {
        buf.readerIndex(readerIndex);
        return this;
    }

    override
    final int writerIndex() {
        return buf.writerIndex();
    }

    override
    final ByteBuf writerIndex(int writerIndex) {
        buf.writerIndex(writerIndex);
        return this;
    }

    override
    ByteBuf setIndex(int readerIndex, int writerIndex) {
        buf.setIndex(readerIndex, writerIndex);
        return this;
    }

    override
    final int readableBytes() {
        return buf.readableBytes();
    }

    override
    final int writableBytes() {
        return buf.writableBytes();
    }

    override
    final int maxWritableBytes() {
        return buf.maxWritableBytes();
    }

    override
    int maxFastWritableBytes() {
        return buf.maxFastWritableBytes();
    }

    override
    final bool isReadable() {
        return buf.isReadable();
    }

    override
    final bool isWritable() {
        return buf.isWritable();
    }

    override
    final ByteBuf clear() {
        buf.clear();
        return this;
    }

    override
    final ByteBuf markReaderIndex() {
        buf.markReaderIndex();
        return this;
    }

    override
    final ByteBuf resetReaderIndex() {
        buf.resetReaderIndex();
        return this;
    }

    override
    final ByteBuf markWriterIndex() {
        buf.markWriterIndex();
        return this;
    }

    override
    final ByteBuf resetWriterIndex() {
        buf.resetWriterIndex();
        return this;
    }

    override
    ByteBuf discardReadBytes() {
        buf.discardReadBytes();
        return this;
    }

    override
    ByteBuf discardSomeReadBytes() {
        buf.discardSomeReadBytes();
        return this;
    }

    override
    ByteBuf ensureWritable(int minWritableBytes) {
        buf.ensureWritable(minWritableBytes);
        return this;
    }

    override
    int ensureWritable(int minWritableBytes, bool force) {
        return buf.ensureWritable(minWritableBytes, force);
    }

    override
    bool getBoolean(int index) {
        return buf.getBoolean(index);
    }

    override
    byte getByte(int index) {
        return buf.getByte(index);
    }

    override
    short getUnsignedByte(int index) {
        return buf.getUnsignedByte(index);
    }

    override
    short getShort(int index) {
        return buf.getShort(index);
    }

    override
    short getShortLE(int index) {
        return buf.getShortLE(index);
    }

    override
    int getUnsignedShort(int index) {
        return buf.getUnsignedShort(index);
    }

    override
    int getUnsignedShortLE(int index) {
        return buf.getUnsignedShortLE(index);
    }

    override
    int getMedium(int index) {
        return buf.getMedium(index);
    }

    override
    int getMediumLE(int index) {
        return buf.getMediumLE(index);
    }

    override
    int getUnsignedMedium(int index) {
        return buf.getUnsignedMedium(index);
    }

    override
    int getUnsignedMediumLE(int index) {
        return buf.getUnsignedMediumLE(index);
    }

    override
    int getInt(int index) {
        return buf.getInt(index);
    }

    override
    int getIntLE(int index) {
        return buf.getIntLE(index);
    }

    override
    long getUnsignedInt(int index) {
        return buf.getUnsignedInt(index);
    }

    override
    long getUnsignedIntLE(int index) {
        return buf.getUnsignedIntLE(index);
    }

    override
    long getLong(int index) {
        return buf.getLong(index);
    }

    override
    long getLongLE(int index) {
        return buf.getLongLE(index);
    }

    override
    char getChar(int index) {
        return buf.getChar(index);
    }

    override
    float getFloat(int index) {
        return buf.getFloat(index);
    }

    override
    double getDouble(int index) {
        return buf.getDouble(index);
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst) {
        buf.getBytes(index, dst);
        return this;
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst, int length) {
        buf.getBytes(index, dst, length);
        return this;
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst, int dstIndex, int length) {
        buf.getBytes(index, dst, dstIndex, length);
        return this;
    }

    override
    ByteBuf getBytes(int index, byte[] dst) {
        buf.getBytes(index, dst);
        return this;
    }

    override
    ByteBuf getBytes(int index, byte[] dst, int dstIndex, int length) {
        buf.getBytes(index, dst, dstIndex, length);
        return this;
    }

    override
    ByteBuf getBytes(int index, ByteBuffer dst) {
        buf.getBytes(index, dst);
        return this;
    }

    override
    ByteBuf getBytes(int index, OutputStream output, int length) {
        buf.getBytes(index, output, length);
        return this;
    }

    // override
    // int getBytes(int index, GatheringByteChannel output, int length) {
    //     return buf.getBytes(index, output, length);
    // }

    // override
    // int getBytes(int index, FileChannel output, long position, int length) {
    //     return buf.getBytes(index, output, position, length);
    // }

    // override
    // CharSequence getCharSequence(int index, int length, Charset charset) {
    //     return buf.getCharSequence(index, length, charset);
    // }

    override
    ByteBuf setBoolean(int index, bool value) {
        buf.setBoolean(index, value);
        return this;
    }

    override
    ByteBuf setByte(int index, int value) {
        buf.setByte(index, value);
        return this;
    }

    override
    ByteBuf setShort(int index, int value) {
        buf.setShort(index, value);
        return this;
    }

    override
    ByteBuf setShortLE(int index, int value) {
        buf.setShortLE(index, value);
        return this;
    }

    override
    ByteBuf setMedium(int index, int value) {
        buf.setMedium(index, value);
        return this;
    }

    override
    ByteBuf setMediumLE(int index, int value) {
        buf.setMediumLE(index, value);
        return this;
    }

    override
    ByteBuf setInt(int index, int value) {
        buf.setInt(index, value);
        return this;
    }

    override
    ByteBuf setIntLE(int index, int value) {
        buf.setIntLE(index, value);
        return this;
    }

    override
    ByteBuf setLong(int index, long value) {
        buf.setLong(index, value);
        return this;
    }

    override
    ByteBuf setLongLE(int index, long value) {
        buf.setLongLE(index, value);
        return this;
    }

    override
    ByteBuf setChar(int index, int value) {
        buf.setChar(index, value);
        return this;
    }

    override
    ByteBuf setFloat(int index, float value) {
        buf.setFloat(index, value);
        return this;
    }

    override
    ByteBuf setDouble(int index, double value) {
        buf.setDouble(index, value);
        return this;
    }

    override
    ByteBuf setBytes(int index, ByteBuf src) {
        buf.setBytes(index, src);
        return this;
    }

    override
    ByteBuf setBytes(int index, ByteBuf src, int length) {
        buf.setBytes(index, src, length);
        return this;
    }

    override
    ByteBuf setBytes(int index, ByteBuf src, int srcIndex, int length) {
        buf.setBytes(index, src, srcIndex, length);
        return this;
    }

    override
    ByteBuf setBytes(int index, byte[] src) {
        buf.setBytes(index, src);
        return this;
    }

    override
    ByteBuf setBytes(int index, byte[] src, int srcIndex, int length) {
        buf.setBytes(index, src, srcIndex, length);
        return this;
    }

    override
    ByteBuf setBytes(int index, ByteBuffer src) {
        buf.setBytes(index, src);
        return this;
    }

    override
    int setBytes(int index, InputStream input, int length) {
        return buf.setBytes(index, input, length);
    }

    // override
    // int setBytes(int index, ScatteringByteChannel input, int length) {
    //     return buf.setBytes(index, input, length);
    // }

    // override
    // int setBytes(int index, FileChannel input, long position, int length) {
    //     return buf.setBytes(index, input, position, length);
    // }

    override
    ByteBuf setZero(int index, int length) {
        buf.setZero(index, length);
        return this;
    }

    // override
    // int setCharSequence(int index, CharSequence sequence, Charset charset) {
    //     return buf.setCharSequence(index, sequence, charset);
    // }

    override
    bool readBoolean() {
        return buf.readBoolean();
    }

    override
    byte readByte() {
        return buf.readByte();
    }

    override
    short readUnsignedByte() {
        return buf.readUnsignedByte();
    }

    override
    short readShort() {
        return buf.readShort();
    }

    override
    short readShortLE() {
        return buf.readShortLE();
    }

    override
    int readUnsignedShort() {
        return buf.readUnsignedShort();
    }

    override
    int readUnsignedShortLE() {
        return buf.readUnsignedShortLE();
    }

    override
    int readMedium() {
        return buf.readMedium();
    }

    override
    int readMediumLE() {
        return buf.readMediumLE();
    }

    override
    int readUnsignedMedium() {
        return buf.readUnsignedMedium();
    }

    override
    int readUnsignedMediumLE() {
        return buf.readUnsignedMediumLE();
    }

    override
    int readInt() {
        return buf.readInt();
    }

    override
    int readIntLE() {
        return buf.readIntLE();
    }

    override
    long readUnsignedInt() {
        return buf.readUnsignedInt();
    }

    override
    long readUnsignedIntLE() {
        return buf.readUnsignedIntLE();
    }

    override
    long readLong() {
        return buf.readLong();
    }

    override
    long readLongLE() {
        return buf.readLongLE();
    }

    override
    char readChar() {
        return buf.readChar();
    }

    override
    float readFloat() {
        return buf.readFloat();
    }

    override
    double readDouble() {
        return buf.readDouble();
    }

    override
    ByteBuf readBytes(int length) {
        return buf.readBytes(length);
    }

    override
    ByteBuf readSlice(int length) {
        return buf.readSlice(length);
    }

    override
    ByteBuf readRetainedSlice(int length) {
        return buf.readRetainedSlice(length);
    }

    override
    ByteBuf readBytes(ByteBuf dst) {
        buf.readBytes(dst);
        return this;
    }

    override
    ByteBuf readBytes(ByteBuf dst, int length) {
        buf.readBytes(dst, length);
        return this;
    }

    override
    ByteBuf readBytes(ByteBuf dst, int dstIndex, int length) {
        buf.readBytes(dst, dstIndex, length);
        return this;
    }

    override
    ByteBuf readBytes(byte[] dst) {
        buf.readBytes(dst);
        return this;
    }

    override
    ByteBuf readBytes(byte[] dst, int dstIndex, int length) {
        buf.readBytes(dst, dstIndex, length);
        return this;
    }

    override
    ByteBuf readBytes(ByteBuffer dst) {
        buf.readBytes(dst);
        return this;
    }

    override
    ByteBuf readBytes(OutputStream output, int length) {
        buf.readBytes(output, length);
        return this;
    }

    // override
    // int readBytes(GatheringByteChannel output, int length) {
    //     return buf.readBytes(output, length);
    // }

    // override
    // int readBytes(FileChannel output, long position, int length) {
    //     return buf.readBytes(output, position, length);
    // }

    // override
    // CharSequence readCharSequence(int length, Charset charset) {
    //     return buf.readCharSequence(length, charset);
    // }

    override
    ByteBuf skipBytes(int length) {
        buf.skipBytes(length);
        return this;
    }

    override
    ByteBuf writeBoolean(bool value) {
        buf.writeBoolean(value);
        return this;
    }

    override
    ByteBuf writeByte(int value) {
        buf.writeByte(value);
        return this;
    }

    override
    ByteBuf writeShort(int value) {
        buf.writeShort(value);
        return this;
    }

    override
    ByteBuf writeShortLE(int value) {
        buf.writeShortLE(value);
        return this;
    }

    override
    ByteBuf writeMedium(int value) {
        buf.writeMedium(value);
        return this;
    }

    override
    ByteBuf writeMediumLE(int value) {
        buf.writeMediumLE(value);
        return this;
    }

    override
    ByteBuf writeInt(int value) {
        buf.writeInt(value);
        return this;
    }

    override
    ByteBuf writeIntLE(int value) {
        buf.writeIntLE(value);
        return this;
    }

    override
    ByteBuf writeLong(long value) {
        buf.writeLong(value);
        return this;
    }

    override
    ByteBuf writeLongLE(long value) {
        buf.writeLongLE(value);
        return this;
    }

    override
    ByteBuf writeChar(int value) {
        buf.writeChar(value);
        return this;
    }

    override
    ByteBuf writeFloat(float value) {
        buf.writeFloat(value);
        return this;
    }

    override
    ByteBuf writeDouble(double value) {
        buf.writeDouble(value);
        return this;
    }

    override
    ByteBuf writeBytes(ByteBuf src) {
        buf.writeBytes(src);
        return this;
    }

    override
    ByteBuf writeBytes(ByteBuf src, int length) {
        buf.writeBytes(src, length);
        return this;
    }

    override
    ByteBuf writeBytes(ByteBuf src, int srcIndex, int length) {
        buf.writeBytes(src, srcIndex, length);
        return this;
    }

    override
    ByteBuf writeBytes(byte[] src) {
        buf.writeBytes(src);
        return this;
    }

    override
    ByteBuf writeBytes(byte[] src, int srcIndex, int length) {
        buf.writeBytes(src, srcIndex, length);
        return this;
    }

    override
    ByteBuf writeBytes(ByteBuffer src) {
        buf.writeBytes(src);
        return this;
    }

    override
    int writeBytes(InputStream input, int length) {
        return buf.writeBytes(input, length);
    }

    // override
    // int writeBytes(ScatteringByteChannel input, int length) {
    //     return buf.writeBytes(input, length);
    // }

    // override
    // int writeBytes(FileChannel input, long position, int length) {
    //     return buf.writeBytes(input, position, length);
    // }

    override
    ByteBuf writeZero(int length) {
        buf.writeZero(length);
        return this;
    }

    // override
    // int writeCharSequence(CharSequence sequence, Charset charset) {
    //     return buf.writeCharSequence(sequence, charset);
    // }

    override
    int indexOf(int fromIndex, int toIndex, byte value) {
        return buf.indexOf(fromIndex, toIndex, value);
    }

    override
    int bytesBefore(byte value) {
        return buf.bytesBefore(value);
    }

    override
    int bytesBefore(int length, byte value) {
        return buf.bytesBefore(length, value);
    }

    override
    int bytesBefore(int index, int length, byte value) {
        return buf.bytesBefore(index, length, value);
    }

    override
    int forEachByte(ByteProcessor processor) {
        return buf.forEachByte(processor);
    }

    override
    int forEachByte(int index, int length, ByteProcessor processor) {
        return buf.forEachByte(index, length, processor);
    }

    override
    int forEachByteDesc(ByteProcessor processor) {
        return buf.forEachByteDesc(processor);
    }

    override
    int forEachByteDesc(int index, int length, ByteProcessor processor) {
        return buf.forEachByteDesc(index, length, processor);
    }

    override
    ByteBuf copy() {
        return buf.copy();
    }

    override
    ByteBuf copy(int index, int length) {
        return buf.copy(index, length);
    }

    override
    ByteBuf slice() {
        return buf.slice();
    }

    override
    ByteBuf retainedSlice() {
        return buf.retainedSlice();
    }

    override
    ByteBuf slice(int index, int length) {
        return buf.slice(index, length);
    }

    override
    ByteBuf retainedSlice(int index, int length) {
        return buf.retainedSlice(index, length);
    }

    override
    ByteBuf duplicate() {
        return buf.duplicate();
    }

    override
    ByteBuf retainedDuplicate() {
        return buf.retainedDuplicate();
    }

    override
    int nioBufferCount() {
        return buf.nioBufferCount();
    }

    override
    ByteBuffer nioBuffer() {
        return buf.nioBuffer();
    }

    override
    ByteBuffer nioBuffer(int index, int length) {
        return buf.nioBuffer(index, length);
    }

    override
    ByteBuffer[] nioBuffers() {
        return buf.nioBuffers();
    }

    override
    ByteBuffer[] nioBuffers(int index, int length) {
        return buf.nioBuffers(index, length);
    }

    override
    ByteBuffer internalNioBuffer(int index, int length) {
        return buf.internalNioBuffer(index, length);
    }

    override
    bool hasArray() {
        return buf.hasArray();
    }

    override
    byte[] array() {
        return buf.array();
    }

    override
    int arrayOffset() {
        return buf.arrayOffset();
    }

    // override
    // string toString(Charset charset) {
    //     return buf.toString(charset);
    // }

    // override
    // string toString(int index, int length, Charset charset) {
    //     return buf.toString(index, length, charset);
    // }

    override
    size_t toHash() @trusted nothrow {
        return buf.toHash();
    }

    override
    bool opEquals(Object obj) {
        return buf == obj;
    }

    override
    int compareTo(ByteBuf buffer) {
        return buf.compareTo(buffer);
    }

    override
    string toString() {
        return typeid(this).name ~ "(" ~ buf.toString() ~ ")";
    }

    override
    ByteBuf retain(int increment) {
        buf.retain(increment);
        return this;
    }

    override
    ByteBuf retain() {
        buf.retain();
        return this;
    }

    override
    ByteBuf touch() {
        buf.touch();
        return this;
    }

    override
    ByteBuf touch(Object hint) {
        buf.touch(hint);
        return this;
    }

    override
    final bool isReadable(int size) {
        return buf.isReadable(size);
    }

    override
    final bool isWritable(int size) {
        return buf.isWritable(size);
    }

    // override
    final int refCnt() {
        return buf.refCnt();
    }

    // override
    bool release() {
        return buf.release();
    }

    // override
    bool release(int decrement) {
        return buf.release(decrement);
    }

    override
    final bool isAccessible() {
        return buf.isAccessible();
    }
}
