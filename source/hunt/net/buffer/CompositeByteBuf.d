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
module hunt.net.buffer.CompositeByteBuf;

import hunt.net.buffer.AbstractByteBuf;
import hunt.net.buffer.AbstractByteBufAllocator;
import hunt.net.buffer.AbstractReferenceCountedByteBuf;
import hunt.net.buffer.AbstractUnpooledSlicedByteBuf;
import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufAllocator;
import hunt.net.buffer.ByteBufUtil;
import hunt.net.buffer.ByteProcessor;
import hunt.net.buffer.ReferenceCountUtil;
import hunt.net.buffer.Unpooled;

import hunt.Byte;
import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.collection.Collections;
import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.Double;
import hunt.Exceptions;
import hunt.Float;
import hunt.logging.ConsoleLogger;
import hunt.net.Exceptions;
import hunt.io.Common;
import hunt.text.StringBuilder;
import hunt.util.Common;

import std.algorithm;
import std.conv;
import std.format;
import std.concurrency : initOnce;
import std.range;

// import io.netty.util.ByteProcessor;
// import io.netty.util.IllegalReferenceCountException;
// import io.netty.util.ReferenceCountUtil;
// import io.netty.util.internal.EmptyArrays;
// import io.netty.util.internal.RecyclableArrayList;

// import java.io.IOException;
// import java.io.InputStream;
// import java.io.OutputStream;
// import java.nio.ByteBuffer;
// import java.nio.ByteOrder;
// import java.nio.channels.FileChannel;
// import java.nio.channels.GatheringByteChannel;
// import java.nio.channels.ScatteringByteChannel;
// import java.util.ArrayList;
// import java.util.Arrays;
// import java.util.Collection;
// import java.util.Collections;
// import java.util.ConcurrentModificationException;
// import java.util.Iterator;
// import java.util.List;
// import java.util.NoSuchElementException;

// import static io.netty.util.internal.ObjectUtil.checkNotNull;

/**
 * A virtual buffer which shows multiple buffers as a single merged buffer.  It is recommended to use
 * {@link ByteBufAllocator#compositeBuffer()} or {@link Unpooled#wrappedBuffer(ByteBuf...)} instead of calling the
 * constructor explicitly.
 */
class CompositeByteBuf : AbstractReferenceCountedByteBuf, Iterable!(ByteBuf) {

    private static ByteBuffer EMPTY_NIO_BUFFER() {
        __gshared ByteBuffer inst;
        return initOnce!inst(Unpooled.EMPTY_BUFFER.nioBuffer());
    }
    // private static final Iterator!(ByteBuf) EMPTY_ITERATOR = Collections.<ByteBuf>emptyList().iterator();

    private ByteBufAllocator _alloc;
    private bool direct;
    private int _maxNumComponents;

    private int componentCount;
    private Component[] components; // resized when needed

    private bool freed;

    private this(ByteBufAllocator alloc, bool direct, int maxNumComponents, int initSize) {
        super(AbstractByteBufAllocator.DEFAULT_MAX_CAPACITY);
        if (alloc is null) {
            throw new NullPointerException("alloc");
        }
        if (maxNumComponents < 1) {
            throw new IllegalArgumentException(
                    "maxNumComponents: " ~ maxNumComponents.to!string() ~ " (expected: >= 1)");
        }
        this._alloc = alloc;
        this.direct = direct;
        this._maxNumComponents = maxNumComponents;
        components = newCompArray(initSize, maxNumComponents);
    }

    this(ByteBufAllocator alloc, bool direct, int maxNumComponents) {
        this(alloc, direct, maxNumComponents, 0);
    }

    this(ByteBufAllocator alloc, bool direct, int maxNumComponents, ByteBuf[] buffers...) {
        this(alloc, direct, maxNumComponents, buffers, 0);
    }

    this(ByteBufAllocator alloc, bool direct, int maxNumComponents,
            ByteBuf[] buffers, int offset) {
        this(alloc, direct, maxNumComponents, cast(int)buffers.length - offset);

        addComponents0(false, 0, buffers, offset);
        consolidateIfNeeded();
        setIndex0(0, capacity());
    }

    // this(ByteBufAllocator alloc, bool direct, int maxNumComponents, Iterable!(ByteBuf) buffers) {
    //     this(alloc, direct, maxNumComponents,
    //             buffers instanceof Collection ? ((Collection!(ByteBuf)) buffers).size() : 0);

    //     addComponents(false, 0, buffers);
    //     setIndex(0, capacity());
    // }

    static ByteWrapper!(byte[]) BYTE_ARRAY_WRAPPER() {
        __gshared ByteWrapper!(byte[]) inst;
        return initOnce!inst(createByteWrapper());
    } 

    private static ByteWrapper!(byte[]) createByteWrapper() {
        return new class ByteWrapper!(byte[]) {
            override
            ByteBuf wrap(byte[] bytes) {
                return Unpooled.wrappedBuffer(bytes);
            }
            override
            bool isEmpty(byte[] bytes) {
                return bytes.length == 0;
            }
        };
    }


    static final ByteWrapper!(ByteBuffer) BYTE_BUFFER_WRAPPER() {
        __gshared ByteWrapper!(ByteBuffer) inst;
        return initOnce!inst(createByteBufferWrapper());
    }

    private static ByteWrapper!(ByteBuffer) createByteBufferWrapper() {
        return new class ByteWrapper!(ByteBuffer) {
            override
            ByteBuf wrap(ByteBuffer bytes) {
                return Unpooled.wrappedBuffer(bytes);
            }
            override
            bool isEmpty(ByteBuffer bytes) {
                return !bytes.hasRemaining();
            }
        };
    }

    this(T)(ByteBufAllocator alloc, bool direct, int maxNumComponents,
            ByteWrapper!(T) wrapper, T[] buffers, int offset) {
        this(alloc, direct, maxNumComponents, cast(int)buffers.length - offset);

        addComponents0(false, 0, wrapper, buffers, offset);
        consolidateIfNeeded();
        setIndex(0, capacity());
    }

    private static Component[] newCompArray(int initComponents, int maxNumComponents) {
        int capacityGuess = min(AbstractByteBufAllocator.DEFAULT_MAX_COMPONENTS, maxNumComponents);
        return new Component[max(initComponents, capacityGuess)];
    }

    // Special constructor used by WrappedCompositeByteBuf
    this(ByteBufAllocator alloc) {
        super(int.max);
        this._alloc = alloc;
        direct = false;
        _maxNumComponents = 0;
        components = null;
    }

    /**
     * Add the given {@link ByteBuf}.
     * <p>
     * Be aware that this method does not increase the {@code writerIndex} of the {@link CompositeByteBuf}.
     * If you need to have it increased use {@link #addComponent(bool, ByteBuf)}.
     * <p>
     * {@link ByteBuf#release()} ownership of {@code buffer} is transferred to this {@link CompositeByteBuf}.
     * @param buffer the {@link ByteBuf} to add. {@link ByteBuf#release()} ownership is transferred to this
     * {@link CompositeByteBuf}.
     */
    CompositeByteBuf addComponent(ByteBuf buffer) {
        return addComponent(false, buffer);
    }

    /**
     * Add the given {@link ByteBuf}s.
     * <p>
     * Be aware that this method does not increase the {@code writerIndex} of the {@link CompositeByteBuf}.
     * If you need to have it increased use {@link #addComponents(bool, ByteBuf[])}.
     * <p>
     * {@link ByteBuf#release()} ownership of all {@link ByteBuf} objects in {@code buffers} is transferred to this
     * {@link CompositeByteBuf}.
     * @param buffers the {@link ByteBuf}s to add. {@link ByteBuf#release()} ownership of all {@link ByteBuf#release()}
     * ownership of all {@link ByteBuf} objects is transferred to this {@link CompositeByteBuf}.
     */
    CompositeByteBuf addComponents(ByteBuf[] buffers...) {
        return addComponents(false, buffers);
    }

    /**
     * Add the given {@link ByteBuf}s.
     * <p>
     * Be aware that this method does not increase the {@code writerIndex} of the {@link CompositeByteBuf}.
     * If you need to have it increased use {@link #addComponents(bool, Iterable)}.
     * <p>
     * {@link ByteBuf#release()} ownership of all {@link ByteBuf} objects in {@code buffers} is transferred to this
     * {@link CompositeByteBuf}.
     * @param buffers the {@link ByteBuf}s to add. {@link ByteBuf#release()} ownership of all {@link ByteBuf#release()}
     * ownership of all {@link ByteBuf} objects is transferred to this {@link CompositeByteBuf}.
     */
    CompositeByteBuf addComponents(Iterable!(ByteBuf) buffers) {
        return addComponents(false, buffers);
    }

