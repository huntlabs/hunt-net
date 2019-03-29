module hunt.net.secure.conscrypt.NativeSsl;

version(BoringSSL) {
    version=WithSSL;
} else version(OpenSSL) {
    version=WithSSL;
}
version(WithSSL):

import hunt.net.Exceptions;
import hunt.net.secure.conscrypt.AbstractSessionContext;
import hunt.net.secure.conscrypt.AddressUtils;
import hunt.net.secure.conscrypt.NativeCrypto;
import hunt.net.secure.conscrypt.OpenSSLKey;
import hunt.net.secure.conscrypt.SSLParametersImpl;
import hunt.net.secure.conscrypt.SSLUtils;

import hunt.net.ssl.X509KeyManager;

import hunt.security.cert.X509Certificate;
import hunt.security.key;
import hunt.security.x500.X500Principal;

import hunt.collection;
import hunt.logging;
import hunt.Exceptions;

import std.array;
import std.container.array;

import deimos.openssl.ssl;


/**
 * A utility wrapper that abstracts operations on the underlying native SSL instance.
 */
final class NativeSsl {
    private SSLParametersImpl parameters;
    private SSLHandshakeCallbacks handshakeCallbacks;
    private AliasChooser aliasChooser;
    private PSKCallbacks pskCallbacks;
    private X509Certificate[] localCertificates;
    // private ReadWriteLock lock = new ReentrantReadWriteLock();
    private long ssl;

    private this(long ssl, SSLParametersImpl parameters,
            SSLHandshakeCallbacks handshakeCallbacks, AliasChooser aliasChooser,
            PSKCallbacks pskCallbacks) {
        this.ssl = ssl;
        this.parameters = parameters;
        this.handshakeCallbacks = handshakeCallbacks;
        this.aliasChooser = aliasChooser;
        this.pskCallbacks = pskCallbacks;
    }

    static NativeSsl newInstance(SSLParametersImpl parameters,
            SSLHandshakeCallbacks handshakeCallbacks, 
            AliasChooser chooser,
            PSKCallbacks pskCallbacks) {
        AbstractSessionContext ctx = parameters.getSessionContext();
        long ssl_ctx = ctx.sslCtxNativePointer;

        // NativeCrypto.SSL_CTX_set_ecdh_auto(ssl_ctx);
        // NativeCrypto.SSL_CTX_use_certificate_file(ssl_ctx, "/home/zxp/cert/server.crt");
        // NativeCrypto.SSL_CTX_use_PrivateKey_file(ssl_ctx, "/home/zxp/cert/server.key");
        long ssl = NativeCrypto.SSL_new(ssl_ctx);

        return new NativeSsl(ssl, parameters, handshakeCallbacks, chooser, pskCallbacks);
    }

    BioWrapper newBio() {
        try {
            return new BioWrapper(this);
        } catch (SSLException e) {
            throw new RuntimeException(e);
        }
    }

    void offerToResumeSession(long sslSessionNativePointer) {
        NativeCrypto.SSL_set_session(ssl, sslSessionNativePointer);
    }

    byte[] getSessionId() {
        return NativeCrypto.SSL_session_id(ssl);
    }

    long getTime() {
        return NativeCrypto.SSL_get_time(ssl);
    }

    long getTimeout() {
        return NativeCrypto.SSL_get_timeout(ssl);
    }

    void setTimeout(long millis) {
        NativeCrypto.SSL_set_timeout(ssl, millis);
    }

    string getCipherSuite() {
        return NativeCrypto.cipherSuiteToJava(NativeCrypto.SSL_get_current_cipher(ssl));
    }

    X509Certificate[] getPeerCertificates() {
        ubyte[][] encoded = null;
        version(BoringSSL) encoded = NativeCrypto.SSL_get0_peer_certificates(ssl);

        return encoded is null ? null : SSLUtils.decodeX509CertificateChain(encoded);
    }

    X509Certificate[] getLocalCertificates() {
        return localCertificates;
    }

    byte[] getPeerCertificateOcspData() {
        return NativeCrypto.SSL_get_ocsp_response(ssl);
    }

