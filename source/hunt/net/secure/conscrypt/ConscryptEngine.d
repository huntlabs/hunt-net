module hunt.net.secure.conscrypt.ConscryptEngine;

version(BoringSSL) {
    version=WithSSL;
} else version(OpenSSL) {
    version=WithSSL;
}
version(WithSSL):

import hunt.net.secure.conscrypt.ApplicationProtocolSelectorAdapter;
import hunt.net.secure.conscrypt.ApplicationProtocolSelector;
import hunt.net.secure.conscrypt.AbstractConscryptEngine;
import hunt.net.secure.conscrypt.AbstractSessionContext;
import hunt.net.secure.conscrypt.ActiveSession;
import hunt.net.secure.conscrypt.AllocatedBuffer;
import hunt.net.secure.conscrypt.ClientSessionContext;
import hunt.net.secure.conscrypt.ConscryptSession;
import hunt.net.secure.conscrypt.common;
import hunt.net.secure.conscrypt.NativeCrypto;
import hunt.net.secure.conscrypt.NativeSsl;
import hunt.net.secure.conscrypt.NativeSslSession;
import hunt.net.secure.conscrypt.OpenSSLKey;
import hunt.net.secure.conscrypt.PeerInfoProvider;
import hunt.net.secure.conscrypt.SessionSnapshot;
import hunt.net.secure.conscrypt.SSLParametersImpl;
import hunt.net.secure.conscrypt.SSLNullSession;
import hunt.net.secure.conscrypt.SSLUtils;


import hunt.net.ssl.KeyManager;
import hunt.net.ssl.X509KeyManager;
import hunt.net.ssl.X509TrustManager;

import hunt.security.key;
import hunt.security.cert.X509Certificate;
import hunt.security.x500.X500Principal;

import hunt.collection;
import hunt.net.Exceptions;

import hunt.net.ssl.SSLEngine;
import hunt.net.ssl.SSLEngineResult;
import hunt.net.ssl.SSLSession;

import hunt.security.key;

import hunt.Exceptions;
import hunt.text.Common;

import hunt.logging;

import deimos.openssl.ssl;

import std.algorithm;
import std.conv;
import std.format;

/**
 * Implements the {@link SSLEngine} API using OpenSSL's non-blocking interfaces.
,
                                                         SSLParametersImpl.AliasChooser,
                                                         SSLParametersImpl.PSKCallbacks  
 */
final class ConscryptEngine : AbstractConscryptEngine , SSLHandshakeCallbacks, AliasChooser, PSKCallbacks {
    private __gshared static SSLEngineResult NEED_UNWRAP_OK;
    private __gshared static SSLEngineResult NEED_UNWRAP_CLOSED;
    private __gshared static SSLEngineResult NEED_WRAP_OK;
    private __gshared static SSLEngineResult NEED_WRAP_CLOSED;
    private __gshared static SSLEngineResult CLOSED_NOT_HANDSHAKING;
    
    shared static this()
    {
        NEED_UNWRAP_OK = new SSLEngineResult(SSLEngineResult.Status.OK, HandshakeStatus.NEED_UNWRAP, 0, 0);
        NEED_UNWRAP_CLOSED = new SSLEngineResult(SSLEngineResult.Status.CLOSED, HandshakeStatus.NEED_UNWRAP, 0, 0);
        NEED_WRAP_OK = new SSLEngineResult(SSLEngineResult.Status.OK, HandshakeStatus.NEED_WRAP, 0, 0);
        NEED_WRAP_CLOSED = new SSLEngineResult(SSLEngineResult.Status.CLOSED, HandshakeStatus.NEED_WRAP, 0, 0);
        CLOSED_NOT_HANDSHAKING = new SSLEngineResult(SSLEngineResult.Status.CLOSED, HandshakeStatus.NOT_HANDSHAKING, 0, 0);
        EMPTY = new HeapByteBuffer(0, 0); // ByteBuffer.allocateDirect(0);
    }
    private __gshared static ByteBuffer EMPTY;

    private static BufferAllocator defaultBufferAllocator = null;

    private SSLParametersImpl sslParameters;
    private BufferAllocator bufferAllocator;

    /**
     * A lazy-created direct buffer used as a bridge between heap buffers provided by the
     * application and JNI. This avoids the overhead of calling JNI with heap buffers.
     * Used only when no {@link #bufferAllocator} has been provided.
     */
    private ByteBuffer lazyDirectBuffer;

    /**
     * Hostname used with the TLS extension SNI hostname.
     */
    private string peerHostname;

    // @GuardedBy("ssl");
    private int state = EngineStates.STATE_NEW;
    private bool handshakeFinished;

    /**
     * Wrapper around the underlying SSL object.
     */
    private NativeSsl ssl;

    /**
     * The BIO used for reading/writing encrypted bytes.
     */
    // @GuardedBy("ssl");
    private BioWrapper networkBio;

    /**
     * Set during startHandshake.
     */
    private ActiveSession activeSession;

    /**
     * A snapshot of the active session when the engine was closed.
     */
    private SessionSnapshot closedSession;

    /**
     * The session object exposed externally from this class.
     */
    private SSLSession externalSession;

    /**
     * Private key for the TLS Channel ID extension. This field is client-side only. Set during
     * startHandshake.
     */
    private OpenSSLKey channelIdPrivateKey;

    private int _maxSealOverhead;

    private HandshakeListener handshakeListener;

    private ByteBuffer[] singleSrcBuffer;
    private ByteBuffer[] singleDstBuffer;
    private PeerInfoProvider peerInfoProvider;

    private SSLException handshakeException;

    this(SSLParametersImpl sslParameters) {
        this.sslParameters = sslParameters;
        peerInfoProvider = PeerInfoProvider.nullProvider();
        this.ssl = newSsl(sslParameters, this);
        singleSrcBuffer = new ByteBuffer[1];
        singleDstBuffer = new ByteBuffer[1];
        bufferAllocator = defaultBufferAllocator;
        this.networkBio = ssl.newBio();
        activeSession = new ActiveSession(ssl, sslParameters.getSessionContext());
        externalSession = this.provideSession();

        // externalSession = Platform.wrapSSLSession(new ExternalSession(new Provider() {
        //     override
        //     ConscryptSession provideSession() {
        //         return ConscryptEngine.this.provideSession();
        //     }
        // }));
    }

    // this(string host, int port, SSLParametersImpl sslParameters) {
    //     this.sslParameters = sslParameters;
    //     this.peerInfoProvider = PeerInfoProvider.forHostAndPort(host, port);
    //     this.ssl = newSsl(sslParameters, this);
    //     this.networkBio = ssl.newBio();
    //     activeSession = new ActiveSession(ssl, sslParameters.getSessionContext());
    // }

    // this(SSLParametersImpl sslParameters, PeerInfoProvider peerInfoProvider) {
    //     this.sslParameters = sslParameters;
    //     this.peerInfoProvider = checkNotNull(peerInfoProvider, "peerInfoProvider");
    //     this.ssl = newSsl(sslParameters, this);
    //     this.networkBio = ssl.newBio();
    //     activeSession = new ActiveSession(ssl, sslParameters.getSessionContext());
    // }

