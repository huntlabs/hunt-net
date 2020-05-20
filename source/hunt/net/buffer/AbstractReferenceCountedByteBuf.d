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

module hunt.net.buffer.AbstractReferenceCountedByteBuf;

import hunt.net.buffer.AbstractByteBuf;
import hunt.net.buffer.ByteBuf;
import hunt.net.buffer.ByteBufUtil;
import hunt.net.buffer.ReferenceCountUpdater;


import hunt.io.ByteBuffer;
import hunt.Exceptions;
import hunt.net.Exceptions;
import hunt.stream.Common;
import hunt.text.StringBuilder;

import std.conv;
import std.format;
import std.concurrency : initOnce;

// import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

// import io.netty.util.internal.ReferenceCountUpdater;

/**
 * Abstract base class for {@link ByteBuf} implementations that count references.
 */
abstract class AbstractReferenceCountedByteBuf : AbstractByteBuf {

    alias IntegerFieldUpdater = AtomicIntegerFieldUpdater!(AbstractReferenceCountedByteBuf, "_refCnt");
    alias RefCntUpdater = ReferenceCountUpdater!(AbstractReferenceCountedByteBuf, "_refCnt");

    private static IntegerFieldUpdater AIF_UPDATER() {
        __gshared IntegerFieldUpdater inst;
        return initOnce!inst(new IntegerFieldUpdater());
    }

    private static RefCntUpdater updater() {
        __gshared RefCntUpdater inst;
        return initOnce!inst(new class RefCntUpdater {
                override
                protected IntegerFieldUpdater updater() {
                    return AIF_UPDATER;
            }
        });

    }
            


    // Value might not equal "real" reference count, all access should be via the updater
    private shared int _refCnt; // = updater.initialValue();

    protected this(int maxCapacity) {
        super(maxCapacity);
        _refCnt = updater.initialValue();
    }

    override
    bool isAccessible() {
        // Try to do non-volatile read for performance as the ensureAccessible() is racy anyway and only provide
        // a best-effort guard.
        return updater.isLiveNonVolatile(this);
    }

    // override
    int refCnt() {
        return updater.refCnt(this);
    }

    /**
     * An unsafe operation intended for use by a subclass that sets the reference count of the buffer directly
     */
    protected final void setRefCnt(int refCnt) {
        updater.setRefCnt(this, refCnt);
    }

    /**
     * An unsafe operation intended for use by a subclass that resets the reference count of the buffer to 1
     */
    protected final void resetRefCnt() {
        // updater.resetRefCnt(this);
    }

    override
    ByteBuf retain() {
        // return updater.retain(this);
        implementationMissing(false);
        return this;
    }

    override
    ByteBuf retain(int increment) {
        // return updater.retain(this, increment);

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
        return handleRelease(updater.release(this));
    }

    // override
    bool release(int decrement) {
        return handleRelease(updater.release(this, decrement));
    }

    private bool handleRelease(bool result) {
        if (result) {
            deallocate();
        }
        return result;
    }

    /**
     * Called once {@link #refCnt()} is equals 0.
     */
    protected abstract void deallocate();
}
