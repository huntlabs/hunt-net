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

module hunt.net.ClientOptionsBase;

import hunt.net.ClientAuth;
import hunt.net.OpenSSLEngineOptions;
import hunt.net.ProxyOptions;
import hunt.net.TcpSslOptions;

import hunt.Exceptions;

import core.time;

/**
 * Base class for Client options
 *
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
abstract class ClientOptionsBase : TcpSslOptions {

    /**
     * The default value of connect timeout = 60000 ms
     */
    enum int DEFAULT_CONNECT_TIMEOUT = 60000;

    /**
     * The default value of whether all servers (SSL/TLS) should be trusted = false
     */
    enum bool DEFAULT_TRUST_ALL = false;

    /**
     * The default value of the client metrics = "":
     */
    enum string DEFAULT_METRICS_NAME = "";

    private Duration connectTimeout;
    private bool trustAll;
    private string metricsName;
    private ProxyOptions proxyOptions;
    private string localAddress;

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
    this(ClientOptionsBase other) {
        super(other);
        this.connectTimeout = other.getConnectTimeout();
        this.trustAll = other.isTrustAll();
        this.metricsName = other.metricsName;
        this.proxyOptions = other.proxyOptions !is null ? new ProxyOptions(other.proxyOptions) : null;
        this.localAddress = other.localAddress;
    }

    private void init() {
        this.connectTimeout = DEFAULT_CONNECT_TIMEOUT.msecs;
        this.trustAll = DEFAULT_TRUST_ALL;
        this.metricsName = DEFAULT_METRICS_NAME;
        this.proxyOptions = null;
        this.localAddress = null;
    }

    /**
     *
     * @return true if all server certificates should be trusted
     */
    bool isTrustAll() {
        return trustAll;
    }

    /**
     * Set whether all server certificates should be trusted
     *
     * @param trustAll true if all should be trusted
     * @return a reference to this, so the API can be used fluently
     */
    ClientOptionsBase setTrustAll(bool trustAll) {
        this.trustAll = trustAll;
        return this;
    }

    /**
     * @return the value of connect timeout
     */
    Duration getConnectTimeout() {
        return connectTimeout;
    }

    /**
     * Set the connect timeout
     *
     * @param connectTimeout  connect timeout, in ms
     * @return a reference to this, so the API can be used fluently
     */
    ClientOptionsBase setConnectTimeout(Duration connectTimeout) {
        if (connectTimeout < Duration.zero) {
            throw new IllegalArgumentException("connectTimeout must be >= 0");
        }
        this.connectTimeout = connectTimeout;
        return this;
    }

    /**
     * @return the metrics name identifying the reported metrics.
     */
    string getMetricsName() {
        return metricsName;
    }

    /**
     * Set the metrics name identifying the reported metrics, useful for grouping metrics
     * with the same name.
     *
     * @param metricsName the metrics name
     * @return a reference to this, so the API can be used fluently
     */
    ClientOptionsBase setMetricsName(string metricsName) {
        this.metricsName = metricsName;
        return this;
    }

    /**
     * Set proxy options for connections via CONNECT proxy (e.g. Squid) or a SOCKS proxy.
     *
     * @param proxyOptions proxy options object
     * @return a reference to this, so the API can be used fluently
     */
    ClientOptionsBase setProxyOptions(ProxyOptions proxyOptions) {
        this.proxyOptions = proxyOptions;
        return this;
    }

    /**
     * Get proxy options for connections
     *
     * @return proxy options
     */
    ProxyOptions getProxyOptions() {
        return proxyOptions;
    }

    /**
     * @return the local interface to bind for network connections.
     */
    string getLocalAddress() {
        return localAddress;
    }

    /**
     * Set the local interface to bind for network connections. When the local address is null,
     * it will pick any local address, the default local address is null.
     *
     * @param localAddress the local address
     * @return a reference to this, so the API can be used fluently
     */
    ClientOptionsBase setLocalAddress(string localAddress) {
        this.localAddress = localAddress;
        return this;
    }

    override
    ClientOptionsBase setLogActivity(bool logEnabled) {
        return cast(ClientOptionsBase) super.setLogActivity(logEnabled);
    }

    override
    ClientOptionsBase setTcpNoDelay(bool tcpNoDelay) {
        return cast(ClientOptionsBase) super.setTcpNoDelay(tcpNoDelay);
    }

    override
    ClientOptionsBase setTcpKeepAlive(bool tcpKeepAlive) {
        return cast(ClientOptionsBase) super.setTcpKeepAlive(tcpKeepAlive);
    }

    override
    ClientOptionsBase setSoLinger(int soLinger) {
        return cast(ClientOptionsBase) super.setSoLinger(soLinger);
    }

    // override
    // ClientOptionsBase setUsePooledBuffers(bool usePooledBuffers) {
    //     return cast(ClientOptionsBase) super.setUsePooledBuffers(usePooledBuffers);
    // }

    override
    ClientOptionsBase setIdleTimeout(Duration idleTimeout) {
        return cast(ClientOptionsBase) super.setIdleTimeout(idleTimeout);
    }

    // override
    // ClientOptionsBase setIdleTimeoutUnit(TimeUnit idleTimeoutUnit) {
    //     return cast(ClientOptionsBase) super.setIdleTimeoutUnit(idleTimeoutUnit);
    // }

    override
    ClientOptionsBase setSsl(bool ssl) {
        return cast(ClientOptionsBase) super.setSsl(ssl);
    }

    // override
    // ClientOptionsBase setKeyCertOptions(KeyCertOptions options) {
    //     return cast(ClientOptionsBase) super.setKeyCertOptions(options);
    // }

    // override
    // ClientOptionsBase setKeyStoreOptions(JksOptions options) {
    //     return cast(ClientOptionsBase) super.setKeyStoreOptions(options);
    // }

    // override
    // ClientOptionsBase setPfxKeyCertOptions(PfxOptions options) {
    //     return cast(ClientOptionsBase) super.setPfxKeyCertOptions(options);
    // }

    // override
    // ClientOptionsBase setPemKeyCertOptions(PemKeyCertOptions options) {
    //     return cast(ClientOptionsBase) super.setPemKeyCertOptions(options);
    // }

    // override
    // ClientOptionsBase setTrustOptions(TrustOptions options) {
    //     return cast(ClientOptionsBase) super.setTrustOptions(options);
    // }

    // override
    // ClientOptionsBase setTrustStoreOptions(JksOptions options) {
    //     return cast(ClientOptionsBase) super.setTrustStoreOptions(options);
    // }

    // override
    // ClientOptionsBase setPfxTrustOptions(PfxOptions options) {
    //     return cast(ClientOptionsBase) super.setPfxTrustOptions(options);
    // }

    // override
    // ClientOptionsBase setPemTrustOptions(PemTrustOptions options) {
    //     return cast(ClientOptionsBase) super.setPemTrustOptions(options);
    // }

    override
    ClientOptionsBase setUseAlpn(bool useAlpn) {
        return cast(ClientOptionsBase) super.setUseAlpn(useAlpn);
    }

    // override
    // ClientOptionsBase setSslEngineOptions(SSLEngineOptions sslEngineOptions) {
    //     return cast(ClientOptionsBase) super.setSslEngineOptions(sslEngineOptions);
    // }

    // override
    // ClientOptionsBase setJdkSslEngineOptions(JdkSSLEngineOptions sslEngineOptions) {
    //     return cast(ClientOptionsBase) super.setJdkSslEngineOptions(sslEngineOptions);
    // }

    override
    ClientOptionsBase setOpenSslEngineOptions(OpenSSLEngineOptions sslEngineOptions) {
        return cast(ClientOptionsBase) super.setOpenSslEngineOptions(sslEngineOptions);
    }

    override
    ClientOptionsBase setSendBufferSize(int sendBufferSize) {
        return cast(ClientOptionsBase) super.setSendBufferSize(sendBufferSize);
    }

    override
    ClientOptionsBase setReceiveBufferSize(int receiveBufferSize) {
        return cast(ClientOptionsBase) super.setReceiveBufferSize(receiveBufferSize);
    }

    override
    ClientOptionsBase setReuseAddress(bool reuseAddress) {
        return cast(ClientOptionsBase) super.setReuseAddress(reuseAddress);
    }

    override
    ClientOptionsBase setReusePort(bool reusePort) {
        return cast(ClientOptionsBase) super.setReusePort(reusePort);
    }

    override
    ClientOptionsBase setTrafficClass(int trafficClass) {
        return cast(ClientOptionsBase) super.setTrafficClass(trafficClass);
    }

    // override
    // ClientOptionsBase addEnabledCipherSuite(string suite) {
    //     return cast(ClientOptionsBase) super.addEnabledCipherSuite(suite);
    // }

    // override
    // ClientOptionsBase addCrlPath(string crlPath) {
    //     return cast(ClientOptionsBase) super.addCrlPath(crlPath);
    // }

    // override
    // ClientOptionsBase addCrlValue(Buffer crlValue) {
    //     return cast(ClientOptionsBase) super.addCrlValue(crlValue);
    // }

    // override
    // ClientOptionsBase addEnabledSecureTransportProtocol(string protocol) {
    //     return cast(ClientOptionsBase) super.addEnabledSecureTransportProtocol(protocol);
    // }

    // override
    // ClientOptionsBase removeEnabledSecureTransportProtocol(string protocol) {
    //     return cast(ClientOptionsBase) super.removeEnabledSecureTransportProtocol(protocol);
    // }

    override
    ClientOptionsBase setTcpFastOpen(bool tcpFastOpen) {
        return cast(ClientOptionsBase) super.setTcpFastOpen(tcpFastOpen);
    }

    override
    ClientOptionsBase setTcpCork(bool tcpCork) {
        return cast(ClientOptionsBase) super.setTcpCork(tcpCork);
    }

    override
    ClientOptionsBase setTcpQuickAck(bool tcpQuickAck) {
        return cast(ClientOptionsBase) super.setTcpQuickAck(tcpQuickAck);
    }

    override
    bool opEquals(Object o) {
        if (this is o) return true;
        if (!super.opEquals(o)) return false;

        ClientOptionsBase that = cast(ClientOptionsBase) o;
        if(that is null)
            return false;

        if (connectTimeout != that.connectTimeout) return false;
        if (trustAll != that.trustAll) return false;
        if (metricsName != that.metricsName) return false;
        if (proxyOptions != that.proxyOptions) return false;
        if (localAddress != that.localAddress) return false;

        return true;
    }

    override
    size_t toHash() @trusted nothrow {
        size_t result = super.toHash();
        result = 31 * result + cast(size_t)connectTimeout.total!("msecs")();
        result = 31 * result + (trustAll ? 1 : 0);
        result = 31 * result + metricsName.hashOf();
        result = 31 * result + proxyOptions.hashOf();
        result = 31 * result + localAddress.hashOf();
        return result;
    }
}
