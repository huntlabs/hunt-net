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
module hunt.net.buffer.AbstractByteBuf;

import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufUtil;
import hunt.net.buffer.ByteProcessor;
import hunt.net.buffer.Unpooled;
import hunt.net.buffer.UnpooledDuplicatedByteBuf;
import hunt.net.buffer.UnpooledSlicedByteBuf;

import hunt.Byte;
import hunt.collection.ByteBuffer;
import hunt.Double;
import hunt.Exceptions;
import hunt.Float;
import hunt.logging.ConsoleLogger;
import hunt.net.Exceptions;
import hunt.io.Common;
import hunt.text.StringBuilder;

import std.conv;
import std.format;

// import io.netty.util.AsciiString;
// import io.netty.util.ByteProcessor;
// import io.netty.util.CharsetUtil;
// import io.netty.util.IllegalReferenceCountException;
// import io.netty.util.ResourceLeakDetector;
// import io.netty.util.ResourceLeakDetectorFactory;
// import io.netty.util.internal.PlatformDependent;
// import io.netty.util.internal.StringUtil;
// import io.netty.util.internal.SystemPropertyUtil;


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
// import static io.netty.util.internal.ObjectUtil.checkPositiveOrZero;

/**
 * Checks that the given argument is positive or zero. If it is not , throws {@link IllegalArgumentException}.
 * Otherwise, returns the argument.
 */
int checkPositiveOrZero(int i, string name) {
    if (i < 0) {
        throw new IllegalArgumentException(name ~ ": " ~ i.to!string() ~ " (expected: >= 0)");
    }
    return i;
}

/**
 * A skeletal implementation of a buffer.
 */
abstract class AbstractByteBuf : ByteBuf {
    private enum string LEGACY_PROP_CHECK_ACCESSIBLE = "hunt.net.buffer.bytebuf.checkAccessible";
    private enum string PROP_CHECK_ACCESSIBLE = "hunt.net.buffer.checkAccessible";
    enum bool checkAccessible = true; // accessed from CompositeByteBuf
    private enum string PROP_CHECK_BOUNDS = "hunt.net.buffer.checkBounds";
    private enum bool checkBounds = true;

    // static {
    //     if (SystemPropertyUtil.contains(PROP_CHECK_ACCESSIBLE)) {
    //         checkAccessible = SystemPropertyUtil.getBoolean(PROP_CHECK_ACCESSIBLE, true);
    //     } else {
    //         checkAccessible = SystemPropertyUtil.getBoolean(LEGACY_PROP_CHECK_ACCESSIBLE, true);
    //     }
    //     checkBounds = SystemPropertyUtil.getBoolean(PROP_CHECK_BOUNDS, true);
    //     if (logger.isDebugEnabled()) {
    //         logger.debug("-D{}: {}", PROP_CHECK_ACCESSIBLE, checkAccessible);
    //         logger.debug("-D{}: {}", PROP_CHECK_BOUNDS, checkBounds);
    //     }
    // }

    // static final ResourceLeakDetector!(ByteBuf) leakDetector =
    //         ResourceLeakDetectorFactory.instance().newResourceLeakDetector(ByteBuf.class);

    int _readerIndex;
    int _writerIndex;
    private int markedReaderIndex;
    private int markedWriterIndex;
    private int _maxCapacity;

    protected this(int maxCapacity) {
        checkPositiveOrZero(maxCapacity, "maxCapacity");
        this._maxCapacity = maxCapacity;
    }


    alias setBytes = ByteBuf.setBytes;
    alias getBytes = ByteBuf.getBytes;

    override
    bool isReadOnly() {
        return false;
    }

    override
    ByteBuf asReadOnly() {
        if (isReadOnly()) {
            return this;
        }
        // return Unpooled.unmodifiableBuffer(this);
        // FIXME: Needing refactor or cleanup -@zxp at 8/15/2019, 3:43:07 PM
        // 
        return this;
    }

    override
    int maxCapacity() {
        return _maxCapacity;
    }

    protected final void maxCapacity(int v) {
        this._maxCapacity = v;
    }

    override
    int readerIndex() {
        return _readerIndex;
    }

    private static void checkIndexBounds(int rIndex, int wIndex, int capacity) {
        if (rIndex < 0 || rIndex > wIndex || wIndex > capacity) {
            throw new IndexOutOfBoundsException(format(
                    "readerIndex: %d, writerIndex: %d (expected: 0 <= readerIndex <= writerIndex <= capacity(%d))",
                    rIndex, wIndex, capacity));
        }
    }

    override
    ByteBuf readerIndex(int index) {
        if (checkBounds) {
            checkIndexBounds(index, _writerIndex, capacity());
        }
        this._readerIndex = index;
        return this;
    }

    override
    int writerIndex() {
        return _writerIndex;
    }

