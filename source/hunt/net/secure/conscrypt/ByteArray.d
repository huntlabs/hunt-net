module hunt.net.secure.conscrypt.ByteArray;


/**
 * Byte array wrapper for hashtable use. Implements equals() and hashCode().
 */
final class ByteArray {
    private byte[] bytes;
    private size_t hashCode;

    this(byte[] bytes) {
        this.bytes = bytes;
        this.hashCode = hashOf(bytes);
    }

    override size_t toHash() @trusted nothrow {
        return hashCode;
    }

    override
    bool opEquals(Object o) {
        if (typeid(o) != typeid(ByteArray)) {
            return false;
        }
        ByteArray lhs = cast(ByteArray) o;
        return bytes == lhs.bytes;
    }
}
