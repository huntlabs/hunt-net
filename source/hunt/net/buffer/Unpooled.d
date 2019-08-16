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
module hunt.net.buffer.Unpooled;

import hunt.net.buffer.AbstractByteBuf;
import hunt.net.buffer.AbstractByteBufAllocator;
import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufAllocator;
import hunt.net.buffer.ByteBufUtil;
import hunt.net.buffer.CompositeByteBuf;
import hunt.net.buffer.ReadOnlyByteBufferBuf;
import hunt.net.buffer.UnpooledByteBufAllocator;
import hunt.net.buffer.UnpooledHeapByteBuf;

import hunt.Byte;
import hunt.collection.ByteBuffer;
import hunt.Exceptions;
import hunt.net.Exceptions;
import hunt.io.Common;
import hunt.text.StringBuilder;

import std.conv;
import std.format;
import std.concurrency : initOnce;

// import io.netty.buffer.CompositeByteBuf.ByteWrapper;
// import io.netty.util.internal.PlatformDependent;

// import java.nio.ByteBuffer;
// import java.nio.ByteOrder;
// import java.nio.CharBuffer;
// import java.nio.charset.Charset;
// import java.util.Arrays;


/**
 * Creates a new {@link ByteBuf} by allocating new space or by wrapping
 * or copying existing byte arrays, byte buffers and a string.
 *
 * <h3>Use static import</h3>
 * This classes is intended to be used with Java 5 static import statement:
 *
 * <pre>
 * import static io.netty.buffer.{@link Unpooled}.*;
 *
 * {@link ByteBuf} heapBuffer    = buffer(128);
 * {@link ByteBuf} directBuffer  = directBuffer(256);
 * {@link ByteBuf} wrappedBuffer = wrappedBuffer(new byte[128], new byte[256]);
 * {@link ByteBuf} copiedBuffer  = copiedBuffer({@link ByteBuffer}.allocate(128));
 * </pre>
 *
 * <h3>Allocating a new buffer</h3>
 *
 * Three buffer types are provided out of the box.
 *
 * <ul>
 * <li>{@link #buffer(int)} allocates a new fixed-capacity heap buffer.</li>
 * <li>{@link #directBuffer(int)} allocates a new fixed-capacity direct buffer.</li>
 * </ul>
 *
 * <h3>Creating a wrapped buffer</h3>
 *
 * Wrapped buffer is a buffer which is a view of one or more existing
 * byte arrays and byte buffers.  Any changes in the content of the original
 * array or buffer will be visible in the wrapped buffer.  Various wrapper
 * methods are provided and their name is all {@code wrappedBuffer()}.
 * You might want to take a look at the methods that accept varargs closely if
 * you want to create a buffer which is composed of more than one array to
 * reduce the number of memory copy.
 *
 * <h3>Creating a copied buffer</h3>
 *
 * Copied buffer is a deep copy of one or more existing byte arrays, byte
 * buffers or a string.  Unlike a wrapped buffer, there's no shared data
 * between the original data and the copied buffer.  Various copy methods are
 * provided and their name is all {@code copiedBuffer()}.  It is also convenient
 * to use this operation to merge multiple buffers into one buffer.
 */
final class Unpooled {

    private static ByteBufAllocator ALLOC() {
        __gshared ByteBufAllocator inst;
        return initOnce!inst(UnpooledByteBufAllocator.DEFAULT());
    }

    /**
     * Big endian byte order.
     */
    enum ByteOrder BIG_ENDIAN = ByteOrder.BigEndian;

    /**
     * Little endian byte order.
     */
    enum ByteOrder LITTLE_ENDIAN = ByteOrder.LittleEndian;

    /**
     * A buffer whose capacity is {@code 0}.
     */
    static ByteBuf EMPTY_BUFFER() {
        __gshared ByteBuf inst;
        return initOnce!inst(ALLOC.buffer(0, 0));
    }

    // static {
    //     assert EMPTY_BUFFER instanceof EmptyByteBuf: "EMPTY_BUFFER must be an EmptyByteBuf.";
    // }

