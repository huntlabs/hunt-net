module hunt.net.secure.conscrypt.SSLUtils;

version(BoringSSL) {
    version=WithSSL;
} else version(OpenSSL) {
    version=WithSSL;
}
version(WithSSL):

import hunt.net.secure.conscrypt.NativeCrypto;
import hunt.net.secure.conscrypt.OpenSSLX509Certificate;

import hunt.security.cert.CertificateFactory;
import hunt.security.cert.X509Certificate;

import hunt.net.exception;

import hunt.container;
import hunt.io.ByteArrayInputStream;
import hunt.logging;
import hunt.lang.exception;
import hunt.string;

import deimos.openssl.ssl3;

import std.algorithm;
import std.conv;

/**
 * Utility methods for SSL packet processing. Copied from the Netty project.
 * <p>
 * This is a public class to allow testing to occur on Android via CTS.
 */
final class SSLUtils {
    enum bool USE_ENGINE_SOCKET_BY_DEFAULT = true;
    // Boolean.parseBoolean(
    //         System.getProperty("org.conscrypt.useEngineSocketByDefault", "false"));
    private enum int MAX_PROTOCOL_LENGTH = 255;

    private enum string US_ASCII = ("US-ASCII");

    // TODO(nathanmittler): Should these be in NativeConstants?
    enum SessionType {
        /**
         * Identifies OpenSSL sessions.
         */
        OPEN_SSL = 1,

        /**
         * Identifies OpenSSL sessions with OCSP stapled data.
         */
        OPEN_SSL_WITH_OCSP = 2,

        /**
         * Identifies OpenSSL sessions with TLS SCT data.
         */
        OPEN_SSL_WITH_TLS_SCT = 3

        // SessionType(int value) {
        //     this.value = value;
        // }

        // static bool isSupportedType(int type) {
        //     return type == OPEN_SSL.value || type == OPEN_SSL_WITH_OCSP.value
        //             || type == OPEN_SSL_WITH_TLS_SCT.value;
        // }

        // int value;
    }

    static bool isSupportedType(int type) {
            return type == cast(int)SessionType.OPEN_SSL || 
                    type == cast(int)SessionType.OPEN_SSL_WITH_OCSP || 
                    type == cast(int)SessionType.OPEN_SSL_WITH_TLS_SCT;
        }


    /**
     * This is the maximum overhead when encrypting plaintext as defined by
     * <a href="https://www.ietf.org/rfc/rfc5246.txt">rfc5264</a>,
     * <a href="https://www.ietf.org/rfc/rfc5289.txt">rfc5289</a> and openssl implementation itself.
     *
     * Please note that we use a padding of 16 here as openssl uses PKC#5 which uses 16 bytes
     * whilethe spec itself allow up to 255 bytes. 16 bytes is the max for PKC#5 (which handles it
     * the same way as PKC#7) as we use a block size of 16. See <a
     * href="https://tools.ietf.org/html/rfc5652#section-6.3">rfc5652#section-6.3</a>.
     *
     * 16 (IV) + 48 (MAC) + 1 (Padding_length field) + 15 (Padding) + 1 (ContentType) + 2
     * (ProtocolVersion) + 2 (Length)
     *
     * TODO: We may need to review this calculation once TLS 1.3 becomes available.
     */
    private enum int MAX_ENCRYPTION_OVERHEAD_LENGTH = 15 + 48 + 1 + 16 + 1 + 2 + 2;

    private enum int MAX_ENCRYPTION_OVERHEAD_DIFF = int.max - MAX_ENCRYPTION_OVERHEAD_LENGTH;

    /** Key type: RSA certificate. */
    private enum string KEY_TYPE_RSA = "RSA";

    /** Key type: Elliptic Curve certificate. */
    private enum string KEY_TYPE_EC = "EC";

    /**
     * If the given session is a {@link SessionDecorator}, unwraps the session and returns the
     * underlying (non-decorated) session. Otherwise, returns the provided session.
     */
    // static SSLSession unwrapSession(SSLSession session) {
    //     while (typeid(session) == typeid(SessionDecorator)) {
    //         session = (cast(SessionDecorator) session).getDelegate();
    //     }
    //     return session;
    // }

    static X509Certificate[] decodeX509CertificateChain(ubyte[][] certChain) {
        int numCerts = cast(int)certChain.length;
        if(numCerts == 0)
            return null;
        tracef("Certificates: %d", numCerts);
        CertificateFactory certificateFactory = getCertificateFactory();
        X509Certificate[] decodedCerts = new X509Certificate[numCerts];
        for (int i = 0; i < numCerts; i++) {
            decodedCerts[i] = decodeX509Certificate(certificateFactory, certChain[i]);
        }
        return decodedCerts;
    }