    override
    ByteBuf writerIndex(int index) {
        if (checkBounds) {
            checkIndexBounds(_readerIndex, index, capacity());
        }
        this._writerIndex = index;
        return this;
    }

    override
    ByteBuf setIndex(int rIndex, int wIndex) {
        if (checkBounds) {
            checkIndexBounds(rIndex, wIndex, capacity());
        }
        setIndex0(rIndex, wIndex);
        return this;
    }

    override
    ByteBuf clear() {
        _readerIndex = _writerIndex = 0;
        return this;
    }

    override
    bool isReadable() {
        return _writerIndex > _readerIndex;
    }

    override
    bool isReadable(int numBytes) {
        return _writerIndex - _readerIndex >= numBytes;
    }

    override
    bool isWritable() {
        return capacity() > _writerIndex;
    }

    override
    bool isWritable(int numBytes) {
        return capacity() - _writerIndex >= numBytes;
    }

    override
    int readableBytes() {
        return _writerIndex - _readerIndex;
    }

    override
    int writableBytes() {
        return capacity() - _writerIndex;
    }

    override
    int maxWritableBytes() {
        return maxCapacity() - _writerIndex;
    }

    override
    ByteBuf markReaderIndex() {
        markedReaderIndex = _readerIndex;
        return this;
    }

    override
    ByteBuf resetReaderIndex() {
        readerIndex(markedReaderIndex);
        return this;
    }

    override
    ByteBuf markWriterIndex() {
        markedWriterIndex = _writerIndex;
        return this;
    }

    override
    ByteBuf resetWriterIndex() {
        writerIndex(markedWriterIndex);
        return this;
    }

    override
    ByteBuf discardReadBytes() {
        ensureAccessible();
        if (_readerIndex == 0) {
            return this;
        }

        if (_readerIndex != _writerIndex) {
            setBytes(0, this, _readerIndex, _writerIndex - _readerIndex);
            _writerIndex -= _readerIndex;
            adjustMarkers(_readerIndex);
            _readerIndex = 0;
        } else {
            adjustMarkers(_readerIndex);
            _writerIndex = _readerIndex = 0;
        }
        return this;
    }

    override
    ByteBuf discardSomeReadBytes() {
        ensureAccessible();
        if (_readerIndex == 0) {
            return this;
        }

        if (_readerIndex == _writerIndex) {
            adjustMarkers(_readerIndex);
            _writerIndex = _readerIndex = 0;
            return this;
        }

        if (_readerIndex >= capacity() >>> 1) {
            setBytes(0, this, _readerIndex, _writerIndex - _readerIndex);
            _writerIndex -= _readerIndex;
            adjustMarkers(_readerIndex);
            _readerIndex = 0;
        }
        return this;
    }

    protected final void adjustMarkers(int decrement) {
        int markedReaderIndex = this.markedReaderIndex;
        if (markedReaderIndex <= decrement) {
            this.markedReaderIndex = 0;
            int markedWriterIndex = this.markedWriterIndex;
            if (markedWriterIndex <= decrement) {
                this.markedWriterIndex = 0;
            } else {
                this.markedWriterIndex = markedWriterIndex - decrement;
            }
        } else {
            this.markedReaderIndex = markedReaderIndex - decrement;
            markedWriterIndex -= decrement;
        }
    }

    override
    ByteBuf ensureWritable(int minWritableBytes) {
        checkPositiveOrZero(minWritableBytes, "minWritableBytes");
        ensureWritable0(minWritableBytes);
        return this;
    }

    final void ensureWritable0(int minWritableBytes) {
        ensureAccessible();
        if (minWritableBytes <= writableBytes()) {
            return;
        }
        int wIndex = writerIndex();
        if (checkBounds) {
            if (minWritableBytes > _maxCapacity - wIndex) {
                throw new IndexOutOfBoundsException(format(
                        "writerIndex(%d) + minWritableBytes(%d) exceeds maxCapacity(%d): %s",
                        wIndex, minWritableBytes, _maxCapacity, this));
            }
        }

        // Normalize the current capacity to the power of 2.
        int minNewCapacity = wIndex + minWritableBytes;
        int newCapacity = alloc().calculateNewCapacity(minNewCapacity, _maxCapacity);

        int fastCapacity = wIndex + maxFastWritableBytes();
        // Grow by a smaller amount if it will avoid reallocation
        if (newCapacity > fastCapacity && minNewCapacity <= fastCapacity) {
            newCapacity = fastCapacity;
        }

        // Adjust to the new capacity.
        capacity(newCapacity);
    }

