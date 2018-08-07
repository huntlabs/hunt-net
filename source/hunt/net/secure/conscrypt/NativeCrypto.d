module hunt.net.secure.conscrypt.NativeCrypto;

// import hunt.net.secure.conscrypt.ApplicationProtocolSelectorAdapter;
import hunt.net.secure.conscrypt.NativeConstants;
import hunt.net.secure.conscrypt.NativeRef;

import deimos.openssl.ssl;
import deimos.openssl.err;

import hunt.container;
import hunt.util.exception;
import hunt.util.string;

import kiss.logger;

import core.stdc.config;
import core.stdc.errno;

import std.algorithm;
import std.array;
import std.conv;
import std.string;
import std.stdint;

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


    // SUPPORTED_CIPHER_SUITES_SET contains all the supported cipher suites, using their Java names.
    __gshared static Set!string SUPPORTED_CIPHER_SUITES_SET;

    // SUPPORTED_LEGACY_CIPHER_SUITES_SET contains all the supported cipher suites using the legacy
    // OpenSSL-style names.
    private __gshared static Set!string SUPPORTED_LEGACY_CIPHER_SUITES_SET;


    /**
     * TLS_EMPTY_RENEGOTIATION_INFO_SCSV is RFC 5746's renegotiation
     * indication signaling cipher suite value. It is not a real
     * cipher suite. It is just an indication in the default and
     * supported cipher suite lists indicates that the implementation
     * supports secure renegotiation.
     * <p>
     * In the RI, its presence means that the SCSV is sent in the
     * cipher suite list to indicate secure renegotiation support and
     * its absense means to send an empty TLS renegotiation info
     * extension instead.
     * <p>
     * However, OpenSSL doesn't provide an API to give this level of
     * control, instead always sending the SCSV and always including
     * the empty renegotiation info if TLS is used (as opposed to
     * SSL). So we simply allow TLS_EMPTY_RENEGOTIATION_INFO_SCSV to
     * be passed for compatibility as to provide the hint that we
     * support secure renegotiation.
     */
    enum string TLS_EMPTY_RENEGOTIATION_INFO_SCSV = "TLS_EMPTY_RENEGOTIATION_INFO_SCSV";

    static string cipherSuiteToJava(string cipherSuite) {
        // For historical reasons, Java uses a different name for TLS_RSA_WITH_3DES_EDE_CBC_SHA.
        if ("TLS_RSA_WITH_3DES_EDE_CBC_SHA".equals(cipherSuite)) {
            return "SSL_RSA_WITH_3DES_EDE_CBC_SHA";
        }
        return cipherSuite;
    }

    static string cipherSuiteFromJava(string javaCipherSuite) {
        if ("SSL_RSA_WITH_3DES_EDE_CBC_SHA".equals(javaCipherSuite)) {
            return "TLS_RSA_WITH_3DES_EDE_CBC_SHA";
        }
        return javaCipherSuite;
    }

    /**
     * TLS_FALLBACK_SCSV is from
     * https://tools.ietf.org/html/draft-ietf-tls-downgrade-scsv-00
     * to indicate to the server that this is a fallback protocol
     * request.
     */
    private enum string TLS_FALLBACK_SCSV = "TLS_FALLBACK_SCSV";

    private __gshared string[] SUPPORTED_CIPHER_SUITES;

    shared static this() {
        SUPPORTED_CIPHER_SUITES_SET = new HashSet!string();
        SUPPORTED_LEGACY_CIPHER_SUITES_SET = new HashSet!string();

        string[] allCipherSuites = get_cipher_names("ALL:!DHE");

        // get_cipher_names returns an array where even indices are the standard name and odd
        // indices are the OpenSSL name.
        int size = cast(int)allCipherSuites.length;
        if (size % 2 != 0) {
            throw new IllegalArgumentException("Invalid cipher list returned by get_cipher_names");
        }
        SUPPORTED_CIPHER_SUITES = new string[size / 2 + 2];
        for (int i = 0; i < size; i += 2) {
            string cipherSuite = cipherSuiteToJava(allCipherSuites[i]);
            SUPPORTED_CIPHER_SUITES[i / 2] = cipherSuite;
            SUPPORTED_CIPHER_SUITES_SET.add(cipherSuite);

            SUPPORTED_LEGACY_CIPHER_SUITES_SET.add(allCipherSuites[i + 1]);
        }
        SUPPORTED_CIPHER_SUITES[size / 2] = TLS_EMPTY_RENEGOTIATION_INFO_SCSV;
        SUPPORTED_CIPHER_SUITES[size / 2 + 1] = TLS_FALLBACK_SCSV;
    }

    static SSL* to_SSL(long ssl_address) {
        return cast(SSL*)(cast(uintptr_t)ssl_address);
    }

    static SSL_CTX* to_SSL_CTX(long ssl_ctx_address)    {
        return cast(SSL_CTX*)(cast(uintptr_t)ssl_ctx_address);
    }

    static BIO* to_SSL_BIO(long bio_address) {
        return cast(BIO*)(cast(uintptr_t)bio_address);
    }

    static SSL_SESSION* to_SSL_SESSION(long ssl_session_address)    {
        return cast(SSL_SESSION*)(cast(uintptr_t)ssl_session_address);
    }

    static SSL_CIPHER* to_SSL_CIPHER(long ssl_cipher_address) {
        return cast(SSL_CIPHER*)(cast(uintptr_t)ssl_cipher_address);
    }

    // static AppData* toAppData(const SSL* ssl) {
    //     return cast(AppData*)(SSL_get_app_data(ssl));
    // }


    /**
     * Returns 1 if the BoringSSL believes the CPU has AES accelerated hardware
     * instructions. Used to determine cipher suite ordering.
     */
    // static int EVP_has_aes_hardware();

    static long SSL_CTX_new()    {
        SSL_CTX* ctx = deimos.openssl.ssl.SSL_CTX_new(TLSv1_2_method());

        infof("SSL_CTX_new => %s", ctx);
        return cast(long)cast(void*)ctx;
    }


    // IMPLEMENTATION NOTE: The default list of cipher suites is a trade-off between what we'd like
    // to use and what servers currently support. We strive to be secure enough by default. We thus
    // avoid unacceptably weak suites (e.g., those with bulk cipher secret key shorter than 128
    // bits), while maintaining the capability to connect to the majority of servers.
    //
    // Cipher suites are listed in preference order (favorite choice first) of the client. However,
    // servers are not required to honor the order. The key rules governing the preference order
    // are:
    // * Prefer Forward Secrecy (i.e., cipher suites that use ECDHE and DHE for key agreement).
    // * Prefer ChaCha20-Poly1305 to AES-GCM unless hardware support for AES is available.
    // * Prefer AES-GCM to AES-CBC whose MAC-pad-then-encrypt approach leads to weaknesses (e.g.,
    //   Lucky 13).
    // * Prefer 128-bit bulk encryption to 256-bit one, because 128-bit is safe enough while
    //   consuming less CPU/time/energy.
    //
    // NOTE: Removing cipher suites from this list needs to be done with caution, because this may
    // prevent apps from connecting to servers they were previously able to connect to.

    /** X.509 based cipher suites enabled by default (if requested), in preference order. */
    private enum bool HAS_AES_HARDWARE = false; // EVP_has_aes_hardware() == 1;
    enum string[] DEFAULT_X509_CIPHER_SUITES = HAS_AES_HARDWARE ?
            [
                    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
                    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
                    "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",
                    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
                    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
                    "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                    "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
                    "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
                    "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
                    "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA",
                    "TLS_RSA_WITH_AES_128_GCM_SHA256",
                    "TLS_RSA_WITH_AES_256_GCM_SHA384",
                    "TLS_RSA_WITH_AES_128_CBC_SHA",
                    "TLS_RSA_WITH_AES_256_CBC_SHA",
            ] :
            [
                    "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",
                    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
                    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
                    "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
                    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
                    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
                    "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
                    "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
                    "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
                    "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA",
                    "TLS_RSA_WITH_AES_128_GCM_SHA256",
                    "TLS_RSA_WITH_AES_256_GCM_SHA384",
                    "TLS_RSA_WITH_AES_128_CBC_SHA",
                    "TLS_RSA_WITH_AES_256_CBC_SHA",
            ];

    /** TLS-PSK cipher suites enabled by default (if requested), in preference order. */
    enum string[] DEFAULT_PSK_CIPHER_SUITES = [
            "TLS_ECDHE_PSK_WITH_CHACHA20_POLY1305_SHA256",
            "TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA",
            "TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA",
            "TLS_PSK_WITH_AES_128_CBC_SHA",
            "TLS_PSK_WITH_AES_256_CBC_SHA",
    ];

    static string[] getSupportedCipherSuites() {
        return SUPPORTED_CIPHER_SUITES.dup;
    }

    // static void SSL_CTX_free(long ssl_ctx);

    // static void SSL_CTX_set_session_id_context(long ssl_ctx, byte[] sid_ctx);

    // static long SSL_CTX_set_timeout(long ssl_ctx, long seconds);

    static long SSL_new(long ssl_ctx_address) {
        SSL_CTX* ssl_ctx = to_SSL_CTX(ssl_ctx_address);
        if (ssl_ctx is null) {
            return 0;
        }
        SSL* ssl = deimos.openssl.ssl.SSL_new(ssl_ctx);
        if (ssl is null) {
            warning("Unable to create SSL structure");
            tracef("ssl_ctx=%s SSL_new => null", ssl_ctx);
            return 0;
        }


        infof("SSL_new => %s", ssl);

        /*
        * Create our special application data.
        */
        // AppData* appData = AppData::create();
        // if (appData is null) {
        //     warning("Unable to create application data");
        //     deimos.openssl.ssl.ERR_clear_error();
        //     tracef("ssl_ctx=%s SSL_new appData => 0", ssl_ctx);
        //     return 0;
        // }
        // deimos.openssl.ssl.SSL_set_app_data(ssl, cast(char*)(appData));
        // deimos.openssl.ssl.SSL_set_custom_verify(ssl, SSL_VERIFY_PEER, cert_verify_callback);

        // tracef("ssl_ctx=%s SSL_new => ssl=%s appData=%s", ssl_ctx, ssl, appData);
        implementationMissing(false);
        return cast(long)ssl;        
    }

    static void SSL_enable_tls_channel_id(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }

        implementationMissing();
        // NOLINTNEXTLINE(runtime/int)
        // long ret = deimos.openssl.ssl.SSL_enable_tls_channel_id(ssl);
        // if (ret != 1L) {
        //     char* str = ERR_error_string(ERR_peek_error(), null);
        //     errorf("%s", fromstringz(str));
        //     return;
        // }
    }

    static byte[] SSL_get_tls_channel_id(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return null;
        }

        // Channel ID is 64 bytes long. Unfortunately, OpenSSL doesn't declare this length
        // as a constant anywhere.
        ubyte[] bytes = new ubyte[64];
        
implementationMissing();
return null;

        // Unfortunately, the SSL_get_tls_channel_id method below always returns 64 (upon success)
        // regardless of the number of bytes copied into the output buffer "tmp". Thus, the correctness
        // of this code currently relies on the "tmp" buffer being exactly 64 bytes long.
        // size_t ret = deimos.openssl.ssl.SSL_get_tls_channel_id(ssl, bytes.ptr, 64);
        // if (ret == 0) {
        //     // Channel ID either not set or did not verify
        //     tracef("SSL_get_tls_channel_id(%s) => not available", ssl);
        //     return null;
        // } else if (ret != 64) {
        //     CONSCRYPT_LOG_ERROR("%s", ERR_error_string(ERR_peek_error(), null));
        //     conscrypt::jniutil::throwSSLExceptionWithSslErrors(env, ssl, SSL_ERROR_NONE,
        //                                                     "Error getting Channel ID");
        //     tracef("ssl=%s SSL_get_tls_channel_id => error, returned %zd", ssl, ret);
        //     return null;
        // }

        // return javaBytes;        
    }

    static void SSL_set1_tls_channel_id(long ssl_address, NativeRef.EVP_PKEY pkey) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }
implementationMissing();
        // EVP_PKEY* pkey = fromContextObject<EVP_PKEY>(env, pkeyRef);
        // if (pkey is null) {
        //     tracef("ssl=%s SSL_set1_tls_channel_id => pkey is null", ssl);
        //     return;
        // }

        // // NOLINTNEXTLINE(runtime/int)
        // long ret = SSL_set1_tls_channel_id(ssl, pkey);

        // if (ret != 1L) {
        //     CONSCRYPT_LOG_ERROR("%s", ERR_error_string(ERR_peek_error(), null));
        //     conscrypt::jniutil::throwSSLExceptionWithSslErrors(
        //             env, ssl, SSL_ERROR_NONE, "Error setting private key for Channel ID");
        //     tracef("ssl=%s SSL_set1_tls_channel_id => error", ssl);
        //     return;
        // }

        // tracef("ssl=%s SSL_set1_tls_channel_id => ok", ssl);        
    }

    /**
     * Sets the local certificates and private key.
     *
     * @param ssl the SSL reference.
     * @param encodedCertificates the encoded form of the local certificate chain.
     * @param pkey a reference to the private key.
     * @ if a problem occurs setting the cert/key.
     */
    // static void setLocalCertsAndPrivateKey(long ssl_address, byte[][] encodedCertificates,
    //     NativeRef.EVP_PKEY pkey) ;

    // static void SSL_set_client_CA_list(long ssl_address, byte[][] asn1DerEncodedX500Principals)
    //         ;

    static long SSL_set_mode(long ssl_address, long mode) {
        SSL* ssl = to_SSL(ssl_address);
        // NOLINTNEXTLINE(runtime/int)
        if (ssl is null) {
            return 0;
        }
        long result = cast(long)(deimos.openssl.ssl.SSL_set_mode(ssl, cast(uint32_t)(mode)));
        // NOLINTNEXTLINE(runtime/int)
        return result;        
    }

    static long SSL_set_options(long ssl_address, long options) {
        SSL* ssl = to_SSL(ssl_address);
        // NOLINTNEXTLINE(runtime/int)
        if (ssl is null) {
            return 0;
        }
        long result = cast(long)(deimos.openssl.ssl.SSL_set_options(ssl, cast(uint)(options)));
        // NOLINTNEXTLINE(runtime/int)
        // JNI_TRACE("ssl=%s SSL_set_options => 0x%lx", ssl, (long)result);
        return result;        
    }

    static long SSL_clear_options(long ssl_address, long options) {
        SSL* ssl = to_SSL(ssl_address);
        // NOLINTNEXTLINE(runtime/int)
        if (ssl is null) {
            return 0;
        }
        long result = cast(long)(deimos.openssl.ssl.SSL_clear_options(ssl, cast(uint32_t)(options)));
        // NOLINTNEXTLINE(runtime/int)
        return result;        
    }

    static int SSL_set_protocol_versions(long ssl_address, int min_version, int max_version) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }
        // TODO: Tasks pending completion -@zxp at 8/2/2018, 3:03:24 PM
        // 
        return 1;
        // int min_result = SSL_set_min_proto_version(ssl, static_cast<uint16_t>(min_version));
        // int max_result = SSL_set_max_proto_version(ssl, static_cast<uint16_t>(max_version));
        // // Return failure if either call failed.
        // int result = 1;
        // if (!min_result || !max_result) {
        //     result = 0;
        //     // The only possible error is an invalid version, so we don't need the details.
        //     ERR_clear_error();
        // }
        // tracef("ssl=%s SSL_set_protocol_versions => (min: %d, max: %d) == %d", ssl, min_result, max_result, result);
        // return result;        
    }

    static void SSL_enable_signed_cert_timestamps(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }

implementationMissing();
        // deimos.openssl.ssl.SSL_enable_signed_cert_timestamps(ssl);        
    }

    static byte[] SSL_get_signed_cert_timestamp_list(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return null;
        }