    /**
     * Creates a new big-endian Java heap buffer with reasonably small initial capacity, which
     * expands its capacity boundlessly on demand.
     */
    static ByteBuf buffer() {
        return ALLOC.heapBuffer();
    }

    /**
     * Creates a new big-endian direct buffer with reasonably small initial capacity, which
     * expands its capacity boundlessly on demand.
     */
    static ByteBuf directBuffer() {
        return ALLOC.directBuffer();
    }

    /**
     * Creates a new big-endian Java heap buffer with the specified {@code capacity}, which
     * expands its capacity boundlessly on demand.  The new buffer's {@code readerIndex} and
     * {@code writerIndex} are {@code 0}.
     */
    static ByteBuf buffer(size_t initialCapacity) {
        return ALLOC.heapBuffer(cast(int)initialCapacity);
    }

    /**
     * Creates a new big-endian direct buffer with the specified {@code capacity}, which
     * expands its capacity boundlessly on demand.  The new buffer's {@code readerIndex} and
     * {@code writerIndex} are {@code 0}.
     */
    static ByteBuf directBuffer(size_t initialCapacity) {
        return ALLOC.directBuffer(cast(int)initialCapacity);
    }

    /**
     * Creates a new big-endian Java heap buffer with the specified
     * {@code initialCapacity}, that may grow up to {@code maxCapacity}
     * The new buffer's {@code readerIndex} and {@code writerIndex} are
     * {@code 0}.
     */
    static ByteBuf buffer(int initialCapacity, int maxCapacity) {
        return ALLOC.heapBuffer(initialCapacity, maxCapacity);
    }

    /**
     * Creates a new big-endian direct buffer with the specified
     * {@code initialCapacity}, that may grow up to {@code maxCapacity}.
     * The new buffer's {@code readerIndex} and {@code writerIndex} are
     * {@code 0}.
     */
    static ByteBuf directBuffer(int initialCapacity, int maxCapacity) {
        return ALLOC.directBuffer(initialCapacity, maxCapacity);
    }

    /**
     * Creates a new big-endian buffer which wraps the specified {@code array}.
     * A modification on the specified array's content will be visible to the
     * returned buffer.
     */
    static ByteBuf wrappedBuffer(byte[] array) {
        if (array.length == 0) {
            return EMPTY_BUFFER;
        }
        return new UnpooledHeapByteBuf(ALLOC, array, cast(int)array.length);
    }

    /**
     * Creates a new big-endian buffer which wraps the sub-region of the
     * specified {@code array}.  A modification on the specified array's
     * content will be visible to the returned buffer.
     */
    static ByteBuf wrappedBuffer(byte[] array, int offset, int length) {
        if (length == 0) {
            return EMPTY_BUFFER;
        }

        if (offset == 0 && length == array.length) {
            return wrappedBuffer(array);
        }

        return wrappedBuffer(array).slice(offset, length);
    }

    /**
     * Creates a new buffer which wraps the specified NIO buffer's current
     * slice.  A modification on the specified buffer's content will be
     * visible to the returned buffer.
     */
    static ByteBuf wrappedBuffer(ByteBuffer buffer) {
        if (!buffer.hasRemaining()) {
            return EMPTY_BUFFER;
        }
        if (!buffer.isDirect() && buffer.hasArray()) {
            ByteBuf b = wrappedBuffer(
                    buffer.array(),
                    buffer.arrayOffset() + buffer.position(),
                    buffer.remaining());
            // return .order(buffer.order());
            return b;
        } else {
            if (buffer.isReadOnly()) {
                return new ReadOnlyByteBufferBuf(ALLOC, buffer);
            }  else {
                implementationMissing(false);
                return null;
                // return new UnpooledDirectByteBuf(ALLOC, buffer, buffer.remaining());
            }
        }
            
        // if (!buffer.isDirect() && buffer.hasArray()) {
        //     return wrappedBuffer(
        //             buffer.array(),
        //             buffer.arrayOffset() + buffer.position(),
        //             buffer.remaining()).order(buffer.order());
        // } else if (PlatformDependent.hasUnsafe()) {
        //     if (buffer.isReadOnly()) {
        //         if (buffer.isDirect()) {
        //             return new ReadOnlyUnsafeDirectByteBuf(ALLOC, buffer);
        //         } else {
        //             return new ReadOnlyByteBufferBuf(ALLOC, buffer);
        //         }
        //     } else {
        //         return new UnpooledUnsafeDirectByteBuf(ALLOC, buffer, buffer.remaining());
        //     }
        // } else {
        //     if (buffer.isReadOnly()) {
        //         return new ReadOnlyByteBufferBuf(ALLOC, buffer);
        //     }  else {
        //         return new UnpooledDirectByteBuf(ALLOC, buffer, buffer.remaining());
        //     }
        // }
    }