    private static NativeSsl newSsl(SSLParametersImpl sslParameters, ConscryptEngine engine) {
        try {
            return NativeSsl.newInstance(sslParameters, engine, engine, engine);
        } catch (SSLException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Configures the default {@link BufferAllocator} to be used by all future
     * {@link SSLEngine} instances from this provider.
     */
    static void setDefaultBufferAllocator(BufferAllocator bufferAllocator) {
        defaultBufferAllocator = bufferAllocator;
    }

    override
    void setBufferAllocator(BufferAllocator bufferAllocator) {
        synchronized (ssl) {
            if (isHandshakeStarted()) {
                throw new IllegalStateException(
                        "Could not set buffer allocator after the initial handshake has begun.");
            }
            this.bufferAllocator = bufferAllocator;
        }
    }

    /**
     * Returns the maximum overhead, in bytes, of sealing a record with SSL.
     */
    override
    int maxSealOverhead() {
        return _maxSealOverhead;
    }

    // /**
    //  * Enables/disables TLS Channel ID for this server engine.
    //  *
    //  * <p>This method needs to be invoked before the handshake starts.
    //  *
    //  * @throws IllegalStateException if this is a client engine or if the handshake has already
    //  *         started.
    //  */
    // override
    // void setChannelIdEnabled(bool enabled) {
    //     synchronized (ssl) {
    //         if (getUseClientMode()) {
    //             throw new IllegalStateException("Not allowed in client mode");
    //         }
    //         if (isHandshakeStarted()) {
    //             throw new IllegalStateException(
    //                     "Could not enable/disable Channel ID after the initial handshake has begun.");
    //         }
    //         sslParameters.channelIdEnabled = enabled;
    //     }
    // }

    // /**
    //  * Gets the TLS Channel ID for this server engine. Channel ID is only available once the
    //  * handshake completes.
    //  *
    //  * @return channel ID or {@code null} if not available.
    //  *
    //  * @throws IllegalStateException if this is a client engine or if the handshake has not yet
    //  * completed.
    //  * @throws SSLException if channel ID is available but could not be obtained.
    //  */
    // override
    // byte[] getChannelId() {
    //     synchronized (ssl) {
    //         if (getUseClientMode()) {
    //             throw new IllegalStateException("Not allowed in client mode");
    //         }

    //         if (isHandshakeStarted()) {
    //             throw new IllegalStateException(
    //                     "Channel ID is only available after handshake completes");
    //         }
    //         return ssl.getTlsChannelId();
    //     }
    // }

    /**
     * Sets the {@link PrivateKey} to be used for TLS Channel ID by this client engine.
     *
     * <p>This method needs to be invoked before the handshake starts.
     *
     * @param privateKey private key (enables TLS Channel ID) or {@code null} for no key (disables
     *        TLS Channel ID). The private key must be an Elliptic Curve (EC) key based on the NIST
     *        P-256 curve (aka SECG secp256r1 or ANSI X9.62 prime256v1).
     *
     * @throws IllegalStateException if this is a server engine or if the handshake has already
     *         started.
     */
    override
    void setChannelIdPrivateKey(PrivateKey privateKey) {
        implementationMissing(false);
        // if (!getUseClientMode()) {
        //     throw new IllegalStateException("Not allowed in server mode");
        // }

        // synchronized (ssl) {
        //     if (isHandshakeStarted()) {
        //         throw new IllegalStateException("Could not change Channel ID private key "
        //                 + "after the initial handshake has begun.");
        //     }

        //     if (privateKey == null) {
        //         sslParameters.channelIdEnabled = false;
        //         channelIdPrivateKey = null;
        //         return;
        //     }

        //     sslParameters.channelIdEnabled = true;
        //     try {
        //         ECParameterSpec ecParams = null;
        //         if (privateKey instanceof ECKey) {
        //             ecParams = ((ECKey) privateKey).getParams();
        //         }
        //         if (ecParams == null) {
        //             // Assume this is a P-256 key, as specified in the contract of this method.
        //             ecParams =
        //                     OpenSSLECGroupContext.getCurveByName("prime256v1").getECParameterSpec();
        //         }
        //         channelIdPrivateKey =
        //                 OpenSSLKey.fromECPrivateKeyForTLSStackOnly(privateKey, ecParams);
        //     } catch (InvalidKeyException e) {
        //         // Will have error in startHandshake
        //     }
        // }
    }

    /**
     * Sets the listener for the completion of the TLS handshake.
     */
    override
    void setHandshakeListener(HandshakeListener handshakeListener) {
        synchronized (ssl) {
            if (isHandshakeStarted()) {
                throw new IllegalStateException(
                        "Handshake listener must be set before starting the handshake.");
            }
            this.handshakeListener = handshakeListener;
        }
    }

    private bool isHandshakeStarted() {
        switch (state) {
            case EngineStates.STATE_NEW:
            case EngineStates.STATE_MODE_SET:
                return false;
            default:
                return true;
        }
    }

    /**
     * This method enables Server Name Indication (SNI) and overrides the {@link PeerInfoProvider}
     * supplied during engine creation.  If the hostname is not a valid SNI hostname, the SNI
     * extension will be omitted from the handshake.
     */
    override
    void setHostname(string hostname) {
        sslParameters.setUseSni(hostname !is null);
        this.peerHostname = hostname;
    }

    /**
     * Returns the hostname from {@link #setHostname(string)} or supplied by the
     * {@link PeerInfoProvider} upon creation. No DNS resolution is attempted before
     * returning the hostname.
     */
    override
    string getHostname() {
        return peerHostname !is null ? peerHostname : peerInfoProvider.getHostname();
    }

    override
    string getPeerHost() {
        return peerHostname !is null ? peerHostname : peerInfoProvider.getHostnameOrIP();
    }

    override
    int getPeerPort() {
        return peerInfoProvider.getPort();
    }

    override
    void beginHandshake() {
        synchronized (ssl) {
            beginHandshakeInternal();
        }
    }

    private void beginHandshakeInternal() {
        switch (state) {
            case EngineStates.STATE_NEW: {
                throw new IllegalStateException("Client/server mode must be set before handshake");
            }
            case EngineStates.STATE_MODE_SET: {
                // We know what mode to handshake in but have not started the handshake, proceed
                break;
            }
            case EngineStates.STATE_CLOSED_INBOUND:
            case EngineStates.STATE_CLOSED_OUTBOUND:
            case EngineStates.STATE_CLOSED:
                throw new IllegalStateException("Engine has already been closed");
            default:
                // We've already started the handshake, just return
                return;
        }

        transitionTo(EngineStates.STATE_HANDSHAKE_STARTED);

        bool releaseResources = true;
        try {
            // Prepare the SSL object for the handshake.
            ssl.initialize(getHostname(), channelIdPrivateKey);

            // For clients, offer to resume a previously cached session to avoid the
            // full TLS handshake.
            if (getUseClientMode()) {
                NativeSslSession cachedSession = clientSessionContext().getCachedSession(
                        getHostname(), getPeerPort(), sslParameters);
                if (cachedSession !is null) {
                    cachedSession.offerToResume(ssl);
                }
            }

            _maxSealOverhead = ssl.getMaxSealOverhead();
            handshake();
            releaseResources = false;
        } catch (IOException e) {
            // Write CCS errors to EventLog
            string message = e.msg;
            // Must match error reason string of SSL_R_UNEXPECTED_CCS (in ssl/ssl_err.c)
            if (message.canFind("unexpected CCS")) {
                errorf("ssl_unexpected_ccs: host=%s", getPeerHost());
            }
            throw SSLUtils.toSSLHandshakeException(e);
        } finally {
            if (releaseResources) {
                closeAndFreeResources();
            }
        }
    }

    override
    void closeInbound() {
        synchronized (ssl) {
            if (state == EngineStates.STATE_CLOSED || state == EngineStates.STATE_CLOSED_INBOUND) {
                return;
            }
            if (isOutboundDone()) {
                transitionTo(EngineStates.STATE_CLOSED);
            } else {
                transitionTo(EngineStates.STATE_CLOSED_INBOUND);
            }
        }
    }

    override
    void closeOutbound() {
        synchronized (ssl) {
            if (state == EngineStates.STATE_CLOSED || state == EngineStates.STATE_CLOSED_OUTBOUND) {
                return;
            }
            if (isHandshakeStarted()) {
                sendSSLShutdown();
                if (isInboundDone()) {
                    closeAndFreeResources();
                } else {
                    transitionTo(EngineStates.STATE_CLOSED_OUTBOUND);
                }
            } else {
                // Never started the handshake. Just close now.
                closeAndFreeResources();
            }
        }
    }

    // override
    // Runnable getDelegatedTask() {
    //     // This implementation doesn't use any delegated tasks.
    //     return null;
    // }

    override
    string[] getEnabledCipherSuites() {
        return sslParameters.getEnabledCipherSuites();
    }

    override
    string[] getEnabledProtocols() {
        return sslParameters.getEnabledProtocols();
    }

    override
    bool getEnableSessionCreation() {
        return sslParameters.getEnableSessionCreation();
    }

    // override
    // SSLParameters getSSLParameters() {
    //     SSLParameters params = super.getSSLParameters();
    //     Platform.getSSLParameters(params, sslParameters, this);
    //     return params;
    // }

    // override
    // void setSSLParameters(SSLParameters p) {
    //     super.setSSLParameters(p);
    //     Platform.setSSLParameters(p, sslParameters, this);
    // }

    override
    HandshakeStatus getHandshakeStatus() {
        synchronized (ssl) {
            return getHandshakeStatusInternal();
        }
    }

    private HandshakeStatus getHandshakeStatusInternal() {
        if (handshakeFinished) {
            return HandshakeStatus.NOT_HANDSHAKING;
        }
        switch (state) {
            case EngineStates.STATE_HANDSHAKE_STARTED:
                return pendingStatus(pendingOutboundEncryptedBytes());
            case EngineStates.STATE_HANDSHAKE_COMPLETED:
                return HandshakeStatus.NEED_WRAP;
            case EngineStates.STATE_NEW:
            case EngineStates.STATE_MODE_SET:
            case EngineStates.STATE_CLOSED:
            case EngineStates.STATE_CLOSED_INBOUND:
            case EngineStates.STATE_CLOSED_OUTBOUND:
            case EngineStates.STATE_READY:
            case EngineStates.STATE_READY_HANDSHAKE_CUT_THROUGH:
                return HandshakeStatus.NOT_HANDSHAKING;
            default:
                break;
        }
        throw new IllegalStateException("Unexpected engine state: " ~ state.to!string());
    }

    private int pendingOutboundEncryptedBytes() {
        return networkBio.getPendingWrittenBytes();
    }

    private int pendingInboundCleartextBytes() {
        return ssl.getPendingReadableBytes();
    }

    private static HandshakeStatus pendingStatus(int pendingOutboundBytes) {
        // Depending on if there is something left in the BIO we need to WRAP or UNWRAP
        return pendingOutboundBytes > 0 ? HandshakeStatus.NEED_WRAP : HandshakeStatus.NEED_UNWRAP;
    }

    override
    bool getNeedClientAuth() {
        return sslParameters.getNeedClientAuth();
    }

    /**
     * Work-around to allow this method to be called on older versions of Android.
     */
    override
    SSLSession handshakeSession() {
        implementationMissing();
return null;
        // synchronized (ssl) {
        //     if (state == EngineStates.STATE_HANDSHAKE_STARTED) {
        //         return Platform.wrapSSLSession(new ExternalSession(new Provider() {
        //             override
        //             ConscryptSession provideSession() {
        //                 return ConscryptEngine.this.provideHandshakeSession();
        //             }
        //         }));
        //     }
        //     return null;
        // }
    }

    override
    SSLSession getSession() {
        return externalSession;
    }

    private ConscryptSession provideSession() {
        synchronized (ssl) {
            if (state == EngineStates.STATE_CLOSED) {
                return closedSession !is null ? closedSession : SSLNullSession.getNullSession();
            }
            if (state < EngineStates.STATE_HANDSHAKE_COMPLETED) {
                // Return an invalid session with invalid cipher suite of "SSL_NULL_WITH_NULL_NULL"
                return SSLNullSession.getNullSession();
            }
            return activeSession;
        }
    }

    private ConscryptSession provideHandshakeSession() {
        synchronized (ssl) {
            return state == EngineStates.STATE_HANDSHAKE_STARTED ? activeSession
                : SSLNullSession.getNullSession();
        }
    }

    override
    string[] getSupportedCipherSuites() {
        return NativeCrypto.getSupportedCipherSuites();
    }

    override
    string[] getSupportedProtocols() {
        return NativeCrypto.getSupportedProtocols();
    }

    override
    bool getUseClientMode() {
        return sslParameters.getUseClientMode();
    }

    override
    bool getWantClientAuth() {
        return sslParameters.getWantClientAuth();
    }

    override
    bool isInboundDone() {
        synchronized (ssl) {
            return state == EngineStates.STATE_CLOSED || state == EngineStates.STATE_CLOSED_INBOUND
                    || ssl.wasShutdownReceived();
        }
    }

    override
    bool isOutboundDone() {
        synchronized (ssl) {
            return state == EngineStates.STATE_CLOSED || state == EngineStates.STATE_CLOSED_OUTBOUND || ssl.wasShutdownSent();
        }
    }

    override
    void setEnabledCipherSuites(string[] suites) {
        sslParameters.setEnabledCipherSuites(suites);
    }

    override
    void setEnabledProtocols(string[] protocols) {
        sslParameters.setEnabledProtocols(protocols);
    }

    override
    void setEnableSessionCreation(bool flag) {
        sslParameters.setEnableSessionCreation(flag);
    }

    override
    void setNeedClientAuth(bool need) {
        sslParameters.setNeedClientAuth(need);
    }

    override
    void setUseClientMode(bool mode) {
        synchronized (ssl) {
            if (isHandshakeStarted()) {
                throw new IllegalArgumentException(
                        "Can not change mode after handshake: state == " ~ state.to!string());
            }
            transitionTo(EngineStates.STATE_MODE_SET);
            sslParameters.setUseClientMode(mode);
        }
    }

    override
    void setWantClientAuth(bool want) {
        sslParameters.setWantClientAuth(want);
    }

    override
    SSLEngineResult unwrap(ByteBuffer src, ByteBuffer dst) {
        synchronized (ssl) {
            try {
                return unwrap(makeSingleSrcBuffer(src), makeSingleDstBuffer(dst));
            } finally {
                resetSingleSrcBuffer();
                resetSingleDstBuffer();
            }
        }
    }

    override
    SSLEngineResult unwrap(ByteBuffer src, ByteBuffer[] dsts) {
        synchronized (ssl) {
            try {
                return unwrap(makeSingleSrcBuffer(src), dsts);
            } finally {
                resetSingleSrcBuffer();
            }
        }
    }

    override
    SSLEngineResult unwrap(ByteBuffer src, ByteBuffer[] dsts, int offset,
            int length) {
        synchronized (ssl) {
            try {
                return unwrap(makeSingleSrcBuffer(src), 0, 1, dsts, offset, length);
            } finally {
                resetSingleSrcBuffer();
            }
        }
    }

    override
    SSLEngineResult unwrap(ByteBuffer[] srcs, ByteBuffer[] dsts) {
        assert(srcs !is null, "srcs is null");
        assert(dsts !is null, "dsts is null");
        return unwrap(srcs, 0, cast(int)srcs.length, dsts, 0, cast(int)dsts.length);
    }

    override
    SSLEngineResult unwrap(ByteBuffer[] srcs, int srcsOffset, int srcsLength,
            ByteBuffer[] dsts, int dstsOffset, int dstsLength) {
        assert(srcs !is null, "srcs is null");
        assert(dsts !is null, "dsts is null");
        checkPositionIndexes(srcsOffset, srcsOffset + srcsLength, cast(int)srcs.length);
        checkPositionIndexes(dstsOffset, dstsOffset + dstsLength, cast(int)dsts.length);

        // Determine the output capacity.
        int dstLength = calcDstsLength(dsts, dstsOffset, dstsLength);
        int endOffset = dstsOffset + dstsLength;

        int srcsEndOffset = srcsOffset + srcsLength;
        long srcLength = calcSrcsLength(srcs, srcsOffset, srcsEndOffset);

        synchronized (ssl) {
            switch (state) {
                case EngineStates.STATE_MODE_SET:
                    // Begin the handshake implicitly.
                    beginHandshakeInternal();
                    break;
                case EngineStates.STATE_CLOSED_INBOUND:
                case EngineStates.STATE_CLOSED:
                    // If the inbound direction is closed. we can't send anymore.
                    return new SSLEngineResult(SSLEngineResult.Status.CLOSED, getHandshakeStatusInternal(), 0, 0);
                case EngineStates.STATE_NEW:
                    throw new IllegalStateException(
                            "Client/server mode must be set before calling unwrap");
                default:
                    break;
            }

            HandshakeStatus handshakeStatus = HandshakeStatus.NOT_HANDSHAKING;
            if (!handshakeFinished) {
                handshakeStatus = handshake();
                if (handshakeStatus == HandshakeStatus.NEED_WRAP) {
                    return NEED_WRAP_OK;
                }
                if (state == EngineStates.STATE_CLOSED) {
                    return NEED_WRAP_CLOSED;
                }
                // NEED_UNWRAP - just fall through to perform the unwrap.
            }

            // Consume any source data. Skip this if there are unread cleartext data.
            bool noCleartextDataAvailable = pendingInboundCleartextBytes() <= 0;
            int lenRemaining = 0;
            if (srcLength > 0 && noCleartextDataAvailable) {
                if (srcLength < SSL3_RT_HEADER_LENGTH) {
                    // Need to be able to read a full TLS header.
                    return new SSLEngineResult(SSLEngineResult.Status.BUFFER_UNDERFLOW, getHandshakeStatus(), 0, 0);
                }

                int packetLength = SSLUtils.getEncryptedPacketLength(srcs, srcsOffset);
                if (packetLength < 0) {
                    throw new SSLException("Unable to parse TLS packet header");
                }

                if (srcLength < packetLength) {
                    // We either have not enough data to read the packet header or not enough for
                    // reading the whole packet.
                    return new SSLEngineResult(SSLEngineResult.Status.BUFFER_UNDERFLOW, getHandshakeStatus(), 0, 0);
                }

                // Limit the amount of data to be read to a single packet.
                lenRemaining = packetLength;
            } else if (noCleartextDataAvailable) {
                // No pending data and nothing provided as input.  Need more data.
                return new SSLEngineResult(SSLEngineResult.Status.BUFFER_UNDERFLOW, getHandshakeStatus(), 0, 0);
            }

            // Write all of the encrypted source data to the networkBio
            int bytesConsumed = 0;
            if (lenRemaining > 0 && srcsOffset < srcsEndOffset) {
                do {
                    ByteBuffer src = srcs[srcsOffset];
                    int remaining = src.remaining();
                    if (remaining == 0) {
                        // We must skip empty buffers as BIO_write will return 0 if asked to
                        // write something with length 0.
                        srcsOffset++;
                        continue;
                    }
                    // Write the source encrypted data to the networkBio.
                    int written = writeEncryptedData(src, min(lenRemaining, remaining));
                    if (written > 0) {
                        bytesConsumed += written;
                        lenRemaining -= written;
                        if (lenRemaining == 0) {
                            // A whole packet has been consumed.
                            break;
                        }

                        if (written == remaining) {
                            srcsOffset++;
                        } else {
                            // We were not able to write everything into the BIO so break the
                            // write loop as otherwise we will produce an error on the next
                            // write attempt, which will trigger a SSL.clearError() later.
                            break;
                        }
                    } else {
                        // BIO_write returned a negative or zero number, this means we could not
                        // complete the write operation and should retry later.
                        // We ignore BIO_* errors here as we use in memory BIO anyway and will
                        // do another SSL_* call later on in which we will produce an exception
                        // in case of an error
                        NativeCrypto.SSL_clear_error();
                        break;
                    }
                } while (srcsOffset < srcsEndOffset);
            }

            // Now read any available plaintext data.
            int bytesProduced = 0;
            try {
                if (dstLength > 0) {
                    // Write decrypted data to dsts buffers
                    for (int idx = dstsOffset; idx < endOffset; ++idx) {
                        ByteBuffer dst = dsts[idx];
                        if (!dst.hasRemaining()) {
                            continue;
                        }

                // tracef("eeeeee, dst=> %s", dst.toString());
                        int bytesRead = readPlaintextData(dst);
                // tracef("ffffffffff, dst=> %s", dst.toString());
                        if (bytesRead > 0) {
                            bytesProduced += bytesRead;
                            if (dst.hasRemaining()) {
                                // We haven't filled this buffer fully, break out of the loop
                                // and determine the correct response status below.
                                break;
                            }
                        } else {
                            switch (bytesRead) {
                                case -SSL_ERROR_WANT_READ:
                                case -SSL_ERROR_WANT_WRITE: {
                                    return newResult(bytesConsumed, bytesProduced, handshakeStatus);
                                }
                                case -SSL_ERROR_ZERO_RETURN: {
                                    // We received a close_notify from the peer, so mark the
                                    // inbound direction as closed and shut down the SSL object
                                    closeInbound();
                                    sendSSLShutdown();
                                    return new SSLEngineResult(SSLEngineResult.Status.CLOSED,
                                            pendingOutboundEncryptedBytes() > 0
                                                    ? HandshakeStatus.NEED_WRAP : HandshakeStatus.NOT_HANDSHAKING,
                                            bytesConsumed, bytesProduced);
                                }
                                default: {
                                    // Should never get here.
                                    sendSSLShutdown();
                                    throw newSslExceptionWithMessage("SSL_read");
                                }
                            }
                        }
                    }
                } else {
                    // If the capacity of all destination buffers is 0 we need to trigger a SSL_read
                    // anyway to ensure everything is flushed in the BIO pair and so we can detect
                    // it in the pendingInboundCleartextBytes() call.
                    readPlaintextData(EMPTY);
                }
            } catch (SSLException e) {
                if (pendingOutboundEncryptedBytes() > 0) {
                    // We need to flush any pending bytes to the remote endpoint in case
                    // there is an alert that needs to be propagated.
                    if (!handshakeFinished && handshakeException is null) {
                        // Save the handshake exception. We will re-throw during the next
                        // handshake.
                        handshakeException = e;
                    }
                    return new SSLEngineResult(SSLEngineResult.Status.OK, HandshakeStatus.NEED_WRAP, bytesConsumed, bytesProduced);
                }

                // Nothing to write, just shutdown and throw the exception.
                sendSSLShutdown();
                throw convertException(e);
            } catch (InterruptedIOException e) {
                return newResult(bytesConsumed, bytesProduced, handshakeStatus);
            } catch (EOFException e) {
                closeAll();
                throw convertException(e);
            } catch (IOException e) {
                sendSSLShutdown();
                throw convertException(e);
            }

            // There won't be any application data until we're done handshaking.
            // We first check handshakeFinished to eliminate the overhead of extra JNI call if
            // possible.
            int pendingCleartextBytes = handshakeFinished ? pendingInboundCleartextBytes() : 0;
            if (pendingCleartextBytes > 0) {
                // We filled all buffers but there is still some data pending in the BIO buffer,
                // return BUFFER_OVERFLOW.
                return new SSLEngineResult(SSLEngineResult.Status.BUFFER_OVERFLOW,
                        mayFinishHandshake(handshakeStatus == HandshakeStatus.FINISHED
                                        ? handshakeStatus
                                        : getHandshakeStatusInternal()),
                        bytesConsumed, bytesProduced);
            }

            return newResult(bytesConsumed, bytesProduced, handshakeStatus);
        }
    }

    private static int calcDstsLength(ByteBuffer[] dsts, int dstsOffset, int dstsLength) {
        int capacity = 0;
        for (int i = 0; i < dsts.length; i++) {
            ByteBuffer dst = dsts[i];
            assert(dst !is null, format("dsts[%d] is null", i));
            if (dst.isReadOnly()) {
                throw new ReadOnlyBufferException("");
            }
            if (i >= dstsOffset && i < dstsOffset + dstsLength) {
                capacity += dst.remaining();
            }
        }
        return capacity;
    }

    private static long calcSrcsLength(ByteBuffer[] srcs, int srcsOffset, int srcsEndOffset) {
        long len = 0;
        for (int i = srcsOffset; i < srcsEndOffset; i++) {
            ByteBuffer src = srcs[i];
            if (src is null) {
                throw new IllegalArgumentException("srcs[" ~ i.to!string() ~ "] is null");
            }
            len += src.remaining();
        }
        return len;
    }


    // private HandshakeStatus handshake() {
    //     // try {
    //         return doHandshake();
    //     // } catch (Exception e) {
    //     //     throw SSLUtils.toSSLHandshakeException(e);
    //     // }
    // }

    private HandshakeStatus handshake() {
        // Only actually perform the handshake if we haven't already just completed it
        // via BIO operations.
        try {
            // First, check to see if we already have a pending alert that needs to be written.
            if (handshakeException !is null) {
                if (pendingOutboundEncryptedBytes() > 0) {
                    // Need to finish writing the alert to the remote peer.
                    return HandshakeStatus.NEED_WRAP;
                }

                // We've finished writing the alert, just throw the exception.
                SSLException e = handshakeException;
                handshakeException = null;
                throw e;
            }

            int ssl_error_code = ssl.doHandshake();
            switch (ssl_error_code) {
                case SSL_ERROR_WANT_READ:
                    return pendingStatus(pendingOutboundEncryptedBytes());
                case SSL_ERROR_WANT_WRITE: {
                    return HandshakeStatus.NEED_WRAP;
                }
                default: {
                    // SSL_ERROR_NONE.
                }
            }
        } catch (SSLException e) {
            if (pendingOutboundEncryptedBytes() > 0) {
                // Delay throwing the exception since we appear to have an outbound alert
                // that needs to be written to the remote endpoint.
                handshakeException = e;
                return HandshakeStatus.NEED_WRAP;
            }

            // There is no pending alert to write - just shutdown and throw.
            sendSSLShutdown();
            throw e;
        } catch (IOException e) {
            sendSSLShutdown();
            throw e;
        }

        // The handshake has completed successfully...
        version(HUNT_DEBUG) trace("The handshake is completing...");

        // Update the session from the current state of the SSL object.
        activeSession.onPeerCertificateAvailable(getPeerHost(), getPeerPort());

        finishHandshake();
        return HandshakeStatus.FINISHED;
    }

    private void finishHandshake() {
        trace("Handshake finish.");
        handshakeFinished = true;
        // Notify the listener, if provided.
        if (handshakeListener !is null) {
            handshakeListener.onHandshakeFinished();
        }
    }

    /**
     * Write plaintext data to the OpenSSL internal BIO
     *
     * Calling this function with src.remaining == 0 is undefined.
     */
    private int writePlaintextData(ByteBuffer src, int len) {
        try {
            int pos = src.position();
            int sslWrote;
            if (src.isDirect()) {
                sslWrote = writePlaintextDataDirect(src, pos, len);
            } else {
                sslWrote = writePlaintextDataHeap(src, pos, len);
            }
            if (sslWrote > 0) {
                src.position(pos + sslWrote);
            }
            return sslWrote;
        } catch (Exception e) {
            throw convertException(e);
        }
    }

    private int writePlaintextDataDirect(ByteBuffer src, int pos, int len) {
        return ssl.writeDirectByteBuffer(directByteBufferAddress(src, pos), len);
    }

    private int writePlaintextDataHeap(ByteBuffer src, int pos, int len) {
        AllocatedBuffer allocatedBuffer = null;
        try {
            ByteBuffer buffer;
            if (bufferAllocator !is null) {
                allocatedBuffer = bufferAllocator.allocateDirectBuffer(len);
                buffer = allocatedBuffer.nioBuffer();
            } else {
                // We don't have a buffer allocator, but we don't want to send a heap
                // buffer to JNI. So lazy-create a direct buffer that we will use from now
                // on to copy plaintext data.
                buffer = getOrCreateLazyDirectBuffer();
            }

            // Copy the data to the direct buffer.
            int limit = src.limit();
            int bytesToWrite = min(len, buffer.remaining());
            src.limit(pos + bytesToWrite);
            buffer.put(src);
            buffer.flip();
            // Restore the original position and limit.
            src.limit(limit);
            src.position(pos);

            return writePlaintextDataDirect(buffer, 0, bytesToWrite);
        } finally {
            if (allocatedBuffer !is null) {
                // Release the buffer back to the pool.
                allocatedBuffer.release();
            }
        }
    }

    /**
     * Read plaintext data from the OpenSSL internal BIO
     */
    private int readPlaintextData(ByteBuffer dst) {
        try {
            int pos = dst.position();
            int limit = dst.limit();
            int len = min(SSL3_RT_MAX_PACKET_SIZE, limit - pos);
            if (dst.isDirect()) {
                int bytesRead = readPlaintextDataDirect(dst, pos, len);
                if (bytesRead > 0) {
                    dst.position(pos + bytesRead);
                }
                return bytesRead;
            }

            // The heap method updates the dst position automatically.
            return readPlaintextDataHeap(dst, len);
        } catch (CertificateException e) {
            throw convertException(e);
        }
    }

    private int readPlaintextDataDirect(ByteBuffer dst, int pos, int len) {
        return ssl.readDirectByteBuffer(directByteBufferAddress(dst, pos), len);
        // tracef("bbbbbbbbbbb=>%s", dst.toString());
        // int r = ssl.readDirectByteBuffer(directByteBufferAddress(dst, pos), len);
        // byte[] bf = dst.array();
        // if(bf.length>16)
        // tracef("ccccccccccccc=>%s, %(%02X %)", dst.toString(), bf[0..16]);
        // else
        // tracef("ccccccccccccc=>%s, %(%02X %)", dst.toString(), bf[0..$]);

        // return r;
    }

    private int readPlaintextDataHeap(ByteBuffer dst, int len) {
        AllocatedBuffer allocatedBuffer = null;
        try {
            ByteBuffer buffer;
            if (bufferAllocator !is null) {
                allocatedBuffer = bufferAllocator.allocateDirectBuffer(len);
                buffer = allocatedBuffer.nioBuffer();
            } else {
                // We don't have a buffer allocator, but we don't want to send a heap
                // buffer to JNI. So lazy-create a direct buffer that we will use from now
                // on to copy plaintext data.
                buffer = getOrCreateLazyDirectBuffer();
            }

            byte[] bf = buffer.array();
            // if(bf.length>16)
            // tracef("aaaaaaaaa=>%s, %(%02X %)", buffer.toString(), bf[0..16]);
            // else
            // tracef("aaaaaaaaa=>%s, %(%02X %)", buffer.toString(), bf[0..$]);

            // Read the data to the direct buffer.
            int bytesToRead = min(len, buffer.remaining());
            int bytesRead = readPlaintextDataDirect(buffer, 0, bytesToRead);

            // if(bf.length>16)
            //     tracef("ccccccccccccc=>bytesRead=%d, %s, %(%02X %)", bytesRead, buffer.toString(), bf[0..16]);

            if (bytesRead > 0) {
                // Copy the data to the heap buffer.
                buffer.position(bytesRead);
                buffer.flip();
                // tracef("ccccccccc, dst=> %s", dst.toString());
                dst.put(buffer);
                // tracef("ddddddddd, dst=> %s", dst.toString());
            }

            return bytesRead;
        } finally {
            if (allocatedBuffer !is null) {
                // Release the buffer back to the pool.
                allocatedBuffer.release();
            }
        }
    }

    private SSLException convertException(Throwable e) {
        if (typeid(e) == typeid(SSLHandshakeException) || !handshakeFinished) {
            return SSLUtils.toSSLHandshakeException(e);
        }
        return SSLUtils.toSSLException(e);
    }

    /**
     * Write encrypted data to the OpenSSL network BIO.
     */
    private int writeEncryptedData(ByteBuffer src, int len) {
        try {
            int pos = src.position();
            int bytesWritten;
            if (src.isDirect()) {
                bytesWritten = writeEncryptedDataDirect(src, pos, len);
            } else {
                bytesWritten = writeEncryptedDataHeap(src, pos, len);
            }

            if (bytesWritten > 0) {
                src.position(pos + bytesWritten);
            }

            return bytesWritten;
        } catch (Exception e) {
            throw new SSLException("", e);
        }
    }

    private int writeEncryptedDataDirect(ByteBuffer src, int pos, int len) {
        return networkBio.writeDirectByteBuffer(directByteBufferAddress(src, pos), len);
    }

    private int writeEncryptedDataHeap(ByteBuffer src, int pos, int len) {
        AllocatedBuffer allocatedBuffer = null;
        try {
            ByteBuffer buffer;
            if (bufferAllocator !is null) {
                allocatedBuffer = bufferAllocator.allocateDirectBuffer(len);
                buffer = allocatedBuffer.nioBuffer();
            } else {
                // We don't have a buffer allocator, but we don't want to send a heap
                // buffer to JNI. So lazy-create a direct buffer that we will use from now
                // on to copy encrypted packets.
                buffer = getOrCreateLazyDirectBuffer();
            }

            int limit = src.limit();
            int bytesToCopy = min(min(limit - pos, len), buffer.remaining());
            src.limit(pos + bytesToCopy);
            buffer.put(src);
            // Restore the original limit.
            src.limit(limit);

            // Reset the original position on the source buffer.
            src.position(pos);

            int bytesWritten = writeEncryptedDataDirect(buffer, 0, bytesToCopy);

            // Restore the original position.
            src.position(pos);

            return bytesWritten;
        } finally {
            if (allocatedBuffer !is null) {
                // Release the buffer back to the pool.
                allocatedBuffer.release();
            }
        }
    }

    private ByteBuffer getOrCreateLazyDirectBuffer() {
        if (lazyDirectBuffer is null) {
            int capacity = max(SSL3_RT_MAX_PLAIN_LENGTH, SSL3_RT_MAX_PACKET_SIZE);
            lazyDirectBuffer = new HeapByteBuffer(capacity, capacity);
            // lazyDirectBuffer = ByteBuffer.allocateDirect(
            //         max(SSL3_RT_MAX_PLAIN_LENGTH, SSL3_RT_MAX_PACKET_SIZE));
        }
        lazyDirectBuffer.clear();
        return lazyDirectBuffer;
    }

    private long directByteBufferAddress(ByteBuffer directBuffer, int pos) {
        byte[] buffer =  directBuffer.array();
        // tracef("xxxxxxxxxxxxx=>%s, pos=%d", buffer.ptr, pos);
        return cast(long)cast(void*)(buffer.ptr + pos);
    }

    private SSLEngineResult readPendingBytesFromBIO(ByteBuffer dst, int bytesConsumed,
            int bytesProduced, HandshakeStatus status) {
        try {
            // Check to see if the engine wrote data into the network BIO
            int pendingNet = pendingOutboundEncryptedBytes();
            if (pendingNet > 0) {
                // Do we have enough room in dst to write encrypted data?
                int capacity = dst.remaining();
                if (capacity < pendingNet) {
                    return new SSLEngineResult(SSLEngineResult.Status.BUFFER_OVERFLOW,
                            mayFinishHandshake( status == HandshakeStatus.FINISHED ? 
                                status : getHandshakeStatus(pendingNet)),
                            bytesConsumed, bytesProduced);
                }

                // Write the pending data from the network BIO into the dst buffer
                int produced = readEncryptedData(dst, pendingNet);

                if (produced <= 0) {
                    warning("Can't read encrypted data.");
                    // We ignore BIO_* errors here as we use in memory BIO anyway and will do
                    // another SSL_* call later on in which we will produce an exception in
                    // case of an error
                    NativeCrypto.SSL_clear_error();
                } else {
                    bytesProduced += produced;
                    pendingNet -= produced;
                }

                return new SSLEngineResult(getEngineStatus(),
                        mayFinishHandshake( status == HandshakeStatus.FINISHED ? 
                            status : getHandshakeStatus(pendingNet)),
                        bytesConsumed, bytesProduced);
            }
            return null;
        } catch (Exception e) {
            throw convertException(e);
        }
    }

    /**
     * Read encrypted data from the OpenSSL network BIO
     */
    private int readEncryptedData(ByteBuffer dst, int pending) {
        try {
            int bytesRead = 0;
            int pos = dst.position();
            if (dst.remaining() >= pending) {
                int limit = dst.limit();
                int len = min(pending, limit - pos);
                if (dst.isDirect()) {
                    bytesRead = readEncryptedDataDirect(dst, pos, len);
                    // Need to update the position on the dst buffer.
                    if (bytesRead > 0) {
                        dst.position(pos + bytesRead);
                    }
                } else {
                    // The heap method will update the position on the dst buffer automatically.
                    bytesRead = readEncryptedDataHeap(dst, len);
                }
            }

            return bytesRead;
        } catch (Exception e) {
            throw convertException(e);
        }
    }

    private int readEncryptedDataDirect(ByteBuffer dst, int pos, int len) {
        return networkBio.readDirectByteBuffer(directByteBufferAddress(dst, pos), len);
    }

    private int readEncryptedDataHeap(ByteBuffer dst, int len) {
        AllocatedBuffer allocatedBuffer = null;
        try {
            ByteBuffer buffer;
            if (bufferAllocator !is null) {
                allocatedBuffer = bufferAllocator.allocateDirectBuffer(len);
                buffer = allocatedBuffer.nioBuffer();
            } else {
                // We don't have a buffer allocator, but we don't want to send a heap
                // buffer to JNI. So lazy-create a direct buffer that we will use from now
                // on to copy encrypted packets.
                buffer = getOrCreateLazyDirectBuffer();
            }

            version(HUNT_DEBUG) trace(BufferUtils.toSummaryString(buffer));

            int bytesToRead = min(len, buffer.remaining());
            int bytesRead = readEncryptedDataDirect(buffer, 0, bytesToRead);

            // byte[] temp =  buffer.array();
            // tracef("%(%02X %)", temp[0..len]);
            version(HUNT_DEBUG) {
                tracef("read encrypted data: %d / %d bytes", bytesRead, bytesToRead);
            }

            if (bytesRead > 0) {
                buffer.position(bytesRead);
                buffer.flip();
                dst.put(buffer);
                version(HUNT_DEBUG) trace(BufferUtils.toSummaryString(dst));
            }

            return bytesRead;
        } finally {
            if (allocatedBuffer !is null) {
                // Release the buffer back to the pool.
                allocatedBuffer.release();
            }
        }
    }

    private HandshakeStatus mayFinishHandshake(HandshakeStatus status) {
        if (!handshakeFinished && status == HandshakeStatus.NOT_HANDSHAKING) {
            // If the status was NOT_HANDSHAKING and we not finished the handshake we need to call
            // SSL_do_handshake() again
            return handshake();
        }
        return status;
    }

    private HandshakeStatus getHandshakeStatus(int pending) {
        // Check if we are in the initial handshake phase or shutdown phase
        return !handshakeFinished ? pendingStatus(pending) : HandshakeStatus.NOT_HANDSHAKING;
    }

    private SSLEngineResult.Status getEngineStatus() {
        switch (state) {
            case EngineStates.STATE_CLOSED_INBOUND:
            case EngineStates.STATE_CLOSED_OUTBOUND:
            case EngineStates.STATE_CLOSED:
                return SSLEngineResult.Status.CLOSED;
            default:
                return SSLEngineResult.Status.OK;
        }
    }

    private void closeAll() {
        closeOutbound();
        closeInbound();
    }

    private SSLException newSslExceptionWithMessage(string err) {
        if (!handshakeFinished) {
            return new SSLException(err);
        }
        return new SSLHandshakeException(err);
    }

    private SSLEngineResult newResult(int bytesConsumed, int bytesProduced,
            HandshakeStatus status) {
        return new SSLEngineResult(getEngineStatus(),
                mayFinishHandshake(status == HandshakeStatus.FINISHED ? status : getHandshakeStatusInternal()),
                bytesConsumed, bytesProduced);
    }

    alias wrap = SSLEngine.wrap;

    override
    SSLEngineResult wrap(ByteBuffer src, ByteBuffer dst) {
        synchronized (ssl) {
            try {
                return wrap(makeSingleSrcBuffer(src), dst);
            } finally {
                resetSingleSrcBuffer();
            }
        }
    }

    private static string badPositionIndexes(int start, int end, int size) {
        if (start < 0 || start > size) {
            return badPositionIndex(start, size, "start index");
        }
        if (end < 0 || end > size) {
            return badPositionIndex(end, size, "end index");
        }
        // end < start
        return format("end index (%s) must not be less than start index (%s)", end, start);
    }

    private static string badPositionIndex(int index, int size, string desc) {
        if (index < 0) {
            return format("%s (%s) must not be negative", desc, index);
        } else if (size < 0) {
            throw new IllegalArgumentException("negative size: " ~ size.to!string());
        } else { // index > size
            return format("%s (%s) must not be greater than size (%s)", desc, index, size);
        }
    }

    /**
     * Ensures that {@code start} and {@code end} specify a valid <i>positions</i> in an array, list
     * or string of size {@code size}, and are in order. A position index may range from zero to
     * {@code size}, inclusive.
     *
     * @param start a user-supplied index identifying a starting position in an array, list or string
     * @param end a user-supplied index identifying a ending position in an array, list or string
     * @param size the size of that array, list or string
     * @throws IndexOutOfBoundsException if either index is negative or is greater than {@code size},
     *     or if {@code end} is less than {@code start}
     * @throws IllegalArgumentException if {@code size} is negative
     */
    static void checkPositionIndexes(int start, int end, int size) {
        // Carefully optimized for execution by hotspot (explanatory comment above)
        if (start < 0 || end < start || end > size) {
            throw new IndexOutOfBoundsException(badPositionIndexes(start, end, size));
        }
    }

    override
    SSLEngineResult wrap(ByteBuffer[] srcs, int srcsOffset, int srcsLength, ByteBuffer dst)
            {
        assert(srcs !is null, "srcs is null");
        assert(dst !is null, "dst is null");
        checkPositionIndexes(srcsOffset, srcsOffset + srcsLength, cast(int)srcs.length);
        if (dst.isReadOnly()) {
            throw new ReadOnlyBufferException("");
        }

        synchronized (ssl) {
            switch (state) {
                case EngineStates.STATE_MODE_SET:
                    // Begin the handshake implicitly.
                    beginHandshakeInternal();
                    break;
                case EngineStates.STATE_CLOSED_OUTBOUND:
                case EngineStates.STATE_CLOSED:
                    // We may have pending encrypted bytes from a close_notify alert, so
                    // try to read them out
                    SSLEngineResult pendingNetResult =
                            readPendingBytesFromBIO(dst, 0, 0, HandshakeStatus.NOT_HANDSHAKING);
                    if (pendingNetResult !is null) {
                        return pendingNetResult;
                    }
                    return new SSLEngineResult(SSLEngineResult.Status.CLOSED, getHandshakeStatusInternal(), 0, 0);
                case EngineStates.STATE_NEW:
                    throw new IllegalStateException(
                            "Client/server mode must be set before calling wrap");
                default:
                    break;
            }

            // If we haven't completed the handshake yet, just let the caller know.
            HandshakeStatus handshakeStatus = HandshakeStatus.NOT_HANDSHAKING;
            // Prepare OpenSSL to work in server mode and receive handshake
            if (!handshakeFinished) {
                handshakeStatus = handshake();
                if (handshakeStatus == HandshakeStatus.NEED_UNWRAP) {
                    return NEED_UNWRAP_OK;
                }

                if (state == EngineStates.STATE_CLOSED) {
                    return NEED_UNWRAP_CLOSED;
                }
                // NEED_WRAP - just fall through to perform the wrap.
            }

            int srcsLen = 0;
            int endOffset = srcsOffset + srcsLength;
            for (int i = srcsOffset; i < endOffset; ++i) {
                ByteBuffer src = srcs[i];
                if (src is null) {
                    throw new IllegalArgumentException("srcs[" ~ i.to!string() ~ "] is null");
                }
                if (srcsLen == SSL3_RT_MAX_PLAIN_LENGTH) {
                    continue;
                }

                srcsLen += src.remaining();
                if (srcsLen > SSL3_RT_MAX_PLAIN_LENGTH || srcsLen < 0) {
                    // If srcLen > MAX_PLAINTEXT_LENGTH or secLen < 0 just set it to
                    // MAX_PLAINTEXT_LENGTH.
                    // This also help us to guard against overflow.
                    // We not break out here as we still need to check for null entries in srcs[].
                    srcsLen = SSL3_RT_MAX_PLAIN_LENGTH;
                }
            }

            if (dst.remaining() < SSLUtils.calculateOutNetBufSize(srcsLen)) {
                return new SSLEngineResult(
                    SSLEngineResult.Status.BUFFER_OVERFLOW, getHandshakeStatusInternal(), 0, 0);
            }

            int bytesProduced = 0;
            int bytesConsumed = 0;
        loop:
            for (int i = srcsOffset; i < endOffset; ++i) {
                ByteBuffer src = srcs[i];
                assert(src !is null, format("srcs[%d] is null", i));
                while (src.hasRemaining()) {
                    SSLEngineResult pendingNetResult;
                    // Write plaintext application data to the SSL engine
                    int result = writePlaintextData(src, min(src.remaining(), SSL3_RT_MAX_PLAIN_LENGTH - bytesConsumed));
                    if (result > 0) {
                        bytesConsumed += result;

                        pendingNetResult = readPendingBytesFromBIO(
                            dst, bytesConsumed, bytesProduced, handshakeStatus);
                        if (pendingNetResult !is null) {
                            if (pendingNetResult.getStatus() != SSLEngineResult.Status.OK) {
                                return pendingNetResult;
                            }
                            bytesProduced = pendingNetResult.bytesProduced();
                        }
                        if (bytesConsumed == SSL3_RT_MAX_PLAIN_LENGTH) {
                            // If we consumed the maximum amount of bytes for the plaintext length
                            // break out of the loop and start to fill the dst buffer.
                            break loop;
                        }
                    } else {
                        int sslError = ssl.getError(result);
                        switch (sslError) {
                            case SSL_ERROR_ZERO_RETURN:
                                // This means the connection was shutdown correctly, close inbound
                                // and outbound
                                closeAll();
                                pendingNetResult = readPendingBytesFromBIO(
                                        dst, bytesConsumed, bytesProduced, handshakeStatus);
                                return pendingNetResult !is null ? pendingNetResult
                                                                : CLOSED_NOT_HANDSHAKING;
                            case SSL_ERROR_WANT_READ:
                                // If there is no pending data to read from BIO we should go back to
                                // event loop and try
                                // to read more data [1]. It is also possible that event loop will
                                // detect the socket
                                // has been closed. [1]
                                // https://www.openssl.org/docs/manmaster/ssl/SSL_write.html
                                pendingNetResult = readPendingBytesFromBIO(
                                        dst, bytesConsumed, bytesProduced, handshakeStatus);
                                return pendingNetResult !is null
                                        ? pendingNetResult
                                        : new SSLEngineResult(getEngineStatus(), HandshakeStatus.NEED_UNWRAP,
                                                  bytesConsumed, bytesProduced);
                            case SSL_ERROR_WANT_WRITE:
                                // SSL_ERROR_WANT_WRITE typically means that the underlying
                                // transport is not writable
                                // and we should set the "want write" flag on the selector and try
                                // again when the
                                // underlying transport is writable [1]. However we are not directly
                                // writing to the
                                // underlying transport and instead writing to a BIO buffer. The
                                // OpenSsl documentation
                                // says we should do the following [1]:
                                //
                                // "When using a buffering BIO, like a BIO pair, data must be
                                // written into or retrieved
                                // out of the BIO before being able to continue."
                                //
                                // So we attempt to drain the BIO buffer below, but if there is no
                                // data this condition
                                // is undefined and we assume their is a fatal error with the
                                // openssl engine and close.
                                // [1] https://www.openssl.org/docs/manmaster/ssl/SSL_write.html
                                pendingNetResult = readPendingBytesFromBIO(
                                        dst, bytesConsumed, bytesProduced, handshakeStatus);
                                return pendingNetResult !is null ? pendingNetResult
                                                                : NEED_WRAP_CLOSED;
                            default:
                                // Everything else is considered as error
                                sendSSLShutdown();
                                throw newSslExceptionWithMessage("SSL_write");
                        }
                    }
                }
            }
            // We need to check if pendingWrittenBytesInBIO was checked yet, as we may not checked
            // if the srcs was
            // empty, or only contained empty buffers.
            if (bytesConsumed == 0) {
                SSLEngineResult pendingNetResult =
                        readPendingBytesFromBIO(dst, 0, bytesProduced, handshakeStatus);
                if (pendingNetResult !is null) {
                    return pendingNetResult;
                }
            }

            // return new SSLEngineResult(OK, getHandshakeStatusInternal(), bytesConsumed,
            // bytesProduced);
            return newResult(bytesConsumed, bytesProduced, handshakeStatus);
        }
    }

    override
    int clientPSKKeyRequested(string identityHint, byte[] identity, byte[] key) {
        return ssl.clientPSKKeyRequested(identityHint, identity, key);
    }

    override
    int serverPSKKeyRequested(string identityHint, string identity, byte[] key) {
        return ssl.serverPSKKeyRequested(identityHint, identity, key);
    }

    override
    void onSSLStateChange(int type, int val) {
        synchronized (ssl) {
            switch (type) {
                case SSL_CB_HANDSHAKE_START: {
                    // For clients, this will allow the NEED_UNWRAP status to be
                    // returned.
                    transitionTo(EngineStates.STATE_HANDSHAKE_STARTED);
                    break;
                }
                case SSL_CB_HANDSHAKE_DONE: {
                    if (state != EngineStates.STATE_HANDSHAKE_STARTED
                            && state != EngineStates.STATE_READY_HANDSHAKE_CUT_THROUGH) {
                        throw new IllegalStateException("Completed handshake while in mode " ~ state.to!string());
                    }
                    transitionTo(EngineStates.STATE_HANDSHAKE_COMPLETED);
                    break;
                }
                default:
                    // Ignore
            }
        }
    }

    override
    void onNewSessionEstablished(long sslSessionNativePtr) {

implementationMissing(false);
        // try {
        //     // Increment the reference count to "take ownership" of the session resource.
        //     NativeCrypto.SSL_SESSION_up_ref(sslSessionNativePtr);

        //     // Create a native reference which will release the SSL_SESSION in its finalizer.
        //     // This constructor will only throw if the native pointer passed in is NULL, which
        //     // BoringSSL guarantees will not happen.
        //     NativeRef.SSL_SESSION ref = new SSL_SESSION(sslSessionNativePtr);

        //     NativeSslSession nativeSession = NativeSslSession.newInstance(ref, activeSession);

        //     // Cache the newly established session.
        //     AbstractSessionContext ctx = sessionContext();
        //     ctx.cacheSession(nativeSession);
        // } catch (Exception ignored) {
        //     // Ignore.
        // }
    }

    override
    long serverSessionRequested(byte[] id) {
        // TODO(nathanmittler): Implement server-side caching for TLS < 1.3
        return 0;
    }

    override
    void verifyCertificateChain(byte[][] certChain, string authMethod) {
implementationMissing(false);
        // try {
        //     if (certChain == null || certChain.length == 0) {
        //         throw new CertificateException("Peer sent no certificate");
        //     }
        //     X509Certificate[] peerCertChain = SSLUtils.decodeX509CertificateChain(certChain);

        //     X509TrustManager x509tm = sslParameters.getX509TrustManager();
        //     if (x509tm == null) {
        //         throw new CertificateException("No X.509 TrustManager");
        //     }

        //     // Update the peer information on the session.
        //     activeSession.onPeerCertificatesReceived(getPeerHost(), getPeerPort(), peerCertChain);

        //     if (getUseClientMode()) {
        //         Platform.checkServerTrusted(x509tm, peerCertChain, authMethod, this);
        //     } else {
        //         string authType = peerCertChain[0].getPublicKey().getAlgorithm();
        //         Platform.checkClientTrusted(x509tm, peerCertChain, authType, this);
        //     }
        // } catch (CertificateException e) {
        //     throw e;
        // } catch (Exception e) {
        //     throw new CertificateException(e);
        // }
    }

    override
    void clientCertificateRequested(byte[] keyTypeBytes, byte[][] asn1DerEncodedPrincipals) {
        ssl.chooseClientCertificate(keyTypeBytes, asn1DerEncodedPrincipals);
    }

    private void sendSSLShutdown() {
        try {
            ssl.shutdown();
        } catch (IOException ignored) {
            // TODO: The RI ignores close failures in SSLSocket, but need to
            // investigate whether it does for SSLEngine.
        }
    }

    private void closeAndFreeResources() {
        transitionTo(EngineStates.STATE_CLOSED);
        if (!ssl.isClosed()) {
            ssl.close();
            networkBio.close();
        }
    }

    // override
    // protected void finalize() throws Throwable {
    //     try {
    //         transitionTo(STATE_CLOSED);
    //     } finally {
    //         super.finalize();
    //     }
    // }

    override string chooseServerAlias(X509KeyManager keyManager, string keyType) {
        // X509ExtendedKeyManager ekm = cast(X509ExtendedKeyManager) keyManager;
        // if (ekm is null) {
        //     return keyManager.chooseServerAlias(keyType, null, null);
        // } else {
        //     return ekm.chooseEngineServerAlias(keyType, null, this);
        // }
        implementationMissing(false);
        return "";
    }

    override string chooseClientAlias(X509KeyManager keyManager, 
            X500Principal[] issuers, string[] keyTypes) {

        implementationMissing(false);
        return "";
        // X509ExtendedKeyManager ekm = cast(X509ExtendedKeyManager) keyManager;
        // if (ekm is null) {
        //     return keyManager.chooseClientAlias(keyTypes, issuers, null);
        // } else {
        //     return ekm.chooseEngineClientAlias(keyTypes, issuers, this);
        // }
    }

    // override
    // @SuppressWarnings("deprecation") // PSKKeyManager is deprecated, but in our own package
    // string chooseServerPSKIdentityHint(PSKKeyManager keyManager) {
    //     return keyManager.chooseServerKeyIdentityHint(this);
    // }

    // override
    // @SuppressWarnings("deprecation") // PSKKeyManager is deprecated, but in our own package
    // string chooseClientPSKIdentity(PSKKeyManager keyManager, string identityHint) {
    //     return keyManager.chooseClientKeyIdentity(identityHint, this);
    // }

    // override
    // @SuppressWarnings("deprecation") // PSKKeyManager is deprecated, but in our own package
    // SecretKey getPSKKey(PSKKeyManager keyManager, string identityHint, string identity) {
    //     return keyManager.getKey(identityHint, identity, this);
    // }

    /**
     * This method enables session ticket support.
     *
     * @param useSessionTickets True to enable session tickets
     */
    override
    void setUseSessionTickets(bool useSessionTickets) {
        sslParameters.setUseSessionTickets(useSessionTickets);
    }

    override
    string[] getApplicationProtocols() {
        return sslParameters.getApplicationProtocols();
    }

    override
    void setApplicationProtocols(string[] protocols) {
        sslParameters.setApplicationProtocols(protocols);
    }

    override
    void setApplicationProtocolSelector(ApplicationProtocolSelector selector) {
        setApplicationProtocolSelector(
                selector is null ? null : new ApplicationProtocolSelectorAdapter(this, selector));
    }

    // override
    // byte[] getTlsUnique() {
    //     return ssl.getTlsUnique();
    // }

    // override
    // void setTokenBindingParams(int... params) {
    //     synchronized (ssl) {
    //         if (isHandshakeStarted()) {
    //             throw new IllegalStateException(
    //                     "Cannot set token binding params after handshake has started.");
    //         }
    //     }
    //     ssl.setTokenBindingParams(params);
    // };

    // override
    // int getTokenBindingParams() {
    //     return ssl.getTokenBindingParams();
    // }

    // override
    // byte[] exportKeyingMaterial(string label, byte[] context, int length) {
    //     synchronized (ssl) {
    //         if (state < STATE_HANDSHAKE_COMPLETED || state == STATE_CLOSED) {
    //             return null;
    //         }
    //     }
    //     return ssl.exportKeyingMaterial(label, context, length);
    // }

    void setApplicationProtocolSelector(ApplicationProtocolSelectorAdapter adapter) {
        sslParameters.setApplicationProtocolSelector(adapter);
    }

    override
    string getApplicationProtocol() {
        return SSLUtils.toProtocolString(ssl.getApplicationProtocol());
    }

    override
    string getHandshakeApplicationProtocol() {
        synchronized (ssl) {
            return state == EngineStates.STATE_HANDSHAKE_STARTED ? getApplicationProtocol() : null;
        }
    }

    private ByteBuffer[] makeSingleSrcBuffer(ByteBuffer src) {
        singleSrcBuffer[0] = src;
        return singleSrcBuffer;
    }

    private void resetSingleSrcBuffer() {
        singleSrcBuffer[0] = null;
    }

    private ByteBuffer[] makeSingleDstBuffer(ByteBuffer src) {
        singleDstBuffer[0] = src;
        return singleDstBuffer;
    }

    private void resetSingleDstBuffer() {
        singleDstBuffer[0] = null;
    }

    private ClientSessionContext clientSessionContext() {
        return sslParameters.getClientSessionContext();
    }

    private AbstractSessionContext sessionContext() {
        return sslParameters.getSessionContext();
    }

    private void transitionTo(int newState) {
        switch (newState) {
            case EngineStates.STATE_HANDSHAKE_STARTED: {
                handshakeFinished = false;
                break;
            }
            case EngineStates.STATE_CLOSED: {
                if (!ssl.isClosed() && state >= EngineStates.STATE_HANDSHAKE_STARTED && 
                    state < EngineStates.STATE_CLOSED ) {
                    closedSession = new SessionSnapshot(activeSession);
                }
                break;
            }
            default: {
                break;
            }
        }

        // Update the state
        this.state = newState;
    }
}