    /**
     * Add the given {@link ByteBuf} on the specific index.
     * <p>
     * Be aware that this method does not increase the {@code writerIndex} of the {@link CompositeByteBuf}.
     * If you need to have it increased use {@link #addComponent(bool, int, ByteBuf)}.
     * <p>
     * {@link ByteBuf#release()} ownership of {@code buffer} is transferred to this {@link CompositeByteBuf}.
     * @param cIndex the index on which the {@link ByteBuf} will be added.
     * @param buffer the {@link ByteBuf} to add. {@link ByteBuf#release()} ownership is transferred to this
     * {@link CompositeByteBuf}.
     */
    CompositeByteBuf addComponent(int cIndex, ByteBuf buffer) {
        return addComponent(false, cIndex, buffer);
    }

    /**
     * Add the given {@link ByteBuf} and increase the {@code writerIndex} if {@code increaseWriterIndex} is
     * {@code true}.
     *
     * {@link ByteBuf#release()} ownership of {@code buffer} is transferred to this {@link CompositeByteBuf}.
     * @param buffer the {@link ByteBuf} to add. {@link ByteBuf#release()} ownership is transferred to this
     * {@link CompositeByteBuf}.
     */
    CompositeByteBuf addComponent(bool increaseWriterIndex, ByteBuf buffer) {
        return addComponent(increaseWriterIndex, componentCount, buffer);
    }

    /**
     * Add the given {@link ByteBuf}s and increase the {@code writerIndex} if {@code increaseWriterIndex} is
     * {@code true}.
     *
     * {@link ByteBuf#release()} ownership of all {@link ByteBuf} objects in {@code buffers} is transferred to this
     * {@link CompositeByteBuf}.
     * @param buffers the {@link ByteBuf}s to add. {@link ByteBuf#release()} ownership of all {@link ByteBuf#release()}
     * ownership of all {@link ByteBuf} objects is transferred to this {@link CompositeByteBuf}.
     */
    CompositeByteBuf addComponents(bool increaseWriterIndex, ByteBuf[] buffers...) {
        checkNotNull(buffers, "buffers");
        addComponents0(increaseWriterIndex, componentCount, buffers, 0);
        consolidateIfNeeded();
        return this;
    }

    /**
     * Add the given {@link ByteBuf}s and increase the {@code writerIndex} if {@code increaseWriterIndex} is
     * {@code true}.
     *
     * {@link ByteBuf#release()} ownership of all {@link ByteBuf} objects in {@code buffers} is transferred to this
     * {@link CompositeByteBuf}.
     * @param buffers the {@link ByteBuf}s to add. {@link ByteBuf#release()} ownership of all {@link ByteBuf#release()}
     * ownership of all {@link ByteBuf} objects is transferred to this {@link CompositeByteBuf}.
     */
    CompositeByteBuf addComponents(bool increaseWriterIndex, Iterable!(ByteBuf) buffers) {
        return addComponents(increaseWriterIndex, componentCount, buffers);
    }

    /**
     * Add the given {@link ByteBuf} on the specific index and increase the {@code writerIndex}
     * if {@code increaseWriterIndex} is {@code true}.
     *
     * {@link ByteBuf#release()} ownership of {@code buffer} is transferred to this {@link CompositeByteBuf}.
     * @param cIndex the index on which the {@link ByteBuf} will be added.
     * @param buffer the {@link ByteBuf} to add. {@link ByteBuf#release()} ownership is transferred to this
     * {@link CompositeByteBuf}.
     */
    CompositeByteBuf addComponent(bool increaseWriterIndex, int cIndex, ByteBuf buffer) {
        checkNotNull(buffer, "buffer");
        addComponent0(increaseWriterIndex, cIndex, buffer);
        consolidateIfNeeded();
        return this;
    }

    /**
     * Precondition is that {@code buffer !is null}.
     */
    private int addComponent0(bool increaseWriterIndex, int cIndex, ByteBuf buffer) {
        assert(buffer !is null);
        bool wasAdded = false;
        try {
            checkComponentIndex(cIndex);

            // No need to consolidate - just add a component to the list.
            Component c = newComponent(buffer, 0);
            int readableBytes = c.length();

            addComp(cIndex, c);
            wasAdded = true;
            if (readableBytes > 0 && cIndex < componentCount - 1) {
                updateComponentOffsets(cIndex);
            } else if (cIndex > 0) {
                c.reposition(components[cIndex - 1].endOffset);
            }
            if (increaseWriterIndex) {
                _writerIndex += readableBytes;
            }
            return cIndex;
        } finally {
            if (!wasAdded) {
                buffer.release();
            }
        }
    }

    private Component newComponent(ByteBuf buf, int offset) {
        if (checkAccessible && !buf.isAccessible()) {
            throw new IllegalReferenceCountException(0);
        }
        int srcIndex = buf.readerIndex(), len = buf.readableBytes();
        ByteBuf _slice = null;
        // unwrap if already sliced
        AbstractUnpooledSlicedByteBuf slicedBuffer = cast(AbstractUnpooledSlicedByteBuf) buf;
        if (slicedBuffer !is null) {
            srcIndex += slicedBuffer.idx(0);
            _slice = buf;
            buf = buf.unwrap();
        } else {
            // TODO: Tasks pending completion -@zxp at 8/16/2019, 6:25:33 PM
            // 
            // implementationMissing(false);
            // if (buf instanceof PooledSlicedByteBuf) {
            //     srcIndex += ((PooledSlicedByteBuf) buf).adjustment;
            //     _slice = buf;
            //     buf = buf.unwrap();
            // }
        }
        return new Component(buf, srcIndex, offset, len, _slice); // .order(ByteOrder.BigEndian)
    }

    /**
     * Add the given {@link ByteBuf}s on the specific index
     * <p>
     * Be aware that this method does not increase the {@code writerIndex} of the {@link CompositeByteBuf}.
     * If you need to have it increased you need to handle it by your own.
     * <p>
     * {@link ByteBuf#release()} ownership of all {@link ByteBuf} objects in {@code buffers} is transferred to this
     * {@link CompositeByteBuf}.
     * @param cIndex the index on which the {@link ByteBuf} will be added. {@link ByteBuf#release()} ownership of all
     * {@link ByteBuf#release()} ownership of all {@link ByteBuf} objects is transferred to this
     * {@link CompositeByteBuf}.
     * @param buffers the {@link ByteBuf}s to add. {@link ByteBuf#release()} ownership of all {@link ByteBuf#release()}
     * ownership of all {@link ByteBuf} objects is transferred to this {@link CompositeByteBuf}.
     */
    CompositeByteBuf addComponents(int cIndex, ByteBuf[] buffers...) {
        checkNotNull(buffers, "buffers");
        addComponents0(false, cIndex, buffers, 0);
        consolidateIfNeeded();
        return this;
    }

    private CompositeByteBuf addComponents0(bool increaseWriterIndex,
            int cIndex, ByteBuf[] buffers, int arrOffset) {
        int len = cast(int)buffers.length;
        int count = len - arrOffset;
        // only set ci after we've shifted so that finally block logic is always correct
        int ci = int.max;
        try {
            checkComponentIndex(cIndex);
            shiftComps(cIndex, count); // will increase componentCount
            int nextOffset = cIndex > 0 ? components[cIndex - 1].endOffset : 0;
            for (ci = cIndex; arrOffset < len; arrOffset++, ci++) {
                ByteBuf b = buffers[arrOffset];
                if (b is null) {
                    break;
                }
                Component c = newComponent(b, nextOffset);
                components[ci] = c;
                nextOffset = c.endOffset;
            }
            return this;
        } finally {
            // ci is now the index following the last successfully added component
            if (ci < componentCount) {
                if (ci < cIndex + count) {
                    // we bailed early
                    removeCompRange(ci, cIndex + count);
                    for (; arrOffset < len; ++arrOffset) {
                        ReferenceCountUtil.safeRelease(buffers[arrOffset]);
                    }
                }
                updateComponentOffsets(ci); // only need to do this here for components after the added ones
            }
            if (increaseWriterIndex && ci > cIndex && ci <= componentCount) {
                _writerIndex += components[ci - 1].endOffset - components[cIndex].offset;
            }
        }
    }

    private int addComponents0(T)(bool increaseWriterIndex, int cIndex,
            ByteWrapper!(T) wrapper, T[] buffers, int offset) {
        checkComponentIndex(cIndex);

        // No need for consolidation
        for (int i = offset, len = cast(int)buffers.length; i < len; i++) {
            T b = buffers[i];
            if (b is null) {
                break;
            }
            if (!wrapper.isEmpty(b)) {
                cIndex = addComponent0(increaseWriterIndex, cIndex, wrapper.wrap(b)) + 1;
                int size = componentCount;
                if (cIndex > size) {
                    cIndex = size;
                }
            }
        }
        return cIndex;
    }

    /**
     * Add the given {@link ByteBuf}s on the specific index
     *
     * Be aware that this method does not increase the {@code writerIndex} of the {@link CompositeByteBuf}.
     * If you need to have it increased you need to handle it by your own.
     * <p>
     * {@link ByteBuf#release()} ownership of all {@link ByteBuf} objects in {@code buffers} is transferred to this
     * {@link CompositeByteBuf}.
     * @param cIndex the index on which the {@link ByteBuf} will be added.
     * @param buffers the {@link ByteBuf}s to add.  {@link ByteBuf#release()} ownership of all
     * {@link ByteBuf#release()} ownership of all {@link ByteBuf} objects is transferred to this
     * {@link CompositeByteBuf}.
     */
    CompositeByteBuf addComponents(int cIndex, Iterable!(ByteBuf) buffers) {
        return addComponents(false, cIndex, buffers);
    }

