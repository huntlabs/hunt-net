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
module hunt.net.buffer.DuplicatedByteBuf;

import hunt.net.buffer.AbstractDerivedByteBuf;
import hunt.net.buffer.AbstractByteBuf;
import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufAllocator;
import hunt.net.buffer.ByteProcessor;

import hunt.Byte;
import hunt.io.ByteBuffer;
import hunt.stream.Common;
import hunt.util.ByteOrder;

/**
 * A derived buffer which simply forwards all data access requests to its
 * parent.  It is recommended to use {@link ByteBuf#duplicate()} instead
 * of calling the constructor explicitly.
 *
 * deprecated("") Do not use.
 */
class DuplicatedByteBuf : AbstractDerivedByteBuf {

    private ByteBuf buffer;

    this(ByteBuf buffer) {
        this(buffer, buffer.readerIndex(), buffer.writerIndex());
    }

    this(ByteBuf buffer, int readerIndex, int writerIndex) {
        super(buffer.maxCapacity());
        DuplicatedByteBuf b = cast(DuplicatedByteBuf)buffer;
        // AbstractPooledDerivedByteBuf a = cast(AbstractPooledDerivedByteBuf)buffer;

        if (b !is null) {
            this.buffer = b.buffer;
        // } else if (a !is null) {
        //     this.buffer = buffer.unwrap();
        } else {
            this.buffer = buffer;
        }

        setIndex(readerIndex, writerIndex);
        markReaderIndex();
        markWriterIndex();
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
    // deprecated("")
    ByteOrder order() {
        return unwrap().order();
    }

    override
    bool isDirect() {
        return unwrap().isDirect();
    }

    override
    int capacity() {
        return unwrap().capacity();
    }

    override
    ByteBuf capacity(int newCapacity) {
        unwrap().capacity(newCapacity);
        return this;
    }

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
        return unwrap().arrayOffset();
    }

    override
    bool hasMemoryAddress() {
        return unwrap().hasMemoryAddress();
    }

    override
    long memoryAddress() {
        return unwrap().memoryAddress();
    }

    override
    byte getByte(int index) {
        return unwrap().getByte(index);
    }

    override
    protected byte _getByte(int index) {
        return unwrap().getByte(index);
    }

    override
    short getShort(int index) {
        return unwrap().getShort(index);
    }

    override
    protected short _getShort(int index) {
        return unwrap().getShort(index);
    }

    override
    short getShortLE(int index) {
        return unwrap().getShortLE(index);
    }

    override
    protected short _getShortLE(int index) {
        return unwrap().getShortLE(index);
    }

    override
    int getUnsignedMedium(int index) {
        return unwrap().getUnsignedMedium(index);
    }

    override
    protected int _getUnsignedMedium(int index) {
        return unwrap().getUnsignedMedium(index);
    }

    override
    int getUnsignedMediumLE(int index) {
        return unwrap().getUnsignedMediumLE(index);
    }

    override
    protected int _getUnsignedMediumLE(int index) {
        return unwrap().getUnsignedMediumLE(index);
    }

    override
    int getInt(int index) {
        return unwrap().getInt(index);
    }

    override
    protected int _getInt(int index) {
        return unwrap().getInt(index);
    }

    override
    int getIntLE(int index) {
        return unwrap().getIntLE(index);
    }

    override
    protected int _getIntLE(int index) {
        return unwrap().getIntLE(index);
    }

    override
    long getLong(int index) {
        return unwrap().getLong(index);
    }

    override
    protected long _getLong(int index) {
        return unwrap().getLong(index);
    }

    override
    long getLongLE(int index) {
        return unwrap().getLongLE(index);
    }

    override
    protected long _getLongLE(int index) {
        return unwrap().getLongLE(index);
    }

    override
    ByteBuf copy(int index, int length) {
        return unwrap().copy(index, length);
    }

    override
    ByteBuf slice(int index, int length) {
        return unwrap().slice(index, length);
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst, int dstIndex, int length) {
        unwrap().getBytes(index, dst, dstIndex, length);
        return this;
    }