implementationMissing();
return null;
        // const uint8_t* data;
        // size_t data_len;
        // SSL_get0_signed_cert_timestamp_list(ssl, &data, &data_len);

        // if (data_len == 0) {
        //     tracef("SSL_get_signed_cert_timestamp_list(%s) => null", ssl);
        //     return null;
        // }

        // jbyteArray result = env.NewByteArray(static_cast<jsize>(data_len));
        // if (result != null) {
        //     env.SetByteArrayRegion(result, 0, static_cast<jsize>(data_len), (const jbyte*)data);
        // }
        // return result;        
    }

    static void SSL_set_signed_cert_timestamp_list(long ssl_address, byte[] list) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }
        
        implementationMissing();

        // if (!deimos.openssl.ssl.SSL_set_signed_cert_timestamp_list(ssl, reinterpret_cast<const uint8_t*>(listBytes.get()),
        //                                         listBytes.size())) {
        //     warningf("ssl=%s SSL_set_signed_cert_timestamp_list => fail", ssl);
        // } else {
        //     infof("ssl=%s SSL_set_signed_cert_timestamp_list => ok", ssl);
        // }        
    }

    static void SSL_enable_ocsp_stapling(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }

        implementationMissing(false);
        // deimos.openssl.ssl.SSL_enable_ocsp_stapling(ssl);        
    }

    static byte[] SSL_get_ocsp_response(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return null;
        }
        implementationMissing();
        return null;

        // const uint8_t* data;
        // size_t data_len;
        // SSL_get0_ocsp_response(ssl, &data, &data_len);

        // if (data_len == 0) {
        //     JNI_TRACE("SSL_get_ocsp_response(%s) => null", ssl);
        //     return null;
        // }

        // ScopedLocalRef<jbyteArray> byteArray(env, env.NewByteArray(static_cast<jsize>(data_len)));
        // if (byteArray.get() is null) {
        //     JNI_TRACE("SSL_get_ocsp_response(%s) => creating byte array failed", ssl);
        //     return null;
        // }

        // env.SetByteArrayRegion(byteArray.get(), 0, static_cast<jsize>(data_len), (const jbyte*)data);
        // JNI_TRACE("SSL_get_ocsp_response(%s) => %s [size=%zd]", ssl, byteArray.get(),
        //         data_len);

        // return byteArray.release();        
    }

    static void SSL_set_ocsp_response(long ssl_address, byte[] response) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }
        implementationMissing(false);

        // ScopedByteArrayRO responseBytes(env, response);
        // if (responseBytes.get() is null) {
        //     JNI_TRACE("ssl=%s SSL_set_ocsp_response => response is null", ssl);
        //     return;
        // }

        // if (!SSL_set_ocsp_response(ssl, reinterpret_cast<const uint8_t*>(responseBytes.get()),
        //                         responseBytes.size())) {
        //     JNI_TRACE("ssl=%s SSL_set_ocsp_response => fail", ssl);
        // } else {
        //     JNI_TRACE("ssl=%s SSL_set_ocsp_response => ok", ssl);
        // }      
    }

    // static byte[] SSL_get_tls_unique(long ssl_address);

    // static void SSL_set_token_binding_params(long ssl_address, int[] params) ;

    // static int SSL_get_token_binding_params(long ssl_address);

    // static byte[] SSL_export_keying_material(long ssl_address, byte[] label, byte[] context, int num_bytes) ;

    // static void SSL_use_psk_identity_hint(long ssl_address, string identityHint) ;

    // static void set_SSL_psk_client_callback_enabled(long ssl_address, bool enabled);

    // static void set_SSL_psk_server_callback_enabled(long ssl_address, bool enabled);


    static void SSL_SESSION_free(long sslSessionNativePointer)    {
        SSL_SESSION* ssl_session = to_SSL_SESSION(sslSessionNativePointer);
        if(ssl_session is null)
            return ;
        
        deimos.openssl.ssl.SSL_SESSION_free(ssl_session);
    }

    static void SSL_CTX_set_session_id_context(long ssl_ctx_address, byte[] sid_ctx)    {
        SSL_CTX* ssl_ctx = to_SSL_CTX(ssl_ctx_address);
        if(ssl_ctx is null)
        {
            return;
        }

        int result = deimos.openssl.ssl.SSL_CTX_set_session_id_context(ssl_ctx, 
            cast(const(ubyte) *) sid_ctx.ptr, cast(uint)sid_ctx.length );
        if (result == 0) {
            error("");
        }
        // else
        // {

        // }

    }

    static byte[] SSL_SESSION_session_id(long sslSessionNativePointer)    {
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

    static long SSL_SESSION_get_time(long sslSessionNativePointer)    {
        SSL_SESSION* ssl_session = to_SSL_SESSION(sslSessionNativePointer);
        if(ssl_session is null)
            return 0;

        // result must be jlong, not long or *1000 will overflow
        c_long result = deimos.openssl.ssl.SSL_SESSION_get_time(ssl_session);

        result *= 1000;  // OpenSSL uses seconds, Java uses milliseconds.
        return result;
    }


    static string SSL_CIPHER_get_kx_name(long cipher_address) {
        const SSL_CIPHER* cipher = to_SSL_CIPHER(cipher_address);
        implementationMissing();
return null;
        // const char* kx_name = deimos.openssl.ssl.SSL_CIPHER_get_kx_name(cipher);
        // return fromStringz(kx_name);        
    }

    static string[] get_cipher_names(string selector) {
        if (selector.empty) {
            warning("selector is null");
            return null;
        }

// TODO: Tasks pending completion -@zxp at 8/3/2018, 10:42:17 AM
// 
        // SSL_CTX* sslCtx = deimos.openssl.ssl.SSL_CTX_new(TLS_with_buffers_method());
        SSL_CTX* sslCtx = deimos.openssl.ssl.SSL_CTX_new(TLSv1_2_method());
        SSL* ssl = deimos.openssl.ssl.SSL_new(sslCtx);

        if (!SSL_set_cipher_list(ssl, selector.toStringz())) {
            warning("Unable to set SSL cipher list");
            return null;
        }
implementationMissing(false);
return null;        
        // STACK_OF(SSL_CIPHER)* ciphers = SSL_get_ciphers(ssl);

        // size_t size = sk_SSL_CIPHER_num(ciphers);
        // ScopedLocalRef<jobjectArray> cipherNamesArray(
        //         env, env.NewObjectArray(static_cast<jsize>(2 * size), conscrypt::jniutil::stringClass,
        //                                 null));
        // if (cipherNamesArray.get() is null) {
        //     return null;
        // }

        // // Return an array of standard and OpenSSL name pairs.
        // for (size_t i = 0; i < size; i++) {
        //     const SSL_CIPHER* cipher = sk_SSL_CIPHER_value(ciphers, i);
        //     ScopedLocalRef<jstring> cipherName(env,
        //                                     env.NewStringUTF(SSL_CIPHER_standard_name(cipher)));
        //     env.SetObjectArrayElement(cipherNamesArray.get(), static_cast<jsize>(2 * i),
        //                             cipherName.get());

        //     ScopedLocalRef<jstring> opensslName(env, env.NewStringUTF(SSL_CIPHER_get_name(cipher)));
        //     env.SetObjectArrayElement(cipherNamesArray.get(), static_cast<jsize>(2 * i + 1),
        //                             opensslName.get());
        // }

        // tracef("get_cipher_names(%s) => success (%zd entries)", selector.c_str(),
        //         2 * size);
        // return cipherNamesArray.release();        
    }

    // static byte[] get_ocsp_single_extension(
    //         byte[] ocspResponse, string oid, long x509Ref, OpenSSLX509Certificate holder, long issuerX509Ref, OpenSSLX509Certificate holder2);

    /**
     * Returns the starting address of the memory region referenced by the provided direct
     * {@link Buffer} or {@code 0} if the provided buffer is not direct or if such access to direct
     * buffers is not supported by the platform.
     *
     * <p>NOTE: This method ignores the buffer's current {@code position}.
     */
    // static long getDirectBufferAddress(Buffer buf) {
    //     return cast(int)<jlong>(env.GetDirectBufferAddress(buffer));
    // }

    static long SSL_BIO_new(long ssl_address)
    {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }

        BIO* internal_bio;
        BIO* network_bio;
        if (BIO_new_bio_pair(&internal_bio, 0, &network_bio, 0) != 1) {
            errorf("ssl=%s SSL_BIO_new => BIO_new_bio_pair exception", ssl);
            return 0;
        }

        infof("SSL_BIO_new => %s", network_bio);

        SSL_set_bio(ssl, internal_bio, internal_bio);

        return cast(long)(network_bio);
    }

    static int SSL_get_error(long ssl_address, int ret) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }
        return deimos.openssl.ssl.SSL_get_error(ssl, ret);        
    }

    static void SSL_clear_error() {
        ERR_clear_error();
    }

    static int SSL_pending_readable_bytes(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }
        return SSL_pending(ssl);        
    }

    static int SSL_pending_written_bytes_in_BIO(long bio_address)
    {
        BIO* bio = to_SSL_BIO(bio_address);
        if (bio is null) {
            return 0;
        }
        int r = cast(int)(BIO_ctrl_pending(bio));
        return r;
    }

    /**
     * Returns the maximum overhead, in bytes, of sealing a record with SSL.
     */
    static int SSL_max_seal_overhead(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }

        implementationMissing(false);
        return 0;
        // return (int)deimos.openssl.ssl.SSL_max_seal_overhead(ssl);        
    }

    /**
     * Enables ALPN for this TLS endpoint and sets the list of supported ALPN protocols in
     * wire-format (length-prefixed 8-bit strings).
     */
    static void setApplicationProtocols(long ssl_address, bool client, byte[] protocols) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }
        implementationMissing(false);
        // AppData* appData = toAppData(ssl);
        // if (appData is null) {
        //     error("Unable to retrieve application data");
        //     return;
        // }

        // if (protocols != null) {
        //     if (client_mode) {
        //         ScopedByteArrayRO protosBytes(env, protocols);
        //         if (protosBytes.get() is null) {
        //             JNI_TRACE(
        //                     "ssl=%s setApplicationProtocols protocols=%s => "
        //                     "protosBytes is null",
        //                     ssl, protocols);
        //             return;
        //         }

        //         const unsigned char* tmp = reinterpret_cast<const unsigned char*>(protosBytes.get());
        //         int ret = SSL_set_alpn_protos(ssl, tmp, static_cast<unsigned int>(protosBytes.size()));
        //         if (ret != 0) {
        //             conscrypt::jniutil::throwSSLExceptionStr(env,
        //                                                     "Unable to set ALPN protocols for client");
        //             JNI_TRACE("ssl=%s setApplicationProtocols => exception", ssl);
        //             return;
        //         }
        //     } else {
        //         // Server mode - configure the ALPN protocol selection callback.
        //         if (!appData.setApplicationProtocols(env, protocols)) {
        //             conscrypt::jniutil::throwSSLExceptionStr(env,
        //                                                     "Unable to set ALPN protocols for server");
        //             JNI_TRACE("ssl=%s setApplicationProtocols => exception", ssl);
        //             return;
        //         }
        //         SSL_CTX_set_alpn_select_cb(SSL_get_SSL_CTX(ssl), alpn_select_callback, null);
        //     }
        // }        
    }

    /**
     * Called for a server endpoint only. Enables ALPN and sets a BiFunction that will
     * be called to delegate protocol selection to the application. Calling this method overrides
     * {@link #setApplicationProtocols(long, NativeSsl, bool, byte[])}.
     */
    // static void setApplicationProtocolSelector(long ssl_address, ApplicationProtocolSelectorAdapter selector) {
    //     SSL* ssl = to_SSL(ssl_address);
    //     if (ssl is null) {
    //         return;
    //     }

    //     implementationMissing();
    //     // AppData* appData = toAppData(ssl);
    //     // if (appData is null) {
    //     //     conscrypt::jniutil::throwSSLExceptionStr(env, "Unable to retrieve application data");
    //     //     JNI_TRACE("ssl=%s setApplicationProtocolSelector appData => 0", ssl);
    //     //     return;
    //     // }

    //     // appData.setApplicationProtocolSelector(env, selector);
    //     // if (selector != null) {
    //     //     SSL_CTX_set_alpn_select_cb(SSL_get_SSL_CTX(ssl), alpn_select_callback, null);
    //     // }
    // }

    /**
     * Returns the selected ALPN protocol. If the server did not select a
     * protocol, {@code null} will be returned.
     */
    static byte[] getApplicationProtocol(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return null;
        }

        implementationMissing();
        return null;
        // const jbyte* protocol;
        // unsigned int protocolLength;
        // SSL_get0_alpn_selected(ssl, reinterpret_cast<const unsigned char**>(&protocol),
        //                     &protocolLength);
        // if (protocolLength == 0) {
        //     return null;
        // }
        // jbyteArray result = env.NewByteArray(static_cast<jsize>(protocolLength));
        // if (result != null) {
        //     env.SetByteArrayRegion(result, 0, (static_cast<jsize>(protocolLength)), protocol);
        // }
        // return result;
    }

    /**
     * Variant of the {@link #SSL_do_handshake} used by {@link ConscryptEngine}. This differs
     * slightly from the raw BoringSSL API in that it returns the SSL error code from the
     * operation, rather than the return value from {@code SSL_do_handshake}. This is done in
     * order to allow to properly handle SSL errors and propagate useful exceptions.
     *
     * @return Returns the SSL error code for the operation when the error was {@code
     * SSL_ERROR_NONE}, {@code SSL_ERROR_WANT_READ}, or {@code SSL_ERROR_WANT_WRITE}.
     * @ when the error code is anything except those returned by this method.
     */
    static int ENGINE_SSL_do_handshake(long ssl_address, SSLHandshakeCallbacks shc) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }

        if (shc is null) {
            warning("sslHandshakeCallbacks is null");
            return 0;
        }

        implementationMissing(false);
        // AppData* appData = toAppData(ssl);
        // if (appData is null) {
        //     warning("Unable to retrieve application data");
        //     return 0;
        // }

        errno = 0;

        // if (!appData.setCallbackState(shc, null)) {
        //     warning("Unable to set appdata callback");
        //     ERR_clear_error();
        //     return 0;
        // }

        int ret = deimos.openssl.ssl.SSL_do_handshake(ssl);
        // appData.clearCallbackState();
        // // if (env.ExceptionCheck()) {
        // //     // cert_verify_callback threw exception
        // //     ERR_clear_error();
        // //     JNI_TRACE("ssl=%s ENGINE_SSL_do_handshake => exception", ssl);
        // //     return 0;
        // // }

        int code = SSL_ERROR_NONE;
        if(ret<=0)
            code = deimos.openssl.ssl.SSL_get_error(ssl, ret);

        if (ret > 0 || code == SSL_ERROR_WANT_READ || code == SSL_ERROR_WANT_WRITE) {
            // Non-exceptional case.
            version(HuntDebugMode) infof("ssl=%s ENGINE_SSL_do_handshake shc=%s => ret=%d", ssl, shc, code);
            return code;
        }

        // Exceptional case...
        if (ret == 0) {
            // TODO(nmittler): Can this happen with memory BIOs?
            /*
            * Clean error. See SSL_do_handshake(3SSL) man page.
            * The other side closed the socket before the handshake could be
            * completed, but everything is within the bounds of the TLS protocol.
            * We still might want to find out the real reason of the failure.
            */
            if (code == SSL_ERROR_NONE || (code == SSL_ERROR_SYSCALL && errno == 0) ||
                (code == SSL_ERROR_ZERO_RETURN)) {
                warning("Connection closed by peer");
            } else {
                warning("SSL handshake terminated");
            }
            return code;
        }

        /*
        * Unclean error. See SSL_do_handshake(3SSL) man page.
        * Translate the error and throw exception. We are sure it is an error
        * at this point.
        */
        warning("SSL handshake aborted");
        return code;        
    }

    /**
     * Variant of the {@link #SSL_read} for a direct {@link java.nio.ByteBuffer} used by {@link
     * ConscryptEngine}.
     *
     * @return if positive, represents the number of bytes read into the given buffer.
     * Returns {@code -SSL_ERROR_WANT_READ} if more data is needed. Returns
     * {@code -SSL_ERROR_WANT_WRITE} if data needs to be written out to flush the BIO.
     *
     * @throws java.io.InterruptedIOException if the read was interrupted.
     * @throws java.io.EOFException if the end of stream has been reached.
     * @throws CertificateException if the application's certificate verification callback failed.
     * Only occurs during handshake processing.
     * @ if any other error occurs.
     */
    static int ENGINE_SSL_read_direct(long ssl_address, long address, int length,
            SSLHandshakeCallbacks shc) {
        SSL* ssl = to_SSL(ssl_address);
        char* destPtr = cast(char*)(address);
        if (ssl is null) {
            return -1;
        }

        if (shc is null) {
            warning("sslHandshakeCallbacks is null");
            return -1;
        }

        // AppData* appData = toAppData(ssl);
        // if (appData is null) {
        //     warning("Unable to retrieve application data");
        //     return -1;
        // }
        // if (!appData.setCallbackState(env, shc, null)) {
        //     warning("Unable to set appdata callback");
        //     ERR_clear_error();
        //     return -1;
        // }

        errno = 0;

        int result = deimos.openssl.ssl.SSL_read(ssl, destPtr, length);
        // appData.clearCallbackState();
        // if (env.ExceptionCheck()) {
        //     // An exception was thrown by one of the callbacks. Just propagate that exception.
        //     ERR_clear_error();
        //     JNI_TRACE("ssl=%s ENGINE_SSL_read_direct => THROWN_EXCEPTION", ssl);
        //     return -1;
        // }

        int sslErrorCode = SSL_ERROR_NONE;
        if(result<=0)
            sslErrorCode = deimos.openssl.ssl.SSL_get_error(ssl, result);

        switch (sslErrorCode) {
            case SSL_ERROR_NONE: {
                // Successfully read at least one byte. Just return the result.
                break;
            }
            case SSL_ERROR_ZERO_RETURN: {
                // A close_notify was received, this stream is finished.
                return -SSL_ERROR_ZERO_RETURN;
            }
            case SSL_ERROR_WANT_READ:
            case SSL_ERROR_WANT_WRITE: {
                // Return the negative of these values.
                result = -result;
                break;
            }
            case SSL_ERROR_SYSCALL: {
                // A problem occurred during a system call, but this is not
                // necessarily an error.
                if (result == 0) {
                    // TODO(nmittler): Can this happen with memory BIOs?
                    // Connection closed without proper shutdown. Tell caller we
                    // have reached end-of-stream.
                    warning("EOFException: ", "Read error");
                    break;
                }

                if (errno == EINTR) {
                    // TODO(nmittler): Can this happen with memory BIOs?
                    // System call has been interrupted. Simply retry.
                    warning("InterruptedIOException: ", "Read error");
                    break;
                }

                // Note that for all other system call errors we fall through
                // to the default case, which results in an Exception.
                // FALLTHROUGH_INTENDED;
                error("Read error");
                break;
            }
            default: {
                // Everything else is basically an error.
                error("Read error");
                break;
            }
        }

        version(HuntDebugMode) tracef("ssl=%s ENGINE_SSL_read_direct address=%s length=%d shc=%s result=%d",
                ssl, destPtr, length, shc, result);
        return result;
    }

    /**
     * Variant of the {@link #SSL_write} for a direct {@link java.nio.ByteBuffer} used by {@link
     * ConscryptEngine}. This version does not lock or and does no error pre-processing.
     */
    static int ENGINE_SSL_write_direct(long ssl_address, long address, int len,
            SSLHandshakeCallbacks shc) {

        SSL* ssl = to_SSL(ssl_address);
        const char* sourcePtr = cast(const char*)(address);
        if (ssl is null) {
            return -1;
        }

// implementationMissing();
// return -1;
        if (shc is null) {
            warning("sslHandshakeCallbacks is null");
            return -1;
        }

        // AppData* appData = toAppData(ssl);
        // if (appData is null) {
        //     warning("Unable to retrieve application data");
        //     ERR_clear_error();
        //     return -1;
        // }
        // if (!appData.setCallbackState(env, shc, null)) {
        //     warning("Unable to set appdata callback");
        //     ERR_clear_error();
        //     return -1;
        // }

        errno = 0;

        int result = SSL_write(ssl, sourcePtr, len);
        // appData.clearCallbackState();
        version(HuntDebugMode) tracef("ssl=%s ENGINE_SSL_write_direct address=%s length=%d shc=%s => ret=%d",
                ssl, sourcePtr, len, shc, result);
        return result;
    }

    /**
     * Writes data from the given direct {@link java.nio.ByteBuffer} to the BIO.
     */
    static int ENGINE_SSL_write_BIO_direct(long ssl_address, long bioRef, long address, int len,
            SSLHandshakeCallbacks shc) {

        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return -1;
        }
        if (shc is null) {
            warning("sslHandshakeCallbacks is null");
            return -1;
        }
        BIO* bio = to_SSL_BIO(bioRef);
        if (bio is null) {
            return -1;
        }
        if (len < 0 || BIO_ctrl_get_write_guarantee(bio) < cast(size_t)(len)) {
            // The network BIO couldn't handle the entire write. Don't write anything, so that we
            // only process one packet at a time.
            return 0;
        }
        const char* sourcePtr = cast(const char*)(address);