    /**
     * Add the given {@link ByteBuf} and increase the {@code writerIndex} if {@code increaseWriterIndex} is
     * {@code true}. If the provided buffer is a {@link CompositeByteBuf} itself, a "shallow copy" of its
     * readable components will be performed. Thus the actual number of new components added may vary
     * and in particular will be zero if the provided buffer is not readable.
     * <p>
     * {@link ByteBuf#release()} ownership of {@code buffer} is transferred to this {@link CompositeByteBuf}.
     * @param buffer the {@link ByteBuf} to add. {@link ByteBuf#release()} ownership is transferred to this
     * {@link CompositeByteBuf}.
     */
    CompositeByteBuf addFlattenedComponents(bool increaseWriterIndex, ByteBuf buffer) {
        checkNotNull(buffer, "buffer");
        int ridx = buffer.readerIndex();
        int widx = buffer.writerIndex();
        if (ridx == widx) {
            buffer.release();
            return this;
        }
        CompositeByteBuf from = cast(CompositeByteBuf) buffer;
        if (from is null) {
            addComponent0(increaseWriterIndex, componentCount, buffer);
            consolidateIfNeeded();
            return this;
        }
        from.checkIndex(ridx, widx - ridx);
        Component[] fromComponents = from.components;
        int compCountBefore = componentCount;
        int writerIndexBefore = writerIndex;
        try {
            for (int cidx = from.toComponentIndex0(ridx), newOffset = capacity();; cidx++) {
                Component component = fromComponents[cidx];
                int compOffset = component.offset;
                int fromIdx = max(ridx, compOffset);
                int toIdx = min(widx, component.endOffset);
                int len = toIdx - fromIdx;
                if (len > 0) { // skip empty components
                    // Note that it's safe to just retain the unwrapped buf here, even in the case
                    // of PooledSlicedByteBufs - those slices will still be properly released by the
                    // source Component's free() method.
                    addComp(componentCount, new Component(
                            component.buf.retain(), component.idx(fromIdx), newOffset, len, null));
                }
                if (widx == toIdx) {
                    break;
                }
                newOffset += len;
            }
            if (increaseWriterIndex) {
                writerIndex = writerIndexBefore + (widx - ridx);
            }
            consolidateIfNeeded();
            buffer.release();
            buffer = null;
            return this;
        } finally {
            if (buffer !is null) {
                // if we did not succeed, attempt to rollback any components that were added
                if (increaseWriterIndex) {
                    writerIndex = writerIndexBefore;
                }
                for (int cidx = componentCount - 1; cidx >= compCountBefore; cidx--) {
                    components[cidx].free();
                    removeComp(cidx);
                }
            }
        }
    }

    // TODO optimize further, similar to ByteBuf[] version
    // (difference here is that we don't know *always* know precise size increase in advance,
    // but we do in the most common case that the Iterable is a Collection)
    private CompositeByteBuf addComponents(bool increaseIndex, int cIndex, Iterable!(ByteBuf) buffers) {
        // if (buffers instanceof ByteBuf) {
        //     // If buffers also implements ByteBuf (e.g. CompositeByteBuf), it has to go to addComponent(ByteBuf).
        //     return addComponent(increaseIndex, cIndex, (ByteBuf) buffers);
        // }
        // checkNotNull(buffers, "buffers");
        // Iterator!(ByteBuf) it = buffers.iterator();
        // try {
        //     checkComponentIndex(cIndex);

        //     // No need for consolidation
        //     while (it.hasNext()) {
        //         ByteBuf b = it.next();
        //         if (b is null) {
        //             break;
        //         }
        //         cIndex = addComponent0(increaseIndex, cIndex, b) + 1;
        //         cIndex = min(cIndex, componentCount);
        //     }
        // } finally {
        //     while (it.hasNext()) {
        //         ReferenceCountUtil.safeRelease(it.next());
        //     }
        // }
        // consolidateIfNeeded();
        implementationMissing(false);
        return this;
    }

    /**
     * This should only be called as last operation from a method as this may adjust the underlying
     * array of components and so affect the index etc.
     */
    private void consolidateIfNeeded() {
        // Consolidate if the number of components will exceed the allowed maximum by the current
        // operation.
        int size = componentCount;
        if (size > _maxNumComponents) {
            int capacity = components[size - 1].endOffset;

            ByteBuf consolidated = allocBuffer(capacity);
            lastAccessed = null;

            // We're not using foreach to avoid creating an iterator.
            for (int i = 0; i < size; i ++) {
                components[i].transferTo(consolidated);
            }

            components[0] = new Component(consolidated, 0, 0, capacity, consolidated);
            removeCompRange(1, size);
        }
    }

    private void checkComponentIndex(int cIndex) {
        ensureAccessible();
        if (cIndex < 0 || cIndex > componentCount) {
            throw new IndexOutOfBoundsException(format(
                    "cIndex: %d (expected: >= 0 && <= numComponents(%d))",
                    cIndex, componentCount));
        }
    }

    private void checkComponentIndex(int cIndex, int numComponents) {
        ensureAccessible();
        if (cIndex < 0 || cIndex + numComponents > componentCount) {
            throw new IndexOutOfBoundsException(format(
                    "cIndex: %d, numComponents: %d " ~
                    "(expected: cIndex >= 0 && cIndex + numComponents <= totalNumComponents(%d))",
                    cIndex, numComponents, componentCount));
        }
    }

    private void updateComponentOffsets(int cIndex) {
        int size = componentCount;
        if (size <= cIndex) {
            return;
        }

        int nextIndex = cIndex > 0 ? components[cIndex - 1].endOffset : 0;
        for (; cIndex < size; cIndex++) {
            Component c = components[cIndex];
            c.reposition(nextIndex);
            nextIndex = c.endOffset;
        }
    }

    /**
     * Remove the {@link ByteBuf} from the given index.
     *
     * @param cIndex the index on from which the {@link ByteBuf} will be remove
     */
    CompositeByteBuf removeComponent(int cIndex) {
        checkComponentIndex(cIndex);
        Component comp = components[cIndex];
        if (lastAccessed == comp) {
            lastAccessed = null;
        }
        comp.free();
        removeComp(cIndex);
        if (comp.length() > 0) {
            // Only need to call updateComponentOffsets if the length was > 0
            updateComponentOffsets(cIndex);
        }
        return this;
    }

    /**
     * Remove the number of {@link ByteBuf}s starting from the given index.
     *
     * @param cIndex the index on which the {@link ByteBuf}s will be started to removed
     * @param numComponents the number of components to remove
     */
    CompositeByteBuf removeComponents(int cIndex, int numComponents) {
        checkComponentIndex(cIndex, numComponents);

        if (numComponents == 0) {
            return this;
        }
        int endIndex = cIndex + numComponents;
        bool needsUpdate = false;
        for (int i = cIndex; i < endIndex; ++i) {
            Component c = components[i];
            if (c.length() > 0) {
                needsUpdate = true;
            }
            if (lastAccessed == c) {
                lastAccessed = null;
            }
            c.free();
        }
        removeCompRange(cIndex, endIndex);

        if (needsUpdate) {
            // Only need to call updateComponentOffsets if the length was > 0
            updateComponentOffsets(cIndex);
        }
        return this;
    }

    // override
    InputRange!(ByteBuf) iterator() {
        ensureAccessible();
        // return componentCount == 0 ? EMPTY_ITERATOR : new CompositeByteBufIterator();
        implementationMissing(false);
        return null;
    }

    int opApply(scope int delegate(ref ByteBuf) dg) {
        if(dg is null)
            throw new NullPointerException();
            
        int result = 0;
        foreach(Component v; components) {
            ByteBuf b = v.slice();
            result = dg(b);
            if(result != 0) return result;
        }
        return result;

    }

    override
    protected int forEachByteAsc0(int start, int end, ByteProcessor processor) {
        if (end <= start) {
            return -1;
        }
        for (int i = toComponentIndex0(start), length = end - start; length > 0; i++) {
            Component c = components[i];
            if (c.offset == c.endOffset) {
                continue; // empty
            }
            ByteBuf s = c.buf;
            int localStart = c.idx(start);
            int localLength = min(length, c.endOffset - start);
            // avoid additional checks in AbstractByteBuf case
            AbstractByteBuf buffer = cast(AbstractByteBuf) s;
            int result = 0;
            if(buffer is null)
                result = s.forEachByte(localStart, localLength, processor);
            else
                buffer.forEachByteAsc0(localStart, localStart + localLength, processor);

            if (result != -1) {
                return result - c.adjustment;
            }
            start += localLength;
            length -= localLength;
        }
        return -1;
    }