    // byte[] getTlsUnique() {
    //     return NativeCrypto.SSL_get_tls_unique(ssl);
    // }

    // void setTokenBindingParams(int... params) {
    //     NativeCrypto.SSL_set_token_binding_params(ssl, params);
    // }

    // int getTokenBindingParams() {
    //     return NativeCrypto.SSL_get_token_binding_params(ssl);
    // }

    // byte[] exportKeyingMaterial(string label, byte[] context, int length) {
    //     if (label is null) {
    //         throw new NullPointerException("Label is null");
    //     }
    //     byte[] labelBytes = label.getBytes(Charset.forName("US-ASCII"));
    //     return NativeCrypto.SSL_export_keying_material(ssl, labelBytes, context, length);
    // }

    byte[] getPeerTlsSctData() {
        return NativeCrypto.SSL_get_signed_cert_timestamp_list(ssl);
    }

    /**
     * @see NativeCrypto.SSLHandshakeCallbacks#clientPSKKeyRequested(string, byte[], byte[])
     */
    // @SuppressWarnings("deprecation") // PSKKeyManager is deprecated, but in our own package
    int clientPSKKeyRequested(string identityHint, byte[] identityBytesOut, byte[] key) {

implementationMissing(false);
return 0;
        // PSKKeyManager pskKeyManager = parameters.getPSKKeyManager();
        // if (pskKeyManager is null) {
        //     return 0;
        // }

        // string identity = pskCallbacks.chooseClientPSKIdentity(pskKeyManager, identityHint);
        // // Store identity in NULL-terminated modified UTF-8 representation into ientityBytesOut
        // byte[] identityBytes;
        // if (identity is null) {
        //     identity = "";
        //     identityBytes = EmptyArray.BYTE;
        // } else if (identity.isEmpty()) {
        //     identityBytes = EmptyArray.BYTE;
        // } else {
        //     try {
        //         identityBytes = identity.getBytes("UTF-8");
        //     } catch (UnsupportedEncodingException e) {
        //         throw new RuntimeException("UTF-8 encoding not supported", e);
        //     }
        // }
        // if (identityBytes.length + 1 > identityBytesOut.length) {
        //     // Insufficient space in the output buffer
        //     return 0;
        // }
        // if (identityBytes.length > 0) {
        //     System.arraycopy(identityBytes, 0, identityBytesOut, 0, identityBytes.length);
        // }
        // identityBytesOut[identityBytes.length] = 0;

        // SecretKey secretKey = pskCallbacks.getPSKKey(pskKeyManager, identityHint, identity);
        // byte[] secretKeyBytes = secretKey.getEncoded();
        // if (secretKeyBytes is null) {
        //     return 0;
        // } else if (secretKeyBytes.length > key.length) {
        //     // Insufficient space in the output buffer
        //     return 0;
        // }
        // System.arraycopy(secretKeyBytes, 0, key, 0, secretKeyBytes.length);
        // return secretKeyBytes.length;
    }

    /**
     * @see NativeCrypto.SSLHandshakeCallbacks#serverPSKKeyRequested(string, string, byte[])
     */
    // @SuppressWarnings("deprecation") // PSKKeyManager is deprecated, but in our own package
    int serverPSKKeyRequested(string identityHint, string identity, byte[] key) {

implementationMissing(false);
return 0;
        // PSKKeyManager pskKeyManager = parameters.getPSKKeyManager();
        // if (pskKeyManager is null) {
        //     return 0;
        // }
        // SecretKey secretKey = pskCallbacks.getPSKKey(pskKeyManager, identityHint, identity);
        // byte[] secretKeyBytes = secretKey.getEncoded();
        // if (secretKeyBytes is null) {
        //     return 0;
        // } else if (secretKeyBytes.length > key.length) {
        //     return 0;
        // }
        // System.arraycopy(secretKeyBytes, 0, key, 0, secretKeyBytes.length);
        // return secretKeyBytes.length;
    }