    private static CertificateFactory getCertificateFactory() {
        try {
            return CertificateFactory.getInstance("X.509");
        } catch (CertificateException e) {
            return null;
        }
    }

    private static X509Certificate decodeX509Certificate(CertificateFactory certificateFactory,
            ubyte[] bytes) {
        //tracef("X509Certificate: %(%02X %)", bytes);
        // TODO: Tasks pending completion -@zxp at 8/19/2018, 3:02:24 PM
        // 
        // if (certificateFactory !is null) {
        //     return cast(X509Certificate) certificateFactory.generateCertificate(
        //             new ByteArrayInputStream(cast(byte[])bytes));
        // }
        // return OpenSSLX509Certificate.fromX509Der(bytes);
        implementationMissing(false);
        return null;
    }

    /**
     * Returns key type constant suitable for calling X509KeyManager.chooseServerAlias or
     * X509ExtendedKeyManager.chooseEngineServerAlias. Returns {@code null} for key exchanges that
     * do not use X.509 for server authentication.
     */
    static string getServerX509KeyType(long sslCipherNative) {
        version(OpenSSL) {
            implementationMissing(false);
            string kx_name = null;
        }
        version(BoringSSL) string kx_name = NativeCrypto.SSL_CIPHER_get_kx_name(sslCipherNative);

        if (kx_name.equals("RSA") || kx_name.equals("DHE_RSA") || kx_name.equals("ECDHE_RSA")) {
            return KEY_TYPE_RSA;
        } else if (kx_name.equals("ECDHE_ECDSA")) {
            return KEY_TYPE_EC;
        } else {
            return null;
        }
    }

    // /**
    //  * Similar to getServerKeyType, but returns value given TLS
    //  * ClientCertificateType byte values from a CertificateRequest
    //  * message for use with X509KeyManager.chooseClientAlias or
    //  * X509ExtendedKeyManager.chooseEngineClientAlias.
    //  * <p>
    //  * Visible for testing.
    //  */
    // static string getClientKeyType(byte clientCertificateType) {
    //     // See also http://www.ietf.org/assignments/tls-parameters/tls-parameters.xml
    //     switch (clientCertificateType) {
    //         case NativeConstants.TLS_CT_RSA_SIGN:
    //             return KEY_TYPE_RSA; // RFC rsa_sign
    //         case NativeConstants.TLS_CT_ECDSA_SIGN:
    //             return KEY_TYPE_EC; // RFC ecdsa_sign
    //         default:
    //             return null;
    //     }
    // }

    // /**
    //  * Gets the supported key types for client certificates based on the
    //  * {@code ClientCertificateType} values provided by the server.
    //  *
    //  * @param clientCertificateTypes {@code ClientCertificateType} values provided by the server.
    //  *        See https://www.ietf.org/assignments/tls-parameters/tls-parameters.xml.
    //  * @return supported key types that can be used in {@code X509KeyManager.chooseClientAlias} and
    //  *         {@code X509ExtendedKeyManager.chooseEngineClientAlias}.
    //  *
    //  * Visible for testing.
    //  */
    // static Set<string> getSupportedClientKeyTypes(byte[] clientCertificateTypes) {
    //     Set<string> result = new HashSet<string>(clientCertificateTypes.length);
    //     for (byte keyTypeCode : clientCertificateTypes) {
    //         string keyType = SSLUtils.getClientKeyType(keyTypeCode);
    //         if (keyType == null) {
    //             // Unsupported client key type -- ignore
    //             continue;
    //         }
    //         result.add(keyType);
    //     }
    //     return result;
    // }

    // static byte[][] encodeSubjectX509Principals(X509Certificate[] certificates)
    //         throws CertificateEncodingException {
    //     byte[][] principalBytes = new byte[certificates.length][];
    //     for (int i = 0; i < certificates.length; i++) {
    //         principalBytes[i] = certificates[i].getSubjectX500Principal().getEncoded();
    //     }
    //     return principalBytes;
    // }

    /**
     * Converts the peer certificates into a cert chain.
     */
    static X509Certificate[] toCertificateChain(X509Certificate[] certificates) {

        implementationMissing();
return null;
        // try {
        //     X509Certificate[] chain =
        //             new X509Certificate[certificates.length];

        //     for (int i = 0; i < certificates.length; i++) {
        //         byte[] encoded = certificates[i].getEncoded();
        //         chain[i] = X509Certificate.getInstance(encoded);
        //     }
        //     return chain;
        // } catch (CertificateEncodingException e) {
        //     SSLPeerUnverifiedException exception = new SSLPeerUnverifiedException(e.getMessage());
        //     exception.initCause(exception);
        //     throw exception;
        // } catch (CertificateException e) {
        //     SSLPeerUnverifiedException exception = new SSLPeerUnverifiedException(e.getMessage());
        //     exception.initCause(exception);
        //     throw exception;
        // }
    }