    override
    protected int forEachByteDesc0(int rStart, int rEnd, ByteProcessor processor) {
        if (rEnd > rStart) { // rStart *and* rEnd are inclusive
            return -1;
        }
        for (int i = toComponentIndex0(rStart), length = 1 + rStart - rEnd; length > 0; i--) {
            Component c = components[i];
            if (c.offset == c.endOffset) {
                continue; // empty
            }
            ByteBuf s = c.buf;
            int localRStart = c.idx(length + rEnd);
            int localLength = min(length, localRStart), localIndex = localRStart - localLength;
            // avoid additional checks in AbstractByteBuf case
            int result = 0;
            AbstractByteBuf buf = cast(AbstractByteBuf) s;
            if(buf is null)
                result = s.forEachByteDesc(localIndex, localLength, processor);
            else
                result = buf.forEachByteDesc0(localRStart - 1, localIndex, processor);

            if (result != -1) {
                return result - c.adjustment;
            }
            length -= localLength;
        }
        return -1;
    }

    /**
     * Same with {@link #slice(int, int)} except that this method returns a list.
     */
    List!(ByteBuf) decompose(int offset, int length) {
        checkIndex(offset, length);
        if (length == 0) {
            return Collections.emptyList!(ByteBuf)();
        }

        int componentId = toComponentIndex0(offset);
        int bytesToSlice = length;
        // The first component
        Component firstC = components[componentId];

        ByteBuf _slice = firstC.buf.slice(firstC.idx(offset), min(firstC.endOffset - offset, bytesToSlice));
        bytesToSlice -= _slice.readableBytes();

        if (bytesToSlice == 0) {
            return Collections.singletonList(_slice);
        }

        List!(ByteBuf) sliceList = new ArrayList!(ByteBuf)(componentCount - componentId);
        sliceList.add(_slice);

        // Add all the slices until there is nothing more left and then return the List.
        do {
            Component component = components[++componentId];
            _slice = component.buf.slice(component.idx(component.offset), min(component.length(), bytesToSlice));
            bytesToSlice -= _slice.readableBytes();
            sliceList.add(_slice);
        } while (bytesToSlice > 0);

        return sliceList;
    }

    override
    bool isDirect() {
        int size = componentCount;
        if (size == 0) {
            return false;
        }
        for (int i = 0; i < size; i++) {
           if (!components[i].buf.isDirect()) {
               return false;
           }
        }
        return true;
    }

    override
    bool hasArray() {
        switch (componentCount) {
        case 0:
            return true;
        case 1:
            return components[0].buf.hasArray();
        default:
            return false;
        }
    }

    override
    byte[] array() {
        switch (componentCount) {
        case 0:
            return [];
        case 1:
            return components[0].buf.array();
        default:
            throw new UnsupportedOperationException();
        }
    }

    override
    int arrayOffset() {
        switch (componentCount) {
        case 0:
            return 0;
        case 1:
            Component c = components[0];
            return c.idx(c.buf.arrayOffset());
        default:
            throw new UnsupportedOperationException();
        }
    }

    override
    bool hasMemoryAddress() {
        switch (componentCount) {
        case 0:
            return Unpooled.EMPTY_BUFFER.hasMemoryAddress();
        case 1:
            return components[0].buf.hasMemoryAddress();
        default:
            return false;
        }
    }

    override
    long memoryAddress() {
        switch (componentCount) {
        case 0:
            return Unpooled.EMPTY_BUFFER.memoryAddress();
        case 1:
            Component c = components[0];
            return c.buf.memoryAddress() + c.adjustment;
        default:
            throw new UnsupportedOperationException();
        }
    }

    override
    int capacity() {
        int size = componentCount;
        return size > 0 ? components[size - 1].endOffset : 0;
    }

    override
    CompositeByteBuf capacity(int newCapacity) {
        checkNewCapacity(newCapacity);

        int size = componentCount, oldCapacity = capacity();
        if (newCapacity > oldCapacity) {
            int paddingLength = newCapacity - oldCapacity;
            ByteBuf padding = allocBuffer(paddingLength).setIndex(0, paddingLength);
            addComponent0(false, size, padding);
            if (componentCount >= _maxNumComponents) {
                // FIXME: No need to create a padding buffer and consolidate.
                // Just create a big single buffer and put the current content there.
                consolidateIfNeeded();
            }
        } else if (newCapacity < oldCapacity) {
            lastAccessed = null;
            int i = size - 1;
            for (int bytesToTrim = oldCapacity - newCapacity; i >= 0; i--) {
                Component c = components[i];
                int cLength = c.length();
                if (bytesToTrim < cLength) {
                    // Trim the last component
                    c.endOffset -= bytesToTrim;
                    ByteBuf _slice = c._slice;
                    if (_slice !is null) {
                        // We must replace the cached slice with a derived one to ensure that
                        // it can later be released properly in the case of PooledSlicedByteBuf.
                        c._slice = _slice.slice(0, c.length());
                    }
                    break;
                }
                c.free();
                bytesToTrim -= cLength;
            }
            removeCompRange(i + 1, size);

            if (readerIndex() > newCapacity) {
                setIndex0(newCapacity, newCapacity);
            } else if (writerIndex > newCapacity) {
                writerIndex = newCapacity;
            }
        }
        return this;
    }

    override
    ByteBufAllocator alloc() {
        return _alloc;
    }

    override
    ByteOrder order() {
        return ByteOrder.BigEndian;
    }

    /**
     * Return the current number of {@link ByteBuf}'s that are composed in this instance
     */
    int numComponents() {
        return componentCount;
    }

    /**
     * Return the max number of {@link ByteBuf}'s that are composed in this instance
     */
    int maxNumComponents() {
        return _maxNumComponents;
    }

    /**
     * Return the index for the given offset
     */
    int toComponentIndex(int offset) {
        checkIndex(offset);
        return toComponentIndex0(offset);
    }

    private int toComponentIndex0(int offset) {
        int size = componentCount;
        if (offset == 0) { // fast-path zero offset
            for (int i = 0; i < size; i++) {
                if (components[i].endOffset > 0) {
                    return i;
                }
            }
        }
        if (size <= 2) { // fast-path for 1 and 2 component count
            return size == 1 || offset < components[0].endOffset ? 0 : 1;
        }
        for (int low = 0, high = size; low <= high;) {
            int mid = low + high >>> 1;
            Component c = components[mid];
            if (offset >= c.endOffset) {
                low = mid + 1;
            } else if (offset < c.offset) {
                high = mid - 1;
            } else {
                return mid;
            }
        }

        throw new Error("should not reach here");
    }

    int toByteIndex(int cIndex) {
        checkComponentIndex(cIndex);
        return components[cIndex].offset;
    }

    override
    byte getByte(int index) {
        Component c = findComponent(index);
        return c.buf.getByte(c.idx(index));
    }

    override
    protected byte _getByte(int index) {
        Component c = findComponent0(index);
        return c.buf.getByte(c.idx(index));
    }

    override
    protected short _getShort(int index) {
        Component c = findComponent0(index);
        if (index + 2 <= c.endOffset) {
            return c.buf.getShort(c.idx(index));
        } else if (order() == ByteOrder.BigEndian) {
            return cast(short) ((_getByte(index) & 0xff) << 8 | _getByte(index + 1) & 0xff);
        } else {
            return cast(short) (_getByte(index) & 0xff | (_getByte(index + 1) & 0xff) << 8);
        }
    }

    override
    protected short _getShortLE(int index) {
        Component c = findComponent0(index);
        if (index + 2 <= c.endOffset) {
            return c.buf.getShortLE(c.idx(index));
        } else if (order() == ByteOrder.BigEndian) {
            return cast(short) (_getByte(index) & 0xff | (_getByte(index + 1) & 0xff) << 8);
        } else {
            return cast(short) ((_getByte(index) & 0xff) << 8 | _getByte(index + 1) & 0xff);
        }
    }

    override
    protected int _getUnsignedMedium(int index) {
        Component c = findComponent0(index);
        if (index + 3 <= c.endOffset) {
            return c.buf.getUnsignedMedium(c.idx(index));
        } else if (order() == ByteOrder.BigEndian) {
            return (_getShort(index) & 0xffff) << 8 | _getByte(index + 2) & 0xff;
        } else {
            return _getShort(index) & 0xFFFF | (_getByte(index + 2) & 0xFF) << 16;
        }
    }

    override
    protected int _getUnsignedMediumLE(int index) {
        Component c = findComponent0(index);
        if (index + 3 <= c.endOffset) {
            return c.buf.getUnsignedMediumLE(c.idx(index));
        } else if (order() == ByteOrder.BigEndian) {
            return _getShortLE(index) & 0xffff | (_getByte(index + 2) & 0xff) << 16;
        } else {
            return (_getShortLE(index) & 0xffff) << 8 | _getByte(index + 2) & 0xff;
        }
    }