// implementationMissing();
// return 0;

// TODO: Tasks pending completion -@zxp at 8/2/2018, 9:45:01 AM
// 
        // AppData* appData = toAppData(ssl);
        // if (appData is null) {
        //     warning("Unable to retrieve application data");
        //     ERR_clear_error();
        //     return -1;
        // }
        // if (!appData.setCallbackState(shc, null)) {
        //     warning("Unable to set appdata callback");
        //     ERR_clear_error();
        //     return -1;
        // }

        errno = 0;

        int result = deimos.openssl.ssl.BIO_write(bio, cast(const char*)(sourcePtr), len);
        // appData.clearCallbackState();
        version(HuntDebugMode) tracef("ssl=%s ENGINE_SSL_write_BIO_direct bio=%s sourcePtr=%s len=%d shc=%s => ret=%d",
                ssl, bio, sourcePtr, len, shc, result);
        return result;
    }

    // /**
    //  * Writes data from the given array to the BIO.
    //  */
    // static int ENGINE_SSL_write_BIO_heap(long ssl_address, long bioRef, byte[] sourceJava,
    //         int sourceOffset, int sourceLength, SSLHandshakeCallbacks shc);            

    /**
     * Reads data from the given BIO into a direct {@link java.nio.ByteBuffer}.
     */
    static int ENGINE_SSL_read_BIO_direct(long ssl_address, long bioRef, long address, int outputSize,
            SSLHandshakeCallbacks shc) {

        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return -1;
        }
        if (shc is null) {
            warning("sslHandshakeCallbacks is null");
            return -1;
        }
        BIO* bio = to_SSL_BIO(bioRef);
        if (bio is null) {
            return -1;
        }
        char* destPtr = cast(char*)(address);
        if (destPtr is null) {
            warning("destPtr is null");
            return -1;
        }

implementationMissing(false);
// return 0;
        // AppData* appData = toAppData(ssl);
        // if (appData is null) {
        //     warning("Unable to retrieve application data");
        //     ERR_clear_error();
        //     return -1;
        // }
        // if (!appData.setCallbackState(shc, null)) {
        //     warning("Unable to set appdata callback");
        //     ERR_clear_error();
        //     return -1;
        // }

        errno = 0;

        int result = BIO_read(bio, destPtr, outputSize);
        // appData.clearCallbackState();
        tracef("ssl=%s ENGINE_SSL_read_BIO_direct bio=%s destPtr=%s outputSize=%d shc=%s => ret=%d",
                ssl, bio, destPtr, outputSize, shc, result);
        return result;
    }

    // /**
    //  * Reads data from the given BIO into an array.
    //  */
    // static int ENGINE_SSL_read_BIO_heap(long ssl_address, long bioRef, byte[] destJava,
    //         int destOffset, int destLength, SSLHandshakeCallbacks shc);

    /**
     * Variant of the {@link #SSL_shutdown} used by {@link ConscryptEngine}. This version does not
     * lock.
     */
    static void ENGINE_SSL_shutdown(long ssl_address, SSLHandshakeCallbacks shc) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }
        tracef("ssl=%s ENGINE_SSL_shutdown", ssl);

        if (shc is null) {
            warning("sslHandshakeCallbacks is null");
            return;
        }

        // AppData* appData = toAppData(ssl);
        // if (appData !is null) {
        //     if (!appData.setCallbackState(env, shc, null)) {
        //         conscrypt::jniutil::throwSSLExceptionStr(env, "Unable to set appdata callback");
        //         ERR_clear_error();
        //         tracef("ssl=%s ENGINE_SSL_shutdown => exception", ssl);
        //         return;
        //     }
        //     int ret = SSL_shutdown(ssl);
        //     appData.clearCallbackState();
        //     // callbacks can happen if server requests renegotiation
        //     if (env.ExceptionCheck()) {
        //         tracef("ssl=%s ENGINE_SSL_shutdown => exception", ssl);
        //         return;
        //     }
        //     switch (ret) {
        //         case 0:
        //             /*
        //             * Shutdown was not successful (yet), but there also
        //             * is no error. Since we can't know whether the remote
        //             * server is actually still there, and we don't want to
        //             * get stuck forever in a second SSL_shutdown() call, we
        //             * simply return. This is not security a problem as long
        //             * as we close the underlying socket, which we actually
        //             * do, because that's where we are just coming from.
        //             */
        //             tracef("ssl=%s ENGINE_SSL_shutdown => 0", ssl);
        //             break;
        //         case 1:
        //             /*
        //             * Shutdown was successful. We can safely return. Hooray!
        //             */
        //             tracef("ssl=%s ENGINE_SSL_shutdown => 1", ssl);
        //             break;
        //         default:
        //             /*
        //             * Everything else is a real error condition. We should
        //             * let the Java layer know about this by throwing an
        //             * exception.
        //             */
        //             int sslError = SSL_get_error(ssl, ret);
        //             tracef("ssl=%s ENGINE_SSL_shutdown => sslError=%d", ssl, sslError);
        //             conscrypt::jniutil::throwSSLExceptionWithSslErrors(env, ssl, sslError,
        //                                                             "SSL shutdown failed");
        //             break;
        //     }
        // }