    override
    int ensureWritable(int minWritableBytes, bool force) {
        ensureAccessible();
        checkPositiveOrZero(minWritableBytes, "minWritableBytes");

        if (minWritableBytes <= writableBytes()) {
            return 0;
        }

        int _maxCapacity = maxCapacity();
        int wIndex = writerIndex();
        if (minWritableBytes > _maxCapacity - wIndex) {
            if (!force || capacity() == _maxCapacity) {
                return 1;
            }

            capacity(_maxCapacity);
            return 3;
        }

        // Normalize the current capacity to the power of 2.
        int minNewCapacity = wIndex + minWritableBytes;
        int newCapacity = alloc().calculateNewCapacity(minNewCapacity, _maxCapacity);

        int fastCapacity = wIndex + maxFastWritableBytes();
        // Grow by a smaller amount if it will avoid reallocation
        if (newCapacity > fastCapacity && minNewCapacity <= fastCapacity) {
            newCapacity = fastCapacity;
        }

        // Adjust to the new capacity.
        capacity(newCapacity);
        return 2;
    }

    // override
    // ByteBuf order(ByteOrder endianness) {
    //     if (endianness == order()) {
    //         return this;
    //     }
    //     if (endianness is null) {
    //         throw new NullPointerException("endianness");
    //     }
    //     return newSwappedByteBuf();
    // }

    /**
     * Creates a new {@link SwappedByteBuf} for this {@link ByteBuf} instance.
     */
    // protected SwappedByteBuf newSwappedByteBuf() {
    //     return new SwappedByteBuf(this);
    // }

    override
    byte getByte(int index) {
        checkIndex(index);
        return _getByte(index);
    }

    protected abstract byte _getByte(int index);

    override
    bool getBoolean(int index) {
        return getByte(index) != 0;
    }

    override
    short getUnsignedByte(int index) {
        return cast(short) (getByte(index) & 0xFF);
    }

    override
    short getShort(int index) {
        checkIndex(index, 2);
        return _getShort(index);
    }

    protected abstract short _getShort(int index);

    override
    short getShortLE(int index) {
        checkIndex(index, 2);
        return _getShortLE(index);
    }

    protected abstract short _getShortLE(int index);

    override
    int getUnsignedShort(int index) {
        return getShort(index) & 0xFFFF;
    }

    override
    int getUnsignedShortLE(int index) {
        return getShortLE(index) & 0xFFFF;
    }

    override
    int getUnsignedMedium(int index) {
        checkIndex(index, 3);
        return _getUnsignedMedium(index);
    }

    protected abstract int _getUnsignedMedium(int index);

    override
    int getUnsignedMediumLE(int index) {
        checkIndex(index, 3);
        return _getUnsignedMediumLE(index);
    }

    protected abstract int _getUnsignedMediumLE(int index);

    override
    int getMedium(int index) {
        int value = getUnsignedMedium(index);
        if ((value & 0x800000) != 0) {
            value |= 0xff000000;
        }
        return value;
    }

    override
    int getMediumLE(int index) {
        int value = getUnsignedMediumLE(index);
        if ((value & 0x800000) != 0) {
            value |= 0xff000000;
        }
        return value;
    }

    override
    int getInt(int index) {
        checkIndex(index, 4);
        return _getInt(index);
    }

    protected abstract int _getInt(int index);

    override
    int getIntLE(int index) {
        checkIndex(index, 4);
        return _getIntLE(index);
    }

    protected abstract int _getIntLE(int index);

    override
    long getUnsignedInt(int index) {
        return getInt(index) & 0xFFFFFFFFL;
    }

    override
    long getUnsignedIntLE(int index) {
        return getIntLE(index) & 0xFFFFFFFFL;
    }

    override
    long getLong(int index) {
        checkIndex(index, 8);
        return _getLong(index);
    }

    protected abstract long _getLong(int index);

    override
    long getLongLE(int index) {
        checkIndex(index, 8);
        return _getLongLE(index);
    }

    protected abstract long _getLongLE(int index);

    override
    char getChar(int index) {
        return cast(char) getShort(index);
    }

    override
    float getFloat(int index) {
        return Float.intBitsToFloat(getInt(index));
    }

    override
    double getDouble(int index) {
        return Double.longBitsToDouble(getLong(index));
    }

    override
    ByteBuf getBytes(int index, byte[] dst) {
        getBytes(index, dst, 0, cast(int)dst.length);
        return this;
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst) {
        getBytes(index, dst, dst.writableBytes());
        return this;
    }

    override
    ByteBuf getBytes(int index, ByteBuf dst, int length) {
        getBytes(index, dst, dst.writerIndex(), length);
        dst.writerIndex(dst.writerIndex() + length);
        return this;
    }

    // override
    // CharSequence getCharSequence(int index, int length, Charset charset) {
    //     if (CharsetUtil.US_ASCII == charset || CharsetUtil.ISO_8859_1 == charset) {
    //         // ByteBufUtil.getBytes(...) will return a new copy which the AsciiString uses directly
    //         return new AsciiString(ByteBufUtil.getBytes(this, index, length, true), false);
    //     }
    //     return toString(index, length, charset);
    // }