    override
    protected int _getInt(int index) {
        Component c = findComponent0(index);
        if (index + 4 <= c.endOffset) {
            return c.buf.getInt(c.idx(index));
        } else if (order() == ByteOrder.BigEndian) {
            return (_getShort(index) & 0xffff) << 16 | _getShort(index + 2) & 0xffff;
        } else {
            return _getShort(index) & 0xFFFF | (_getShort(index + 2) & 0xFFFF) << 16;
        }
    }

    override
    protected int _getIntLE(int index) {
        Component c = findComponent0(index);
        if (index + 4 <= c.endOffset) {
            return c.buf.getIntLE(c.idx(index));
        } else if (order() == ByteOrder.BigEndian) {
            return _getShortLE(index) & 0xffff | (_getShortLE(index + 2) & 0xffff) << 16;
        } else {
            return (_getShortLE(index) & 0xffff) << 16 | _getShortLE(index + 2) & 0xffff;
        }
    }

    override
    protected long _getLong(int index) {
        Component c = findComponent0(index);
        if (index + 8 <= c.endOffset) {
            return c.buf.getLong(c.idx(index));
        } else if (order() == ByteOrder.BigEndian) {
            return (_getInt(index) & 0xffffffffL) << 32 | _getInt(index + 4) & 0xffffffffL;
        } else {
            return _getInt(index) & 0xFFFFFFFFL | (_getInt(index + 4) & 0xFFFFFFFFL) << 32;
        }
    }

    override
    protected long _getLongLE(int index) {
        Component c = findComponent0(index);
        if (index + 8 <= c.endOffset) {
            return c.buf.getLongLE(c.idx(index));
        } else if (order() == ByteOrder.BigEndian) {
            return _getIntLE(index) & 0xffffffffL | (_getIntLE(index + 4) & 0xffffffffL) << 32;
        } else {
            return (_getIntLE(index) & 0xffffffffL) << 32 | _getIntLE(index + 4) & 0xffffffffL;
        }
    }

    override
    CompositeByteBuf getBytes(int index, byte[] dst, int dstIndex, int length) {
        checkDstIndex(index, length, dstIndex, cast(int)dst.length);
        if (length == 0) {
            return this;
        }

        int i = toComponentIndex0(index);
        while (length > 0) {
            Component c = components[i];
            int localLength = min(length, c.endOffset - index);
            c.buf.getBytes(c.idx(index), dst, dstIndex, localLength);
            index += localLength;
            dstIndex += localLength;
            length -= localLength;
            i ++;
        }
        return this;
    }

    override
    CompositeByteBuf getBytes(int index, ByteBuffer dst) {
        int limit = dst.limit();
        int length = dst.remaining();

        checkIndex(index, length);
        if (length == 0) {
            return this;
        }

        int i = toComponentIndex0(index);
        try {
            while (length > 0) {
                Component c = components[i];
                int localLength = min(length, c.endOffset - index);
                dst.limit(dst.position() + localLength);
                c.buf.getBytes(c.idx(index), dst);
                index += localLength;
                length -= localLength;
                i ++;
            }
        } finally {
            dst.limit(limit);
        }
        return this;
    }

    override
    CompositeByteBuf getBytes(int index, ByteBuf dst, int dstIndex, int length) {
        checkDstIndex(index, length, dstIndex, dst.capacity());
        if (length == 0) {
            return this;
        }

        int i = toComponentIndex0(index);
        while (length > 0) {
            Component c = components[i];
            int localLength = min(length, c.endOffset - index);
            c.buf.getBytes(c.idx(index), dst, dstIndex, localLength);
            index += localLength;
            dstIndex += localLength;
            length -= localLength;
            i ++;
        }
        return this;
    }

    // override
    // int getBytes(int index, GatheringByteChannel output, int length) {
    //     int count = nioBufferCount();
    //     if (count == 1) {
    //         return output.write(internalNioBuffer(index, length));
    //     } else {
    //         long writtenBytes = output.write(nioBuffers(index, length));
    //         if (writtenBytes > int.max) {
    //             return int.max;
    //         } else {
    //             return cast(int) writtenBytes;
    //         }
    //     }
    // }

    // override
    // int getBytes(int index, FileChannel output, long position, int length) {
    //     int count = nioBufferCount();
    //     if (count == 1) {
    //         return output.write(internalNioBuffer(index, length), position);
    //     } else {
    //         long writtenBytes = 0;
    //         foreach(ByteBuffer buf ; nioBuffers(index, length)) {
    //             writtenBytes += output.write(buf, position + writtenBytes);
    //         }
    //         if (writtenBytes > int.max) {
    //             return int.max;
    //         }
    //         return cast(int) writtenBytes;
    //     }
    // }

    override
    CompositeByteBuf getBytes(int index, OutputStream output, int length) {
        checkIndex(index, length);
        if (length == 0) {
            return this;
        }

        int i = toComponentIndex0(index);
        while (length > 0) {
            Component c = components[i];
            int localLength = min(length, c.endOffset - index);
            c.buf.getBytes(c.idx(index), output, localLength);
            index += localLength;
            length -= localLength;
            i ++;
        }
        return this;
    }

    override
    CompositeByteBuf setByte(int index, int value) {
        Component c = findComponent(index);
        c.buf.setByte(c.idx(index), value);
        return this;
    }

    override
    protected void _setByte(int index, int value) {
        Component c = findComponent0(index);
        c.buf.setByte(c.idx(index), value);
    }

    override
    CompositeByteBuf setShort(int index, int value) {
        checkIndex(index, 2);
        _setShort(index, value);
        return this;
    }

    override
    protected void _setShort(int index, int value) {
        Component c = findComponent0(index);
        if (index + 2 <= c.endOffset) {
            c.buf.setShort(c.idx(index), value);
        } else if (order() == ByteOrder.BigEndian) {
            _setByte(index, cast(byte) (value >>> 8));
            _setByte(index + 1, cast(byte) value);
        } else {
            _setByte(index, cast(byte) value);
            _setByte(index + 1, cast(byte) (value >>> 8));
        }
    }

    override
    protected void _setShortLE(int index, int value) {
        Component c = findComponent0(index);
        if (index + 2 <= c.endOffset) {
            c.buf.setShortLE(c.idx(index), value);
        } else if (order() == ByteOrder.BigEndian) {
            _setByte(index, cast(byte) value);
            _setByte(index + 1, cast(byte) (value >>> 8));
        } else {
            _setByte(index, cast(byte) (value >>> 8));
            _setByte(index + 1, cast(byte) value);
        }
    }

    override
    CompositeByteBuf setMedium(int index, int value) {
        checkIndex(index, 3);
        _setMedium(index, value);
        return this;
    }

    override
    protected void _setMedium(int index, int value) {
        Component c = findComponent0(index);
        if (index + 3 <= c.endOffset) {
            c.buf.setMedium(c.idx(index), value);
        } else if (order() == ByteOrder.BigEndian) {
            _setShort(index, cast(short) (value >> 8));
            _setByte(index + 2, cast(byte) value);
        } else {
            _setShort(index, cast(short) value);
            _setByte(index + 2, cast(byte) (value >>> 16));
        }
    }

    override
    protected void _setMediumLE(int index, int value) {
        Component c = findComponent0(index);
        if (index + 3 <= c.endOffset) {
            c.buf.setMediumLE(c.idx(index), value);
        } else if (order() == ByteOrder.BigEndian) {
            _setShortLE(index, cast(short) value);
            _setByte(index + 2, cast(byte) (value >>> 16));
        } else {
            _setShortLE(index, cast(short) (value >> 8));
            _setByte(index + 2, cast(byte) value);
        }
    }

    override
    CompositeByteBuf setInt(int index, int value) {
        checkIndex(index, 4);
        _setInt(index, value);
        return this;
    }

    override
    protected void _setInt(int index, int value) {
        Component c = findComponent0(index);
        if (index + 4 <= c.endOffset) {
            c.buf.setInt(c.idx(index), value);
        } else if (order() == ByteOrder.BigEndian) {
            _setShort(index, cast(short) (value >>> 16));
            _setShort(index + 2, cast(short) value);
        } else {
            _setShort(index, cast(short) value);
            _setShort(index + 2, cast(short) (value >>> 16));
        }
    }

    override
    protected void _setIntLE(int index, int value) {
        Component c = findComponent0(index);
        if (index + 4 <= c.endOffset) {
            c.buf.setIntLE(c.idx(index), value);
        } else if (order() == ByteOrder.BigEndian) {
            _setShortLE(index, cast(short) value);
            _setShortLE(index + 2, cast(short) (value >>> 16));
        } else {
            _setShortLE(index, cast(short) (value >>> 16));
            _setShortLE(index + 2, cast(short) value);
        }
    }

    override
    CompositeByteBuf setLong(int index, long value) {
        checkIndex(index, 8);
        _setLong(index, value);
        return this;
    }

