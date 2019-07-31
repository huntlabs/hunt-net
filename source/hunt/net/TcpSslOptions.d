/*
 * Copyright (c) 2011-2017 Contributors to the Eclipse Foundation
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0, or the Apache License, Version 2.0
 * which is available at https://www.apache.org/licenses/LICENSE-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0 OR Apache-2.0
 */

module hunt.net.TcpSslOptions;

import hunt.net.NetworkOptions;
import hunt.net.OpenSSLEngineOptions;

/**
 * Base class. TCP and SSL related options
 *
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
abstract class TcpSslOptions : NetworkOptions {

    /**
     * The default value of TCP-no-delay = true (Nagle disabled)
     */
    enum bool DEFAULT_TCP_NO_DELAY = true;

    /**
     * The default value of TCP keep alive = false
     */
    enum bool DEFAULT_TCP_KEEP_ALIVE = false;

    /**
     * The default value of SO_linger = -1
     */
    enum int DEFAULT_SO_LINGER = -1;

    /**
     * The default value of Netty use pooled buffers = false
     */
    enum bool DEFAULT_USE_POOLED_BUFFERS = false;

    /**
     * SSL enable by default = false
     */
    enum bool DEFAULT_SSL = false;

    /**
     * Default idle timeout = 0
     */
    enum int DEFAULT_IDLE_TIMEOUT = 0;

    /**
     * Default idle time unit = SECONDS
     */
    // enum TimeUnit DEFAULT_IDLE_TIMEOUT_TIME_UNIT = TimeUnit.SECONDS;

    /**
     * Default use alpn = false
     */
    enum bool DEFAULT_USE_ALPN = false;

    /**
     * The default SSL engine options = null (autoguess)
     */
    // enum SSLEngineOptions DEFAULT_SSL_ENGINE = null;

    /**
     * The default ENABLED_SECURE_TRANSPORT_PROTOCOLS value = { "SSLv2Hello", "TLSv1", "TLSv1.1", "TLSv1.2" }
     * <p/>
     * SSLv3 is NOT enabled due to POODLE vulnerability http://en.wikipedia.org/wiki/POODLE
     * <p/>
     * "SSLv2Hello" is NOT enabled since it's disabled by default since JDK7
     */
    enum string[] DEFAULT_ENABLED_SECURE_TRANSPORT_PROTOCOLS = ["TLSv1", "TLSv1.1", "TLSv1.2"];

    /**
     * The default TCP_FASTOPEN value = false
     */
    enum bool DEFAULT_TCP_FAST_OPEN = false;

    /**
     * The default TCP_CORK value = false
     */
    enum bool DEFAULT_TCP_CORK = false;

    /**
     * The default TCP_QUICKACK value = false
     */
    enum bool DEFAULT_TCP_QUICKACK = false;

    /**
     * The default value of SSL handshake timeout = 10
     */
    enum long DEFAULT_SSL_HANDSHAKE_TIMEOUT = 10L;

    /**
     * Default SSL handshake time unit = SECONDS
     */
    // enum TimeUnit DEFAULT_SSL_HANDSHAKE_TIMEOUT_TIME_UNIT = TimeUnit.SECONDS;

    private bool tcpNoDelay;
    private bool tcpKeepAlive;
    private int soLinger;
    private bool usePooledBuffers;
    private int idleTimeout;
    // private TimeUnit idleTimeoutUnit;
    private bool ssl;
    private long sslHandshakeTimeout;
    // private TimeUnit sslHandshakeTimeoutUnit;
    // private KeyCertOptions keyCertOptions;
    // private TrustOptions trustOptions;
    // private Set!(string) enabledCipherSuites;
    // private ArrayList!(string) crlPaths;
    // private ArrayList!(Buffer) crlValues;
    private bool useAlpn;
    // private SSLEngineOptions sslEngineOptions;
    // private Set!(string) enabledSecureTransportProtocols;
    private bool tcpFastOpen;
    private bool tcpCork;
    private bool tcpQuickAck;

    /**
     * Default constructor
     */
    this() {
        super();
        init();
    }

    /**
     * Copy constructor
     *
     * @param other  the options to copy
     */
    this(TcpSslOptions other) {
        super(other);
        this.tcpNoDelay = other.isTcpNoDelay();
        this.tcpKeepAlive = other.isTcpKeepAlive();
        this.soLinger = other.getSoLinger();
        this.usePooledBuffers = other.isUsePooledBuffers();
        this.idleTimeout = other.getIdleTimeout();
        // this.idleTimeoutUnit = other.getIdleTimeoutUnit() !is null ? other.getIdleTimeoutUnit() : DEFAULT_IDLE_TIMEOUT_TIME_UNIT;
        this.ssl = other.isSsl();
        this.sslHandshakeTimeout = other.sslHandshakeTimeout;
        // this.sslHandshakeTimeoutUnit = other.getSslHandshakeTimeoutUnit() !is null ? other.getSslHandshakeTimeoutUnit() : DEFAULT_SSL_HANDSHAKE_TIMEOUT_TIME_UNIT;
        // this.keyCertOptions = other.getKeyCertOptions() !is null ? other.getKeyCertOptions().copy() : null;
        // this.trustOptions = other.getTrustOptions() !is null ? other.getTrustOptions().copy() : null;
        // this.enabledCipherSuites = other.getEnabledCipherSuites() is null ? new LinkedHashSet<>() : new LinkedHashSet<>(other.getEnabledCipherSuites());
        // this.crlPaths = new ArrayList<>(other.getCrlPaths());
        // this.crlValues = new ArrayList<>(other.getCrlValues());
        this.useAlpn = other.useAlpn;
        // this.sslEngineOptions = other.sslEngineOptions !is null ? other.sslEngineOptions.copy() : null;
        // this.enabledSecureTransportProtocols = other.getEnabledSecureTransportProtocols() is null ? new LinkedHashSet<>() : new LinkedHashSet<>(other.getEnabledSecureTransportProtocols());
        this.tcpFastOpen = other.isTcpFastOpen();
        this.tcpCork = other.isTcpCork();
        this.tcpQuickAck = other.isTcpQuickAck();
    }

    private void init() {
        tcpNoDelay = DEFAULT_TCP_NO_DELAY;
        tcpKeepAlive = DEFAULT_TCP_KEEP_ALIVE;
        soLinger = DEFAULT_SO_LINGER;
        usePooledBuffers = DEFAULT_USE_POOLED_BUFFERS;
        idleTimeout = DEFAULT_IDLE_TIMEOUT;
        // idleTimeoutUnit = DEFAULT_IDLE_TIMEOUT_TIME_UNIT;
        ssl = DEFAULT_SSL;
        // sslHandshakeTimeout = DEFAULT_SSL_HANDSHAKE_TIMEOUT;
        // sslHandshakeTimeoutUnit = DEFAULT_SSL_HANDSHAKE_TIMEOUT_TIME_UNIT;
        // enabledCipherSuites = new LinkedHashSet<>();
        // crlPaths = new ArrayList<>();
        // crlValues = new ArrayList<>();
        useAlpn = DEFAULT_USE_ALPN;
        // sslEngineOptions = DEFAULT_SSL_ENGINE;
        // enabledSecureTransportProtocols = new LinkedHashSet<>(DEFAULT_ENABLED_SECURE_TRANSPORT_PROTOCOLS);
        tcpFastOpen = DEFAULT_TCP_FAST_OPEN;
        tcpCork = DEFAULT_TCP_CORK;
        tcpQuickAck = DEFAULT_TCP_QUICKACK;
    }

    /**
     * @return TCP no delay enabled ?
     */
    bool isTcpNoDelay() {
        return tcpNoDelay;
    }

    /**
     * Set whether TCP no delay is enabled
     *
     * @param tcpNoDelay true if TCP no delay is enabled (Nagle disabled)
     * @return a reference to this, so the API can be used fluently
     */
    TcpSslOptions setTcpNoDelay(bool tcpNoDelay) {
        this.tcpNoDelay = tcpNoDelay;
        return this;
    }

    /**
     * @return is TCP keep alive enabled?
     */
    bool isTcpKeepAlive() {
        return tcpKeepAlive;
    }

    /**
     * Set whether TCP keep alive is enabled
     *
     * @param tcpKeepAlive true if TCP keep alive is enabled
     * @return a reference to this, so the API can be used fluently
     */
    TcpSslOptions setTcpKeepAlive(bool tcpKeepAlive) {
        this.tcpKeepAlive = tcpKeepAlive;
        return this;
    }

    /**
     *
     * @return is SO_linger enabled
     */
    int getSoLinger() {
        return soLinger;
    }

    /**
     * Set whether SO_linger keep alive is enabled
     *
     * @param soLinger true if SO_linger is enabled
     * @return a reference to this, so the API can be used fluently
     */
    TcpSslOptions setSoLinger(int soLinger) {
        if (soLinger < 0 && soLinger != DEFAULT_SO_LINGER) {
            throw new IllegalArgumentException("soLinger must be >= 0");
        }
        this.soLinger = soLinger;
        return this;
    }

    // /**
    //  * @return are Netty pooled buffers enabled?
    //  * @deprecated this has no effect, just don't use it
    //  */
    // @Deprecated
    // bool isUsePooledBuffers() {
    //     return usePooledBuffers;
    // }

    // /**
    //  * Set whether Netty pooled buffers are enabled
    //  *
    //  * @param usePooledBuffers true if pooled buffers enabled
    //  * @return a reference to this, so the API can be used fluently
    //  * @deprecated this has no effect, just don't use it
    //  */
    // @Deprecated
    // TcpSslOptions setUsePooledBuffers(bool usePooledBuffers) {
    //     this.usePooledBuffers = usePooledBuffers;
    //     return this;
    // }

    /**
     * Set the idle timeout, default time unit is seconds. Zero means don't timeout.
     * This determines if a connection will timeout and be closed if no data is received within the timeout.
     *
     * If you want change default time unit, use {@link #setIdleTimeoutUnit(TimeUnit)}
     *
     * @param idleTimeout  the timeout, in seconds
     * @return a reference to this, so the API can be used fluently
     */
    TcpSslOptions setIdleTimeout(int idleTimeout) {
        if (idleTimeout < 0) {
            throw new IllegalArgumentException("idleTimeout must be >= 0");
        }
        this.idleTimeout = idleTimeout;
        return this;
    }

    /**
     * @return the idle timeout, in time unit specified by {@link #getIdleTimeoutUnit()}.
     */
    int getIdleTimeout() {
        return idleTimeout;
    }

    /**
     * Set the idle timeout unit. If not specified, default is seconds.
     *
     * @param idleTimeoutUnit specify time unit.
     * @return a reference to this, so the API can be used fluently
     */
    TcpSslOptions setIdleTimeoutUnit(TimeUnit idleTimeoutUnit) {
        this.idleTimeoutUnit = idleTimeoutUnit;
        return this;
    }

    /**
     * @return the idle timeout unit.
     */
    TimeUnit getIdleTimeoutUnit() {
        return idleTimeoutUnit;
    }

    /**
     *
     * @return is SSL/TLS enabled?
     */
    bool isSsl() {
        return ssl;
    }

    /**
     * Set whether SSL/TLS is enabled
     *
     * @param ssl  true if enabled
     * @return a reference to this, so the API can be used fluently
     */
    TcpSslOptions setSsl(bool ssl) {
        this.ssl = ssl;
        return this;
    }

    /**
     * @return the key/cert options
     */
    
    // KeyCertOptions getKeyCertOptions() {
    //     return keyCertOptions;
    // }

    // /**
    //  * Set the key/cert options.
    //  *
    //  * @param options the key store options
    //  * @return a reference to this, so the API can be used fluently
    //  */
    
    // TcpSslOptions setKeyCertOptions(KeyCertOptions options) {
    //     this.keyCertOptions = options;
    //     return this;
    // }

    // /**
    //  * Get the key/cert options in jks format, aka Java keystore.
    //  *
    //  * @return the key/cert options in jks format, aka Java keystore.
    //  */
    // JksOptions getKeyStoreOptions() {
    //     return keyCertOptions instanceof JksOptions ? (JksOptions) keyCertOptions : null;
    // }

    // /**
    //  * Set the key/cert options in jks format, aka Java keystore.
    //  * @param options the key store in jks format
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions setKeyStoreOptions(JksOptions options) {
    //     this.keyCertOptions = options;
    //     return this;
    // }

    // /**
    //  * Get the key/cert options in pfx format.
    //  *
    //  * @return the key/cert options in pfx format.
    //  */
    // PfxOptions getPfxKeyCertOptions() {
    //     return keyCertOptions instanceof PfxOptions ? (PfxOptions) keyCertOptions : null;
    // }

    // /**
    //  * Set the key/cert options in pfx format.
    //  * @param options the key cert options in pfx format
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions setPfxKeyCertOptions(PfxOptions options) {
    //     this.keyCertOptions = options;
    //     return this;
    // }

    // /**
    //  * Get the key/cert store options in pem format.
    //  *
    //  * @return the key/cert store options in pem format.
    //  */
    // PemKeyCertOptions getPemKeyCertOptions() {
    //     return keyCertOptions instanceof PemKeyCertOptions ? (PemKeyCertOptions) keyCertOptions : null;
    // }

    // /**
    //  * Set the key/cert store options in pem format.
    //  * @param options the options in pem format
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions setPemKeyCertOptions(PemKeyCertOptions options) {
    //     this.keyCertOptions = options;
    //     return this;
    // }

    // /**
    //  * @return the trust options
    //  */
    // TrustOptions getTrustOptions() {
    //     return trustOptions;
    // }

    // /**
    //  * Set the trust options.
    //  * @param options the trust options
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions setTrustOptions(TrustOptions options) {
    //     this.trustOptions = options;
    //     return this;
    // }

    // /**
    //  * Get the trust options in jks format, aka Java truststore
    //  *
    //  * @return the trust options in jks format, aka Java truststore
    //  */
    // JksOptions getTrustStoreOptions() {
    //     return trustOptions instanceof JksOptions ? (JksOptions) trustOptions : null;
    // }

    // /**
    //  * Set the trust options in jks format, aka Java truststore
    //  * @param options the trust options in jks format
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions setTrustStoreOptions(JksOptions options) {
    //     this.trustOptions = options;
    //     return this;
    // }

    // /**
    //  * Get the trust options in pfx format
    //  *
    //  * @return the trust options in pfx format
    //  */
    // PfxOptions getPfxTrustOptions() {
    //     return trustOptions instanceof PfxOptions ? (PfxOptions) trustOptions : null;
    // }

    // /**
    //  * Set the trust options in pfx format
    //  * @param options the trust options in pfx format
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions setPfxTrustOptions(PfxOptions options) {
    //     this.trustOptions = options;
    //     return this;
    // }

    // /**
    //  * Get the trust options in pem format
    //  *
    //  * @return the trust options in pem format
    //  */
    // PemTrustOptions getPemTrustOptions() {
    //     return trustOptions instanceof PemTrustOptions ? (PemTrustOptions) trustOptions : null;
    // }

    // /**
    //  * Set the trust options in pem format
    //  * @param options the trust options in pem format
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions setPemTrustOptions(PemTrustOptions options) {
    //     this.trustOptions = options;
    //     return this;
    // }

    /**
     * Add an enabled cipher suite, appended to the ordered suites.
     *
     * @param suite  the suite
     * @return a reference to this, so the API can be used fluently
     */
    TcpSslOptions addEnabledCipherSuite(string suite) {
        enabledCipherSuites.add(suite);
        return this;
    }

    // /**
    //  *
    //  * @return the enabled cipher suites
    //  */
    // Set!(string) getEnabledCipherSuites() {
    //     return enabledCipherSuites;
    // }

    // /**
    //  *
    //  * @return the CRL (Certificate revocation list) paths
    //  */
    // List!(string) getCrlPaths() {
    //     return crlPaths;
    // }

    // /**
    //  * Add a CRL path
    //  * @param crlPath  the path
    //  * @return a reference to this, so the API can be used fluently
    //  * @throws NullPointerException
    //  */
    // TcpSslOptions addCrlPath(string crlPath) throws NullPointerException {
    //     Objects.requireNonNull(crlPath, "No null crl accepted");
    //     crlPaths.add(crlPath);
    //     return this;
    // }

    // /**
    //  * Get the CRL values
    //  *
    //  * @return the list of values
    //  */
    // List!(Buffer) getCrlValues() {
    //     return crlValues;
    // }

    // /**
    //  * Add a CRL value
    //  *
    //  * @param crlValue  the value
    //  * @return a reference to this, so the API can be used fluently
    //  * @throws NullPointerException
    //  */
    // TcpSslOptions addCrlValue(Buffer crlValue) throws NullPointerException {
    //     Objects.requireNonNull(crlValue, "No null crl accepted");
    //     crlValues.add(crlValue);
    //     return this;
    // }

    /**
     * @return whether to use or not Application-Layer Protocol Negotiation
     */
    bool isUseAlpn() {
        return useAlpn;
    }

    /**
     * Set the ALPN usage.
     *
     * @param useAlpn true when Application-Layer Protocol Negotiation should be used
     */
    TcpSslOptions setUseAlpn(bool useAlpn) {
        this.useAlpn = useAlpn;
        return this;
    }

    // /**
    //  * @return the SSL engine implementation to use
    //  */
    // SSLEngineOptions getSslEngineOptions() {
    //     return sslEngineOptions;
    // }

    // /**
    //  * Set to use SSL engine implementation to use.
    //  *
    //  * @param sslEngineOptions the ssl engine to use
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions setSslEngineOptions(SSLEngineOptions sslEngineOptions) {
    //     this.sslEngineOptions = sslEngineOptions;
    //     return this;
    // }

    // JdkSSLEngineOptions getJdkSslEngineOptions() {
    //     return sslEngineOptions instanceof JdkSSLEngineOptions ? (JdkSSLEngineOptions) sslEngineOptions : null;
    // }

    // TcpSslOptions setJdkSslEngineOptions(JdkSSLEngineOptions sslEngineOptions) {
    //     return setSslEngineOptions(sslEngineOptions);
    // }

    // OpenSSLEngineOptions getOpenSslEngineOptions() {
    //     return sslEngineOptions instanceof OpenSSLEngineOptions ? (OpenSSLEngineOptions) sslEngineOptions : null;
    // }

    // TcpSslOptions setOpenSslEngineOptions(OpenSSLEngineOptions sslEngineOptions) {
    //     return setSslEngineOptions(sslEngineOptions);
    // }

    // /**
    //  * Sets the list of enabled SSL/TLS protocols.
    //  *
    //  * @param enabledSecureTransportProtocols  the SSL/TLS protocols to enable
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions setEnabledSecureTransportProtocols(Set!(string) enabledSecureTransportProtocols) {
    //     this.enabledSecureTransportProtocols = enabledSecureTransportProtocols;
    //     return this;
    // }

    // /**
    //  * Add an enabled SSL/TLS protocols, appended to the ordered protocols.
    //  *
    //  * @param protocol  the SSL/TLS protocol to enable
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions addEnabledSecureTransportProtocol(string protocol) {
    //     enabledSecureTransportProtocols.add(protocol);
    //     return this;
    // }

    // /**
    //  * Removes an enabled SSL/TLS protocol from the ordered protocols.
    //  *
    //  * @param protocol the SSL/TLS protocol to disable
    //  * @return a reference to this, so the API can be used fluently
    //  */
    // TcpSslOptions removeEnabledSecureTransportProtocol(string protocol) {
    //     enabledSecureTransportProtocols.remove(protocol);
    //     return this;
    // }

    /**
     * @return wether {@code TCP_FASTOPEN} option is enabled
     */
    bool isTcpFastOpen() {
        return tcpFastOpen;
    }

    /**
     * Enable the {@code TCP_FASTOPEN} option - only with linux native transport.
     *
     * @param tcpFastOpen the fast open value
     */
    TcpSslOptions setTcpFastOpen(bool tcpFastOpen) {
        this.tcpFastOpen = tcpFastOpen;
        return this;
    }

    /**
     * @return wether {@code TCP_CORK} option is enabled
     */
    bool isTcpCork() {
        return tcpCork;
    }

    /**
     * Enable the {@code TCP_CORK} option - only with linux native transport.
     *
     * @param tcpCork the cork value
     */
    TcpSslOptions setTcpCork(bool tcpCork) {
        this.tcpCork = tcpCork;
        return this;
    }

    /**
     * @return wether {@code TCP_QUICKACK} option is enabled
     */
    bool isTcpQuickAck() {
        return tcpQuickAck;
    }

    /**
     * Enable the {@code TCP_QUICKACK} option - only with linux native transport.
     *
     * @param tcpQuickAck the quick ack value
     */
    TcpSslOptions setTcpQuickAck(bool tcpQuickAck) {
        this.tcpQuickAck = tcpQuickAck;
        return this;
    }

    /**
     * Returns the enabled SSL/TLS protocols
     * @return the enabled protocols
     */
    // Set!(string) getEnabledSecureTransportProtocols() {
    //     return new LinkedHashSet<>(enabledSecureTransportProtocols);
    // }

    /**
     * @return the SSL handshake timeout, in time unit specified by {@link #getSslHandshakeTimeoutUnit()}.
     */
    long getSslHandshakeTimeout() {
        return sslHandshakeTimeout;
    }

    /**
     * Set the SSL handshake timeout, default time unit is seconds.
     *
     * @param sslHandshakeTimeout the SSL handshake timeout to set, in milliseconds
     * @return a reference to this, so the API can be used fluently
     */
    // TcpSslOptions setSslHandshakeTimeout(long sslHandshakeTimeout) {
    //     if (sslHandshakeTimeout < 0) {
    //         throw new IllegalArgumentException("sslHandshakeTimeout must be >= 0");
    //     }
    //     this.sslHandshakeTimeout = sslHandshakeTimeout;
    //     return this;
    // }

    /**
     * Set the SSL handshake timeout unit. If not specified, default is seconds.
     *
     * @param sslHandshakeTimeoutUnit specify time unit.
     * @return a reference to this, so the API can be used fluently
     */
    // TcpSslOptions setSslHandshakeTimeoutUnit(TimeUnit sslHandshakeTimeoutUnit) {
    //     this.sslHandshakeTimeoutUnit = sslHandshakeTimeoutUnit;
    //     return this;
    // }

    /**
     * @return the SSL handshake timeout unit.
     */
    // TimeUnit getSslHandshakeTimeoutUnit() {
    //     return sslHandshakeTimeoutUnit;
    // }

    override
    TcpSslOptions setLogActivity(bool logEnabled) {
        return cast(TcpSslOptions) super.setLogActivity(logEnabled);
    }

    override
    TcpSslOptions setSendBufferSize(int sendBufferSize) {
        return cast(TcpSslOptions) super.setSendBufferSize(sendBufferSize);
    }

    override
    TcpSslOptions setReceiveBufferSize(int receiveBufferSize) {
        return cast(TcpSslOptions) super.setReceiveBufferSize(receiveBufferSize);
    }

    override
    TcpSslOptions setReuseAddress(bool reuseAddress) {
        return cast(TcpSslOptions) super.setReuseAddress(reuseAddress);
    }

    override
    TcpSslOptions setTrafficClass(int trafficClass) {
        return cast(TcpSslOptions) super.setTrafficClass(trafficClass);
    }

    override
    TcpSslOptions setReusePort(bool reusePort) {
        return cast(TcpSslOptions) super.setReusePort(reusePort);
    }

    override
    bool opEquals(Object o) {
        if (this is o) return true;
        if (!super.opEquals(o)) return false;

        TcpSslOptions that = cast(TcpSslOptions) o;
        if(that is null)
            return false;

        if (idleTimeout != that.idleTimeout) return false;
        // if (idleTimeoutUnit !is null ? !idleTimeoutUnit.equals(that.idleTimeoutUnit) : that.idleTimeoutUnit !is null) return false;
        if (soLinger != that.soLinger) return false;
        if (ssl != that.ssl) return false;
        if (tcpKeepAlive != that.tcpKeepAlive) return false;
        if (tcpNoDelay != that.tcpNoDelay) return false;
        if (tcpFastOpen != that.tcpFastOpen) return false;
        if (tcpQuickAck != that.tcpQuickAck) return false;
        if (tcpCork != that.tcpCork) return false;
        if (usePooledBuffers != that.usePooledBuffers) return false;
        // if (crlPaths !is null ? !crlPaths.equals(that.crlPaths) : that.crlPaths !is null) return false;
        // if (crlValues !is null ? !crlValues.equals(that.crlValues) : that.crlValues !is null) return false;
        // if (enabledCipherSuites !is null ? !enabledCipherSuites.equals(that.enabledCipherSuites) : that.enabledCipherSuites !is null)
            // return false;
        // if (keyCertOptions !is null ? !keyCertOptions.equals(that.keyCertOptions) : that.keyCertOptions !is null) return false;
        // if (trustOptions !is null ? !trustOptions.equals(that.trustOptions) : that.trustOptions !is null) return false;
        if (useAlpn != that.useAlpn) return false;
        // if (sslEngineOptions !is null ? !sslEngineOptions.equals(that.sslEngineOptions) : that.sslEngineOptions !is null) return false;
        // if (!enabledSecureTransportProtocols.equals(that.enabledSecureTransportProtocols)) return false;

        return true;
    }

    override
    size_t toHash() @trusted nothrow {
        size_t result = super.toHash();
        result = 31 * result + (tcpNoDelay ? 1 : 0);
        result = 31 * result + (tcpFastOpen ? 1 : 0);
        result = 31 * result + (tcpCork ? 1 : 0);
        result = 31 * result + (tcpQuickAck ? 1 : 0);
        result = 31 * result + (tcpKeepAlive ? 1 : 0);
        result = 31 * result + soLinger;
        result = 31 * result + (usePooledBuffers ? 1 : 0);
        result = 31 * result + idleTimeout;
        // result = 31 * result + (idleTimeoutUnit !is null ? idleTimeoutUnit.toHash() : 0);
        result = 31 * result + (ssl ? 1 : 0);
        // result = 31 * result + (keyCertOptions !is null ? keyCertOptions.toHash() : 0);
        // result = 31 * result + (trustOptions !is null ? trustOptions.toHash() : 0);
        // result = 31 * result + (enabledCipherSuites !is null ? enabledCipherSuites.toHash() : 0);
        // result = 31 * result + (crlPaths !is null ? crlPaths.toHash() : 0);
        // result = 31 * result + (crlValues !is null ? crlValues.toHash() : 0);
        result = 31 * result + (useAlpn ? 1 : 0);
        // result = 31 * result + (sslEngineOptions !is null ? sslEngineOptions.toHash() : 0);
        result = 31 * result + (enabledSecureTransportProtocols !is null ? enabledSecureTransportProtocols
                .toHash() : 0);
        return result;
    }
}