    /**
     * Creates a new buffer which wraps the specified memory address. If {@code doFree} is true the
     * memoryAddress will automatically be freed once the reference count of the {@link ByteBuf} reaches {@code 0}.
     */
    // static ByteBuf wrappedBuffer(long memoryAddress, int size, bool doFree) {
    //     return new WrappedUnpooledUnsafeDirectByteBuf(ALLOC, memoryAddress, size, doFree);
    // }

    /**
     * Creates a new buffer which wraps the specified buffer's readable bytes.
     * A modification on the specified buffer's content will be visible to the
     * returned buffer.
     * @param buffer The buffer to wrap. Reference count ownership of this variable is transferred to this method.
     * @return The readable portion of the {@code buffer}, or an empty buffer if there is no readable portion.
     * The caller is responsible for releasing this buffer.
     */
    static ByteBuf wrappedBuffer(ByteBuf buffer) {
        if (buffer.isReadable()) {
            return buffer.slice();
        } else {
            buffer.release();
            return EMPTY_BUFFER;
        }
    }

    /**
     * Creates a new big-endian composite buffer which wraps the specified
     * arrays without copying them.  A modification on the specified arrays'
     * content will be visible to the returned buffer.
     */
    static ByteBuf wrappedBuffer(byte[][] arrays... ) {
        return wrappedBuffer(cast(int)arrays.length, arrays);
    }

    /**
     * Creates a new big-endian composite buffer which wraps the readable bytes of the
     * specified buffers without copying them.  A modification on the content
     * of the specified buffers will be visible to the returned buffer.
     * @param buffers The buffers to wrap. Reference count ownership of all variables is transferred to this method.
     * @return The readable portion of the {@code buffers}. The caller is responsible for releasing this buffer.
     */
    static ByteBuf wrappedBuffer(ByteBuf[] buffers...) {
        return wrappedBuffer(cast(int)buffers.length, buffers);
    }

    /**
     * Creates a new big-endian composite buffer which wraps the slices of the specified
     * NIO buffers without copying them.  A modification on the content of the
     * specified buffers will be visible to the returned buffer.
     */
    static ByteBuf wrappedBuffer(ByteBuffer[] buffers...) {
        return wrappedBuffer(cast(int)buffers.length, buffers);
    }

    static ByteBuf wrappedBuffer(T)(int maxNumComponents, ByteWrapper!(T) wrapper, T[] array) {
        switch (array.length) {
        case 0:
            break;
        case 1:
            if (!wrapper.isEmpty(array[0])) {
                return wrapper.wrap(array[0]);
            }
            break;
        default:
            for (int i = 0, len = cast(int)array.length; i < len; i++) {
                T bytes = array[i];
                if (bytes is null) {
                    return EMPTY_BUFFER;
                }
                if (!wrapper.isEmpty(bytes)) {
                    return new CompositeByteBuf(ALLOC, false, maxNumComponents, wrapper, array, i);
                }
            }
        }

        return EMPTY_BUFFER;
    }

    /**
     * Creates a new big-endian composite buffer which wraps the specified
     * arrays without copying them.  A modification on the specified arrays'
     * content will be visible to the returned buffer.
     */
    static ByteBuf wrappedBuffer(int maxNumComponents, byte[][] arrays...) {
        return wrappedBuffer(maxNumComponents, CompositeByteBuf.BYTE_ARRAY_WRAPPER, arrays);
    }