    /**
     * Calculates the minimum bytes required in the encrypted output buffer for the given number of
     * plaintext source bytes.
     */
    static int calculateOutNetBufSize(int pendingBytes) {
        return min(SSL3_RT_MAX_PACKET_SIZE,
                MAX_ENCRYPTION_OVERHEAD_LENGTH + min(MAX_ENCRYPTION_OVERHEAD_DIFF, pendingBytes));
    }

    /**
     * Wraps the given exception if it's not already a {@link SSLHandshakeException}.
     */
    static SSLHandshakeException toSSLHandshakeException(Throwable e) {
        if (typeid(e) == typeid(SSLHandshakeException)) {
            return cast(SSLHandshakeException) e;
        }

        return new SSLHandshakeException(e.msg, e);
    }

    /**
     * Wraps the given exception if it's not already a {@link SSLException}.
     */
    static SSLException toSSLException(Throwable e) {
        if (typeid(e) == typeid(SSLException)) {
            return cast(SSLException) e;
        }
        return new SSLException("", e);
    }

    static string toProtocolString(byte[] bytes) {
        if (bytes == null) {
            return null;
        }
        return cast(string)bytes.idup;
    }

    static byte[] toProtocolBytes(string protocol) {
        if (protocol == null) {
            return null;
        }
        return cast(byte[] )protocol.dup;
    }

    /**
     * Decodes the given list of protocols into {@link string}s.
     * @param protocols the encoded protocol list
     * @return the decoded protocols or {@link EmptyArray#BYTE} if {@code protocols} is
     * empty.
     * @throws NullPointerException if protocols is {@code null}.
     */
    static string[] decodeProtocols(ubyte[] protocols) {
        if (protocols.length == 0) {
            return null;
        }

        int numProtocols = 0;
        for (size_t i = 0; i < protocols.length;) {
            int protocolLength = protocols[i];
            if (protocolLength < 0 || protocolLength > protocols.length - i) {
                throw new IllegalArgumentException(
                    "Protocol has invalid length (" ~  protocolLength.to!string() ~ " at position "
                        ~  i.to!string() ~ "): " ~  (protocols.length < 50
                        ? protocols.to!string() : protocols.length.to!string() ~ " byte array"));
            }

            numProtocols++;
            i += 1 + protocolLength;
        }

        string[] decoded = new string[numProtocols];
        for (size_t i = 0, d = 0; i < protocols.length;) {
            int protocolLength = protocols[i];
            decoded[d++] = protocolLength > 0
                    ?  cast(string)protocols[i + 1 .. protocolLength].idup
                    : "";
            i += 1 + protocolLength;
        }

        return decoded;
    }

    /**
     * Encodes a list of protocols into the wire-format (length-prefixed 8-bit strings).
     * Requires that all strings be encoded with US-ASCII.
     *
     * @param protocols the list of protocols to be encoded
     * @return the encoded form of the protocol list.
     * @throws IllegalArgumentException if protocols is {@code null}, or if any element is
     * {@code null} or an empty string.
     */
    static byte[] encodeProtocols(string[] protocols) {
        if (protocols == null) {
            throw new IllegalArgumentException("protocols array must be non-null");
        }

        if (protocols.length == 0) {
            return [];
        }

        // Calculate the encoded length.
        int length = 0;
        for (int i = 0; i < protocols.length; ++i) {
            string protocol = protocols[i];
            if (protocol == null) {
                throw new IllegalArgumentException("protocol[" ~  i.to!string() ~ "] is null");
            }
            int protocolLength = cast(int)protocols[i].length;

            // Verify that the length is valid here, so that we don't attempt to allocate an array
            // below if the threshold is violated.
            if (protocolLength == 0 || protocolLength > MAX_PROTOCOL_LENGTH) {
                throw new IllegalArgumentException(
                    "protocol[" ~  i.to!string() ~ "] has invalid length: " ~  protocolLength.to!string());
            }

            // Include a 1-byte prefix for each protocol.
            length += 1 + protocolLength;
        }

        byte[] data = new byte[length];
        for (int dataIndex = 0, i = 0; i < cast(int)protocols.length; ++i) {
            string protocol = protocols[i];
            int protocolLength = cast(int)protocol.length;

            // Add the length prefix.
            data[dataIndex++] = cast(byte) protocolLength;
            for (int ci = 0; ci < protocolLength; ++ci) {
                char c = protocol.charAt(ci);
                if (c > byte.max) {
                    // Enforce US-ASCII
                    throw new IllegalArgumentException("Protocol contains invalid character: "
                        ~ c.to!string() ~ "(protocol=" ~  protocol ~ ")");
                }
                data[dataIndex++] = cast(byte) c;
            }
        }
        return data;
    }

