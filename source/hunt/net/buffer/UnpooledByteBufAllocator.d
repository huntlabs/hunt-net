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
module hunt.net.buffer.UnpooledByteBufAllocator;

import hunt.net.buffer.AbstractByteBufAllocator;
import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufAllocator;
import hunt.net.buffer.ByteBufUtil;
import hunt.net.buffer.CompositeByteBuf;
import hunt.net.buffer.UnpooledHeapByteBuf;
// import hunt.net.buffer.UnpooledUnsafeHeapByteBuf;


import hunt.Byte;
import hunt.io.ByteBuffer;
import hunt.Exceptions;
import hunt.stream.Common;
import hunt.net.Exceptions;
import hunt.text.StringBuilder;

import std.conv;
import std.format;
import std.concurrency : initOnce;

// import io.netty.util.internal.LongCounter;
// import io.netty.util.internal.PlatformDependent;
// import io.netty.util.internal.StringUtil;


/**
 * Simplistic {@link ByteBufAllocator} implementation that does not pool anything.
 */
final class UnpooledByteBufAllocator : AbstractByteBufAllocator { // ByteBufAllocatorMetricProvider

    // private final UnpooledByteBufAllocatorMetric metric = new UnpooledByteBufAllocatorMetric();
    private bool disableLeakDetector;
    private bool noCleaner;

    /**
     * Default instance which uses leak-detection for direct buffers.
     */
    static UnpooledByteBufAllocator DEFAULT() {
        __gshared UnpooledByteBufAllocator inst;
        // new UnpooledByteBufAllocator(PlatformDependent.directBufferPreferred());
        return initOnce!inst(new UnpooledByteBufAllocator(false));
    }
            

    /**
     * Create a new instance which uses leak-detection for direct buffers.
     *
     * @param preferDirect {@code true} if {@link #buffer(int)} should try to allocate a direct buffer rather than
     *                     a heap buffer
     */
    this(bool preferDirect) {
        this(preferDirect, false);
    }

    /**
     * Create a new instance
     *
     * @param preferDirect {@code true} if {@link #buffer(int)} should try to allocate a direct buffer rather than
     *                     a heap buffer
     * @param disableLeakDetector {@code true} if the leak-detection should be disabled completely for this
     *                            allocator. This can be useful if the user just want to depend on the GC to handle
     *                            direct buffers when not explicit released.
     */
    this(bool preferDirect, bool disableLeakDetector) {
        // this(preferDirect, disableLeakDetector, PlatformDependent.useDirectBufferNoCleaner());
        this(preferDirect, disableLeakDetector, false);
    }

    /**
     * Create a new instance
     *
     * @param preferDirect {@code true} if {@link #buffer(int)} should try to allocate a direct buffer rather than
     *                     a heap buffer
     * @param disableLeakDetector {@code true} if the leak-detection should be disabled completely for this
     *                            allocator. This can be useful if the user just want to depend on the GC to handle
     *                            direct buffers when not explicit released.
     * @param tryNoCleaner {@code true} if we should try to use {@link PlatformDependent#allocateDirectNoCleaner(int)}
     *                            to allocate direct memory.
     */
    this(bool preferDirect, bool disableLeakDetector, bool tryNoCleaner) {
        super(preferDirect);
        this.disableLeakDetector = disableLeakDetector;
        // noCleaner = tryNoCleaner && PlatformDependent.hasUnsafe()
        //         && PlatformDependent.hasDirectBufferNoCleanerConstructor();
    }

    override
    protected ByteBuf newHeapBuffer(int initialCapacity, int maxCapacity) {
        // return PlatformDependent.hasUnsafe() ?
        //         new InstrumentedUnpooledUnsafeHeapByteBuf(this, initialCapacity, maxCapacity) :
        //         new InstrumentedUnpooledHeapByteBuf(this, initialCapacity, maxCapacity);
        return new InstrumentedUnpooledHeapByteBuf(this, initialCapacity, maxCapacity);
    }

    override
    protected ByteBuf newDirectBuffer(int initialCapacity, int maxCapacity) {
        ByteBuf buf;
        implementationMissing(false);
        return null;
        // if (PlatformDependent.hasUnsafe()) {
        //     buf = noCleaner ? new InstrumentedUnpooledUnsafeNoCleanerDirectByteBuf(this, initialCapacity, maxCapacity) :
        //             new InstrumentedUnpooledUnsafeDirectByteBuf(this, initialCapacity, maxCapacity);
        // } else {
        //     buf = new InstrumentedUnpooledDirectByteBuf(this, initialCapacity, maxCapacity);
        // }
        // return disableLeakDetector ? buf : toLeakAwareBuffer(buf);
    }

    override
    CompositeByteBuf compositeHeapBuffer(int maxNumComponents) {
        CompositeByteBuf buf = new CompositeByteBuf(this, false, maxNumComponents);
        // return disableLeakDetector ? buf : toLeakAwareBuffer(buf);
        return buf;
    }

    override
    CompositeByteBuf compositeDirectBuffer(int maxNumComponents) {
        CompositeByteBuf buf = new CompositeByteBuf(this, true, maxNumComponents);
        // return disableLeakDetector ? buf : toLeakAwareBuffer(buf);
        return buf;
    }

    // override
    bool isDirectBufferPooled() {
        return false;
    }

    // override
    // ByteBufAllocatorMetric metric() {
    //     return metric;
    // }