implementationMissing(false);
        ERR_clear_error();        
    }

    // /**
    //  * Used for testing only.
    //  */
    // static int BIO_read(long bioRef, byte[] buffer);
    // static void BIO_write(long bioRef, byte[] buffer, int offset, int length);
    // static long ERR_peek_last_error();
    static long SSL_clear_mode(long ssl_address, long mode) {
        SSL* ssl = to_SSL(ssl_address);
        // NOLINTNEXTLINE(runtime/int)
        if (ssl is null) {
            return 0;
        }
        long result = cast(long)(deimos.openssl.ssl.SSL_clear_mode(ssl, cast(uint32_t)(mode)));
        // NOLINTNEXTLINE(runtime/int)
        return result;
    }

    static long SSL_get_mode(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }
        long mode = cast(long)(deimos.openssl.ssl.SSL_get_mode(ssl));
        // NOLINTNEXTLINE(runtime/int)
        return mode;        
    }

    static long SSL_get_options(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }
        long options = cast(long)(deimos.openssl.ssl.SSL_get_options(ssl));
        // NOLINTNEXTLINE(runtime/int)
        return options;        
    }
    // static long SSL_get1_session(long ssl_address);

    // --- DSA/RSA public/private key handling functions -----------------------

    // static long EVP_PKEY_new_RSA(byte[] n, byte[] e, byte[] d, byte[] p, byte[] q,
    //         byte[] dmp1, byte[] dmq1, byte[] iqmp);

    // static int EVP_PKEY_type(NativeRef.EVP_PKEY pkey);

    // static string EVP_PKEY_print_public(NativeRef.EVP_PKEY pkeyRef);

    // static string EVP_PKEY_print_params(NativeRef.EVP_PKEY pkeyRef);

    static void EVP_PKEY_free(long pkeyRef) {
        EVP_PKEY* pkey = cast(EVP_PKEY*)(pkeyRef);

        if (pkey !is null) {
            deimos.openssl.ssl.EVP_PKEY_free(pkey);
        }        
    }

    // static int EVP_PKEY_cmp(NativeRef.EVP_PKEY pkey1, NativeRef.EVP_PKEY pkey2);

    // static byte[] EVP_marshal_private_key(NativeRef.EVP_PKEY pkey);

    // static long EVP_parse_private_key(byte[] data) throws ParsingException;

    // static byte[] EVP_marshal_public_key(NativeRef.EVP_PKEY pkey);

    // static long EVP_parse_public_key(byte[] data) throws ParsingException;

    // static long PEM_read_bio_PUBKEY(long bioCtx);

    // static long PEM_read_bio_PrivateKey(long bioCtx);

    // static long getRSAPrivateKeyWrapper(PrivateKey key, byte[] modulus);

    // static long getECPrivateKeyWrapper(PrivateKey key, NativeRef.EC_GROUP ecGroupRef);

    // static long RSA_generate_key_ex(int modulusBits, byte[] publicExponent);

    // static int RSA_size(NativeRef.EVP_PKEY pkey);

    // static int RSA_private_encrypt(
    //         int flen, byte[] from, byte[] to, NativeRef.EVP_PKEY pkey, int padding);

    // static int RSA_public_decrypt(int flen, byte[] from, byte[] to, NativeRef.EVP_PKEY pkey,
    //         int padding) throws BadPaddingException, SignatureException;

    // static int RSA_public_encrypt(
    //         int flen, byte[] from, byte[] to, NativeRef.EVP_PKEY pkey, int padding);

    // static int RSA_private_decrypt(int flen, byte[] from, byte[] to, NativeRef.EVP_PKEY pkey,
    //         int padding) throws BadPaddingException, SignatureException;

    // /**
    //  * @return array of {n, e}
    //  */
    // static byte[][] get_RSA_public_params(NativeRef.EVP_PKEY rsa);

    // /**
    //  * @return array of {n, e, d, p, q, dmp1, dmq1, iqmp}
    //  */
    // static byte[][] get_RSA_private_params(NativeRef.EVP_PKEY rsa);

    // // --- ChaCha20 -----------------------

    // /**
    //  * Returns the encrypted or decrypted version of the data.
    //  */
    // static void chacha20_encrypt_decrypt(byte[] in, int inOffset, byte[] out, int outOffset,
    //         int length, byte[] key, byte[] nonce, int blockCounter);

    // // --- EC functions --------------------------

    // static long EVP_PKEY_new_EC_KEY(
    //         NativeRef.EC_GROUP groupRef, NativeRef.EC_POINT pubkeyRef, byte[] privkey);

    // static long EC_GROUP_new_by_curve_name(string curveName);

    // static long EC_GROUP_new_arbitrary(
    //         byte[] p, byte[] a, byte[] b, byte[] x, byte[] y, byte[] order, int cofactor);

    // static string EC_GROUP_get_curve_name(NativeRef.EC_GROUP groupRef);

    // static byte[][] EC_GROUP_get_curve(NativeRef.EC_GROUP groupRef);

    // static void EC_GROUP_clear_free(long groupRef);

    // static long EC_GROUP_get_generator(NativeRef.EC_GROUP groupRef);

    // static byte[] EC_GROUP_get_order(NativeRef.EC_GROUP groupRef);

    // static int EC_GROUP_get_degree(NativeRef.EC_GROUP groupRef);

    // static byte[] EC_GROUP_get_cofactor(NativeRef.EC_GROUP groupRef);

    // static long EC_POINT_new(NativeRef.EC_GROUP groupRef);

    // static void EC_POINT_clear_free(long pointRef);

    // static byte[][] EC_POINT_get_affine_coordinates(
    //         NativeRef.EC_GROUP groupRef, NativeRef.EC_POINT pointRef);

    // static void EC_POINT_set_affine_coordinates(
    //         NativeRef.EC_GROUP groupRef, NativeRef.EC_POINT pointRef, byte[] x, byte[] y);

    // static long EC_KEY_generate_key(NativeRef.EC_GROUP groupRef);

    // static long EC_KEY_get1_group(NativeRef.EVP_PKEY pkeyRef);

    // static byte[] EC_KEY_get_private_key(NativeRef.EVP_PKEY keyRef);

    // static long EC_KEY_get_public_key(NativeRef.EVP_PKEY keyRef);

    // static byte[] EC_KEY_marshal_curve_name(NativeRef.EC_GROUP groupRef) throws IOException;

    // static long EC_KEY_parse_curve_name(byte[] encoded) throws IOException;

    // static int ECDH_compute_key(byte[] out, int outOffset, NativeRef.EVP_PKEY publicKeyRef,
    //         NativeRef.EVP_PKEY privateKeyRef) throws InvalidKeyException, IndexOutOfBoundsException;

    // static int ECDSA_size(NativeRef.EVP_PKEY pkey);

    // static int ECDSA_sign(byte[] data, byte[] sig, NativeRef.EVP_PKEY pkey);

    // static int ECDSA_verify(byte[] data, byte[] sig, NativeRef.EVP_PKEY pkey);

    // // --- Message digest functions --------------

    // // These return const references
    // static long EVP_get_digestbyname(string name);

    // static int EVP_MD_size(long evp_md_const);

    // // --- Message digest context functions --------------

    // static long EVP_MD_CTX_create();

    // static void EVP_MD_CTX_cleanup(NativeRef.EVP_MD_CTX ctx);

    // static void EVP_MD_CTX_destroy(long ctx);

    // static int EVP_MD_CTX_copy_ex(
    //         NativeRef.EVP_MD_CTX dst_ctx, NativeRef.EVP_MD_CTX src_ctx);

    // // --- Digest handling functions -------------------------------------------

    // static int EVP_DigestInit_ex(NativeRef.EVP_MD_CTX ctx, long evp_md);

    // static void EVP_DigestUpdate(
    //         NativeRef.EVP_MD_CTX ctx, byte[] buffer, int offset, int length);

    // static void EVP_DigestUpdateDirect(NativeRef.EVP_MD_CTX ctx, long ptr, int length);

    // static int EVP_DigestFinal_ex(NativeRef.EVP_MD_CTX ctx, byte[] hash, int offset);

    // // --- Signature handling functions ----------------------------------------

    // static long EVP_DigestSignInit(
    //         NativeRef.EVP_MD_CTX ctx, long evpMdRef, NativeRef.EVP_PKEY key);

    // static long EVP_DigestVerifyInit(
    //         NativeRef.EVP_MD_CTX ctx, long evpMdRef, NativeRef.EVP_PKEY key);

    // static void EVP_DigestSignUpdate(
    //         NativeRef.EVP_MD_CTX ctx, byte[] buffer, int offset, int length);

    // static void EVP_DigestSignUpdateDirect(NativeRef.EVP_MD_CTX ctx, long ptr, int length);

    // static void EVP_DigestVerifyUpdate(
    //         NativeRef.EVP_MD_CTX ctx, byte[] buffer, int offset, int length);

    // static void EVP_DigestVerifyUpdateDirect(NativeRef.EVP_MD_CTX ctx, long ptr, int length);

    // static byte[] EVP_DigestSignFinal(NativeRef.EVP_MD_CTX ctx);

    // static bool EVP_DigestVerifyFinal(NativeRef.EVP_MD_CTX ctx, byte[] signature,
    //         int offset, int length) throws IndexOutOfBoundsException;

    // static long EVP_PKEY_encrypt_init(NativeRef.EVP_PKEY pkey) throws InvalidKeyException;

    // static int EVP_PKEY_encrypt(NativeRef.EVP_PKEY_CTX ctx, byte[] out, int outOffset,
    //         byte[] input, int inOffset, int inLength)
    //         throws IndexOutOfBoundsException, BadPaddingException;

    // static long EVP_PKEY_decrypt_init(NativeRef.EVP_PKEY pkey) throws InvalidKeyException;

    // static int EVP_PKEY_decrypt(NativeRef.EVP_PKEY_CTX ctx, byte[] out, int outOffset,
    //         byte[] input, int inOffset, int inLength)
    //         throws IndexOutOfBoundsException, BadPaddingException;

    // static void EVP_PKEY_CTX_free(long pkeyCtx);

    // static void EVP_PKEY_CTX_set_rsa_padding(long ctx, int pad)
    //         throws InvalidAlgorithmParameterException;

    // static void EVP_PKEY_CTX_set_rsa_pss_saltlen(long ctx, int len)
    //         throws InvalidAlgorithmParameterException;

    // static void EVP_PKEY_CTX_set_rsa_mgf1_md(long ctx, long evpMdRef)
    //         throws InvalidAlgorithmParameterException;

    // static void EVP_PKEY_CTX_set_rsa_oaep_md(long ctx, long evpMdRef)
    //         throws InvalidAlgorithmParameterException;

    // static void EVP_PKEY_CTX_set_rsa_oaep_label(long ctx, byte[] label)
    //         throws InvalidAlgorithmParameterException;

    // // --- Block ciphers -------------------------------------------------------

    // // These return const references
    // static long EVP_get_cipherbyname(string string);

    // static void EVP_CipherInit_ex(NativeRef.EVP_CIPHER_CTX ctx, long evpCipher, byte[] key,
    //         byte[] iv, bool encrypting);

    // static int EVP_CipherUpdate(NativeRef.EVP_CIPHER_CTX ctx, byte[] out, int outOffset,
    //         byte[] in, int inOffset, int inLength) throws IndexOutOfBoundsException;

    // static int EVP_CipherFinal_ex(NativeRef.EVP_CIPHER_CTX ctx, byte[] out, int outOffset)
    //         throws BadPaddingException, IllegalBlockSizeException;

    // static int EVP_CIPHER_iv_length(long evpCipher);

    // static long EVP_CIPHER_CTX_new();

    // static int EVP_CIPHER_CTX_block_size(NativeRef.EVP_CIPHER_CTX ctx);

    // static int get_EVP_CIPHER_CTX_buf_len(NativeRef.EVP_CIPHER_CTX ctx);

    // static bool get_EVP_CIPHER_CTX_final_used(NativeRef.EVP_CIPHER_CTX ctx);

    // static void EVP_CIPHER_CTX_set_padding(
    //         NativeRef.EVP_CIPHER_CTX ctx, bool enablePadding);

    // static void EVP_CIPHER_CTX_set_key_length(NativeRef.EVP_CIPHER_CTX ctx, int keyBitSize);

    // static void EVP_CIPHER_CTX_free(long ctx);

    // // --- AEAD ----------------------------------------------------------------
    // static long EVP_aead_aes_128_gcm();

    // static long EVP_aead_aes_256_gcm();

    // static long EVP_aead_chacha20_poly1305();

    // static int EVP_AEAD_max_overhead(long evpAead);

    // static int EVP_AEAD_nonce_length(long evpAead);

    // static int EVP_AEAD_CTX_seal(long evpAead, byte[] key, int tagLengthInBytes, byte[] out,
    //         int outOffset, byte[] nonce, byte[] in, int inOffset, int inLength, byte[] ad)
    //         throws ShortBufferException, BadPaddingException, IndexOutOfBoundsException;

    // static int EVP_AEAD_CTX_open(long evpAead, byte[] key, int tagLengthInBytes, byte[] out,
    //         int outOffset, byte[] nonce, byte[] in, int inOffset, int inLength, byte[] ad)
    //         throws ShortBufferException, BadPaddingException, IndexOutOfBoundsException;

    // // --- HMAC functions ------------------------------------------------------

    // static long HMAC_CTX_new();

    // static void HMAC_CTX_free(long ctx);

    // static void HMAC_Init_ex(NativeRef.HMAC_CTX ctx, byte[] key, long evp_md);

    // static void HMAC_Update(NativeRef.HMAC_CTX ctx, byte[] in, int inOffset, int inLength);

    // static void HMAC_UpdateDirect(NativeRef.HMAC_CTX ctx, long inPtr, int inLength);

    // static byte[] HMAC_Final(NativeRef.HMAC_CTX ctx);

    // // --- RAND ----------------------------------------------------------------

    // static void RAND_bytes(byte[] output);

    // // --- X509_NAME -----------------------------------------------------------

    // static int X509_NAME_hash(X500Principal principal) {
    //     return X509_NAME_hash(principal, "SHA1");
    // }

    // public static int X509_NAME_hash_old(X500Principal principal) {
    //     return X509_NAME_hash(principal, "MD5");
    // }
    // private static int X509_NAME_hash(X500Principal principal, string algorithm) {
    //     try {
    //         byte[] digest = MessageDigest.getInstance(algorithm).digest(principal.getEncoded());
    //         int offset = 0;
    //         return (((digest[offset++] & 0xff) << 0) | ((digest[offset++] & 0xff) << 8)
    //                 | ((digest[offset++] & 0xff) << 16) | ((digest[offset] & 0xff) << 24));
    //     } catch (NoSuchAlgorithmException e) {
    //         throw new AssertionError(e);
    //     }
    // }

    // --- X509 ----------------------------------------------------------------

    /** Used to request get_X509_GENERAL_NAME_stack get the "altname" field. */
    enum int GN_STACK_SUBJECT_ALT_NAME = 1;

    /**
     * Used to request get_X509_GENERAL_NAME_stack get the issuerAlternativeName
     * extension.
     */
    enum int GN_STACK_ISSUER_ALT_NAME = 2;

    /**
     * Used to request only non-critical types in get_X509*_ext_oids.
     */
    enum int EXTENSION_TYPE_NON_CRITICAL = 0;

    /**
     * Used to request only critical types in get_X509*_ext_oids.
     */
    enum int EXTENSION_TYPE_CRITICAL = 1;

    // static long d2i_X509_bio(long bioCtx);

    // static long d2i_X509(byte[] encoded) throws ParsingException;

    // static long PEM_read_bio_X509(long bioCtx);

    // static byte[] i2d_X509(long x509ctx, OpenSSLX509Certificate holder);

    // /** Takes an X509 context not an X509_PUBKEY context. */
    // static byte[] i2d_X509_PUBKEY(long x509ctx, OpenSSLX509Certificate holder);

    // static byte[] ASN1_seq_pack_X509(long[] x509CertRefs);

    // static long[] ASN1_seq_unpack_X509_bio(long bioRef) throws ParsingException;

    // static void X509_free(long x509ctx, OpenSSLX509Certificate holder);

    // static long X509_dup(long x509ctx, OpenSSLX509Certificate holder);

    // static int X509_cmp(long x509ctx1, OpenSSLX509Certificate holder, long x509ctx2, OpenSSLX509Certificate holder2);

    // static void X509_print_ex(long bioCtx, long x509ctx, OpenSSLX509Certificate holder, long nmflag, long certflag);

    // static byte[] X509_get_issuer_name(long x509ctx, OpenSSLX509Certificate holder);

    // static byte[] X509_get_subject_name(long x509ctx, OpenSSLX509Certificate holder);

    // static string get_X509_sig_alg_oid(long x509ctx, OpenSSLX509Certificate holder);

    // static byte[] get_X509_sig_alg_parameter(long x509ctx, OpenSSLX509Certificate holder);

    // static bool[] get_X509_issuerUID(long x509ctx, OpenSSLX509Certificate holder);

    // static bool[] get_X509_subjectUID(long x509ctx, OpenSSLX509Certificate holder);

    // static long X509_get_pubkey(long x509ctx, OpenSSLX509Certificate holder)
    //         throws NoSuchAlgorithmException, InvalidKeyException;

    // static string get_X509_pubkey_oid(long x509ctx, OpenSSLX509Certificate holder);

    // static byte[] X509_get_ext_oid(long x509ctx, OpenSSLX509Certificate holder, string oid);

    // static string[] get_X509_ext_oids(long x509ctx, OpenSSLX509Certificate holder, int critical);

    // static Object[][] get_X509_GENERAL_NAME_stack(long x509ctx, OpenSSLX509Certificate holder, int type)
    //         throws CertificateParsingException;

    // static bool[] get_X509_ex_kusage(long x509ctx, OpenSSLX509Certificate holder);

    // static string[] get_X509_ex_xkusage(long x509ctx, OpenSSLX509Certificate holder);

    // static int get_X509_ex_pathlen(long x509ctx, OpenSSLX509Certificate holder);

    // static long X509_get_notBefore(long x509ctx, OpenSSLX509Certificate holder);

    // static long X509_get_notAfter(long x509ctx, OpenSSLX509Certificate holder);

    // static long X509_get_version(long x509ctx, OpenSSLX509Certificate holder);

    // static byte[] X509_get_serialNumber(long x509ctx, OpenSSLX509Certificate holder);

    // static void X509_verify(long x509ctx, OpenSSLX509Certificate holder, NativeRef.EVP_PKEY pkeyCtx)
    //         throws BadPaddingException;

    // static byte[] get_X509_cert_info_enc(long x509ctx, OpenSSLX509Certificate holder);

    // static byte[] get_X509_signature(long x509ctx, OpenSSLX509Certificate holder);

    // static int get_X509_ex_flags(long x509ctx, OpenSSLX509Certificate holder);

    // // Used by Android platform TrustedCertificateStore.
    // @SuppressWarnings("unused")
    // static int X509_check_issued(long ctx, OpenSSLX509Certificate holder, long ctx2, OpenSSLX509Certificate holder2);

    // --- PKCS7 ---------------------------------------------------------------

    /** Used as the "which" field in d2i_PKCS7_bio and PEM_read_bio_PKCS7. */
    enum int PKCS7_CERTS = 1;

    /** Used as the "which" field in d2i_PKCS7_bio and PEM_read_bio_PKCS7. */
    enum int PKCS7_CRLS = 2;

    // /** Returns an array of X509 or X509_CRL pointers. */
    // static long[] d2i_PKCS7_bio(long bioCtx, int which) throws ParsingException;

    // /** Returns an array of X509 or X509_CRL pointers. */
    // static byte[] i2d_PKCS7(long[] certs);

    // /** Returns an array of X509 or X509_CRL pointers. */
    // static long[] PEM_read_bio_PKCS7(long bioCtx, int which);

    // // --- X509_CRL ------------------------------------------------------------

    // static long d2i_X509_CRL_bio(long bioCtx);

    // static long PEM_read_bio_X509_CRL(long bioCtx);

    // static byte[] i2d_X509_CRL(long x509CrlCtx, OpenSSLX509CRL holder);

    // static void X509_CRL_free(long x509CrlCtx, OpenSSLX509CRL holder);

    // static void X509_CRL_print(long bioCtx, long x509CrlCtx, OpenSSLX509CRL holder);

    // static string get_X509_CRL_sig_alg_oid(long x509CrlCtx, OpenSSLX509CRL holder);

    // static byte[] get_X509_CRL_sig_alg_parameter(long x509CrlCtx, OpenSSLX509CRL holder);

    // static byte[] X509_CRL_get_issuer_name(long x509CrlCtx, OpenSSLX509CRL holder);

    // /** Returns X509_REVOKED reference that is not duplicated! */
    // static long X509_CRL_get0_by_cert(long x509CrlCtx, OpenSSLX509CRL holder, long x509Ctx, OpenSSLX509Certificate holder2);

    // /** Returns X509_REVOKED reference that is not duplicated! */
    // static long X509_CRL_get0_by_serial(long x509CrlCtx, OpenSSLX509CRL holder, byte[] serial);

    // /** Returns an array of X509_REVOKED that are owned by the caller. */
    // static long[] X509_CRL_get_REVOKED(long x509CrlCtx, OpenSSLX509CRL holder);

    // static string[] get_X509_CRL_ext_oids(long x509Crlctx, OpenSSLX509CRL holder, int critical);

    // static byte[] X509_CRL_get_ext_oid(long x509CrlCtx, OpenSSLX509CRL holder, string oid);

    // static void X509_delete_ext(long x509, OpenSSLX509Certificate holder, string oid);

    // static long X509_CRL_get_version(long x509CrlCtx, OpenSSLX509CRL holder);

    // static long X509_CRL_get_ext(long x509CrlCtx, OpenSSLX509CRL holder, string oid);

    // static byte[] get_X509_CRL_signature(long x509ctx, OpenSSLX509CRL holder);

    // static void X509_CRL_verify(long x509CrlCtx, OpenSSLX509CRL holder, NativeRef.EVP_PKEY pkeyCtx);

    // static byte[] get_X509_CRL_crl_enc(long x509CrlCtx, OpenSSLX509CRL holder);

    // static long X509_CRL_get_lastUpdate(long x509CrlCtx, OpenSSLX509CRL holder);

    // static long X509_CRL_get_nextUpdate(long x509CrlCtx, OpenSSLX509CRL holder);

    // // --- X509_REVOKED --------------------------------------------------------

    // static long X509_REVOKED_dup(long x509RevokedCtx);

    // static byte[] i2d_X509_REVOKED(long x509RevokedCtx);

    // static string[] get_X509_REVOKED_ext_oids(long x509ctx, int critical);

    // static byte[] X509_REVOKED_get_ext_oid(long x509RevokedCtx, string oid);

    // static byte[] X509_REVOKED_get_serialNumber(long x509RevokedCtx);

    // static long X509_REVOKED_get_ext(long x509RevokedCtx, string oid);

    // /** Returns ASN1_TIME reference. */
    // static long get_X509_REVOKED_revocationDate(long x509RevokedCtx);

    // static void X509_REVOKED_print(long bioRef, long x509RevokedCtx);

    // // --- X509_EXTENSION ------------------------------------------------------

    // static int X509_supported_extension(long x509ExtensionRef);

    // // --- ASN1_TIME -----------------------------------------------------------

    // static void ASN1_TIME_to_Calendar(long asn1TimeCtx, Calendar cal) throws ParsingException;

    // // --- ASN1 Encoding -------------------------------------------------------

    // /**
    //  * Allocates and returns an opaque reference to an object that can be used with other
    //  * asn1_read_* functions to read the ASN.1-encoded data in val.  The returned object must
    //  * be freed after use by calling asn1_read_free.
    //  */
    // static long asn1_read_init(byte[] val) ;

    // /**
    //  * Allocates and returns an opaque reference to an object that can be used with other
    //  * asn1_read_* functions to read the ASN.1 sequence pointed to by cbsRef.  The returned
    //  * object must be freed after use by calling asn1_read_free.
    //  */
    // static long asn1_read_sequence(long cbsRef) ;

    // /**
    //  * Returns whether the next object in the given reference is explicitly tagged with the
    //  * given tag number.
    //  */
    // static bool asn1_read_next_tag_is(long cbsRef, int tag) ;

    // /**
    //  * Allocates and returns an opaque reference to an object that can be used with
    //  * other asn1_read_* functions to read the ASN.1 data pointed to by cbsRef.  The returned
    //  * object must be freed after use by calling asn1_read_free.
    //  */
    // static long asn1_read_tagged(long cbsRef) ;

    // /**
    //  * Returns the contents of an ASN.1 octet string from the given reference.
    //  */
    // static byte[] asn1_read_octetstring(long cbsRef) ;

    // /**
    //  * Returns an ASN.1 integer from the given reference.  If the integer doesn't fit
    //  * in a uint64, this method will throw an IOException.
    //  */
    // static long asn1_read_uint64(long cbsRef) ;

    // /**
    //  * Consumes an ASN.1 NULL from the given reference.
    //  */
    // static void asn1_read_null(long cbsRef) ;

    // /**
    //  * Returns an ASN.1 OID in dotted-decimal notation (eg, "1.3.14.3.2.26" for SHA-1) from the
    //  * given reference.
    //  */
    // static string asn1_read_oid(long cbsRef) ;

    // /**
    //  * Returns whether or not the given reference has been read completely.
    //  */
    // static bool asn1_read_is_empty(long cbsRef);

    // /**
    //  * Frees any resources associated with the given reference.  After calling, the reference
    //  * must not be used again.  This may be called with a zero reference, in which case nothing
    //  * will be done.
    //  */
    // static void asn1_read_free(long cbsRef);

    // /**
    //  * Allocates and returns an opaque reference to an object that can be used with other
    //  * asn1_write_* functions to write ASN.1-encoded data.  The returned object must be finalized
    //  * after use by calling either asn1_write_finish or asn1_write_cleanup, and its resources
    //  * must be freed by calling asn1_write_free.
    //  */
    // static long asn1_write_init() ;

    // /**
    //  * Allocates and returns an opaque reference to an object that can be used with other
    //  * asn1_write_* functions to write an ASN.1 sequence into the given reference.  The returned
    //  * reference may only be used until the next call on the parent reference.  The returned
    //  * object must be freed after use by calling asn1_write_free.
    //  */
    // static long asn1_write_sequence(long cbbRef) ;

    // /**
    //  * Allocates and returns an opaque reference to an object that can be used with other
    //  * asn1_write_* functions to write a explicitly-tagged ASN.1 object with the given tag
    //  * into the given reference. The returned reference may only be used until the next
    //  * call on the parent reference.  The returned object must be freed after use by
    //  * calling asn1_write_free.
    //  */
    // static long asn1_write_tag(long cbbRef, int tag) ;

    // /**
    //  * Writes the given data into the given reference as an ASN.1-encoded octet string.
    //  */
    // static void asn1_write_octetstring(long cbbRef, byte[] data) ;

    // /**
    //  * Writes the given value into the given reference as an ASN.1-encoded integer.
    //  */
    // static void asn1_write_uint64(long cbbRef, long value) ;

    // /**
    //  * Writes a NULL value into the given reference.
    //  */
    // static void asn1_write_null(long cbbRef) ;

    // /**
    //  * Writes the given OID (which must be in dotted-decimal notation) into the given reference.
    //  */
    // static void asn1_write_oid(long cbbRef, string oid) ;

    // /**
    //  * Flushes the given reference, invalidating any child references and completing their
    //  * operations.  This must be called if the child references are to be freed before
    //  * asn1_write_finish is called on the ultimate parent.  The child references must still
    //  * be freed.
    //  */
    // static void asn1_write_flush(long cbbRef) ;

    // /**
    //  * Completes any in-progress operations and returns the ASN.1-encoded data.  Either this
    //  * or asn1_write_cleanup must be called on any reference returned from asn1_write_init
    //  * before it is freed.
    //  */
    // static byte[] asn1_write_finish(long cbbRef) ;

    // /**
    //  * Cleans up intermediate state in the given reference.  Either this or asn1_write_finish
    //  * must be called on any reference returned from asn1_write_init before it is freed.
    //  */
    // static void asn1_write_cleanup(long cbbRef);

    // /**
    //  * Frees resources associated with the given reference.  After calling, the reference
    //  * must not be used again.  This may be called with a zero reference, in which case nothing
    //  * will be done.
    //  */
    // static void asn1_write_free(long cbbRef);

    // --- BIO stream creation -------------------------------------------------

    // static long create_BIO_InputStream(OpenSSLBIOInputStream is, bool isFinite);

    // static long create_BIO_OutputStream(OutputStream os);

    static void BIO_free_all(long bioRef)    {
        BIO* bio = to_SSL_BIO(bioRef); // cast(BIO*)(cast(uintptr_t)(bioRef));
        if (bio is null) {
            warning("bio is null");
        }
        else
            deimos.openssl.ssl.BIO_free_all(bio);
    }

    static string[] getSupportedProtocols() {
        return SUPPORTED_PROTOCOLS.dup;
    }

    static void setEnabledProtocols(long ssl_address, string[] protocols) {
        checkEnabledProtocols(protocols);
        // TLS protocol negotiation only allows a min and max version
        // to be set, despite the Java API allowing a sparse set of
        // protocols to be enabled.  Use the lowest contiguous range
        // of protocols provided by the caller, which is what we've
        // done historically.
        string min = null;
        string max = null;
        for (int i = 0; i < SUPPORTED_PROTOCOLS.length; i++) {
            string protocol = SUPPORTED_PROTOCOLS[i];
            if (protocols.contains(protocol)) {
                if (min is null) {
                    min = protocol;
                }
                max = protocol;
            } else if (min != null) {
                break;
            }
        }
        if ((min is null) || (max is null)) {
            throw new IllegalArgumentException("No protocols enabled.");
        }
        SSL_set_protocol_versions(ssl_address, getProtocolConstant(min), getProtocolConstant(max));
    }

    private static int getProtocolConstant(string protocol) {
        if (protocol.equals(SUPPORTED_PROTOCOL_TLSV1)) {
            return NativeConstants.TLS1_VERSION;
        } else if (protocol.equals(SUPPORTED_PROTOCOL_TLSV1_1)) {
            return NativeConstants.TLS1_1_VERSION;
        } else if (protocol.equals(SUPPORTED_PROTOCOL_TLSV1_2)) {
            return NativeConstants.TLS1_2_VERSION;
        } else {
            throw new Exception("Unknown protocol encountered: " ~ protocol);
        }
    }

    static string[] checkEnabledProtocols(string[] protocols) {
        if (protocols is null) {
            throw new IllegalArgumentException("protocols is null");
        }

        foreach (string protocol ; protocols) {
            if (protocol.empty) {
                throw new IllegalArgumentException("protocols contains null");
            }
            if (!protocol.equals(SUPPORTED_PROTOCOL_TLSV1)
                    && !protocol.equals(SUPPORTED_PROTOCOL_TLSV1_1)
                    && !protocol.equals(SUPPORTED_PROTOCOL_TLSV1_2)
                    && !protocol.equals(OBSOLETE_PROTOCOL_SSLV3)) {
                throw new IllegalArgumentException("protocol " ~ protocol ~ " is not supported");
            }
        }
        return protocols;
    }

    static void SSL_set_cipher_lists(long ssl_address, string[] cipherSuites) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }
        if (cipherSuites is null) {
            warning("cipherSuites is null");
            return;
        }