    void chooseClientCertificate(byte[] keyTypeBytes, byte[][] asn1DerEncodedPrincipals) {
        
        implementationMissing(false);
        // Set<string> keyTypesSet = SSLUtils.getSupportedClientKeyTypes(keyTypeBytes);
        // string[] keyTypes = keyTypesSet.toArray(new string[keyTypesSet.size()]);

        // X500Principal[] issuers;
        // if (asn1DerEncodedPrincipals is null) {
        //     issuers = null;
        // } else {
        //     issuers = new X500Principal[asn1DerEncodedPrincipals.length];
        //     for (int i = 0; i < asn1DerEncodedPrincipals.length; i++) {
        //         issuers[i] = new X500Principal(asn1DerEncodedPrincipals[i]);
        //     }
        // }
        // X509KeyManager keyManager = parameters.getX509KeyManager();
        // string name = (keyManager != null)
        //         ? aliasChooser.chooseClientAlias(keyManager, issuers, keyTypes)
        //         : null;
        // setCertificate(name);
    }

    void setCertificate(string name) {
        if (name.empty) {
            warning("The certificate name is empty");
            return;
        }
        tracef("Certificate: %s", name);
        X509KeyManager keyManager = parameters.getX509KeyManager();
        if (keyManager is null) {
            return;
        }
        PrivateKey privateKey = keyManager.getPrivateKey(name);
        if (privateKey is null) {
            return;
        }
        localCertificates = keyManager.getCertificateChain(name);
        if (localCertificates is null) {
            return;
        }
        size_t numLocalCerts = localCertificates.length;
        PublicKey publicKey = (numLocalCerts > 0) ? localCertificates[0].getPublicKey() : null;

        // Encode the local certificates.
        byte[][] encodedLocalCerts = new byte[][numLocalCerts];
        for (size_t i = 0; i < numLocalCerts; ++i) {
            encodedLocalCerts[i] = localCertificates[i].getEncoded();
        }

        // Convert the key so we can access a native reference.
        OpenSSLKey key;
        try {
            key = OpenSSLKey.fromPrivateKeyForTLSStackOnly(privateKey, publicKey);
        } catch (InvalidKeyException e) {
            throw new SSLException(e.msg);
        }

        // Set the local certs and private key.
        version(BoringSSL) NativeCrypto.setLocalCertsAndPrivateKey(ssl, encodedLocalCerts, key.getNativeRef());
        version(OpenSSL) {
            implementationMissing(false);
        }
    }

    string getVersion() {
        return NativeCrypto.SSL_get_version(ssl);
    }

    string getRequestedServerName() {
        return NativeCrypto.SSL_get_servername(ssl);
    }

    byte[] getTlsChannelId() {
        return NativeCrypto.SSL_get_tls_channel_id(ssl);
    }