    override
    ByteBuf getBytes(int index, byte[] dst, int dstIndex, int length) {
        unwrap().getBytes(index, dst, dstIndex, length);
        return this;
    }

    override
    ByteBuf getBytes(int index, ByteBuffer dst) {
        unwrap().getBytes(index, dst);
        return this;
    }

    override
    ByteBuf setByte(int index, int value) {
        unwrap().setByte(index, value);
        return this;
    }

    override
    protected void _setByte(int index, int value) {
        unwrap().setByte(index, value);
    }

    override
    ByteBuf setShort(int index, int value) {
        unwrap().setShort(index, value);
        return this;
    }

    override
    protected void _setShort(int index, int value) {
        unwrap().setShort(index, value);
    }

    override
    ByteBuf setShortLE(int index, int value) {
        unwrap().setShortLE(index, value);
        return this;
    }

    override
    protected void _setShortLE(int index, int value) {
        unwrap().setShortLE(index, value);
    }

    override
    ByteBuf setMedium(int index, int value) {
        unwrap().setMedium(index, value);
        return this;
    }

    override
    protected void _setMedium(int index, int value) {
        unwrap().setMedium(index, value);
    }

    override
    ByteBuf setMediumLE(int index, int value) {
        unwrap().setMediumLE(index, value);
        return this;
    }

    override
    protected void _setMediumLE(int index, int value) {
        unwrap().setMediumLE(index, value);
    }

    override
    ByteBuf setInt(int index, int value) {
        unwrap().setInt(index, value);
        return this;
    }

    override
    protected void _setInt(int index, int value) {
        unwrap().setInt(index, value);
    }

    override
    ByteBuf setIntLE(int index, int value) {
        unwrap().setIntLE(index, value);
        return this;
    }

    override
    protected void _setIntLE(int index, int value) {
        unwrap().setIntLE(index, value);
    }

    override
    ByteBuf setLong(int index, long value) {
        unwrap().setLong(index, value);
        return this;
    }

    override
    protected void _setLong(int index, long value) {
        unwrap().setLong(index, value);
    }

    override
    ByteBuf setLongLE(int index, long value) {
        unwrap().setLongLE(index, value);
        return this;
    }

    override
    protected void _setLongLE(int index, long value) {
        unwrap().setLongLE(index, value);
    }

    override
    ByteBuf setBytes(int index, byte[] src, int srcIndex, int length) {
        unwrap().setBytes(index, src, srcIndex, length);
        return this;
    }

    override
    ByteBuf setBytes(int index, ByteBuf src, int srcIndex, int length) {
        unwrap().setBytes(index, src, srcIndex, length);
        return this;
    }

    override
    ByteBuf setBytes(int index, ByteBuffer src) {
        unwrap().setBytes(index, src);
        return this;
    }

    override
    ByteBuf getBytes(int index, OutputStream outStream, int length) {
        unwrap().getBytes(index, outStream, length);
        return this;
    }

    // override
    // int getBytes(int index, GatheringByteChannel outStream, int length) {
    //     return unwrap().getBytes(index, outStream, length);
    // }

    // override
    // int getBytes(int index, FileChannel outStream, long position, int length) {
    //     return unwrap().getBytes(index, outStream, position, length);
    // }

    override
    int setBytes(int index, InputStream inStream, int length) {
        return unwrap().setBytes(index, inStream, length);
    }

    // override
    // int setBytes(int index, ScatteringByteChannel inStream, int length) {
    //     return unwrap().setBytes(index, inStream, length);
    // }

    // override
    // int setBytes(int index, FileChannel inStream, long position, int length) {
    //     return unwrap().setBytes(index, inStream, position, length);
    // }

    override
    int nioBufferCount() {
        return unwrap().nioBufferCount();
    }

    override
    ByteBuffer[] nioBuffers(int index, int length) {
        return unwrap().nioBuffers(index, length);
    }

    override
    int forEachByte(int index, int length, ByteProcessor processor) {
        return unwrap().forEachByte(index, length, processor);
    }

    override
    int forEachByteDesc(int index, int length, ByteProcessor processor) {
        return unwrap().forEachByteDesc(index, length, processor);
    }
}