    // override
    // CharSequence readCharSequence(int length, Charset charset) {
    //     CharSequence sequence = getCharSequence(_readerIndex, length, charset);
    //     _readerIndex += length;
    //     return sequence;
    // }

    override
    ByteBuf setByte(int index, int value) {
        checkIndex(index);
        _setByte(index, value);
        return this;
    }

    protected abstract void _setByte(int index, int value);

    override
    ByteBuf setBoolean(int index, bool value) {
        setByte(index, value? 1 : 0);
        return this;
    }

    override
    ByteBuf setShort(int index, int value) {
        checkIndex(index, 2);
        _setShort(index, value);
        return this;
    }

    protected abstract void _setShort(int index, int value);

    override
    ByteBuf setShortLE(int index, int value) {
        checkIndex(index, 2);
        _setShortLE(index, value);
        return this;
    }

    protected abstract void _setShortLE(int index, int value);

    override
    ByteBuf setChar(int index, int value) {
        setShort(index, value);
        return this;
    }

    override
    ByteBuf setMedium(int index, int value) {
        checkIndex(index, 3);
        _setMedium(index, value);
        return this;
    }

    protected abstract void _setMedium(int index, int value);

    override
    ByteBuf setMediumLE(int index, int value) {
        checkIndex(index, 3);
        _setMediumLE(index, value);
        return this;
    }

    protected abstract void _setMediumLE(int index, int value);

    override
    ByteBuf setInt(int index, int value) {
        checkIndex(index, 4);
        _setInt(index, value);
        return this;
    }

    protected abstract void _setInt(int index, int value);

    override
    ByteBuf setIntLE(int index, int value) {
        checkIndex(index, 4);
        _setIntLE(index, value);
        return this;
    }

    protected abstract void _setIntLE(int index, int value);

    override
    ByteBuf setFloat(int index, float value) {
        setInt(index, Float.floatToRawIntBits(value));
        return this;
    }

    override
    ByteBuf setLong(int index, long value) {
        checkIndex(index, 8);
        _setLong(index, value);
        return this;
    }

    protected abstract void _setLong(int index, long value);

    override
    ByteBuf setLongLE(int index, long value) {
        checkIndex(index, 8);
        _setLongLE(index, value);
        return this;
    }

    protected abstract void _setLongLE(int index, long value);

    override
    ByteBuf setDouble(int index, double value) {
        setLong(index, Double.doubleToRawLongBits(value));
        return this;
    }

    override
    ByteBuf setBytes(int index, byte[] src) {
        setBytes(index, src, 0, cast(int)src.length);
        return this;
    }

    override
    ByteBuf setBytes(int index, ByteBuf src) {
        setBytes(index, src, src.readableBytes());
        return this;
    }

    private static void checkReadableBounds(ByteBuf src, int length) {
        if (length > src.readableBytes()) {
            throw new IndexOutOfBoundsException(format(
                    "length(%d) exceeds src.readableBytes(%d) where src is: %s", length, src.readableBytes(), src));
        }
    }

    override
    ByteBuf setBytes(int index, ByteBuf src, int length) {
        checkIndex(index, length);
        if (src is null) {
            throw new NullPointerException("src");
        }
        if (checkBounds) {
            checkReadableBounds(src, length);
        }

        setBytes(index, src, src.readerIndex(), length);
        src.readerIndex(src.readerIndex() + length);
        return this;
    }

    override
    ByteBuf setZero(int index, int length) {
        if (length == 0) {
            return this;
        }

        checkIndex(index, length);

        int nLong = length >>> 3;
        int nBytes = length & 7;
        for (int i = nLong; i > 0; i --) {
            _setLong(index, 0);
            index += 8;
        }
        if (nBytes == 4) {
            _setInt(index, 0);
            // Not need to update the index as we not will use it after this.
        } else if (nBytes < 4) {
            for (int i = nBytes; i > 0; i --) {
                _setByte(index, cast(byte) 0);
                index ++;
            }
        } else {
            _setInt(index, 0);
            index += 4;
            for (int i = nBytes - 4; i > 0; i --) {
                _setByte(index, cast(byte) 0);
                index ++;
            }
        }
        return this;
    }

    // override
    // int setCharSequence(int index, CharSequence sequence, Charset charset) {
    //     return setCharSequence0(index, sequence, charset, false);
    // }

    // private int setCharSequence0(int index, CharSequence sequence, Charset charset, bool expand) {
    //     if (charset == CharsetUtil.UTF_8) {
    //         int length = ByteBufUtil.utf8MaxBytes(sequence);
    //         if (expand) {
    //             ensureWritable0(length);
    //             checkIndex0(index, length);
    //         } else {
    //             checkIndex(index, length);
    //         }
    //         return ByteBufUtil.writeUtf8(this, index, sequence, sequence.length());
    //     }
    //     if (charset == CharsetUtil.US_ASCII || charset == CharsetUtil.ISO_8859_1) {
    //         int length = sequence.length();
    //         if (expand) {
    //             ensureWritable0(length);
    //             checkIndex0(index, length);
    //         } else {
    //             checkIndex(index, length);
    //         }
    //         return ByteBufUtil.writeAscii(this, index, sequence, length);
    //     }
    //     byte[] bytes = sequence.toString().getBytes(charset);
    //     if (expand) {
    //         ensureWritable0(bytes.length);
    //         // setBytes(...) will take care of checking the indices.
    //     }
    //     setBytes(index, bytes);
    //     return bytes.length;
    // }