    /**
     * Creates a new big-endian composite buffer which wraps the readable bytes of the
     * specified buffers without copying them.  A modification on the content
     * of the specified buffers will be visible to the returned buffer.
     * @param maxNumComponents Advisement as to how many independent buffers are allowed to exist before
     * consolidation occurs.
     * @param buffers The buffers to wrap. Reference count ownership of all variables is transferred to this method.
     * @return The readable portion of the {@code buffers}. The caller is responsible for releasing this buffer.
     */
    static ByteBuf wrappedBuffer(int maxNumComponents, ByteBuf[] buffers...) {
        switch (buffers.length) {
        case 0:
            break;
        case 1:
            ByteBuf buffer = buffers[0];
            if (buffer.isReadable()) {
                return wrappedBuffer(buffer); // .order(BIG_ENDIAN)
            } else {
                buffer.release();
            }
            break;
        default:
            for (int i = 0; i < buffers.length; i++) {
                ByteBuf buf = buffers[i];
                if (buf.isReadable()) {
                    return new CompositeByteBuf(ALLOC, false, maxNumComponents, buffers, i);
                }
                buf.release();
            }
            break;
        }
        return EMPTY_BUFFER;
    }

    /**
     * Creates a new big-endian composite buffer which wraps the slices of the specified
     * NIO buffers without copying them.  A modification on the content of the
     * specified buffers will be visible to the returned buffer.
     */
    static ByteBuf wrappedBuffer(int maxNumComponents, ByteBuffer[] buffers... ) {
        return wrappedBuffer(maxNumComponents, CompositeByteBuf.BYTE_BUFFER_WRAPPER, buffers);
    }

    /**
     * Returns a new big-endian composite buffer with no components.
     */
    static CompositeByteBuf compositeBuffer() {
        return compositeBuffer(AbstractByteBufAllocator.DEFAULT_MAX_COMPONENTS);
    }

    /**
     * Returns a new big-endian composite buffer with no components.
     */
    static CompositeByteBuf compositeBuffer(int maxNumComponents) {
        return new CompositeByteBuf(ALLOC, false, maxNumComponents);
    }

    /**
     * Creates a new big-endian buffer whose content is a copy of the
     * specified {@code array}.  The new buffer's {@code readerIndex} and
     * {@code writerIndex} are {@code 0} and {@code array.length} respectively.
     */
    static ByteBuf copiedBuffer(byte[] array) {
        if (array.length == 0) {
            return EMPTY_BUFFER;
        }
        return wrappedBuffer(array.dup);
    }

    /**
     * Creates a new big-endian buffer whose content is a copy of the
     * specified {@code array}'s sub-region.  The new buffer's
     * {@code readerIndex} and {@code writerIndex} are {@code 0} and
     * the specified {@code length} respectively.
     */
    static ByteBuf copiedBuffer(byte[] array, int offset, int length) {
        if (length == 0) {
            return EMPTY_BUFFER;
        }
        // byte[] copy = PlatformDependent.allocateUninitializedArray(length);
        // System.arraycopy(array, offset, copy, 0, length);
        byte[] copy = array[offset .. offset+length].dup;
        return wrappedBuffer(copy);
    }

    /**
     * Creates a new buffer whose content is a copy of the specified
     * {@code buffer}'s current slice.  The new buffer's {@code readerIndex}
     * and {@code writerIndex} are {@code 0} and {@code buffer.remaining}
     * respectively.
     */
    static ByteBuf copiedBuffer(ByteBuffer buffer) {
        int length = buffer.remaining();
        if (length == 0) {
            return EMPTY_BUFFER;
        }
        byte[] copy = new byte[length]; // PlatformDependent.allocateUninitializedArray(length);
        // Duplicate the buffer so we not adjust the position during our get operation.
        // See https://github.com/netty/netty/issues/3896
        ByteBuffer duplicate = buffer.duplicate();
        duplicate.get(copy);
        return wrappedBuffer(copy); // .order(duplicate.order())
    }

