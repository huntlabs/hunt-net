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

module hunt.net.buffer.AbstractByteBufAllocator;

import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufAllocator;
import hunt.net.buffer.CompositeByteBuf;
import hunt.net.buffer.EmptyByteBuf;

import hunt.Exceptions;

// import io.netty.util.ResourceLeakDetector;
// import io.netty.util.ResourceLeakTracker;
// import io.netty.util.internal.PlatformDependent;
// import io.netty.util.internal.StringUtil;

import std.algorithm;
import std.conv;
import std.format;


/**
 * Skeletal {@link ByteBufAllocator} implementation to extend.
 */
abstract class AbstractByteBufAllocator : ByteBufAllocator {
    enum int DEFAULT_INITIAL_CAPACITY = 256;
    enum int DEFAULT_MAX_CAPACITY = int.max;
    enum int DEFAULT_MAX_COMPONENTS = 16;
    enum int CALCULATE_THRESHOLD = 1048576 * 4; // 4 MiB page

    // static {
    //     ResourceLeakDetector.addExclusions(AbstractByteBufAllocator.class, "toLeakAwareBuffer");
    // }

    // protected static ByteBuf toLeakAwareBuffer(ByteBuf buf) {
    //     ResourceLeakTracker!(ByteBuf) leak;
    //     switch (ResourceLeakDetector.getLevel()) {
    //         case SIMPLE:
    //             leak = AbstractByteBuf.leakDetector.track(buf);
    //             if (leak !is null) {
    //                 buf = new SimpleLeakAwareByteBuf(buf, leak);
    //             }
    //             break;
    //         case ADVANCED:
    //         case PARANOID:
    //             leak = AbstractByteBuf.leakDetector.track(buf);
    //             if (leak !is null) {
    //                 buf = new AdvancedLeakAwareByteBuf(buf, leak);
    //             }
    //             break;
    //         default:
    //             break;
    //     }
    //     return buf;
    // }

    // protected static CompositeByteBuf toLeakAwareBuffer(CompositeByteBuf buf) {
    //     ResourceLeakTracker!(ByteBuf) leak;
    //     switch (ResourceLeakDetector.getLevel()) {
    //         case SIMPLE:
    //             leak = AbstractByteBuf.leakDetector.track(buf);
    //             if (leak !is null) {
    //                 buf = new SimpleLeakAwareCompositeByteBuf(buf, leak);
    //             }
    //             break;
    //         case ADVANCED:
    //         case PARANOID:
    //             leak = AbstractByteBuf.leakDetector.track(buf);
    //             if (leak !is null) {
    //                 buf = new AdvancedLeakAwareCompositeByteBuf(buf, leak);
    //             }
    //             break;
    //         default:
    //             break;
    //     }
    //     return buf;
    // }

    private bool directByDefault;
    private ByteBuf emptyBuf;

    /**
     * Instance use heap buffers by default
     */
    protected this() {
        this(false);
    }

    /**
     * Create new instance
     *
     * @param preferDirect {@code true} if {@link #buffer(int)} should try to allocate a direct buffer rather than
     *                     a heap buffer
     */
    protected this(bool preferDirect) {
        directByDefault = false; // preferDirect && PlatformDependent.hasUnsafe();
        emptyBuf = new EmptyByteBuf(this);
    }

    override
    ByteBuf buffer() {
        if (directByDefault) {
            return directBuffer();
        }
        return heapBuffer();
    }

    override
    ByteBuf buffer(int initialCapacity) {
        // if (directByDefault) {
        //     return directBuffer(initialCapacity);
        // }
        return heapBuffer(initialCapacity);
    }

    override
    ByteBuf buffer(int initialCapacity, int maxCapacity) {
        // if (directByDefault) {
        //     return directBuffer(initialCapacity, maxCapacity);
        // }
        return heapBuffer(initialCapacity, maxCapacity);
    }

    override
    ByteBuf ioBuffer() {
        // if (PlatformDependent.hasUnsafe() || isDirectBufferPooled()) {
        //     return directBuffer(DEFAULT_INITIAL_CAPACITY);
        // }
        return heapBuffer(DEFAULT_INITIAL_CAPACITY);
    }

    override
    ByteBuf ioBuffer(int initialCapacity) {
        // if (PlatformDependent.hasUnsafe() || isDirectBufferPooled()) {
        //     return directBuffer(initialCapacity);
        // }
        return heapBuffer(initialCapacity);
    }

    override
    ByteBuf ioBuffer(int initialCapacity, int maxCapacity) {
        // TODO: Tasks pending completion -@zxp at 8/15/2019, 9:38:10 AM
        // 
        // if (PlatformDependent.hasUnsafe() || isDirectBufferPooled()) {
        //     return directBuffer(initialCapacity, maxCapacity);
        // }
        return heapBuffer(initialCapacity, maxCapacity);
    }