implementationMissing();

        // int length = env.GetArrayLength(cipherSuites);

        // /*
        // * Special case for empty cipher list. This is considered an error by the
        // * SSL_set_cipher_list API, but Java allows this silly configuration.
        // * However, the SSL cipher list is still set even when SSL_set_cipher_list
        // * returns 0 in this case. Just to make sure, we check the resulting cipher
        // * list to make sure it's zero length.
        // */
        // if (length == 0) {
        //     tracef("ssl=%s SSL_set_cipher_lists cipherSuites=empty", ssl);
        //     SSL_set_cipher_list(ssl, "");
        //     ERR_clear_error();
        //     if (sk_SSL_CIPHER_num(SSL_get_ciphers(ssl)) != 0) {
        //         tracef("ssl=%s SSL_set_cipher_lists cipherSuites=empty => error", ssl);
        //         conscrypt::jniutil::throwRuntimeException(
        //                 env, "SSL_set_cipher_list did not update ciphers!");
        //         ERR_clear_error();
        //     }
        //     return;
        // }

        // static const char noSSLv2[] = "!SSLv2";
        // size_t cipherStringLen = strlen(noSSLv2);

        // for (int i = 0; i < length; i++) {
        //     ScopedLocalRef<jstring> cipherSuite(
        //             env, reinterpret_cast<jstring>(env.GetObjectArrayElement(cipherSuites, i)));
        //     ScopedUtfChars c(env, cipherSuite.get());
        //     if (c.c_str() is null) {
        //         return;
        //     }

        //     if (cipherStringLen + 1 < cipherStringLen) {
        //         warning("java/lang/IllegalArgumentException",
        //                                             "Overflow in cipher suite strings");
        //         return;
        //     }
        //     cipherStringLen += 1; /* For the separating colon */

        //     if (cipherStringLen + c.size() < cipherStringLen) {
        //         warning("java/lang/IllegalArgumentException",
        //                                             "Overflow in cipher suite strings");
        //         return;
        //     }
        //     cipherStringLen += c.size();
        // }

        // if (cipherStringLen + 1 < cipherStringLen) {
        //     warning("java/lang/IllegalArgumentException",
        //                                         "Overflow in cipher suite strings");
        //     return;
        // }
        // cipherStringLen += 1; /* For final NUL. */

        // std::unique_ptr<char[]> cipherString(new char[cipherStringLen]);
        // if (cipherString.get() is null) {
        //     conscrypt::jniutil::throwOutOfMemory(env, "Unable to alloc cipher string");
        //     return;
        // }
        // memcpy(cipherString.get(), noSSLv2, strlen(noSSLv2));
        // size_t j = strlen(noSSLv2);

        // for (int i = 0; i < length; i++) {
        //     ScopedLocalRef<jstring> cipherSuite(
        //             env, reinterpret_cast<jstring>(env.GetObjectArrayElement(cipherSuites, i)));
        //     ScopedUtfChars c(env, cipherSuite.get());

        //     cipherString[j++] = ':';
        //     memcpy(&cipherString[j], c.c_str(), c.size());
        //     j += c.size();
        // }

        // cipherString[j++] = 0;
        // if (j != cipherStringLen) {
        //     warning("java/lang/IllegalArgumentException",
        //                                         "Internal error");
        //     return;
        // }

        // tracef("ssl=%s SSL_set_cipher_lists cipherSuites=%s", ssl, cipherString.get());
        // if (!SSL_set_cipher_list(ssl, cipherString.get())) {
        //     ERR_clear_error();
        //     warning("java/lang/IllegalArgumentException",
        //                                         "Illegal cipher suite strings.");
        //     return;
        // }        
    }

    // /**
    //  * Gets the list of cipher suites enabled for the provided {@code SSL} instance.
    //  *
    //  * @return array of {@code SSL_CIPHER} references.
    //  */
    static long[] SSL_get_ciphers(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return null;
        }