    /**
     * Creates a new buffer whose content is a copy of the specified
     * {@code buffer}'s readable bytes.  The new buffer's {@code readerIndex}
     * and {@code writerIndex} are {@code 0} and {@code buffer.readableBytes}
     * respectively.
     */
    static ByteBuf copiedBuffer(ByteBuf b) {
        int readable = b.readableBytes();
        if (readable > 0) {
            ByteBuf copy = buffer(readable);
            copy.writeBytes(b, b.readerIndex(), readable);
            return copy;
        } else {
            return EMPTY_BUFFER;
        }
    }

    /**
     * Creates a new big-endian buffer whose content is a merged copy of
     * the specified {@code arrays}.  The new buffer's {@code readerIndex}
     * and {@code writerIndex} are {@code 0} and the sum of all arrays'
     * {@code length} respectively.
     */
    static ByteBuf copiedBuffer(byte[][] arrays...) {
        switch (arrays.length) {
            case 0:
                return EMPTY_BUFFER;
            case 1:
                if (arrays[0].length == 0) {
                    return EMPTY_BUFFER;
                } else {
                    return copiedBuffer(arrays[0]);
                }
            
            default: 
                implementationMissing(false);
        }

        // Merge the specified arrays into one array.
        int length = 0;
        foreach(byte[] a; arrays) {
            if (int.max - length < a.length) {
                throw new IllegalArgumentException(
                        "The total length of the specified arrays is too big.");
            }
            length += a.length;
        }

        if (length == 0) {
            return EMPTY_BUFFER;
        }

        byte[] mergedArray = new byte[length]; 
        for (size_t i = 0, j = 0; i < arrays.length; i ++) {
            byte[] a = arrays[i];
            // System.arraycopy(a, 0, mergedArray, j, a.length);
            mergedArray[j .. j+a.length] = a[0 .. $];
            j += a.length;
        }

        return wrappedBuffer(mergedArray);
    }

    /**
     * Creates a new buffer whose content is a merged copy of the specified
     * {@code buffers}' readable bytes.  The new buffer's {@code readerIndex}
     * and {@code writerIndex} are {@code 0} and the sum of all buffers'
     * {@code readableBytes} respectively.
     *
     * @throws IllegalArgumentException
     *         if the specified buffers' endianness are different from each
     *         other
     */
    static ByteBuf copiedBuffer(ByteBuf[] buffers...) {
        switch (buffers.length) {
            case 0:
                return EMPTY_BUFFER;
            case 1:
                return copiedBuffer(buffers[0]);
            default:
                break;
        }

        // Merge the specified buffers into one buffer.
        ByteOrder order;
        bool detected = false;
        int length = 0;
        foreach(ByteBuf b; buffers) {
            int bLen = b.readableBytes();
            if (bLen <= 0) {
                continue;
            }
            if (int.max - length < bLen) {
                throw new IllegalArgumentException(
                        "The total length of the specified buffers is too big.");
            }
            length += bLen;
            if (detected) {
                if (order != b.order()) {
                    throw new IllegalArgumentException("inconsistent byte order");
                }
            } else {
                order = b.order();
                detected = true;
            }
        }

        if (length == 0) {
            return EMPTY_BUFFER;
        }

        byte[] mergedArray = new byte[length]; // PlatformDependent.allocateUninitializedArray(length);
        for (int i = 0, j = 0; i < cast(int)buffers.length; i ++) {
            ByteBuf b = buffers[i];
            int bLen = b.readableBytes();
            b.getBytes(b.readerIndex(), mergedArray, j, bLen);
            j += bLen;
        }

        return wrappedBuffer(mergedArray); //.order(order);
    }