    override
    byte readByte() {
        checkReadableBytes0(1);
        int i = _readerIndex;
        byte b = _getByte(i);
        _readerIndex = i + 1;
        return b;
    }

    override
    bool readBoolean() {
        return readByte() != 0;
    }

    override
    short readUnsignedByte() {
        return cast(short) (readByte() & 0xFF);
    }

    override
    short readShort() {
        checkReadableBytes0(2);
        short v = _getShort(_readerIndex);
        _readerIndex += 2;
        return v;
    }

    override
    short readShortLE() {
        checkReadableBytes0(2);
        short v = _getShortLE(_readerIndex);
        _readerIndex += 2;
        return v;
    }

    override
    int readUnsignedShort() {
        return readShort() & 0xFFFF;
    }

    override
    int readUnsignedShortLE() {
        return readShortLE() & 0xFFFF;
    }

    override
    int readMedium() {
        int value = readUnsignedMedium();
        if ((value & 0x800000) != 0) {
            value |= 0xff000000;
        }
        return value;
    }

    override
    int readMediumLE() {
        int value = readUnsignedMediumLE();
        if ((value & 0x800000) != 0) {
            value |= 0xff000000;
        }
        return value;
    }

    override
    int readUnsignedMedium() {
        checkReadableBytes0(3);
        int v = _getUnsignedMedium(_readerIndex);
        _readerIndex += 3;
        return v;
    }

    override
    int readUnsignedMediumLE() {
        checkReadableBytes0(3);
        int v = _getUnsignedMediumLE(_readerIndex);
        _readerIndex += 3;
        return v;
    }

    override
    int readInt() {
        checkReadableBytes0(4);
        int v = _getInt(_readerIndex);
        _readerIndex += 4;
        return v;
    }

    override
    int readIntLE() {
        checkReadableBytes0(4);
        int v = _getIntLE(_readerIndex);
        _readerIndex += 4;
        return v;
    }

    override
    long readUnsignedInt() {
        return readInt() & 0xFFFFFFFFL;
    }

    override
    long readUnsignedIntLE() {
        return readIntLE() & 0xFFFFFFFFL;
    }

    override
    long readLong() {
        checkReadableBytes0(8);
        long v = _getLong(_readerIndex);
        _readerIndex += 8;
        return v;
    }

    override
    long readLongLE() {
        checkReadableBytes0(8);
        long v = _getLongLE(_readerIndex);
        _readerIndex += 8;
        return v;
    }

    override
    char readChar() {
        return cast(char) readShort();
    }

    override
    float readFloat() {
        return Float.intBitsToFloat(readInt());
    }

    override
    double readDouble() {
        return Double.longBitsToDouble(readLong());
    }

    override
    ByteBuf readBytes(int length) {
        checkReadableBytes(length);
        if (length == 0) {
            return Unpooled.EMPTY_BUFFER;
        }

        ByteBuf buf = alloc().buffer(length, _maxCapacity);
        buf.writeBytes(this, _readerIndex, length);
        _readerIndex += length;
        return buf;
    }

    override
    ByteBuf readSlice(int length) {
        checkReadableBytes(length);
        ByteBuf slice = slice(_readerIndex, length);
        _readerIndex += length;
        return slice;
    }

    override
    ByteBuf readRetainedSlice(int length) {
        checkReadableBytes(length);
        ByteBuf slice = retainedSlice(_readerIndex, length);
        _readerIndex += length;
        return slice;
    }

    override
    ByteBuf readBytes(byte[] dst, int dstIndex, int length) {
        checkReadableBytes(length);
        getBytes(_readerIndex, dst, dstIndex, length);
        _readerIndex += length;
        return this;
    }

    override
    ByteBuf readBytes(byte[] dst) {
        readBytes(dst, 0, cast(int)dst.length);
        return this;
    }

    override
    ByteBuf readBytes(ByteBuf dst) {
        readBytes(dst, dst.writableBytes());
        return this;
    }

    override
    ByteBuf readBytes(ByteBuf dst, int length) {
        if (checkBounds) {
            if (length > dst.writableBytes()) {
                throw new IndexOutOfBoundsException(format(
                        "length(%d) exceeds dst.writableBytes(%d) where dst is: %s", length, dst.writableBytes(), dst));
            }
        }
        readBytes(dst, dst.writerIndex(), length);
        dst.writerIndex(dst.writerIndex() + length);
        return this;
    }

