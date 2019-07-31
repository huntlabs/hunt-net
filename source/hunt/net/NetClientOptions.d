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

module hunt.net.NetClientOptions;

import hunt.net.ClientOptionsBase;
import hunt.net.OpenSSLEngineOptions;
import hunt.net.ProxyOptions;

import hunt.Exceptions;

import core.time;
import std.array;

/**
 * Options for configuring a {@link hunt.net.NetClient}.
 *
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
class NetClientOptions : ClientOptionsBase {

    /**
     * The default value for reconnect attempts = 0
     */
    enum int DEFAULT_RECONNECT_ATTEMPTS = 0;

    /**
     * The default value for reconnect interval = 1000 ms
     */
    enum long DEFAULT_RECONNECT_INTERVAL = 1000;

    /**
     * Default value to determine hostname verification algorithm hostname verification (for SSL/TLS) = ""
     */
    enum string DEFAULT_HOSTNAME_VERIFICATION_ALGORITHM = "";


    private int reconnectAttempts;
    private long reconnectInterval;
    private string hostnameVerificationAlgorithm;

        /**
     * The default constructor
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
    this(NetClientOptions other) {
        super(other);
        this.reconnectAttempts = other.getReconnectAttempts();
        this.reconnectInterval = other.getReconnectInterval();
        this.hostnameVerificationAlgorithm = other.getHostnameVerificationAlgorithm();
    }

    private void init() {
        this.reconnectAttempts = DEFAULT_RECONNECT_ATTEMPTS;
        this.reconnectInterval = DEFAULT_RECONNECT_INTERVAL;
        this.hostnameVerificationAlgorithm = DEFAULT_HOSTNAME_VERIFICATION_ALGORITHM;
    }

    override
    NetClientOptions setSendBufferSize(int sendBufferSize) {
        super.setSendBufferSize(sendBufferSize);
        return this;
    }

    override
    NetClientOptions setReceiveBufferSize(int receiveBufferSize) {
        super.setReceiveBufferSize(receiveBufferSize);
        return this;
    }

    override
    NetClientOptions setReuseAddress(bool reuseAddress) {
        super.setReuseAddress(reuseAddress);
        return this;
    }

    override
    NetClientOptions setReusePort(bool reusePort) {
        super.setReusePort(reusePort);
        return this;
    }

    override
    NetClientOptions setTrafficClass(int trafficClass) {
        super.setTrafficClass(trafficClass);
        return this;
    }

    override
    NetClientOptions setTcpNoDelay(bool tcpNoDelay) {
        super.setTcpNoDelay(tcpNoDelay);
        return this;
    }

    override
    NetClientOptions setTcpKeepAlive(bool tcpKeepAlive) {
        super.setTcpKeepAlive(tcpKeepAlive);
        return this;
    }

    override
    NetClientOptions setSoLinger(int soLinger) {
        super.setSoLinger(soLinger);
        return this;
    }

    // override
    // NetClientOptions setUsePooledBuffers(bool usePooledBuffers) {
    //     super.setUsePooledBuffers(usePooledBuffers);
    //     return this;
    // }

    override
    NetClientOptions setIdleTimeout(Duration idleTimeout) {
        super.setIdleTimeout(idleTimeout);
        return this;
    }

    override
    NetClientOptions setSsl(bool ssl) {
        super.setSsl(ssl);
        return this;
    }

    // override
    // NetClientOptions setKeyCertOptions(KeyCertOptions options) {
    //     super.setKeyCertOptions(options);
    //     return this;
    // }

    // override
    // NetClientOptions setKeyStoreOptions(JksOptions options) {
    //     super.setKeyStoreOptions(options);
    //     return this;
    // }

    // override
    // NetClientOptions setPfxKeyCertOptions(PfxOptions options) {
    //     return cast(NetClientOptions) super.setPfxKeyCertOptions(options);
    // }

    // override
    // NetClientOptions setPemKeyCertOptions(PemKeyCertOptions options) {
    //     return cast(NetClientOptions) super.setPemKeyCertOptions(options);
    // }

    // override
    // NetClientOptions setTrustOptions(TrustOptions options) {
    //     super.setTrustOptions(options);
    //     return this;
    // }

    // override
    // NetClientOptions setTrustStoreOptions(JksOptions options) {
    //     super.setTrustStoreOptions(options);
    //     return this;
    // }

    // override
    // NetClientOptions setPemTrustOptions(PemTrustOptions options) {
    //     return cast(NetClientOptions) super.setPemTrustOptions(options);
    // }

    // override
    // NetClientOptions setPfxTrustOptions(PfxOptions options) {
    //     return cast(NetClientOptions) super.setPfxTrustOptions(options);
    // }

    // override
    // NetClientOptions addEnabledCipherSuite(string suite) {
    //     super.addEnabledCipherSuite(suite);
    //     return this;
    // }

    // override
    // NetClientOptions addEnabledSecureTransportProtocol(string protocol) {
    //     super.addEnabledSecureTransportProtocol(protocol);
    //     return this;
    // }

    // override
    // NetClientOptions removeEnabledSecureTransportProtocol(string protocol) {
    //     return cast(NetClientOptions) super.removeEnabledSecureTransportProtocol(protocol);
    // }

    override
    NetClientOptions setUseAlpn(bool useAlpn) {
        return cast(NetClientOptions) super.setUseAlpn(useAlpn);
    }

    // override
    // NetClientOptions setSslEngineOptions(SSLEngineOptions sslEngineOptions) {
    //     return cast(NetClientOptions) super.setSslEngineOptions(sslEngineOptions);
    // }

    // override
    // NetClientOptions setJdkSslEngineOptions(JdkSSLEngineOptions sslEngineOptions) {
    //     return cast(NetClientOptions) super.setJdkSslEngineOptions(sslEngineOptions);
    // }

    override
    NetClientOptions setTcpFastOpen(bool tcpFastOpen) {
        return cast(NetClientOptions) super.setTcpFastOpen(tcpFastOpen);
    }

    override
    NetClientOptions setTcpCork(bool tcpCork) {
        return cast(NetClientOptions) super.setTcpCork(tcpCork);
    }

    override
    NetClientOptions setTcpQuickAck(bool tcpQuickAck) {
        return cast(NetClientOptions) super.setTcpQuickAck(tcpQuickAck);
    }

    override
    ClientOptionsBase setOpenSslEngineOptions(OpenSSLEngineOptions sslEngineOptions) {
        return super.setOpenSslEngineOptions(sslEngineOptions);
    }

    // override
    // NetClientOptions addCrlPath(string crlPath) {
    //     return cast(NetClientOptions) super.addCrlPath(crlPath);
    // }

    // override
    // NetClientOptions addCrlValue(Buffer crlValue) {
    //     return cast(NetClientOptions) super.addCrlValue(crlValue);
    // }

    override
    NetClientOptions setTrustAll(bool trustAll) {
        super.setTrustAll(trustAll);
        return this;
    }

    override
    NetClientOptions setConnectTimeout(int connectTimeout) {
        super.setConnectTimeout(connectTimeout);
        return this;
    }

    override
    NetClientOptions setMetricsName(string metricsName) {
        return cast(NetClientOptions) super.setMetricsName(metricsName);
    }

    /**
     * Set the value of reconnect attempts
     *
     * @param attempts  the maximum number of reconnect attempts
     * @return a reference to this, so the API can be used fluently
     */
    NetClientOptions setReconnectAttempts(int attempts) {
        if (attempts < -1) {
            throw new IllegalArgumentException("reconnect attempts must be >= -1");
        }
        this.reconnectAttempts = attempts;
        return this;
    }

    /**
     * @return  the value of reconnect attempts
     */
    int getReconnectAttempts() {
        return reconnectAttempts;
    }

    /**
     * Set the reconnect interval
     *
     * @param interval  the reconnect interval in ms
     * @return a reference to this, so the API can be used fluently
     */
    NetClientOptions setReconnectInterval(long interval) {
        if (interval < 1) {
            throw new IllegalArgumentException("reconnect interval must be >= 1");
        }
        this.reconnectInterval = interval;
        return this;
    }

    /**
     * @return  the value of the hostname verification algorithm
     */

    string getHostnameVerificationAlgorithm() {
        return hostnameVerificationAlgorithm;
    }

    /**
     * Set the hostname verification algorithm interval
     * To disable hostname verification, set hostnameVerificationAlgorithm to an empty string
     *
     * @param hostnameVerificationAlgorithm should be HTTPS, LDAPS or an empty string
     * @return a reference to this, so the API can be used fluently
     */

    NetClientOptions setHostnameVerificationAlgorithm(string hostnameVerificationAlgorithm) {
        assert(!hostnameVerificationAlgorithm.empty, "hostnameVerificationAlgorithm can not be null!");
        this.hostnameVerificationAlgorithm = hostnameVerificationAlgorithm;
        return this;
    }

    /**
     * @return  the value of reconnect interval
     */
    long getReconnectInterval() {
        return reconnectInterval;
    }

    override
    NetClientOptions setLogActivity(bool logEnabled) {
        return cast(NetClientOptions) super.setLogActivity(logEnabled);
    }

    override NetClientOptions setProxyOptions(ProxyOptions proxyOptions) {
        return cast(NetClientOptions) super.setProxyOptions(proxyOptions);
    }

    override
    NetClientOptions setLocalAddress(string localAddress) {
        return cast(NetClientOptions) super.setLocalAddress(localAddress);
    }

    // override
    // NetClientOptions setEnabledSecureTransportProtocols(Set!(string) enabledSecureTransportProtocols) {
    //     return cast(NetClientOptions) super.setEnabledSecureTransportProtocols(enabledSecureTransportProtocols);
    // }

    override NetClientOptions setSslHandshakeTimeout(Duration sslHandshakeTimeout) {
        return cast(NetClientOptions) super.setSslHandshakeTimeout(sslHandshakeTimeout);
    }


    override
    bool opEquals(Object o) {
        if (this is o) return true;
        if (!super.opEquals(o)) return false;

        NetClientOptions that = cast(NetClientOptions) o;
        if(that is null) return false;

        if (reconnectAttempts != that.reconnectAttempts) return false;
        if (reconnectInterval != that.reconnectInterval) return false;
        if (hostnameVerificationAlgorithm != that.hostnameVerificationAlgorithm) return false;

        return true;
    }

    override
    size_t toHash() @trusted nothrow {
        size_t result = super.toHash();
        result = 31 * result + reconnectAttempts;
        result = 31 * result + cast(size_t) (reconnectInterval ^ (reconnectInterval >>> 32));
        result = 31 * result + hostnameVerificationAlgorithm.hashOf();
        return result;
    }

}