    /**
     * Creates a new buffer whose content is a merged copy of the specified
     * {@code buffers}' slices.  The new buffer's {@code readerIndex} and
     * {@code writerIndex} are {@code 0} and the sum of all buffers'
     * {@code remaining} respectively.
     *
     * @throws IllegalArgumentException
     *         if the specified buffers' endianness are different from each
     *         other
     */
    static ByteBuf copiedBuffer(ByteBuffer[] buffers...) {
        switch (buffers.length) {
            case 0:
                return EMPTY_BUFFER;
            case 1:
                return copiedBuffer(buffers[0]);
            default:
                break;
        }

        // Merge the specified buffers into one buffer.
        ByteOrder order;
        bool isDetected = false;
        int length = 0;
        foreach(ByteBuffer b; buffers) {
            int bLen = b.remaining();
            if (bLen <= 0) {
                continue;
            }
            if (int.max - length < bLen) {
                throw new IllegalArgumentException(
                        "The total length of the specified buffers is too big.");
            }
            length += bLen;
            if (isDetected) {
                if (order != b.order()) {
                    throw new IllegalArgumentException("inconsistent byte order");
                }
            } else {
                order = b.order();
                isDetected = true;
            }
        }

        if (length == 0) {
            return EMPTY_BUFFER;
        }

        byte[] mergedArray = new byte[length]; // PlatformDependent.allocateUninitializedArray(length);
        for (int i = 0, j = 0; i < buffers.length; i ++) {
            // Duplicate the buffer so we not adjust the position during our get operation.
            // See https://github.com/netty/netty/issues/3896
            ByteBuffer b = buffers[i].duplicate();
            int bLen = b.remaining();
            b.get(mergedArray, j, bLen);
            j += bLen;
        }

        return wrappedBuffer(mergedArray); // .order(order);
    }

    /**
     * Creates a new big-endian buffer whose content is the specified
     * {@code string} encoded in the specified {@code charset}.
     * The new buffer's {@code readerIndex} and {@code writerIndex} are
     * {@code 0} and the length of the encoded string respectively.
     */
    // static ByteBuf copiedBuffer(CharSequence string, Charset charset) {
    //     if (string is null) {
    //         throw new NullPointerException("string");
    //     }

    //     if (string instanceof CharBuffer) {
    //         return copiedBuffer((CharBuffer) string, charset);
    //     }

    //     return copiedBuffer(CharBuffer.wrap(string), charset);
    // }

    /**
     * Creates a new big-endian buffer whose content is a subregion of
     * the specified {@code string} encoded in the specified {@code charset}.
     * The new buffer's {@code readerIndex} and {@code writerIndex} are
     * {@code 0} and the length of the encoded string respectively.
     */
    // static ByteBuf copiedBuffer(
    //         CharSequence string, int offset, int length, Charset charset) {
    //     if (string is null) {
    //         throw new NullPointerException("string");
    //     }
    //     if (length == 0) {
    //         return EMPTY_BUFFER;
    //     }

    //     if (string instanceof CharBuffer) {
    //         CharBuffer buf = (CharBuffer) string;
    //         if (buf.hasArray()) {
    //             return copiedBuffer(
    //                     buf.array(),
    //                     buf.arrayOffset() + buf.position() + offset,
    //                     length, charset);
    //         }

    //         buf = buf.slice();
    //         buf.limit(length);
    //         buf.position(offset);
    //         return copiedBuffer(buf, charset);
    //     }

    //     return copiedBuffer(CharBuffer.wrap(string, offset, offset + length), charset);
    // }

    /**
     * Creates a new big-endian buffer whose content is the specified
     * {@code array} encoded in the specified {@code charset}.
     * The new buffer's {@code readerIndex} and {@code writerIndex} are
     * {@code 0} and the length of the encoded string respectively.
     */
    // static ByteBuf copiedBuffer(char[] array, Charset charset) {
    //     if (array is null) {
    //         throw new NullPointerException("array");
    //     }
    //     return copiedBuffer(array, 0, array.length, charset);
    // }

    /**
     * Creates a new big-endian buffer whose content is a subregion of
     * the specified {@code array} encoded in the specified {@code charset}.
     * The new buffer's {@code readerIndex} and {@code writerIndex} are
     * {@code 0} and the length of the encoded string respectively.
     */
    // static ByteBuf copiedBuffer(char[] array, int offset, int length, Charset charset) {
    //     if (array is null) {
    //         throw new NullPointerException("array");
    //     }
    //     if (length == 0) {
    //         return EMPTY_BUFFER;
    //     }
    //     return copiedBuffer(CharBuffer.wrap(array, offset, length), charset);
    // }

