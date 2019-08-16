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
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
module hunt.net.buffer.HeapByteBufUtil;

/**
 * Utility class for heap buffers.
 */
final class HeapByteBufUtil {

    static byte getByte(byte[] memory, int index) {
        return memory[index];
    }

    static short getShort(byte[] memory, int index) {
        return cast(short) (memory[index] << 8 | memory[index + 1] & 0xFF);
    }

    static short getShortLE(byte[] memory, int index) {
        return cast(short) (memory[index] & 0xff | memory[index + 1] << 8);
    }

    static int getUnsignedMedium(byte[] memory, int index) {
        return  (memory[index]     & 0xff) << 16 |
                (memory[index + 1] & 0xff) <<  8 |
                memory[index + 2] & 0xff;
    }

    static int getUnsignedMediumLE(byte[] memory, int index) {
        return  memory[index]     & 0xff         |
                (memory[index + 1] & 0xff) <<  8 |
                (memory[index + 2] & 0xff) << 16;
    }

    static int getInt(byte[] memory, int index) {
        return  (memory[index]     & 0xff) << 24 |
                (memory[index + 1] & 0xff) << 16 |
                (memory[index + 2] & 0xff) <<  8 |
                memory[index + 3] & 0xff;
    }

    static int getIntLE(byte[] memory, int index) {
        return  memory[index]      & 0xff        |
                (memory[index + 1] & 0xff) << 8  |
                (memory[index + 2] & 0xff) << 16 |
                (memory[index + 3] & 0xff) << 24;
    }

    static long getLong(byte[] memory, int index) {
        return  (cast(long) memory[index]     & 0xff) << 56 |
                (cast(long) memory[index + 1] & 0xff) << 48 |
                (cast(long) memory[index + 2] & 0xff) << 40 |
                (cast(long) memory[index + 3] & 0xff) << 32 |
                (cast(long) memory[index + 4] & 0xff) << 24 |
                (cast(long) memory[index + 5] & 0xff) << 16 |
                (cast(long) memory[index + 6] & 0xff) <<  8 |
                cast(long) memory[index + 7] & 0xff;
    }

    static long getLongLE(byte[] memory, int index) {
        return  cast(long) memory[index]      & 0xff        |
                (cast(long) memory[index + 1] & 0xff) <<  8 |
                (cast(long) memory[index + 2] & 0xff) << 16 |
                (cast(long) memory[index + 3] & 0xff) << 24 |
                (cast(long) memory[index + 4] & 0xff) << 32 |
                (cast(long) memory[index + 5] & 0xff) << 40 |
                (cast(long) memory[index + 6] & 0xff) << 48 |
                (cast(long) memory[index + 7] & 0xff) << 56;
    }

    static void setByte(byte[] memory, int index, int value) {
        memory[index] = cast(byte) value;
    }

    static void setShort(byte[] memory, int index, int value) {
        memory[index]     = cast(byte) (value >>> 8);
        memory[index + 1] = cast(byte) value;
    }

    static void setShortLE(byte[] memory, int index, int value) {
        memory[index]     = cast(byte) value;
        memory[index + 1] = cast(byte) (value >>> 8);
    }

    static void setMedium(byte[] memory, int index, int value) {
        memory[index]     = cast(byte) (value >>> 16);
        memory[index + 1] = cast(byte) (value >>> 8);
        memory[index + 2] = cast(byte) value;
    }

    static void setMediumLE(byte[] memory, int index, int value) {
        memory[index]     = cast(byte) value;
        memory[index + 1] = cast(byte) (value >>> 8);
        memory[index + 2] = cast(byte) (value >>> 16);
    }

    static void setInt(byte[] memory, int index, int value) {
        memory[index]     = cast(byte) (value >>> 24);
        memory[index + 1] = cast(byte) (value >>> 16);
        memory[index + 2] = cast(byte) (value >>> 8);
        memory[index + 3] = cast(byte) value;
    }

    static void setIntLE(byte[] memory, int index, int value) {
        memory[index]     = cast(byte) value;
        memory[index + 1] = cast(byte) (value >>> 8);
        memory[index + 2] = cast(byte) (value >>> 16);
        memory[index + 3] = cast(byte) (value >>> 24);
    }

    static void setLong(byte[] memory, int index, long value) {
        memory[index]     = cast(byte) (value >>> 56);
        memory[index + 1] = cast(byte) (value >>> 48);
        memory[index + 2] = cast(byte) (value >>> 40);
        memory[index + 3] = cast(byte) (value >>> 32);
        memory[index + 4] = cast(byte) (value >>> 24);
        memory[index + 5] = cast(byte) (value >>> 16);
        memory[index + 6] = cast(byte) (value >>> 8);
        memory[index + 7] = cast(byte) value;
    }

    static void setLongLE(byte[] memory, int index, long value) {
        memory[index]     = cast(byte) value;
        memory[index + 1] = cast(byte) (value >>> 8);
        memory[index + 2] = cast(byte) (value >>> 16);
        memory[index + 3] = cast(byte) (value >>> 24);
        memory[index + 4] = cast(byte) (value >>> 32);
        memory[index + 5] = cast(byte) (value >>> 40);
        memory[index + 6] = cast(byte) (value >>> 48);
        memory[index + 7] = cast(byte) (value >>> 56);
    }

    private this() { }
}
