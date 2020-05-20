/*
 * Copyright 2015 The Netty Project
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
module hunt.net.buffer.UnpooledDuplicatedByteBuf;

import hunt.net.buffer.AbstractByteBuf;
import hunt.net.buffer.DuplicatedByteBuf;
import hunt.util.ByteOrder;

/**
 * {@link DuplicatedByteBuf} implementation that can do optimizations because it knows the duplicated buffer
 * is of type {@link AbstractByteBuf}.
 */
class UnpooledDuplicatedByteBuf : DuplicatedByteBuf {

    this(AbstractByteBuf buffer) {
        super(buffer);
    }

    override
    AbstractByteBuf unwrap() {
        return cast(AbstractByteBuf) super.unwrap();
    }

    override
    protected byte _getByte(int index) {
        return unwrap()._getByte(index);
    }

    override
    protected short _getShort(int index) {
        return unwrap()._getShort(index);
    }

    override
    protected short _getShortLE(int index) {
        return unwrap()._getShortLE(index);
    }

    override
    protected int _getUnsignedMedium(int index) {
        return unwrap()._getUnsignedMedium(index);
    }

    override
    protected int _getUnsignedMediumLE(int index) {
        return unwrap()._getUnsignedMediumLE(index);
    }

    override
    protected int _getInt(int index) {
        return unwrap()._getInt(index);
    }

    override
    protected int _getIntLE(int index) {
        return unwrap()._getIntLE(index);
    }

    override
    protected long _getLong(int index) {
        return unwrap()._getLong(index);
    }

    override
    protected long _getLongLE(int index) {
        return unwrap()._getLongLE(index);
    }

    override
    protected void _setByte(int index, int value) {
        unwrap()._setByte(index, value);
    }

    override
    protected void _setShort(int index, int value) {
        unwrap()._setShort(index, value);
    }

    override
    protected void _setShortLE(int index, int value) {
        unwrap()._setShortLE(index, value);
    }

    override
    protected void _setMedium(int index, int value) {
        unwrap()._setMedium(index, value);
    }

    override
    protected void _setMediumLE(int index, int value) {
        unwrap()._setMediumLE(index, value);
    }

    override
    protected void _setInt(int index, int value) {
        unwrap()._setInt(index, value);
    }

    override
    protected void _setIntLE(int index, int value) {
        unwrap()._setIntLE(index, value);
    }

    override
    protected void _setLong(int index, long value) {
        unwrap()._setLong(index, value);
    }

    override
    protected void _setLongLE(int index, long value) {
        unwrap()._setLongLE(index, value);
    }
}