    /**
     * Return how much bytes can be read out of the encrypted data. Be aware that this method will
     * not increase the readerIndex of the given {@link ByteBuffer}.
     *
     * @param buffers The {@link ByteBuffer}s to read from. Be aware that they must have at least
     * {@link org.conscrypt.NativeConstants#SSL3_RT_HEADER_LENGTH} bytes to read, otherwise it will
     * throw an {@link IllegalArgumentException}.
     * @return length The length of the encrypted packet that is included in the buffer. This will
     * return {@code -1} if the given {@link ByteBuffer} is not encrypted at all.
     * @throws IllegalArgumentException Is thrown if the given {@link ByteBuffer} has not at least
     * {@link org.conscrypt.NativeConstants#SSL3_RT_HEADER_LENGTH} bytes to read.
     */
    static int getEncryptedPacketLength(ByteBuffer[] buffers, int offset) {
        ByteBuffer buffer = buffers[offset];

        // Check if everything we need is in one ByteBuffer. If so we can make use of the fast-path.
        if (buffer.remaining() >= SSL3_RT_HEADER_LENGTH) {
            return getEncryptedPacketLength(buffer);
        }

        // We need to copy 5 bytes into a temporary buffer so we can parse out the packet length
        // easily.
        ByteBuffer tmp = ByteBuffer.allocate(SSL3_RT_HEADER_LENGTH);
        do {
            buffer = buffers[offset++];
            int pos = buffer.position();
            int limit = buffer.limit();
            if (buffer.remaining() > tmp.remaining()) {
                buffer.limit(pos + tmp.remaining());
            }
            try {
                tmp.put(buffer);
            } finally {
                // Restore the original indices.
                buffer.limit(limit);
                buffer.position(pos);
            }
        } while (tmp.hasRemaining());

        // Done, flip the buffer so we can read from it.
        tmp.flip();
        return getEncryptedPacketLength(tmp);
    }

    private static int getEncryptedPacketLength(ByteBuffer buffer) {
        int pos = buffer.position();
        // SSLv3 or TLS - Check ContentType
        switch (unsignedByte(buffer.get(pos))) {
            case SSL3_RT_CHANGE_CIPHER_SPEC:
            case SSL3_RT_ALERT:
            case SSL3_RT_HANDSHAKE:
            case SSL3_RT_APPLICATION_DATA:
                break;
            default:
                // SSLv2 or bad data
                return -1;
        }

        // SSLv3 or TLS - Check ProtocolVersion
        int majorVersion = unsignedByte(buffer.get(pos + 1));
        if (majorVersion != 3) {
            // Neither SSLv3 or TLSv1 (i.e. SSLv2 or bad data)
            return -1;
        }

        // SSLv3 or TLS
        int packetLength = unsignedShort(buffer.getShort(pos + 3)) + SSL3_RT_HEADER_LENGTH;
        if (packetLength <= SSL3_RT_HEADER_LENGTH) {
            // Neither SSLv3 or TLSv1 (i.e. SSLv2 or bad data)
            return -1;
        }
        return packetLength;
    }

    private static short unsignedByte(byte b) {
        return cast(short) (b & 0xFF);
    }

    private static int unsignedShort(short s) {
        return s & 0xFFFF;
    }

    private this() {}
}


/**
 * States for SSL engines.
 */
final class EngineStates {
    private this() {}

    /**
     * The engine is constructed, but the initial handshake hasn't been started
     */
    enum int STATE_NEW = 0;

    /**
     * The client/server mode of the engine has been set.
     */
    enum int STATE_MODE_SET = 1;

    /**
     * The handshake has been started
     */
    enum int STATE_HANDSHAKE_STARTED = 2;

    /**
     * Listeners of the handshake have been notified of completion but the handshake call
     * hasn't returned.
     */
    enum int STATE_HANDSHAKE_COMPLETED = 3;

    /**
     * The handshake call returned but the listeners have not yet been notified. This is expected
     * behaviour in cut-through mode, where SSL_do_handshake returns before the handshake is
     * complete. We can now start writing data to the socket.
     */
    enum int STATE_READY_HANDSHAKE_CUT_THROUGH = 4;

    /**
     * The handshake call has returned and the listeners have been notified. Ready to begin
     * writing data.
     */
    enum int STATE_READY = 5;

    /**
     * The inbound direction of the engine has been closed.
     */
    enum int STATE_CLOSED_INBOUND = 6;

    /**
     * The outbound direction of the engine has been closed.
     */
    enum int STATE_CLOSED_OUTBOUND = 7;

    /**
     * The engine has been closed.
     */
    enum int STATE_CLOSED = 8;
}