    override
    protected void _setLong(int index, long value) {
        Component c = findComponent0(index);
        if (index + 8 <= c.endOffset) {
            c.buf.setLong(c.idx(index), value);
        } else if (order() == ByteOrder.BigEndian) {
            _setInt(index, cast(int) (value >>> 32));
            _setInt(index + 4, cast(int) value);
        } else {
            _setInt(index, cast(int) value);
            _setInt(index + 4, cast(int) (value >>> 32));
        }
    }

    override
    protected void _setLongLE(int index, long value) {
        Component c = findComponent0(index);
        if (index + 8 <= c.endOffset) {
            c.buf.setLongLE(c.idx(index), value);
        } else if (order() == ByteOrder.BigEndian) {
            _setIntLE(index, cast(int) value);
            _setIntLE(index + 4, cast(int) (value >>> 32));
        } else {
            _setIntLE(index, cast(int) (value >>> 32));
            _setIntLE(index + 4, cast(int) value);
        }
    }

    override
    CompositeByteBuf setBytes(int index, byte[] src, int srcIndex, int length) {
        checkSrcIndex(index, length, srcIndex, cast(int)src.length);
        if (length == 0) {
            return this;
        }

        int i = toComponentIndex0(index);
        while (length > 0) {
            Component c = components[i];
            int localLength = min(length, c.endOffset - index);
            c.buf.setBytes(c.idx(index), src, srcIndex, localLength);
            index += localLength;
            srcIndex += localLength;
            length -= localLength;
            i ++;
        }
        return this;
    }

    override
    CompositeByteBuf setBytes(int index, ByteBuffer src) {
        int limit = src.limit();
        int length = src.remaining();

        checkIndex(index, length);
        if (length == 0) {
            return this;
        }

        int i = toComponentIndex0(index);
        try {
            while (length > 0) {
                Component c = components[i];
                int localLength = min(length, c.endOffset - index);
                src.limit(src.position() + localLength);
                c.buf.setBytes(c.idx(index), src);
                index += localLength;
                length -= localLength;
                i ++;
            }
        } finally {
            src.limit(limit);
        }
        return this;
    }

    override
    CompositeByteBuf setBytes(int index, ByteBuf src, int srcIndex, int length) {
        checkSrcIndex(index, length, srcIndex, src.capacity());
        if (length == 0) {
            return this;
        }

        int i = toComponentIndex0(index);
        while (length > 0) {
            Component c = components[i];
            int localLength = min(length, c.endOffset - index);
            c.buf.setBytes(c.idx(index), src, srcIndex, localLength);
            index += localLength;
            srcIndex += localLength;
            length -= localLength;
            i ++;
        }
        return this;
    }

    override
    int setBytes(int index, InputStream input, int length) {
        checkIndex(index, length);
        if (length == 0) {
            return input.read([]);
        }

        int i = toComponentIndex0(index);
        int readBytes = 0;
        do {
            Component c = components[i];
            int localLength = min(length, c.endOffset - index);
            if (localLength == 0) {
                // Skip empty buffer
                i++;
                continue;
            }
            int localReadBytes = c.buf.setBytes(c.idx(index), input, localLength);
            if (localReadBytes < 0) {
                if (readBytes == 0) {
                    return -1;
                } else {
                    break;
                }
            }

            index += localReadBytes;
            length -= localReadBytes;
            readBytes += localReadBytes;
            if (localReadBytes == localLength) {
                i ++;
            }
        } while (length > 0);

        return readBytes;
    }

    // override
    // int setBytes(int index, ScatteringByteChannel input, int length) {
    //     checkIndex(index, length);
    //     if (length == 0) {
    //         return input.read(EMPTY_NIO_BUFFER);
    //     }

    //     int i = toComponentIndex0(index);
    //     int readBytes = 0;
    //     do {
    //         Component c = components[i];
    //         int localLength = min(length, c.endOffset - index);
    //         if (localLength == 0) {
    //             // Skip empty buffer
    //             i++;
    //             continue;
    //         }
    //         int localReadBytes = c.buf.setBytes(c.idx(index), input, localLength);

    //         if (localReadBytes == 0) {
    //             break;
    //         }

    //         if (localReadBytes < 0) {
    //             if (readBytes == 0) {
    //                 return -1;
    //             } else {
    //                 break;
    //             }
    //         }

    //         index += localReadBytes;
    //         length -= localReadBytes;
    //         readBytes += localReadBytes;
    //         if (localReadBytes == localLength) {
    //             i ++;
    //         }
    //     } while (length > 0);

    //     return readBytes;
    // }

    // override
    // int setBytes(int index, FileChannel input, long position, int length) {
    //     checkIndex(index, length);
    //     if (length == 0) {
    //         return input.read(EMPTY_NIO_BUFFER, position);
    //     }

    //     int i = toComponentIndex0(index);
    //     int readBytes = 0;
    //     do {
    //         Component c = components[i];
    //         int localLength = min(length, c.endOffset - index);
    //         if (localLength == 0) {
    //             // Skip empty buffer
    //             i++;
    //             continue;
    //         }
    //         int localReadBytes = c.buf.setBytes(c.idx(index), input, position + readBytes, localLength);

    //         if (localReadBytes == 0) {
    //             break;
    //         }

    //         if (localReadBytes < 0) {
    //             if (readBytes == 0) {
    //                 return -1;
    //             } else {
    //                 break;
    //             }
    //         }

    //         index += localReadBytes;
    //         length -= localReadBytes;
    //         readBytes += localReadBytes;
    //         if (localReadBytes == localLength) {
    //             i ++;
    //         }
    //     } while (length > 0);

    //     return readBytes;
    // }

    override
    ByteBuf copy(int index, int length) {
        checkIndex(index, length);
        ByteBuf dst = allocBuffer(length);
        if (length != 0) {
            copyTo(index, length, toComponentIndex0(index), dst);
        }
        return dst;
    }

    private void copyTo(int index, int length, int componentId, ByteBuf dst) {
        int dstIndex = 0;
        int i = componentId;

        while (length > 0) {
            Component c = components[i];
            int localLength = min(length, c.endOffset - index);
            c.buf.getBytes(c.idx(index), dst, dstIndex, localLength);
            index += localLength;
            dstIndex += localLength;
            length -= localLength;
            i ++;
        }

        dst.writerIndex(dst.capacity());
    }

    /**
     * Return the {@link ByteBuf} on the specified index
     *
     * @param cIndex the index for which the {@link ByteBuf} should be returned
     * @return buf the {@link ByteBuf} on the specified index
     */
    ByteBuf component(int cIndex) {
        checkComponentIndex(cIndex);
        return components[cIndex].duplicate();
    }

    /**
     * Return the {@link ByteBuf} on the specified index
     *
     * @param offset the offset for which the {@link ByteBuf} should be returned
     * @return the {@link ByteBuf} on the specified index
     */
    ByteBuf componentAtOffset(int offset) {
        return findComponent(offset).duplicate();
    }

    /**
     * Return the internal {@link ByteBuf} on the specified index. Note that updating the indexes of the returned
     * buffer will lead to an undefined behavior of this buffer.
     *
     * @param cIndex the index for which the {@link ByteBuf} should be returned
     */
    ByteBuf internalComponent(int cIndex) {
        checkComponentIndex(cIndex);
        return components[cIndex].slice();
    }

    /**
     * Return the internal {@link ByteBuf} on the specified offset. Note that updating the indexes of the returned
     * buffer will lead to an undefined behavior of this buffer.
     *
     * @param offset the offset for which the {@link ByteBuf} should be returned
     */
    ByteBuf internalComponentAtOffset(int offset) {
        return findComponent(offset).slice();
    }

    // weak cache - check it first when looking for component
    private Component lastAccessed;

    private Component findComponent(int offset) {
        Component la = lastAccessed;
        if (la !is null && offset >= la.offset && offset < la.endOffset) {
           ensureAccessible();
           return la;
        }
        checkIndex(offset);
        return findIt(offset);
    }

    private Component findComponent0(int offset) {
        Component la = lastAccessed;
        if (la !is null && offset >= la.offset && offset < la.endOffset) {
           return la;
        }
        return findIt(offset);
    }

    private Component findIt(int offset) {
        for (int low = 0, high = componentCount; low <= high;) {
            int mid = low + high >>> 1;
            Component c = components[mid];
            if (offset >= c.endOffset) {
                low = mid + 1;
            } else if (offset < c.offset) {
                high = mid - 1;
            } else {
                lastAccessed = c;
                return c;
            }
        }

        throw new Error("should not reach here");
    }

    override
    int nioBufferCount() {
        int size = componentCount;
        switch (size) {
        case 0:
            return 1;
        case 1:
            return components[0].buf.nioBufferCount();
        default:
            int count = 0;
            for (int i = 0; i < size; i++) {
                count += components[i].buf.nioBufferCount();
            }
            return count;
        }
    }

    override
    ByteBuffer internalNioBuffer(int index, int length) {
        switch (componentCount) {
        case 0:
            return EMPTY_NIO_BUFFER;
        case 1:
            return components[0].internalNioBuffer(index, length);
        default:
            throw new UnsupportedOperationException();
        }
    }