    void initialize(string hostname, OpenSSLKey channelIdPrivateKey) {
        bool enableSessionCreation = parameters.getEnableSessionCreation();
        if (!enableSessionCreation) {
            NativeCrypto.SSL_set_session_creation_enabled(ssl, false);
        }

        // Allow servers to trigger renegotiation. Some inadvisable server
        // configurations cause them to attempt to renegotiate during
        // certain protocols.
        NativeCrypto.SSL_accept_renegotiations(ssl);

        if (isClient()) {
            NativeCrypto.SSL_set_connect_state(ssl);

            // Configure OCSP and CT extensions for client
            version(BoringSSL) {
                NativeCrypto.SSL_enable_ocsp_stapling(ssl);
                if (parameters.isCTVerificationEnabled(hostname))
                    NativeCrypto.SSL_enable_signed_cert_timestamps(ssl);
            }
        } else {
            NativeCrypto.SSL_set_accept_state(ssl);

            // Configure OCSP for server
            if (parameters.getOCSPResponse() != null) {
                version(BoringSSL) NativeCrypto.SSL_enable_ocsp_stapling(ssl);
            }
        }

        if (parameters.getEnabledProtocols().length == 0 && parameters.isEnabledProtocolsFiltered) {
            throw new SSLHandshakeException("No enabled protocols; "
                    ~ NativeCrypto.OBSOLETE_PROTOCOL_SSLV3
                    ~ " is no longer supported and was filtered from the list");
        }
        NativeCrypto.setEnabledProtocols(ssl, parameters.enabledProtocols);
        NativeCrypto.setEnabledCipherSuites(ssl, parameters.enabledCipherSuites);

        if (parameters.applicationProtocols.length > 0) {
            NativeCrypto.setApplicationProtocols(ssl, isClient(), parameters.applicationProtocols);
        }
        if (!isClient() && parameters.applicationProtocolSelector !is null) {
            NativeCrypto.setApplicationProtocolSelector(ssl, parameters.applicationProtocolSelector);
        }

        // setup server certificates and private keys.
        // clients will receive a call back to request certificates.
        if (!isClient()) {
            Array!string keyTypes;
            foreach (long sslCipherNativePointer ; NativeCrypto.SSL_get_ciphers(ssl)) {
                string keyType = SSLUtils.getServerX509KeyType(sslCipherNativePointer);
                if (!keyType.empty()) 
                    keyTypes.insertBack(keyType);
            }

            X509KeyManager keyManager = parameters.getX509KeyManager();
            if (keyManager !is null) {
                foreach (string keyType ; keyTypes) {
                    try {
                        setCertificate(aliasChooser.chooseServerAlias(keyManager, keyType));
                    } catch (CertificateEncodingException e) {
                        throw new IOException(e.msg);
                    }
                }
            } else {
                warning("keyManager is null");
            }

            NativeCrypto.SSL_set_options(ssl, SSL_OP_CIPHER_SERVER_PREFERENCE);

            if (parameters.sctExtension != null) {
                NativeCrypto.SSL_set_signed_cert_timestamp_list(ssl, parameters.sctExtension);
            }

            if (parameters.ocspResponse != null) {
                NativeCrypto.SSL_set_ocsp_response(ssl, parameters.ocspResponse);
            }
        }

// FIXME: Needing refactor or cleanup -@zxp at 8/3/2018, 11:32:59 AM
// 
        // enablePSKKeyManagerIfRequested(); 

        if (parameters.useSessionTickets) {
            NativeCrypto.SSL_clear_options(ssl, SSL_OP_NO_TICKET);
        } else {
            NativeCrypto.SSL_set_options(
                    ssl, NativeCrypto.SSL_get_options(ssl) | SSL_OP_NO_TICKET);
        }

        if (parameters.getUseSni() && AddressUtils.isValidSniHostname(hostname)) {
            NativeCrypto.SSL_set_tlsext_host_name(ssl, hostname);
        }

        // BEAST attack mitigation (1/n-1 record splitting for CBC cipher suites
        // with TLSv1 and SSLv3).
        version(BoringSSL) NativeCrypto.SSL_set_mode(ssl, SSL_MODE_CBC_RECORD_SPLITTING);

        setCertificateValidation();
        setTlsChannelId(channelIdPrivateKey);
    }

    // // TODO(nathanmittler): Remove once after we switch to the engine socket.
    // void doHandshake(FileDescriptor fd, int timeoutMillis)
    //         throws CertificateException, IOException {
    //     lock.readLock().lock();
    //     try {
    //         if (isClosed() || fd is null || !fd.valid()) {
    //             throw new SocketException("Socket is closed");
    //         }
    //         NativeCrypto.SSL_do_handshake(ssl, fd, handshakeCallbacks, timeoutMillis);
    //     } finally {
    //         lock.readLock().unlock();
    //     }
    // }

    int doHandshake() {
        // lock.readLock().lock();
        try {
            return NativeCrypto.ENGINE_SSL_do_handshake(ssl, handshakeCallbacks);
        } finally {
            // lock.readLock().unlock();
        }
    }

    // // TODO(nathanmittler): Remove once after we switch to the engine socket.
    // int read(FileDescriptor fd, byte[] buf, int offset, int len, int timeoutMillis)
    //         {
    //     lock.readLock().lock();
    //     try {
    //         if (isClosed() || fd is null || !fd.valid()) {
    //             throw new SocketException("Socket is closed");
    //         }
    //         return NativeCrypto
    //                 .SSL_read(ssl, fd, handshakeCallbacks, buf, offset, len, timeoutMillis);
    //     } finally {
    //         lock.readLock().unlock();
    //     }
    // }

