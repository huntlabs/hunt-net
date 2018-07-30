module hunt.net.ssl.SNIServerName;

import hunt.util.exception;
import hunt.util.string;

import std.conv;

enum SNI_HOST_NAME = 0x00;

/**
 * Instances of this class represent a server name in a Server Name
 * Indication (SNI) extension.
 * <P>
 * The SNI extension is a feature that extends the SSL/TLS protocols to
 * indicate what server name the client is attempting to connect to during
 * handshaking.  See section 3, "Server Name Indication", of <A
 * HREF="http://www.ietf.org/rfc/rfc6066.txt">TLS Extensions (RFC 6066)</A>.
 * <P>
 * {@code SNIServerName} objects are immutable.  Subclasses should not provide
 * methods that can change the state of an instance once it has been created.
 *
 * @see SSLParameters#getServerNames()
 * @see SSLParameters#setServerNames(List)
 *
 * @since 1.8
 */
abstract class SNIServerName {

    // the type of the server name
    private int type;

    // the encoded value of the server name
    private byte[] encoded;

    // the hex digitals
    private enum char[] HEXES = "0123456789ABCDEF".dup;

    /**
     * Creates an {@code SNIServerName} using the specified name type and
     * encoded value.
     * <P>
     * Note that the {@code encoded} byte array is cloned to protect against
     * subsequent modification.
     *
     * @param  type
     *         the type of the server name
     * @param  encoded
     *         the encoded value of the server name
     *
     * @throws IllegalArgumentException if {@code type} is not in the range
     *         of 0 to 255, inclusive.
     * @throws NullPointerException if {@code encoded} is null
     */
    protected this(int type, byte[] encoded) {
        if (type < 0) {
            throw new IllegalArgumentException(
                "Server name type cannot be less than zero");
        } else if (type > 255) {
            throw new IllegalArgumentException(
                "Server name type cannot be greater than 255");
        }
        this.type = type;

        if (encoded is null) {
            throw new NullPointerException(
                "Server name encoded value cannot be null");
        }
        this.encoded = encoded.dup; // .clone();
    }


    /**
     * Returns the name type of this server name.
     *
     * @return the name type of this server name
     */
    int getType() {
        return type;
    }

    /**
     * Returns a copy of the encoded server name value of this server name.
     *
     * @return a copy of the encoded server name value of this server name
     */
    byte[] getEncoded() {
        return encoded.dup; //.clone();
    }

    /**
     * Indicates whether some other object is "equal to" this server name.
     *
     * @return true if, and only if, {@code other} is of the same class
     *         of this object, and has the same name type and
     *         encoded value as this server name.
     */
    override
    bool opEquals(Object other) {
        if (this is other) {
            return true;
        }

        if (typeid(this) != typeid(other)) {
            return false;
        }

        SNIServerName that = cast(SNIServerName)other;
        return (this.type == that.type) && this.encoded == that.encoded;
                    // Arrays.equals(this.encoded, that.encoded);
    }

    /**
     * Returns a hash code value for this server name.
     * <P>
     * The hash code value is generated using the name type and encoded
     * value of this server name.
     *
     * @return a hash code value for this server name.
     */
    override
    size_t toHash() @trusted nothrow {
        size_t result = 17;    // 17/31: prime number to decrease collisions
        result = 31 * result + type;
        result = 31 * result + hashOf(encoded);

        return result;
    }

    /**
     * Returns a string representation of this server name, including the server
     * name type and the encoded server name value in this
     * {@code SNIServerName} object.
     * <P>
     * The exact details of the representation are unspecified and subject
     * to change, but the following may be regarded as typical:
     * <pre>
     *     "type={@literal <name type>}, value={@literal <name value>}"
     * </pre>
     * <P>
     * In this class, the format of "{@literal <name type>}" is
     * "[LITERAL] (INTEGER)", where the optional "LITERAL" is the literal
     * name, and INTEGER is the integer value of the name type.  The format
     * of "{@literal <name value>}" is "XX:...:XX", where "XX" is the
     * hexadecimal digit representation of a byte value. For example, a
     * returned value of an pseudo server name may look like:
     * <pre>
     *     "type=(31), value=77:77:77:2E:65:78:61:6D:70:6C:65:2E:63:6E"
     * </pre>
     * or
     * <pre>
     *     "type=host_name (0), value=77:77:77:2E:65:78:61:6D:70:6C:65:2E:63:6E"
     * </pre>
     *
     * <P>
     * Please NOTE that the exact details of the representation are unspecified
     * and subject to change, and subclasses may override the method with
     * their own formats.
     *
     * @return a string representation of this server name
     */
    override
    string toString() {
        if (type == SNI_HOST_NAME) {
            return "type=host_name (0), value=" ~ toHexString(encoded);
        } else {
            return "type=(" ~ type.to!string() ~ "), value=" ~ toHexString(encoded);
        }
    }

    // convert byte array to hex string
    private static string toHexString(byte[] bytes) {
        if (bytes.length == 0) {
            return "(empty)";
        }

        StringBuilder sb = new StringBuilder(cast(int)bytes.length * 3 - 1);
        bool isInitial = true;
        foreach (byte b ; bytes) {
            if (isInitial) {
                isInitial = false;
            } else {
                sb.append(':');
            }

            int k = b & 0xFF;
            sb.append(HEXES[k >>> 4]);
            sb.append(HEXES[k & 0xF]);
        }

        return sb.toString();
    }
}