    // private static ByteBuf copiedBuffer(CharBuffer buffer, Charset charset) {
    //     return ByteBufUtil.encodeString0(ALLOC, true, buffer, charset, 0);
    // }

    /**
     * Creates a read-only buffer which disallows any modification operations
     * on the specified {@code buffer}.  The new buffer has the same
     * {@code readerIndex} and {@code writerIndex} with the specified
     * {@code buffer}.
     *
     * deprecated("") Use {@link ByteBuf#asReadOnly()}.
     */
    // deprecated("")
    // static ByteBuf unmodifiableBuffer(ByteBuf buffer) {
    //     ByteOrder endianness = buffer.order();
    //     if (endianness == ByteOrder.BigEndian) {
    //         return new ReadOnlyByteBuf(buffer);
    //     }

    //     return new ReadOnlyByteBuf(buffer.order(BIG_ENDIAN)).order(LITTLE_ENDIAN);
    // }

    /**
     * Creates a new 4-byte big-endian buffer that holds the specified 32-bit integer.
     */
    static ByteBuf copyInt(int value) {
        ByteBuf buf = buffer(4);
        buf.writeInt(value);
        return buf;
    }

    /**
     * Create a big-endian buffer that holds a sequence of the specified 32-bit integers.
     */
    static ByteBuf copyInt(int[] values...) {
        if (values is null || values.length == 0) {
            return EMPTY_BUFFER;
        }
        ByteBuf buffer = buffer(cast(int)values.length * 4);
        foreach(int v; values) {
            buffer.writeInt(v);
        }
        return buffer;
    }

    /**
     * Creates a new 2-byte big-endian buffer that holds the specified 16-bit integer.
     */
    static ByteBuf copyShort(int value) {
        ByteBuf buf = buffer(2);
        buf.writeShort(value);
        return buf;
    }

    /**
     * Create a new big-endian buffer that holds a sequence of the specified 16-bit integers.
     */
    static ByteBuf copyShort(short[] values...) {
        if (values is null || values.length == 0) {
            return EMPTY_BUFFER;
        }
        ByteBuf buffer = buffer(cast(int)values.length * 2);
        foreach(int v; values) {
            buffer.writeShort(v);
        }
        return buffer;
    }

    /**
     * Create a new big-endian buffer that holds a sequence of the specified 16-bit integers.
     */
    static ByteBuf copyShort(int[] values...) {
        if (values is null || values.length == 0) {
            return EMPTY_BUFFER;
        }
        ByteBuf buffer = buffer(cast(int)values.length * 2);
        foreach(int v; values) {
            buffer.writeShort(v);
        }
        return buffer;
    }

    /**
     * Creates a new 3-byte big-endian buffer that holds the specified 24-bit integer.
     */
    static ByteBuf copyMedium(int value) {
        ByteBuf buf = buffer(3);
        buf.writeMedium(value);
        return buf;
    }

    /**
     * Create a new big-endian buffer that holds a sequence of the specified 24-bit integers.
     */
    static ByteBuf copyMedium(int[] values...) {
        if (values is null || values.length == 0) {
            return EMPTY_BUFFER;
        }
        ByteBuf buffer = buffer(cast(int)values.length * 3);
        foreach(int v; values) {
            buffer.writeMedium(v);
        }
        return buffer;
    }

    /**
     * Creates a new 8-byte big-endian buffer that holds the specified 64-bit integer.
     */
    static ByteBuf copyLong(long value) {
        ByteBuf buf = buffer(8);
        buf.writeLong(value);
        return buf;
    }

    /**
     * Create a new big-endian buffer that holds a sequence of the specified 64-bit integers.
     */
    static ByteBuf copyLong(long[] values...) {
        if (values is null || values.length == 0) {
            return EMPTY_BUFFER;
        }
        ByteBuf buffer = buffer(cast(int)values.length * 8);
        foreach(long v; values) {
            buffer.writeLong(v);
        }
        return buffer;
    }