    // // TODO(nathanmittler): Remove once after we switch to the engine socket.
    // void write(FileDescriptor fd, byte[] buf, int offset, int len, int timeoutMillis)
    //         {
    //     lock.readLock().lock();
    //     try {
    //         if (isClosed() || fd is null || !fd.valid()) {
    //             throw new SocketException("Socket is closed");
    //         }
    //         NativeCrypto
    //                 .SSL_write(ssl, fd, handshakeCallbacks, buf, offset, len, timeoutMillis);
    //     } finally {
    //         lock.readLock().unlock();
    //     }
    // }

    // @SuppressWarnings("deprecation") // PSKKeyManager is deprecated, but in our own package
    // private void enablePSKKeyManagerIfRequested() {
    //     // Enable Pre-Shared Key (PSK) key exchange if requested
    //     PSKKeyManager pskKeyManager = parameters.getPSKKeyManager();
    //     if (pskKeyManager != null) {
    //         bool pskEnabled = false;
    //         for (string enabledCipherSuite : parameters.enabledCipherSuites) {
    //             if ((enabledCipherSuite != null) && (enabledCipherSuite.contains("PSK"))) {
    //                 pskEnabled = true;
    //                 break;
    //             }
    //         }
    //         if (pskEnabled) {
    //             if (isClient()) {
    //                 NativeCrypto.set_SSL_psk_client_callback_enabled(ssl, true);
    //             } else {
    //                 NativeCrypto.set_SSL_psk_server_callback_enabled(ssl, true);
    //                 string identityHint = pskCallbacks.chooseServerPSKIdentityHint(pskKeyManager);
    //                 NativeCrypto.SSL_use_psk_identity_hint(ssl, identityHint);
    //             }
    //         }
    //     }
    // }

    private void setTlsChannelId(OpenSSLKey channelIdPrivateKey) {
        if (!parameters.channelIdEnabled) {
            return;
        }

        if (parameters.getUseClientMode()) {
            // Client-side TLS Channel ID
            if (channelIdPrivateKey is null) {
                throw new SSLHandshakeException("Invalid TLS channel ID key specified");
            }
            NativeCrypto.SSL_set1_tls_channel_id(ssl, channelIdPrivateKey.getNativeRef());
        } else {
            // Server-side TLS Channel ID
            NativeCrypto.SSL_enable_tls_channel_id(ssl);
        }
    }

    private void setCertificateValidation() {
        // setup peer certificate verification
        if (isClient()) 
            return ;

        implementationMissing(false);
        // needing client auth takes priority...
        // bool certRequested;
        // if (parameters.getNeedClientAuth()) {
        //     NativeCrypto.SSL_set_verify(ssl, SSL_VERIFY_PEER
        //                     | SSL_VERIFY_FAIL_IF_NO_PEER_CERT);
        //     certRequested = true;
        //     // ... over just wanting it...
        // } else if (parameters.getWantClientAuth()) {
        //     NativeCrypto.SSL_set_verify(ssl, SSL_VERIFY_PEER);
        //     certRequested = true;
        //     // ... and we must disable verification if we don't want client auth.
        // } else {
        //     NativeCrypto.SSL_set_verify(ssl, SSL_VERIFY_NONE);
        //     certRequested = false;
        // }

        // if (certRequested) {
        //     X509TrustManager trustManager = parameters.getX509TrustManager();
        //     X509Certificate[] issuers = trustManager.getAcceptedIssuers();
        //     if (issuers != null && issuers.length != 0) {
        //         byte[][] issuersBytes;
        //         try {
        //             issuersBytes = SSLUtils.encodeSubjectX509Principals(issuers);
        //         } catch (CertificateEncodingException e) {
        //             throw new SSLException("Problem encoding principals", e);
        //         }
        //         NativeCrypto.SSL_set_client_CA_list(ssl, issuersBytes);
        //     }
        // }
    }