implementationMissing();
return null;
        // STACK_OF!(SSL_CIPHER)* cipherStack = deimos.openssl.ssl.SSL_get_ciphers(ssl);
        // size_t count = (cipherStack !is null) ? sk_SSL_CIPHER_num(cipherStack) : 0;
        // long[] ciphers = new long[count];
        // for (size_t i = 0; i < count; i++) {
        //     ciphers[i] = cast(long)(sk_SSL_CIPHER_value(cipherStack, cast(int)i));
        // }
        // return ciphers;        
    }

    static void setEnabledCipherSuites(long ssl_address, string[] cipherSuites) {
        checkEnabledCipherSuites(cipherSuites);

        SSL* ssl = to_SSL(ssl_address);
        string[] opensslSuites;
        for (size_t i = 0; i < cipherSuites.length; i++) {
            string cipherSuite = cipherSuites[i];
            if (cipherSuite.equals(TLS_EMPTY_RENEGOTIATION_INFO_SCSV)) {
                continue;
            }
            if (cipherSuite.equals(TLS_FALLBACK_SCSV)) {
                SSL_set_mode(ssl_address, NativeConstants.SSL_MODE_SEND_FALLBACK_SCSV);
                continue;
            }
            opensslSuites ~= cipherSuiteFromJava(cipherSuite);
            // opensslSuites.add(cipherSuiteFromJava(cipherSuite));
        }
        SSL_set_cipher_lists(ssl_address, opensslSuites);
    }

    static string[] checkEnabledCipherSuites(string[] cipherSuites) {
        if (cipherSuites is null) {
            throw new IllegalArgumentException("cipherSuites is null");
        }
        // makes sure all suites are valid, throwing on error
        for (size_t i = 0; i < cipherSuites.length; i++) {
            if (cipherSuites[i] is null) {
                throw new IllegalArgumentException("cipherSuites[" ~ i.to!string() ~ "] is null");
            }
            if (cipherSuites[i] == TLS_EMPTY_RENEGOTIATION_INFO_SCSV
                    || cipherSuites[i] == TLS_FALLBACK_SCSV ) {
                continue;
            }
            if (SUPPORTED_CIPHER_SUITES_SET.contains(cipherSuites[i])) {
                continue;
            }

            // For backwards compatibility, it's allowed for |cipherSuite| to
            // be an OpenSSL-style cipher-suite name.
            if (SUPPORTED_LEGACY_CIPHER_SUITES_SET.contains(cipherSuites[i])) {
                // TODO log warning about using backward compatability
                continue;
            }
            throw new IllegalArgumentException(
                    "cipherSuite " ~ cipherSuites[i] ~ " is not supported.");
        }
        return cipherSuites;
    }

    static void SSL_set_accept_state(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }
        deimos.openssl.ssl.SSL_set_accept_state(ssl);        
    }

    static void SSL_set_connect_state(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }
        deimos.openssl.ssl.SSL_set_connect_state(ssl);
    }

    // static void SSL_set_verify(long ssl_address, int mode);

    static void SSL_set_session(long ssl_address, long ssl_session_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            warningf("ssl=%s SSL_set_session => exception", ssl);
            return;
        }

        SSL_SESSION* ssl_session = to_SSL_SESSION(ssl_session_address);
        if (ssl_session is null) {
            return;
        }

        int ret = deimos.openssl.ssl.SSL_set_session(ssl, ssl_session);
        if (ret != 1) {
            /*
            * Translate the error, and throw if it turns out to be a real
            * problem.
            */
            int sslErrorCode = deimos.openssl.ssl.SSL_get_error(ssl, ret);
            if (sslErrorCode != SSL_ERROR_ZERO_RETURN) {
                warning("SSL session set");
            }
        }
        tracef("ssl=%s SSL_set_session ssl_session=%s => ret=%d", ssl, ssl_session,
                ret);        
    }

    static void SSL_set_session_creation_enabled(
            long ssl_address, bool creation_enabled){
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }

        if (creation_enabled) {
            deimos.openssl.ssl.SSL_clear_mode(ssl, SSL_MODE_AUTO_RETRY); // SSL_MODE_NO_SESSION_CREATION
        } else {
            deimos.openssl.ssl.SSL_set_mode(ssl, SSL_MODE_AUTO_RETRY);
        }                
    }

    // static bool SSL_session_reused(long ssl_address);

    static void SSL_accept_renegotiations(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }
implementationMissing(false);
        // deimos.openssl.ssl.SSL_set_renegotiate_mode(ssl, ssl_renegotiate_freely);        
    }

    static void SSL_set_tlsext_host_name(long ssl_address, string hostname) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null || hostname.empty) {
            return;
        }

        int ret = cast(int) deimos.openssl.ssl.SSL_set_tlsext_host_name(ssl, cast(char*) toStringz(hostname));
        if (ret != 1) 
            warning("Error setting host name");
        else 
            tracef("ssl=%s SSL_set_tlsext_host_name => ok", ssl);
    }

    static string SSL_get_servername(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return null;
        }
        const(char)* servername = deimos.openssl.ssl.SSL_get_servername(ssl, TLSEXT_NAMETYPE_host_name);
        return cast(string)fromStringz(servername);        
    }

    /**
    * Perform SSL handshake
    */
    // static void SSL_do_handshake(long ssl_address, FileDescriptor fdObject, SSLHandshakeCallbacks shc, int timeoutMillis) {
    //     SSL* ssl = to_SSL(ssl_address);
    //     if (ssl is null) {
    //         return;
    //     }
    //     if (fdObject is null) {
    //         warning("fd is null");
    //         return;
    //     }

    //     if (shc is null) {
    //         warning("sslHandshakeCallbacks is null");
    //         return;
    //     }

    //     NetFd fd(env, fdObject);
    //     if (fd.isClosed()) {
    //         // SocketException thrown by NetFd.isClosed
    //         tracef("ssl=%s SSL_do_handshake fd.isClosed() => exception", ssl);
    //         return;
    //     }

    //     int ret = SSL_set_fd(ssl, fd.get());
    //     tracef("ssl=%s SSL_do_handshake s=%d", ssl, fd.get());

    //     if (ret != 1) {
    //         conscrypt::jniutil::throwSSLExceptionWithSslErrors(env, ssl, SSL_ERROR_NONE,
    //                                                         "Error setting the file descriptor");
    //         tracef("ssl=%s SSL_do_handshake SSL_set_fd => exception", ssl);
    //         return;
    //     }

    //     /*
    //     * Make socket non-blocking, so SSL_connect SSL_read() and SSL_write() don't hang
    //     * forever and we can use select() to find out if the socket is ready.
    //     */
    //     if (!conscrypt::netutil::setBlocking(fd.get(), false)) {
    //         conscrypt::jniutil::throwSSLExceptionStr(env, "Unable to make socket non blocking");
    //         tracef("ssl=%s SSL_do_handshake setBlocking => exception", ssl);
    //         return;
    //     }

    //     AppData* appData = toAppData(ssl);
    //     if (appData is null) {
    //         conscrypt::jniutil::throwSSLExceptionStr(env, "Unable to retrieve application data");
    //         tracef("ssl=%s SSL_do_handshake appData => exception", ssl);
    //         return;
    //     }

    //     ret = 0;
    //     SslError sslError;
    //     while (appData.aliveAndKicking) {
    //         errno = 0;

    //         if (!appData.setCallbackState(env, shc, fdObject)) {
    //             // SocketException thrown by NetFd.isClosed
    //             tracef("ssl=%s SSL_do_handshake setCallbackState => exception", ssl);
    //             return;
    //         }
    //         ret = SSL_do_handshake(ssl);
    //         appData.clearCallbackState();
    //         // cert_verify_callback threw exception
    //         if (env.ExceptionCheck()) {
    //             ERR_clear_error();
    //             tracef("ssl=%s SSL_do_handshake exception => exception", ssl);
    //             return;
    //         }
    //         // success case
    //         if (ret == 1) {
    //             break;
    //         }
    //         // retry case
    //         if (errno == EINTR) {
    //             continue;
    //         }
    //         // error case
    //         sslError.reset(ssl, ret);
    //         tracef(
    //                 "ssl=%s SSL_do_handshake ret=%d errno=%d sslError=%d "
    //                 "timeout_millis=%d",
    //                 ssl, ret, errno, sslError.get(), timeout_millis);

    //         /*
    //         * If SSL_do_handshake doesn't succeed due to the socket being
    //         * either unreadable or unwritable, we use sslSelect to
    //         * wait for it to become ready. If that doesn't happen
    //         * before the specified timeout or an error occurs, we
    //         * cancel the handshake. Otherwise we try the SSL_connect
    //         * again.
    //         */
    //         if (sslError.get() == SSL_ERROR_WANT_READ || sslError.get() == SSL_ERROR_WANT_WRITE) {
    //             appData.waitingThreads++;
    //             int selectResult = sslSelect(env, sslError.get(), fdObject, appData, timeout_millis);

    //             if (selectResult == THROWN_EXCEPTION) {
    //                 // SocketException thrown by NetFd.isClosed
    //                 tracef("ssl=%s SSL_do_handshake sslSelect => exception", ssl);
    //                 return;
    //             }
    //             if (selectResult == -1) {
    //                 conscrypt::jniutil::throwSSLExceptionWithSslErrors(
    //                         env, ssl, SSL_ERROR_SYSCALL, "handshake error",
    //                         conscrypt::jniutil::throwSSLHandshakeExceptionStr);
    //                 tracef("ssl=%s SSL_do_handshake selectResult == -1 => exception",
    //                         ssl);
    //                 return;
    //             }
    //             if (selectResult == 0) {
    //                 conscrypt::jniutil::throwSocketTimeoutException(env, "SSL handshake timed out");
    //                 ERR_clear_error();
    //                 tracef("ssl=%s SSL_do_handshake selectResult == 0 => exception",
    //                         ssl);
    //                 return;
    //             }
    //         } else {
    //             // CONSCRYPT_LOG_ERROR("Unknown error %d during handshake", error);
    //             break;
    //         }
    //     }

    //     // clean error. See SSL_do_handshake(3SSL) man page.
    //     if (ret == 0) {
    //         /*
    //         * The other side closed the socket before the handshake could be
    //         * completed, but everything is within the bounds of the TLS protocol.
    //         * We still might want to find out the real reason of the failure.
    //         */
    //         if (sslError.get() == SSL_ERROR_NONE ||
    //             (sslError.get() == SSL_ERROR_SYSCALL && errno == 0) ||
    //             (sslError.get() == SSL_ERROR_ZERO_RETURN)) {
    //             conscrypt::jniutil::throwSSLHandshakeExceptionStr(env, "Connection closed by peer");
    //         } else {
    //             conscrypt::jniutil::throwSSLExceptionWithSslErrors(
    //                     env, ssl, sslError.release(), "SSL handshake terminated",
    //                     conscrypt::jniutil::throwSSLHandshakeExceptionStr);
    //         }
    //         tracef("ssl=%s SSL_do_handshake clean error => exception", ssl);
    //         return;
    //     }

    //     // unclean error. See SSL_do_handshake(3SSL) man page.
    //     if (ret < 0) {
    //         /*
    //         * Translate the error and throw exception. We are sure it is an error
    //         * at this point.
    //         */
    //         conscrypt::jniutil::throwSSLExceptionWithSslErrors(
    //                 env, ssl, sslError.release(), "SSL handshake aborted",
    //                 conscrypt::jniutil::throwSSLHandshakeExceptionStr);
    //         tracef("ssl=%s SSL_do_handshake unclean error => exception", ssl);
    //         return;
    //     }
    //     tracef("ssl=%s SSL_do_handshake => success", ssl);
    // }

    static string SSL_get_current_cipher(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return null;
        }
        const SSL_CIPHER* cipher = deimos.openssl.ssl.SSL_get_current_cipher(ssl);
        if (cipher is null) {
            tracef("ssl=%s SSL_get_current_cipher cipher => null", ssl);
            return null;
        }
        implementationMissing();
return null;
        // const char* name = SSL_CIPHER_standard_name(cipher);
        // tracef("ssl=%s SSL_get_current_cipher => %s", ssl, name);
        // return env.NewStringUTF(name);        
    }

    static string SSL_get_version(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return null;
        }
        const char* protocol = deimos.openssl.ssl.SSL_get_version(ssl);
        return cast(string)fromStringz(protocol);        
    }

    /**
     * Returns the peer certificate chain.
     */
    static byte[][] SSL_get0_peer_certificates(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return null;
        }
implementationMissing();
return null;
        // const STACK_OF(CRYPTO_BUFFER)* chain = deimos.openssl.ssl.SSL_get0_peer_certificates(ssl);
        // if (chain is null) {
        //     return null;
        // }

        // ScopedLocalRef<jobjectArray> array(env, CryptoBuffersToObjectArray(env, chain));
        // if (array.get() is null) {
        //     return null;
        // }

        // tracef("ssl=%s SSL_get0_peer_certificates => %s", ssl, array.get());
        // return array.release();        
    }

    // /**
    //  * Reads with the SSL_read function from the encrypted data stream
    //  * @return -1 if error or the end of the stream is reached.
    //  */
    // static int SSL_read(long ssl_address, FileDescriptor fd, SSLHandshakeCallbacks shc,
    //         byte[] b, int off, int len, int readTimeoutMillis) ;

    // /**
    //  * Writes with the SSL_write function to the encrypted data stream.
    //  */
    // static void SSL_write(long ssl_address, FileDescriptor fd,
    //         SSLHandshakeCallbacks shc, byte[] b, int off, int len, int writeTimeoutMillis)
    //         ;

    // static void SSL_interrupt(long ssl_address);
    // static void SSL_shutdown(
    //         long ssl_address, FileDescriptor fd, SSLHandshakeCallbacks shc) ;

    static int SSL_get_shutdown(long ssl_address) {
        const SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }

        int status = deimos.openssl.ssl.SSL_get_shutdown(ssl);
        return status;        
    }

    static void SSL_free(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return;
        }

        // AppData* appData = toAppData(ssl);
        // SSL_set_app_data(ssl, null);
        // delete appData;
        implementationMissing(false);
        deimos.openssl.ssl.SSL_free(ssl);        
    }

    static long SSL_get_time(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }

        SSL_SESSION* ssl_session = deimos.openssl.ssl.SSL_get_session(ssl);
        if (ssl_session is null) {
            // BoringSSL does not protect against a NULL session.
            return 0;
        }
        // result must be long, not long or *1000 will overflow
        long result = deimos.openssl.ssl.SSL_SESSION_get_time(ssl_session);
        result *= 1000;  // OpenSSL uses seconds, Java uses milliseconds.
        // NOLINTNEXTLINE(runtime/int)
        return result;        
    }

    static long SSL_set_timeout(long ssl_address, long millis) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }

        SSL_SESSION* ssl_session = deimos.openssl.ssl.SSL_get_session(ssl);
        if (ssl_session is null) {
            // BoringSSL does not protect against a NULL session.
            return 0;
        }

        // Convert to seconds
        static const long INT_MAX_AS_JLONG = cast(long)(int.max);
        uint32_t timeout = cast(uint32_t)(
                max(0, cast(int)(min(INT_MAX_AS_JLONG, millis / 1000))));
        return deimos.openssl.ssl.SSL_set_timeout(ssl_session, timeout);        
    }

    static long SSL_get_timeout(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return 0;
        }

        SSL_SESSION* ssl_session = SSL_get_session(ssl);
        if (ssl_session is null) {
            // BoringSSL does not protect against a NULL session.
            return 0;
        }

        long result = deimos.openssl.ssl.SSL_get_timeout(ssl_session);
        result *= 1000;  // OpenSSL uses seconds, Java uses milliseconds.
        return result;        
    }

    static byte[] SSL_session_id(long ssl_address) {
        SSL* ssl = to_SSL(ssl_address);
        if (ssl is null) {
            return null;
        }

        SSL_SESSION* ssl_session = deimos.openssl.ssl.SSL_get_session(ssl);
        tracef("ssl_session=%s SSL_session_id", ssl_session);
        if (ssl_session is null) {
            return null;
        }

        uint session_id_length;
        const(ubyte)* session_id = deimos.openssl.ssl.SSL_SESSION_get_id(ssl_session, &session_id_length);
        byte[] result = cast(byte[])session_id[0..session_id_length].dup;       
            
        return result;        
    }

    // static byte[] SSL_SESSION_session_id(long sslSessionNativePointer);

    // static long SSL_SESSION_get_time(long sslSessionNativePointer);

    // static long SSL_SESSION_get_timeout(long sslSessionNativePointer);

    // static string SSL_SESSION_get_version(long sslSessionNativePointer);

    // static string SSL_SESSION_cipher(long sslSessionNativePointer);

    // static void SSL_SESSION_up_ref(long sslSessionNativePointer);

    // static void SSL_SESSION_free(long sslSessionNativePointer);

    // static byte[] i2d_SSL_SESSION(long sslSessionNativePointer);

    // static long d2i_SSL_SESSION(byte[] data) ;

}

/**
* A collection of callbacks from the native OpenSSL code that are
 * related to the SSL handshake initiated by SSL_do_handshake.
 */
interface SSLHandshakeCallbacks {
    /**
     * Verify that the certificate chain is trusted.
     *
     * @param certificateChain chain of X.509 certificates in their encoded form
     * @param authMethod auth algorithm name
     *
     * @throws CertificateException if the certificate is untrusted
     */
    void verifyCertificateChain(byte[][] certificateChain, string authMethod);

    /**
     * Called on an SSL client when the server requests (or
     * requires a certificate). The client can respond by using
     * SSL_use_certificate and SSL_use_PrivateKey to set a
     * certificate if has an appropriate one available, similar to
     * how the server provides its certificate.
     *
     * @param keyTypes key types supported by the server,
     * convertible to strings with #keyType
     * @param asn1DerEncodedX500Principals CAs known to the server
     */
    void clientCertificateRequested(byte[] keyTypes, byte[][] asn1DerEncodedX500Principals);

    /**
     * Gets the key to be used in client mode for this connection in Pre-Shared Key (PSK) key
     * exchange.
     *
     * @param identityHint PSK identity hint provided by the server or {@code null} if no hint
     *        provided.
     * @param identity buffer to be populated with PSK identity (NULL-terminated modified UTF-8)
     *        by this method. This identity will be provided to the server.
     * @param key buffer to be populated with key material by this method.
     *
     * @return number of bytes this method stored in the {@code key} buffer or {@code 0} if an
     *         error occurred in which case the handshake will be aborted.
     */
    int clientPSKKeyRequested(string identityHint, byte[] identity, byte[] key);

    /**
     * Gets the key to be used in server mode for this connection in Pre-Shared Key (PSK) key
     * exchange.
     *
     * @param identityHint PSK identity hint provided by this server to the client or
     *        {@code null} if no hint was provided.
     * @param identity PSK identity provided by the client.
     * @param key buffer to be populated with key material by this method.
     *
     * @return number of bytes this method stored in the {@code key} buffer or {@code 0} if an
     *         error occurred in which case the handshake will be aborted.
     */
    int serverPSKKeyRequested(string identityHint, string identity, byte[] key);

    /**
     * Called when SSL state changes. This could be handshake completion.
     */
    
    void onSSLStateChange(int type, int val);

    /**
     * Called when a new session has been established and may be added to the session cache.
     * The callee is responsible for incrementing the reference count on the returned session.
     */
    
    void onNewSessionEstablished(long sslSessionNativePtr);

    /**
     * Called for servers where TLS < 1.3 (TLS 1.3 uses session tickets rather than
     * application session caches).
     *
     * <p/>Looks up the session by ID in the application's session cache. If a valid session
     * is returned, this callback is responsible for incrementing the reference count (and any
     * required synchronization).
     *
     * @param id the ID of the session to find.
     * @return the cached session or {@code 0} if no session was found matching the given ID.
     */
    
    long serverSessionRequested(byte[] id);
}     