    void incrementDirect(int amount) {
        // metric.directCounter.add(amount);
    }

    void decrementDirect(int amount) {
        // metric.directCounter.add(-amount);
    }

    void incrementHeap(int amount) {
        // metric.heapCounter.add(amount);
    }

    void decrementHeap(int amount) {
        // metric.heapCounter.add(-amount);
    }

}



// private final class InstrumentedUnpooledUnsafeHeapByteBuf : UnpooledUnsafeHeapByteBuf {
//     this(UnpooledByteBufAllocator alloc, int initialCapacity, int maxCapacity) {
//         super(alloc, initialCapacity, maxCapacity);
//     }

//     override
//     protected byte[] allocateArray(int initialCapacity) {
//         byte[] bytes = super.allocateArray(initialCapacity);
//         (cast(UnpooledByteBufAllocator) alloc()).incrementHeap(bytes.length);
//         return bytes;
//     }

//     override
//     protected void freeArray(byte[] array) {
//         int length = cast(int)array.length;
//         super.freeArray(array);
//         (cast(UnpooledByteBufAllocator) alloc()).decrementHeap(length);
//     }
// }


private final class InstrumentedUnpooledHeapByteBuf : UnpooledHeapByteBuf {
    this(UnpooledByteBufAllocator alloc, int initialCapacity, int maxCapacity) {
        super(alloc, initialCapacity, maxCapacity);
    }

    override
    protected byte[] allocateArray(int initialCapacity) {
        byte[] bytes = super.allocateArray(initialCapacity);
        (cast(UnpooledByteBufAllocator) alloc()).incrementHeap(cast(int)bytes.length);
        return bytes;
    }

    override
    protected void freeArray(byte[] array) {
        int length = cast(int)array.length;
        super.freeArray(array);
        (cast(UnpooledByteBufAllocator) alloc()).decrementHeap(length);
    }
}


// private final class InstrumentedUnpooledUnsafeNoCleanerDirectByteBuf
//         : UnpooledUnsafeNoCleanerDirectByteBuf {
//     this(
//             UnpooledByteBufAllocator alloc, int initialCapacity, int maxCapacity) {
//         super(alloc, initialCapacity, maxCapacity);
//     }

//     override
//     protected ByteBuffer allocateDirect(int initialCapacity) {
//         ByteBuffer buffer = super.allocateDirect(initialCapacity);
//         (cast(UnpooledByteBufAllocator) alloc()).incrementDirect(buffer.capacity());
//         return buffer;
//     }

//     override
//     ByteBuffer reallocateDirect(ByteBuffer oldBuffer, int initialCapacity) {
//         int capacity = oldBuffer.capacity();
//         ByteBuffer buffer = super.reallocateDirect(oldBuffer, initialCapacity);
//         (cast(UnpooledByteBufAllocator) alloc()).incrementDirect(buffer.capacity() - capacity);
//         return buffer;
//     }

//     override
//     protected void freeDirect(ByteBuffer buffer) {
//         int capacity = buffer.capacity();
//         super.freeDirect(buffer);
//         (cast(UnpooledByteBufAllocator) alloc()).decrementDirect(capacity);
//     }
// }

// private final class InstrumentedUnpooledUnsafeDirectByteBuf : UnpooledUnsafeDirectByteBuf {
//     this(
//             UnpooledByteBufAllocator alloc, int initialCapacity, int maxCapacity) {
//         super(alloc, initialCapacity, maxCapacity);
//     }

//     override
//     protected ByteBuffer allocateDirect(int initialCapacity) {
//         ByteBuffer buffer = super.allocateDirect(initialCapacity);
//         (cast(UnpooledByteBufAllocator) alloc()).incrementDirect(buffer.capacity());
//         return buffer;
//     }

//     override
//     protected void freeDirect(ByteBuffer buffer) {
//         int capacity = buffer.capacity();
//         super.freeDirect(buffer);
//         (cast(UnpooledByteBufAllocator) alloc()).decrementDirect(capacity);
//     }
// }


// private final class InstrumentedUnpooledDirectByteBuf : UnpooledDirectByteBuf {
//     this(
//             UnpooledByteBufAllocator alloc, int initialCapacity, int maxCapacity) {
//         super(alloc, initialCapacity, maxCapacity);
//     }

//     override
//     protected ByteBuffer allocateDirect(int initialCapacity) {
//         ByteBuffer buffer = super.allocateDirect(initialCapacity);
//         (cast(UnpooledByteBufAllocator) alloc()).incrementDirect(buffer.capacity());
//         return buffer;
//     }

//     override
//     protected void freeDirect(ByteBuffer buffer) {
//         int capacity = buffer.capacity();
//         super.freeDirect(buffer);
//         (cast(UnpooledByteBufAllocator) alloc()).decrementDirect(capacity);
//     }
// }

// private final class UnpooledByteBufAllocatorMetric : ByteBufAllocatorMetric {
//     final LongCounter directCounter = PlatformDependent.newLongCounter();
//     final LongCounter heapCounter = PlatformDependent.newLongCounter();

//     override
//     long usedHeapMemory() {
//         return heapCounter.value();
//     }

//     override
//     long usedDirectMemory() {
//         return directCounter.value();
//     }

//     override
//     String toString() {
//         return StringUtil.simpleClassName(this) +
//                 "(usedHeapMemory: " + usedHeapMemory() + "; usedDirectMemory: " + usedDirectMemory() + ')';
//     }
// }