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

module hunt.net.buffer.AbstractDerivedByteBuf;

import hunt.net.buffer.AbstractByteBuf;
import hunt.net.buffer.ByteBuf;

import hunt.io.ByteBuffer;

/**
 * Abstract base class for {@link ByteBuf} implementations that wrap another
 * {@link ByteBuf}.
 *
 * deprecated("") Do not use.
 */
abstract class AbstractDerivedByteBuf : AbstractByteBuf {

    protected this(int maxCapacity) {
        super(maxCapacity);
    }

    override
    final bool isAccessible() {
        return unwrap().isAccessible();
    }

    // override
    final int refCnt() {
        return refCnt0();
    }

    int refCnt0() {
        return unwrap().refCnt();
    }

    override
    final ByteBuf retain() {
        return retain0();
    }

    ByteBuf retain0() {
        unwrap().retain();
        return this;
    }

    override
    final ByteBuf retain(int increment) {
        return retain0(increment);
    }

    ByteBuf retain0(int increment) {
        unwrap().retain(increment);
        return this;
    }

    override
    final ByteBuf touch() {
        return touch0();
    }

    ByteBuf touch0() {
        unwrap().touch();
        return this;
    }

    override
    final ByteBuf touch(Object hint) {
        return touch0(hint);
    }

    ByteBuf touch0(Object hint) {
        unwrap().touch(hint);
        return this;
    }

    // override
    final bool release() {
        return release0();
    }

    bool release0() {
        return unwrap().release();
    }

    // override
    final bool release(int decrement) {
        return release0(decrement);
    }

    bool release0(int decrement) {
        return unwrap().release(decrement);
    }

    override
    bool isReadOnly() {
        return unwrap().isReadOnly();
    }

    override
    ByteBuffer internalNioBuffer(int index, int length) {
        return nioBuffer(index, length);
    }

    override
    ByteBuffer nioBuffer(int index, int length) {
        return unwrap().nioBuffer(index, length);
    }
}
