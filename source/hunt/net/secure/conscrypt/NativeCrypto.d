module hunt.net.secure.conscrypt.NativeCrypto;

import deimos.openssl.ssl;
import core.stdc.config;
/**
 * Provides the Java side of our JNI glue for OpenSSL.
 * <p>
 * Note: Many methods in this class take a reference to a Java object that holds a
 * native pointer in the form of a long in addition to the long itself and don't use
 * the Java object in the native implementation.  This is to prevent the Java object
 * from becoming eligible for GC while the native method is executing.  See
 * <a href="https://github.com/google/error-prone/blob/master/docs/bugpattern/UnsafeFinalization.md">this</a>
 * for more details.
 *
 * @hide
 */
final class NativeCrypto {
    // --- SSL handling --------------------------------------------------------

    enum string OBSOLETE_PROTOCOL_SSLV3 = "SSLv3";
    private enum string SUPPORTED_PROTOCOL_TLSV1 = "TLSv1";
    private enum string SUPPORTED_PROTOCOL_TLSV1_1 = "TLSv1.1";
    private enum string SUPPORTED_PROTOCOL_TLSV1_2 = "TLSv1.2";

    /** Protocols to enable by default when "TLSv1.2" is requested. */
    enum string[] TLSV12_PROTOCOLS = [
            SUPPORTED_PROTOCOL_TLSV1,
            SUPPORTED_PROTOCOL_TLSV1_1,
            SUPPORTED_PROTOCOL_TLSV1_2,
    ];

    /** Protocols to enable by default when "TLSv1.1" is requested. */
    enum string[] TLSV11_PROTOCOLS = TLSV12_PROTOCOLS;

    /** Protocols to enable by default when "TLSv1" is requested. */
    enum string[] TLSV1_PROTOCOLS = TLSV11_PROTOCOLS;

    enum string[] DEFAULT_PROTOCOLS = TLSV12_PROTOCOLS;
    private enum string[] SUPPORTED_PROTOCOLS = DEFAULT_PROTOCOLS;

    static string[] getSupportedProtocols() {
        return SUPPORTED_PROTOCOLS.dup;
    }

    private static SSL_SESSION* to_SSL_SESSION(long ssl_session_address)
    {
        return cast(SSL_SESSION*)ssl_session_address;
    }

    static long SSL_CTX_new()
    {
        SSL_CTX* ctx = deimos.openssl.ssl.SSL_CTX_new(SSLv23_method());
        return cast(long)cast(void*)ctx;
    }

    static void SSL_SESSION_free(long sslSessionNativePointer)
    {
        SSL_SESSION* ssl_session = to_SSL_SESSION(sslSessionNativePointer);
        if(ssl_session is null)
            return ;
        
        deimos.openssl.ssl.SSL_SESSION_free(ssl_session);
    }

    static byte[] SSL_SESSION_session_id(long sslSessionNativePointer)
    {
        SSL_SESSION* ssl_session = to_SSL_SESSION(sslSessionNativePointer);
        if(ssl_session is null)
            return null;

        uint len;
        const(ubyte)* id_ptr = deimos.openssl.ssl.SSL_SESSION_get_id(ssl_session, &len);
        if(id_ptr is null)
            return null;
        else
            return cast(byte[])id_ptr[0..len];
    }

    static long SSL_SESSION_get_time(long sslSessionNativePointer)
    {
        SSL_SESSION* ssl_session = to_SSL_SESSION(sslSessionNativePointer);
        if(ssl_session is null)
            return 0;

        // result must be jlong, not long or *1000 will overflow
        c_long result = deimos.openssl.ssl.SSL_SESSION_get_time(ssl_session);

        result *= 1000;  // OpenSSL uses seconds, Java uses milliseconds.
        return result;
    }

}