    override
    ByteBuf readBytes(ByteBuf dst, int dstIndex, int length) {
        checkReadableBytes(length);
        getBytes(_readerIndex, dst, dstIndex, length);
        _readerIndex += length;
        return this;
    }

    override
    ByteBuf readBytes(ByteBuffer dst) {
        int length = dst.remaining();
        checkReadableBytes(length);
        getBytes(_readerIndex, dst);
        _readerIndex += length;
        return this;
    }

    // override
    // int readBytes(GatheringByteChannel out, int length) {
    //     checkReadableBytes(length);
    //     int readBytes = getBytes(_readerIndex, out, length);
    //     _readerIndex += readBytes;
    //     return readBytes;
    // }

    // override
    // int readBytes(FileChannel out, long position, int length) {
    //     checkReadableBytes(length);
    //     int readBytes = getBytes(_readerIndex, out, position, length);
    //     _readerIndex += readBytes;
    //     return readBytes;
    // }

    override
    ByteBuf readBytes(OutputStream outStream, int length) {
        checkReadableBytes(length);
        getBytes(_readerIndex, outStream, length);
        _readerIndex += length;
        return this;
    }

    override
    ByteBuf skipBytes(int length) {
        checkReadableBytes(length);
        _readerIndex += length;
        return this;
    }

    override
    ByteBuf writeBoolean(bool value) {
        writeByte(value ? 1 : 0);
        return this;
    }

    override
    ByteBuf writeByte(int value) {
        ensureWritable0(1);
        _setByte(_writerIndex++, value);
        return this;
    }

    override
    ByteBuf writeShort(int value) {
        ensureWritable0(2);
        _setShort(_writerIndex, value);
        _writerIndex += 2;
        return this;
    }

    override
    ByteBuf writeShortLE(int value) {
        ensureWritable0(2);
        _setShortLE(_writerIndex, value);
        _writerIndex += 2;
        return this;
    }

    override
    ByteBuf writeMedium(int value) {
        ensureWritable0(3);
        _setMedium(_writerIndex, value);
        _writerIndex += 3;
        return this;
    }

    override
    ByteBuf writeMediumLE(int value) {
        ensureWritable0(3);
        _setMediumLE(_writerIndex, value);
        _writerIndex += 3;
        return this;
    }

    override
    ByteBuf writeInt(int value) {
        ensureWritable0(4);
        _setInt(_writerIndex, value);
        _writerIndex += 4;
        return this;
    }

    override
    ByteBuf writeIntLE(int value) {
        ensureWritable0(4);
        _setIntLE(_writerIndex, value);
        _writerIndex += 4;
        return this;
    }

    override
    ByteBuf writeLong(long value) {
        ensureWritable0(8);
        _setLong(_writerIndex, value);
        _writerIndex += 8;
        return this;
    }

    override
    ByteBuf writeLongLE(long value) {
        ensureWritable0(8);
        _setLongLE(_writerIndex, value);
        _writerIndex += 8;
        return this;
    }

    override
    ByteBuf writeChar(int value) {
        writeShort(value);
        return this;
    }

    override
    ByteBuf writeFloat(float value) {
        writeInt(Float.floatToRawIntBits(value));
        return this;
    }

    override
    ByteBuf writeDouble(double value) {
        writeLong(Double.doubleToRawLongBits(value));
        return this;
    }

    override
    ByteBuf writeBytes(byte[] src, int srcIndex, int length) {
        ensureWritable(length);
        setBytes(_writerIndex, src, srcIndex, length);
        _writerIndex += length;
        return this;
    }

    override
    ByteBuf writeBytes(byte[] src) {
        writeBytes(src, 0, cast(int)src.length);
        return this;
    }

    override
    ByteBuf writeBytes(ByteBuf src) {
        writeBytes(src, src.readableBytes());
        return this;
    }

    override
    ByteBuf writeBytes(ByteBuf src, int length) {
        if (checkBounds) {
            checkReadableBounds(src, length);
        }
        writeBytes(src, src.readerIndex(), length);
        src.readerIndex(src.readerIndex() + length);
        return this;
    }

    override
    ByteBuf writeBytes(ByteBuf src, int srcIndex, int length) {
        ensureWritable(length);
        setBytes(_writerIndex, src, srcIndex, length);
        _writerIndex += length;
        return this;
    }

    override
    ByteBuf writeBytes(ByteBuffer src) {
        int length = src.remaining();
        ensureWritable0(length);
        setBytes(_writerIndex, src);
        _writerIndex += length;
        return this;
    }

    override
    int writeBytes(InputStream inStream, int length) {
        ensureWritable(length);
        int writtenBytes = setBytes(_writerIndex, inStream, length);
        if (writtenBytes > 0) {
            _writerIndex += writtenBytes;
        }
        return writtenBytes;
    }