    override
    ByteBuffer nioBuffer(int index, int length) {
        checkIndex(index, length);

        switch (componentCount) {
            case 0:
                return EMPTY_NIO_BUFFER;
            case 1:
                Component c = components[0];
                ByteBuf buf = c.buf;
                if (buf.nioBufferCount() == 1) {
                    return buf.nioBuffer(c.idx(index), length);
                }
                break;
            default :
                break;
        }

        ByteBuffer[] buffers = nioBuffers(index, length);

        if (buffers.length == 1) {
            return buffers[0];
        }

        ByteBuffer merged = BufferUtils.allocate(length).order(order());
        foreach(ByteBuffer buf; buffers) {
            merged.put(buf);
        }

        merged.flip();
        return merged;
    }

    override
    ByteBuffer[] nioBuffers(int index, int length) {
        checkIndex(index, length);
        if (length == 0) {
            return [ EMPTY_NIO_BUFFER ];
        }

        implementationMissing(false);
        return null;

        // RecyclableArrayList buffers = RecyclableArrayList.newInstance(componentCount);
        // try {
        //     int i = toComponentIndex0(index);
        //     while (length > 0) {
        //         Component c = components[i];
        //         ByteBuf s = c.buf;
        //         int localLength = min(length, c.endOffset - index);
        //         switch (s.nioBufferCount()) {
        //         case 0:
        //             throw new UnsupportedOperationException();
        //         case 1:
        //             buffers.add(s.nioBuffer(c.idx(index), localLength));
        //             break;
        //         default:
        //             Collections.addAll(buffers, s.nioBuffers(c.idx(index), localLength));
        //         }

        //         index += localLength;
        //         length -= localLength;
        //         i ++;
        //     }

        //     return buffers.toArray(new ByteBuffer[0]);
        // } finally {
        //     buffers.recycle();
        // }
    }

    /**
     * Consolidate the composed {@link ByteBuf}s
     */
    CompositeByteBuf consolidate() {
        ensureAccessible();
        int numComponents = componentCount;
        if (numComponents <= 1) {
            return this;
        }

        int capacity = components[numComponents - 1].endOffset;
        ByteBuf consolidated = allocBuffer(capacity);

        for (int i = 0; i < numComponents; i ++) {
            components[i].transferTo(consolidated);
        }
        lastAccessed = null;
        components[0] = new Component(consolidated, 0, 0, capacity, consolidated);
        removeCompRange(1, numComponents);
        return this;
    }

    /**
     * Consolidate the composed {@link ByteBuf}s
     *
     * @param cIndex the index on which to start to compose
     * @param numComponents the number of components to compose
     */
    CompositeByteBuf consolidate(int cIndex, int numComponents) {
        checkComponentIndex(cIndex, numComponents);
        if (numComponents <= 1) {
            return this;
        }

        int endCIndex = cIndex + numComponents;
        Component last = components[endCIndex - 1];
        int capacity = last.endOffset - components[cIndex].offset;
        ByteBuf consolidated = allocBuffer(capacity);

        for (int i = cIndex; i < endCIndex; i ++) {
            components[i].transferTo(consolidated);
        }
        lastAccessed = null;
        removeCompRange(cIndex + 1, endCIndex);
        components[cIndex] = new Component(consolidated, 0, 0, capacity, consolidated);
        updateComponentOffsets(cIndex);
        return this;
    }

    /**
     * Discard all {@link ByteBuf}s which are read.
     */
    CompositeByteBuf discardReadComponents() {
        ensureAccessible();
        int rIndex = readerIndex();
        if (rIndex == 0) {
            return this;
        }

        // Discard everything if (readerIndex = writerIndex = capacity).
        int wIndex = writerIndex();
        if (rIndex == wIndex && wIndex == capacity()) {
            for (int i = 0, size = componentCount; i < size; i++) {
                components[i].free();
            }
            lastAccessed = null;
            clearComps();
            setIndex(0, 0);
            adjustMarkers(rIndex);
            return this;
        }

        // Remove read components.
        int firstComponentId = 0;
        Component c = null;
        for (int size = componentCount; firstComponentId < size; firstComponentId++) {
            c = components[firstComponentId];
            if (c.endOffset > rIndex) {
                break;
            }
            c.free();
        }
        if (firstComponentId == 0) {
            return this; // Nothing to discard
        }
        Component la = lastAccessed;
        if (la !is null && la.endOffset <= rIndex) {
            lastAccessed = null;
        }
        removeCompRange(0, firstComponentId);

        // Update indexes and markers.
        int offset = c.offset;
        updateComponentOffsets(0);
        setIndex(rIndex - offset, wIndex - offset);
        adjustMarkers(offset);
        return this;
    }

    override
    CompositeByteBuf discardReadBytes() {
        ensureAccessible();
        int rIndex = readerIndex();
        if (rIndex == 0) {
            return this;
        }

        // Discard everything if (readerIndex = writerIndex = capacity).
        int wIndex = writerIndex();
        if (rIndex == wIndex && wIndex == capacity()) {
            for (int i = 0, size = componentCount; i < size; i++) {
                components[i].free();
            }
            lastAccessed = null;
            clearComps();
            setIndex(0, 0);
            adjustMarkers(rIndex);
            return this;
        }

        int firstComponentId = 0;
        Component c = null;
        for (int size = componentCount; firstComponentId < size; firstComponentId++) {
            c = components[firstComponentId];
            if (c.endOffset > rIndex) {
                break;
            }
            c.free();
        }

        // Replace the first readable component with a new slice.
        int trimmedBytes = rIndex - c.offset;
        c.offset = 0;
        c.endOffset -= rIndex;
        c.adjustment += rIndex;
        ByteBuf slice = c.slice;
        if (slice !is null) {
            // We must replace the cached slice with a derived one to ensure that
            // it can later be released properly in the case of PooledSlicedByteBuf.
            c._slice = slice.slice(trimmedBytes, c.length());
        }
        Component la = lastAccessed;
        if (la !is null && la.endOffset <= rIndex) {
            lastAccessed = null;
        }

        removeCompRange(0, firstComponentId);

        // Update indexes and markers.
        updateComponentOffsets(0);
        setIndex(0, wIndex - rIndex);
        adjustMarkers(rIndex);
        return this;
    }

    private ByteBuf allocBuffer(int capacity) {
        return direct ? alloc().directBuffer(capacity) : alloc().heapBuffer(capacity);
    }

    override
    string toString() {
        string result = super.toString();
        result = result[0 .. $ - 1];
        return result ~ ", components=" ~ componentCount.to!string() ~ ")";
    }


    override
    CompositeByteBuf readerIndex(int index) {
        super.readerIndex(index);
        return this;
    }

    alias readerIndex = ByteBuf.readerIndex;

    override
    CompositeByteBuf writerIndex(int index) {
        super.writerIndex(index);
        return this;
    }
    alias writerIndex = ByteBuf.writerIndex;

    override
    CompositeByteBuf setIndex(int rIndex, int wIndex) {
        super.setIndex(rIndex, wIndex);
        return this;
    }

    override
    CompositeByteBuf clear() {
        super.clear();
        return this;
    }

    override
    CompositeByteBuf markReaderIndex() {
        super.markReaderIndex();
        return this;
    }

    override
    CompositeByteBuf resetReaderIndex() {
        super.resetReaderIndex();
        return this;
    }

    override
    CompositeByteBuf markWriterIndex() {
        super.markWriterIndex();
        return this;
    }

    override
    CompositeByteBuf resetWriterIndex() {
        super.resetWriterIndex();
        return this;
    }

    override
    CompositeByteBuf ensureWritable(int minWritableBytes) {
        super.ensureWritable(minWritableBytes);
        return this;
    }

    override
    CompositeByteBuf getBytes(int index, ByteBuf dst) {
        return getBytes(index, dst, dst.writableBytes());
    }

    override
    CompositeByteBuf getBytes(int index, ByteBuf dst, int length) {
        getBytes(index, dst, dst.writerIndex(), length);
        dst.writerIndex(dst.writerIndex() + length);
        return this;
    }

    override
    CompositeByteBuf getBytes(int index, byte[] dst) {
        return getBytes(index, dst, 0, cast(int)dst.length);
    }

    override
    CompositeByteBuf setBoolean(int index, bool value) {
        return setByte(index, value? 1 : 0);
    }

    override
    CompositeByteBuf setChar(int index, int value) {
        return setShort(index, value);
    }

    override
    CompositeByteBuf setFloat(int index, float value) {
        return setInt(index, Float.floatToRawIntBits(value));
    }

    override
    CompositeByteBuf setDouble(int index, double value) {
        return setLong(index, Double.doubleToRawLongBits(value));
    }

    override
    CompositeByteBuf setBytes(int index, ByteBuf src) {
        super.setBytes(index, src, src.readableBytes());
        return this;
    }

    override
    CompositeByteBuf setBytes(int index, ByteBuf src, int length) {
        super.setBytes(index, src, length);
        return this;
    }

