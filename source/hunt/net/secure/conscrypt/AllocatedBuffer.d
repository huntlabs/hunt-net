module hunt.net.secure.conscrypt.AllocatedBuffer;

import hunt.container;

/**
 * A buffer that was allocated by a {@link BufferAllocator}.
 */
abstract class AllocatedBuffer {
    /**
     * Returns the {@link ByteBuffer} that backs this buffer.
     */
    abstract ByteBuffer nioBuffer();

    /**
     * Increases the reference count by {@code 1}.
     */
    abstract AllocatedBuffer retain();

    /**
     * Decreases the reference count by {@code 1} and deallocates this object if the reference count
     * reaches at {@code 0}.
     *
     * @return {@code true} if and only if the reference count became {@code 0} and this object has
     * been deallocated
     */
    abstract AllocatedBuffer release();

    /**
     * Creates a new {@link AllocatedBuffer} that is backed by the given {@link ByteBuffer}.
     */
    static AllocatedBuffer wrap(ByteBuffer buffer) {
        // checkNotNull(buffer, "buffer");

        return new class AllocatedBuffer {

            override
            ByteBuffer nioBuffer() {
                return buffer;
            }

            override
            AllocatedBuffer retain() {
                // Do nothing.
                return this;
            }

            override
            AllocatedBuffer release() {
                // Do nothing.
                return this;
            }
        };
    }
}



/**
 * An object responsible for allocation of buffers. This is an extension point to enable buffer
 * pooling within an application.
 */
abstract class BufferAllocator {
    private __gshared static BufferAllocator UNPOOLED;

    shared static this()
    {
        UNPOOLED = new class BufferAllocator {
            override
            AllocatedBuffer allocateDirectBuffer(int capacity) {
                return AllocatedBuffer.wrap(new HeapByteBuffer(capacity,capacity));
                // ByteBuffer.allocateDirect(capacity)
            }
        };        
    }

    /**
     * Returns an unpooled buffer allocator, which will create a new buffer for each request.
     */
    static BufferAllocator unpooled() {
        return UNPOOLED;
    }

    /**
     * Allocates a direct (i.e. non-heap) buffer with the given capacity.
     */
    abstract AllocatedBuffer allocateDirectBuffer(int capacity);
}