    // override
    // int writeBytes(ScatteringByteChannel in, int length) {
    //     ensureWritable(length);
    //     int writtenBytes = setBytes(_writerIndex, in, length);
    //     if (writtenBytes > 0) {
    //         _writerIndex += writtenBytes;
    //     }
    //     return writtenBytes;
    // }

    // override
    // int writeBytes(FileChannel in, long position, int length) {
    //     ensureWritable(length);
    //     int writtenBytes = setBytes(_writerIndex, in, position, length);
    //     if (writtenBytes > 0) {
    //         _writerIndex += writtenBytes;
    //     }
    //     return writtenBytes;
    // }

    override
    ByteBuf writeZero(int length) {
        if (length == 0) {
            return this;
        }

        ensureWritable(length);
        int wIndex = _writerIndex;
        checkIndex0(wIndex, length);

        int nLong = length >>> 3;
        int nBytes = length & 7;
        for (int i = nLong; i > 0; i --) {
            _setLong(wIndex, 0);
            wIndex += 8;
        }
        if (nBytes == 4) {
            _setInt(wIndex, 0);
            wIndex += 4;
        } else if (nBytes < 4) {
            for (int i = nBytes; i > 0; i --) {
                _setByte(wIndex, cast(byte) 0);
                wIndex++;
            }
        } else {
            _setInt(wIndex, 0);
            wIndex += 4;
            for (int i = nBytes - 4; i > 0; i --) {
                _setByte(wIndex, cast(byte) 0);
                wIndex++;
            }
        }
        _writerIndex = wIndex;
        return this;
    }

    // override
    // int writeCharSequence(CharSequence sequence, Charset charset) {
    //     int written = setCharSequence0(_writerIndex, sequence, charset, true);
    //     _writerIndex += written;
    //     return written;
    // }

    override
    ByteBuf copy() {
        return copy(_readerIndex, readableBytes());
    }

    alias copy = ByteBuf.copy;

    override
    ByteBuf duplicate() {
        ensureAccessible();
        // return new UnpooledDuplicatedByteBuf(this);
        implementationMissing(false);
        return null;
    }

    override
    ByteBuf retainedDuplicate() {
        return duplicate().retain();
    }

    override
    ByteBuf slice() {
        return slice(_readerIndex, readableBytes());
    }

    override
    ByteBuf retainedSlice() {
        return slice().retain();
    }

    override
    ByteBuf slice(int index, int length) {
        ensureAccessible();
        return new UnpooledSlicedByteBuf(this, index, length);
        // implementationMissing(false);
        // return null;
    }

    override
    ByteBuf retainedSlice(int index, int length) {
        return slice(index, length).retain();
    }

    override
    ByteBuffer nioBuffer() {
        return nioBuffer(_readerIndex, readableBytes());
    }

    alias nioBuffer = ByteBuf.nioBuffer;
    alias nioBuffers = ByteBuf.nioBuffers;

    override
    ByteBuffer[] nioBuffers() {
        return nioBuffers(_readerIndex, readableBytes());
    }

    // override
    // string toString(Charset charset) {
    //     return toString(_readerIndex, readableBytes(), charset);
    // }

    // override
    // string toString(int index, int length, Charset charset) {
    //     return ByteBufUtil.decodeString(this, index, length, charset);
    // }

    override
    int indexOf(int fromIndex, int toIndex, byte value) {
        return ByteBufUtil.indexOf(this, fromIndex, toIndex, value);
    }

    override
    int bytesBefore(byte value) {
        return bytesBefore(readerIndex(), readableBytes(), value);
    }

    override
    int bytesBefore(int length, byte value) {
        checkReadableBytes(length);
        return bytesBefore(readerIndex(), length, value);
    }

    override
    int bytesBefore(int index, int length, byte value) {
        int endIndex = indexOf(index, index + length, value);
        if (endIndex < 0) {
            return -1;
        }
        return endIndex - index;
    }

    override
    int forEachByte(ByteProcessor processor) {
        ensureAccessible();
        try {
            return forEachByteAsc0(_readerIndex, _writerIndex, processor);
        } catch (Exception e) {
            throwException(e);
            return -1;
        }
    }

    override
    int forEachByte(int index, int length, ByteProcessor processor) {
        checkIndex(index, length);
        try {
            return forEachByteAsc0(index, index + length, processor);
        } catch (Exception e) {
            throwException(e);
            return -1;
        }
    }

    int forEachByteAsc0(int start, int end, ByteProcessor processor) {
        for (; start < end; ++start) {
            if (!processor.process(_getByte(start))) {
                return start;
            }
        }

        return -1;
    }

    override
    int forEachByteDesc(ByteProcessor processor) {
        ensureAccessible();
        try {
            return forEachByteDesc0(_writerIndex - 1, _readerIndex, processor);
        } catch (Exception e) {
            throwException(e);
            return -1;
        }
    }