    override
    CompositeByteBuf setBytes(int index, byte[] src) {
        return setBytes(index, src, 0, cast(int)src.length);
    }

    override
    CompositeByteBuf setZero(int index, int length) {
        super.setZero(index, length);
        return this;
    }

    override
    CompositeByteBuf readBytes(ByteBuf dst) {
        super.readBytes(dst, dst.writableBytes());
        return this;
    }

    override
    CompositeByteBuf readBytes(ByteBuf dst, int length) {
        super.readBytes(dst, length);
        return this;
    }

    override
    CompositeByteBuf readBytes(ByteBuf dst, int dstIndex, int length) {
        super.readBytes(dst, dstIndex, length);
        return this;
    }

    override
    CompositeByteBuf readBytes(byte[] dst) {
        super.readBytes(dst, 0, cast(int)dst.length);
        return this;
    }

    override
    CompositeByteBuf readBytes(byte[] dst, int dstIndex, int length) {
        super.readBytes(dst, dstIndex, length);
        return this;
    }

    override
    CompositeByteBuf readBytes(ByteBuffer dst) {
        super.readBytes(dst);
        return this;
    }

    override
    CompositeByteBuf readBytes(OutputStream output, int length) {
        super.readBytes(output, length);
        return this;
    }

    override
    CompositeByteBuf skipBytes(int length) {
        super.skipBytes(length);
        return this;
    }

    override
    CompositeByteBuf writeBoolean(bool value) {
        writeByte(value ? 1 : 0);
        return this;
    }

    override
    CompositeByteBuf writeByte(int value) {
        ensureWritable0(1);
        _setByte(_writerIndex++, value);
        return this;
    }

    override
    CompositeByteBuf writeShort(int value) {
        super.writeShort(value);
        return this;
    }

    override
    CompositeByteBuf writeMedium(int value) {
        super.writeMedium(value);
        return this;
    }

    override
    CompositeByteBuf writeInt(int value) {
        super.writeInt(value);
        return this;
    }

    override
    CompositeByteBuf writeLong(long value) {
        super.writeLong(value);
        return this;
    }

    override
    CompositeByteBuf writeChar(int value) {
        super.writeShort(value);
        return this;
    }

    override
    CompositeByteBuf writeFloat(float value) {
        super.writeInt(Float.floatToRawIntBits(value));
        return this;
    }

    override
    CompositeByteBuf writeDouble(double value) {
        super.writeLong(Double.doubleToRawLongBits(value));
        return this;
    }

    override
    CompositeByteBuf writeBytes(ByteBuf src) {
        super.writeBytes(src, src.readableBytes());
        return this;
    }

    override
    CompositeByteBuf writeBytes(ByteBuf src, int length) {
        super.writeBytes(src, length);
        return this;
    }

    override
    CompositeByteBuf writeBytes(ByteBuf src, int srcIndex, int length) {
        super.writeBytes(src, srcIndex, length);
        return this;
    }

    override
    CompositeByteBuf writeBytes(byte[] src) {
        super.writeBytes(src, 0, cast(int)src.length);
        return this;
    }

    override
    CompositeByteBuf writeBytes(byte[] src, int srcIndex, int length) {
        super.writeBytes(src, srcIndex, length);
        return this;
    }

    override
    CompositeByteBuf writeBytes(ByteBuffer src) {
        super.writeBytes(src);
        return this;
    }

    override
    CompositeByteBuf writeZero(int length) {
        super.writeZero(length);
        return this;
    }

    override
    CompositeByteBuf retain(int increment) {
        super.retain(increment);
        return this;
    }

    override
    CompositeByteBuf retain() {
        super.retain();
        return this;
    }

    override
    CompositeByteBuf touch() {
        return this;
    }

    override
    CompositeByteBuf touch(Object hint) {
        return this;
    }

    override
    ByteBuffer[] nioBuffers() {
        return nioBuffers(readerIndex(), readableBytes());
    }

    override
    CompositeByteBuf discardSomeReadBytes() {
        return discardReadComponents();
    }

    override
    protected void deallocate() {
        if (freed) {
            return;
        }

        freed = true;
        // We're not using foreach to avoid creating an iterator.
        // see https://github.com/netty/netty/issues/2642
        for (int i = 0, size = componentCount; i < size; i++) {
            components[i].free();
        }
    }

    override
    bool isAccessible() {
        return !freed;
    }

    override
    ByteBuf unwrap() {
        return null;
    }

    // private final class CompositeByteBufIterator : InputRange!(ByteBuf) {
    //     private int size = numComponents();
    //     private int index;

    //     override
    //     bool hasNext() {
    //         return size > index;
    //     }

    //     override
    //     ByteBuf next() {
    //         if (size != numComponents()) {
    //             throw new ConcurrentModificationException();
    //         }
    //         if (!hasNext()) {
    //             throw new NoSuchElementException();
    //         }
    //         try {
    //             return components[index++].slice();
    //         } catch (IndexOutOfBoundsException e) {
    //             throw new ConcurrentModificationException();
    //         }
    //     }

    //     override
    //     void remove() {
    //         throw new UnsupportedOperationException("Read-Only");
    //     }
    // }

    // Component array manipulation - range checking omitted

    private void clearComps() {
        removeCompRange(0, componentCount);
    }

    private void removeComp(int i) {
        removeCompRange(i, i + 1);
    }

    private void removeCompRange(int from, int to) {
        if (from >= to) {
            return;
        }
        int size = componentCount;
        assert(from >= 0 && to <= size);
        if (to < size) {
            // System.arraycopy(components, to, components, from, size - to);
            // components[from .. from + size - to] = components[to .. size];
            for(int i=0; i<size - to; i++) {
                components[from+i] = components[to+i];
            }
        }
        int newSize = size - to + from;
        for (int i = newSize; i < size; i++) {
            components[i] = null;
        }
        componentCount = newSize;
    }

    private void addComp(int i, Component c) {
        shiftComps(i, 1);
        components[i] = c;
    }

    private void shiftComps(int i, int count) {
        int size = componentCount, newSize = size + count;
        assert( i >= 0 && i <= size && count > 0);
        if (newSize > components.length) {
            // grow the array
            int newArrSize = max(size + (size >> 1), newSize);
            Component[] newArr;
            if (i == size) {
                newArr = components.dup; // Arrays.copyOf(components, newArrSize, Component[].class);
            } else {
                newArr = new Component[newArrSize];
                if (i > 0) {
                    // System.arraycopy(components, 0, newArr, 0, i);
                    newArr[0..i] = components[0..i];
                }
                if (i < size) {
                    newArr[i + count .. size+count] = components[i .. size];
                    // System.arraycopy(components, i, newArr, i + count, size - i);
                }
            }
            components = newArr;
        } else if (i < size) {
            // System.arraycopy(components, i, components, i + count, size - i);
            // components[i + count .. count+size] = components[i .. size];
            for(int j=0; j<size - i; j++)
                components[i + count + j] = components[i+j];
        }
        componentCount = newSize;
    }
}


private final class Component {
    ByteBuf buf;
    int adjustment;
    int offset;
    int endOffset;

    private ByteBuf _slice; // cached slice, may be null

    this(ByteBuf buf, int srcOffset, int offset, int len, ByteBuf slice) {
        this.buf = buf;
        this.offset = offset;
        this.endOffset = offset + len;
        this.adjustment = srcOffset - offset;
        this._slice = slice;
    }

    int idx(int index) {
        return index + adjustment;
    }

    int length() {
        return endOffset - offset;
    }

    void reposition(int newOffset) {
        int move = newOffset - offset;
        endOffset += move;
        adjustment -= move;
        offset = newOffset;
    }

    // copy then release
    void transferTo(ByteBuf dst) {
        dst.writeBytes(buf, idx(offset), length());
        free();
    }

    ByteBuf slice() {
        return _slice !is null ? _slice : (_slice = buf.slice(idx(offset), length()));
    }

    ByteBuf duplicate() {
        return buf.duplicate().setIndex(idx(offset), idx(endOffset));
    }

    ByteBuffer internalNioBuffer(int index, int length) {
        // We must not return the unwrapped buffer's internal buffer
        // if it was originally added as a slice - this check of the
        // slice field is threadsafe since we only care whether it
        // was set upon Component construction, and we aren't
        // attempting to access the referenced slice itself
        return _slice !is null ? buf.nioBuffer(idx(index), length)
                : buf.internalNioBuffer(idx(index), length);
    }

    void free() {
        // Release the slice if present since it may have a different
        // refcount to the unwrapped buf if it is a PooledSlicedByteBuf
        ByteBuf buffer = _slice;
        if (buffer !is null) {
            buffer.release();
        } else {
            buf.release();
        }
        // null out in either case since it could be racy if set lazily (but not
        // in the case we care about, where it will have been set in the ctor)
        _slice = null;
    }
}



// support passing arrays of other types instead of having to copy to a ByteBuf[] first
interface ByteWrapper(T) {
    ByteBuf wrap(T bytes);
    bool isEmpty(T bytes);
}