    override
    ByteBuf heapBuffer() {
        return heapBuffer(DEFAULT_INITIAL_CAPACITY, DEFAULT_MAX_CAPACITY);
    }

    override
    ByteBuf heapBuffer(int initialCapacity) {
        return heapBuffer(initialCapacity, DEFAULT_MAX_CAPACITY);
    }

    override
    ByteBuf heapBuffer(int initialCapacity, int maxCapacity) {
        if (initialCapacity == 0 && maxCapacity == 0) {
            return emptyBuf;
        }
        validate(initialCapacity, maxCapacity);
        return newHeapBuffer(initialCapacity, maxCapacity);
    }

    override
    ByteBuf directBuffer() {
        return directBuffer(DEFAULT_INITIAL_CAPACITY, DEFAULT_MAX_CAPACITY);
    }

    override
    ByteBuf directBuffer(int initialCapacity) {
        return directBuffer(initialCapacity, DEFAULT_MAX_CAPACITY);
    }

    override
    ByteBuf directBuffer(int initialCapacity, int maxCapacity) {
        if (initialCapacity == 0 && maxCapacity == 0) {
            return emptyBuf;
        }
        validate(initialCapacity, maxCapacity);
        return newDirectBuffer(initialCapacity, maxCapacity);
    }

    override
    CompositeByteBuf compositeBuffer() {
        if (directByDefault) {
            return compositeDirectBuffer();
        }
        return compositeHeapBuffer();
    }

    override
    CompositeByteBuf compositeBuffer(int maxNumComponents) {
        if (directByDefault) {
            return compositeDirectBuffer(maxNumComponents);
        }
        return compositeHeapBuffer(maxNumComponents);
    }

    override
    CompositeByteBuf compositeHeapBuffer() {
        return compositeHeapBuffer(DEFAULT_MAX_COMPONENTS);
    }

    override
    CompositeByteBuf compositeHeapBuffer(int maxNumComponents) {
        // return toLeakAwareBuffer(new CompositeByteBuf(this, false, maxNumComponents));
        return new CompositeByteBuf(this, false, maxNumComponents);
    }

    override
    CompositeByteBuf compositeDirectBuffer() {
        return compositeDirectBuffer(DEFAULT_MAX_COMPONENTS);
    }

    override
    CompositeByteBuf compositeDirectBuffer(int maxNumComponents) {
        // return toLeakAwareBuffer(new CompositeByteBuf(this, true, maxNumComponents));
        return new CompositeByteBuf(this, true, maxNumComponents);
    }

    private static void validate(int initialCapacity, int maxCapacity) {
        checkPositiveOrZero(initialCapacity, "initialCapacity");
        if (initialCapacity > maxCapacity) {
            throw new IllegalArgumentException(format(
                    "initialCapacity: %d (expected: not greater than maxCapacity(%d)",
                    initialCapacity, maxCapacity));
        }
    }

    /**
     * Create a heap {@link ByteBuf} with the given initialCapacity and maxCapacity.
     */
    protected abstract ByteBuf newHeapBuffer(int initialCapacity, int maxCapacity);

    /**
     * Create a direct {@link ByteBuf} with the given initialCapacity and maxCapacity.
     */
    protected abstract ByteBuf newDirectBuffer(int initialCapacity, int maxCapacity);

    override
    string toString() {
        return typeid(this).name ~ "(directByDefault: " ~ directByDefault.to!string ~ ")";
    }

    override
    int calculateNewCapacity(int minNewCapacity, int maxCapacity) {
        checkPositiveOrZero(minNewCapacity, "minNewCapacity");
        if (minNewCapacity > maxCapacity) {
            throw new IllegalArgumentException(format(
                    "minNewCapacity: %d (expected: not greater than maxCapacity(%d)",
                    minNewCapacity, maxCapacity));
        }
        int threshold = CALCULATE_THRESHOLD; // 4 MiB page

        if (minNewCapacity == threshold) {
            return threshold;
        }

        // If over threshold, do not double but just increase by threshold.
        if (minNewCapacity > threshold) {
            int newCapacity = minNewCapacity / threshold * threshold;
            if (newCapacity > maxCapacity - threshold) {
                newCapacity = maxCapacity;
            } else {
                newCapacity += threshold;
            }
            return newCapacity;
        }

        // Not over threshold. Double up to 4 MiB, starting from 64.
        int newCapacity = 64;
        while (newCapacity < minNewCapacity) {
            newCapacity <<= 1;
        }

        return min(newCapacity, maxCapacity);
    }
}