    override
    int forEachByteDesc(int index, int length, ByteProcessor processor) {
        checkIndex(index, length);
        try {
            return forEachByteDesc0(index + length - 1, index, processor);
        } catch (Exception e) {
            throwException(e);
            return -1;
        }
    }

    int forEachByteDesc0(int rStart, int rEnd, ByteProcessor processor) {
        for (; rStart >= rEnd; --rStart) {
            if (!processor.process(_getByte(rStart))) {
                return rStart;
            }
        }
        return -1;
    }

    override
    size_t toHash() @trusted nothrow {
        size_t v;
        try {
            v = ByteBufUtil.toHash(this);
        } catch(Exception ex) {
            warning(ex);
        }
        return v;
    }

    override
    bool opEquals(Object o) {
        if(this is o) return true;
        ByteBuf buf = cast(ByteBuf) o;
        if(buf is null) return false;
        return ByteBufUtil.equals(this, buf);
    }

    override
    int compareTo(ByteBuf that) {
        return ByteBufUtil.compare(this, that);
    }

    override
    string toString() {
        if (refCnt() == 0) {
            return typeid(this).name ~ "(freed)";
        }

        StringBuilder buf = new StringBuilder()
            .append(typeid(this).name)
            .append("(ridx: ").append(_readerIndex)
            .append(", widx: ").append(_writerIndex)
            .append(", cap: ").append(capacity());
        if (_maxCapacity != int.max) {
            buf.append('/').append(_maxCapacity);
        }

        ByteBuf unwrapped = unwrap();
        if (unwrapped !is null) {
            buf.append(", unwrapped: ").append(unwrapped);
        }
        buf.append(')');
        return buf.toString();
    }

    protected final void checkIndex(int index) {
        checkIndex(index, 1);
    }

    protected final void checkIndex(int index, int fieldLength) {
        ensureAccessible();
        checkIndex0(index, fieldLength);
    }

    private static void checkRangeBounds(string indexName, int index,
            int fieldLength, int capacity) {
        if (isOutOfBounds(index, fieldLength, capacity)) {
            throw new IndexOutOfBoundsException(format(
                    "%s: %d, length: %d (expected: range(0, %d))", indexName, index, fieldLength, capacity));
        }
    }

    final void checkIndex0(int index, int fieldLength) {
        if (checkBounds) {
            checkRangeBounds("index", index, fieldLength, capacity());
        }
    }

    protected final void checkSrcIndex(int index, int length, int srcIndex, int srcCapacity) {
        checkIndex(index, length);
        if (checkBounds) {
            checkRangeBounds("srcIndex", srcIndex, length, srcCapacity);
        }
    }

    protected final void checkDstIndex(int index, int length, int dstIndex, int dstCapacity) {
        checkIndex(index, length);
        if (checkBounds) {
            checkRangeBounds("dstIndex", dstIndex, length, dstCapacity);
        }
    }

    protected final void checkDstIndex(int length, int dstIndex, int dstCapacity) {
        checkReadableBytes(length);
        if (checkBounds) {
            checkRangeBounds("dstIndex", dstIndex, length, dstCapacity);
        }
    }

    /**
     * {@link IndexOutOfBoundsException} if the current
     * {@linkplain #readableBytes() readable bytes} of this buffer is less
     * than the specified value.
     */
    protected final void checkReadableBytes(int minimumReadableBytes) {
        checkPositiveOrZero(minimumReadableBytes, "minimumReadableBytes");
        checkReadableBytes0(minimumReadableBytes);
    }

    protected final void checkNewCapacity(int newCapacity) {
        ensureAccessible();
        if (checkBounds) {
            if (newCapacity < 0 || newCapacity > maxCapacity()) {
                throw new IllegalArgumentException("newCapacity: " ~ newCapacity.to!string() ~
                        " (expected: 0-" ~ maxCapacity().to!string() ~ ")");
            }
        }
    }

    private void checkReadableBytes0(int minimumReadableBytes) {
        ensureAccessible();
        if (checkBounds) {
            if (_readerIndex > _writerIndex - minimumReadableBytes) {
                throw new IndexOutOfBoundsException(format(
                        "readerIndex(%d) + length(%d) exceeds writerIndex(%d): %s",
                        _readerIndex, minimumReadableBytes, _writerIndex, this));
            }
        }
    }

    /**
     * Should be called by every method that tries to access the buffers content to check
     * if the buffer was released before.
     */
    protected final void ensureAccessible() {
        if (checkAccessible && !isAccessible()) {
            throw new IllegalReferenceCountException(0);
        }
    }

    final void setIndex0(int rIndex, int wIndex) {
        this._readerIndex = rIndex;
        this._writerIndex = wIndex;
    }

    final void discardMarks() {
        markedReaderIndex = markedWriterIndex = 0;
    }
}