    // void interrupt() {
    //     NativeCrypto.SSL_interrupt(ssl);
    // }

    // // TODO(nathanmittler): Remove once after we switch to the engine socket.
    // void shutdown(FileDescriptor fd) {
    //     NativeCrypto.SSL_shutdown(ssl, fd, handshakeCallbacks);
    // }

    void shutdown() {
        NativeCrypto.ENGINE_SSL_shutdown(ssl, handshakeCallbacks);
    }

    bool wasShutdownReceived() {
        return (NativeCrypto.SSL_get_shutdown(ssl) & SSL_RECEIVED_SHUTDOWN) != 0;
    }

    bool wasShutdownSent() {
        return (NativeCrypto.SSL_get_shutdown(ssl) & SSL_SENT_SHUTDOWN) != 0;
    }

    int readDirectByteBuffer(long destAddress, int destLength) {
        // lock.readLock().lock();
        try {
            return NativeCrypto.ENGINE_SSL_read_direct(
                    ssl, destAddress, destLength, handshakeCallbacks);
        } finally {
            // lock.readLock().unlock();
        }
    }

    int writeDirectByteBuffer(long sourceAddress, int sourceLength) {
        // lock.readLock().lock();
        try {
            return NativeCrypto.ENGINE_SSL_write_direct(
                    ssl, sourceAddress, sourceLength, handshakeCallbacks);
        } finally {
            // lock.readLock().unlock();
        }
    }

    // void forceRead() {
    //     lock.readLock().lock();
    //     try {
    //         NativeCrypto.ENGINE_SSL_force_read(ssl, handshakeCallbacks);
    //     } finally {
    //         lock.readLock().unlock();
    //     }
    // }

    int getPendingReadableBytes() {
        return NativeCrypto.SSL_pending_readable_bytes(ssl);
    }

    int getMaxSealOverhead() {
        version(BoringSSL) return NativeCrypto.SSL_max_seal_overhead(ssl);
        version(OpenSSL) {
            implementationMissing(false);
            return 0;
        }
    }

    void close() {
        // lock.writeLock().lock();
        try {
            if (!isClosed()) {
                long toFree = ssl;
                ssl = 0L;
                NativeCrypto.SSL_free(toFree);
            }
        } finally {
            // lock.writeLock().unlock();
        }
    }

    bool isClosed() {
        return ssl == 0L;
    }

    int getError(int result) {
        return NativeCrypto.SSL_get_error(ssl, result);
    }

    byte[] getApplicationProtocol() {
        return NativeCrypto.getApplicationProtocol(ssl);
    }

    private bool isClient() {
        return parameters.getUseClientMode();
    }

    // protected void finalize() {
    //     try {
    //         close();
    //     } finally {
    //         // super.finalize();
    //     }
    // }
}


/**
* A utility wrapper that abstracts operations on the underlying native BIO instance.
*/
class BioWrapper {
    private long bio;
    private NativeSsl nativeSsl;

    private this(NativeSsl nativeSsl) {
        this.nativeSsl = nativeSsl;
        this.bio = NativeCrypto.SSL_BIO_new(nativeSsl.ssl);
    }

    int getPendingWrittenBytes() {
        if (bio != 0) {
            return NativeCrypto.SSL_pending_written_bytes_in_BIO(bio);
        } else {
            return 0;
        }
    }

    int writeDirectByteBuffer(long address, int length) {
        return NativeCrypto.ENGINE_SSL_write_BIO_direct(
                nativeSsl.ssl, bio, address, length, nativeSsl.handshakeCallbacks);
    }

    int readDirectByteBuffer(long destAddress, int destLength) {
        return NativeCrypto.ENGINE_SSL_read_BIO_direct(
                nativeSsl.ssl, bio, destAddress, destLength, nativeSsl.handshakeCallbacks);
    }

    void close() {
        long toFree = bio;
        bio = 0L;
        NativeCrypto.BIO_free_all(toFree);
    }
}