    /**
     * Creates a new single-byte big-endian buffer that holds the specified bool value.
     */
    static ByteBuf copyBoolean(bool value) {
        ByteBuf buf = buffer(1);
        buf.writeBoolean(value);
        return buf;
    }

    /**
     * Create a new big-endian buffer that holds a sequence of the specified bool values.
     */
    static ByteBuf copyBoolean(bool[] values...) {
        if (values is null || values.length == 0) {
            return EMPTY_BUFFER;
        }
        ByteBuf buffer = buffer(values.length);
        foreach(bool v; values) {
            buffer.writeBoolean(v);
        }
        return buffer;
    }

    /**
     * Creates a new 4-byte big-endian buffer that holds the specified 32-bit floating point number.
     */
    static ByteBuf copyFloat(float value) {
        ByteBuf buf = buffer(4);
        buf.writeFloat(value);
        return buf;
    }

    /**
     * Create a new big-endian buffer that holds a sequence of the specified 32-bit floating point numbers.
     */
    static ByteBuf copyFloat(float[] values...) {
        if (values is null || values.length == 0) {
            return EMPTY_BUFFER;
        }
        ByteBuf buffer = buffer(values.length * 4);
        foreach(float v; values) {
            buffer.writeFloat(v);
        }
        return buffer;
    }

    /**
     * Creates a new 8-byte big-endian buffer that holds the specified 64-bit floating point number.
     */
    static ByteBuf copyDouble(double value) {
        ByteBuf buf = buffer(8);
        buf.writeDouble(value);
        return buf;
    }

    /**
     * Create a new big-endian buffer that holds a sequence of the specified 64-bit floating point numbers.
     */
    static ByteBuf copyDouble(double[] values...) {
        if (values is null || values.length == 0) {
            return EMPTY_BUFFER;
        }
        ByteBuf buffer = buffer(values.length * 8);
        foreach(double v; values) {
            buffer.writeDouble(v);
        }
        return buffer;
    }

    /**
     * Return a unreleasable view on the given {@link ByteBuf} which will just ignore release and retain calls.
     */
    // static ByteBuf unreleasableBuffer(ByteBuf buf) {
    //     return new UnreleasableByteBuf(buf);
    // }

    /**
     * Wrap the given {@link ByteBuf}s in an unmodifiable {@link ByteBuf}. Be aware the returned {@link ByteBuf} will
     * not try to slice the given {@link ByteBuf}s to reduce GC-Pressure.
     *
     * deprecated("") Use {@link #wrappedUnmodifiableBuffer(ByteBuf...)}.
     */
    // deprecated("")
    // static ByteBuf unmodifiableBuffer(ByteBuf[] buffers...) {
    //     return wrappedUnmodifiableBuffer(true, buffers);
    // }

    /**
     * Wrap the given {@link ByteBuf}s in an unmodifiable {@link ByteBuf}. Be aware the returned {@link ByteBuf} will
     * not try to slice the given {@link ByteBuf}s to reduce GC-Pressure.
     *
     * The returned {@link ByteBuf} may wrap the provided array directly, and so should not be subsequently modified.
     */
    static ByteBuf wrappedUnmodifiableBuffer(ByteBuf[] buffers...) {
        return wrappedUnmodifiableBuffer(false, buffers);
    }

    private static ByteBuf wrappedUnmodifiableBuffer(bool copy, ByteBuf[] buffers...) {
        switch (buffers.length) {
            case 0:
                return EMPTY_BUFFER;
            case 1:
                return buffers[0].asReadOnly();
            default:
                ByteBuf[] bs = buffers;
                if (copy) {
                    bs = buffers.dup;
                    // buffers = Arrays.copyOf(buffers, buffers.length, ByteBuf[].class);
                }
                implementationMissing(false);
                return null;
                // return new FixedCompositeByteBuf(ALLOC, bs);
        }
    }

    private this() {
        // Unused
    }
}
