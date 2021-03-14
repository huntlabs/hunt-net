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

module hunt.net.NetServerOptions;

import hunt.net.ClientAuth;
import hunt.net.OpenSSLEngineOptions;
import hunt.net.TcpSslOptions;

import hunt.Exceptions;
import hunt.io.TcpStreamOptions;
import hunt.system.Memory;

import core.time;

/**
 * Options for configuring a {@link hunt.net.NetServer}.
 *
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
class NetServerOptions : TcpSslOptions {

    // Server specific HTTP stuff

    /**
     * The default port to listen on = 0 (meaning a random ephemeral free port will be chosen)
     */
    enum int DEFAULT_PORT = 0;

    /**
     * The default host to listen on = "0.0.0.0" (meaning listen on all available interfaces).
     */
    enum string DEFAULT_HOST = "0.0.0.0";

    /**
     * The default accept backlog = 1024
     */
    enum int DEFAULT_ACCEPT_BACKLOG = -1;

    /**
     * Default value of whether client auth is required (SSL/TLS) = No
     */
    enum ClientAuth DEFAULT_CLIENT_AUTH = ClientAuth.NONE;

    /**
     * Default value of whether the server supports SNI = false
     */
    enum bool DEFAULT_SNI = false;

    private ushort port;
    private string host;
    private int acceptBacklog;
    private ClientAuth clientAuth;
    private bool sni;
    private size_t _workerThreadSize = 0;
    private size_t _ioThreadSize = 2;

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
    this(NetServerOptions other) {
        super(other);
        this.port = other.getPort();
        this.host = other.getHost();
        this.acceptBacklog = other.getAcceptBacklog();
        this.clientAuth = other.getClientAuth();
        this.sni = other.isSni();
        _workerThreadSize = other._workerThreadSize;
        _ioThreadSize = other._ioThreadSize;
    }

    size_t ioThreadSize() {
        return _ioThreadSize;
    }

    NetServerOptions ioThreadSize(size_t value) {
        _ioThreadSize = value;
        return this;
    }

    size_t workerThreadSize() {
        return _workerThreadSize;
    }

    NetServerOptions workerThreadSize(size_t value) {
        _workerThreadSize = value;
        return this;
    }

    override NetServerOptions setSendBufferSize(int sendBufferSize) {
        super.setSendBufferSize(sendBufferSize);
        return this;
    }

    override NetServerOptions setReceiveBufferSize(int receiveBufferSize) {
        super.setReceiveBufferSize(receiveBufferSize);
        return this;
    }

    override NetServerOptions setReuseAddress(bool reuseAddress) {
        super.setReuseAddress(reuseAddress);
        return this;
    }

    override NetServerOptions setReusePort(bool reusePort) {
        super.setReusePort(reusePort);
        return this;
    }

    override NetServerOptions setTrafficClass(int trafficClass) {
        super.setTrafficClass(trafficClass);
        return this;
    }

    override NetServerOptions setTcpNoDelay(bool tcpNoDelay) {
        super.setTcpNoDelay(tcpNoDelay);
        return this;
    }

    override NetServerOptions setTcpKeepAlive(bool tcpKeepAlive) {
        super.setTcpKeepAlive(tcpKeepAlive);
        return this;
    }

    override NetServerOptions setSoLinger(int soLinger) {
        super.setSoLinger(soLinger);
        return this;
    }

    // override
    // NetServerOptions setUsePooledBuffers(bool usePooledBuffers) {
    //     super.setUsePooledBuffers(usePooledBuffers);
    //     return this;
    // }

    override NetServerOptions setIdleTimeout(Duration idleTimeout) {
        super.setIdleTimeout(idleTimeout);
        return this;
    }

    override NetServerOptions setSsl(bool ssl) {
        super.setSsl(ssl);
        return this;
    }

    override NetServerOptions setUseAlpn(bool useAlpn) {
        super.setUseAlpn(useAlpn);
        return this;
    }

    // override
    // NetServerOptions setSslEngineOptions(SSLEngineOptions sslEngineOptions) {
    //     super.setSslEngineOptions(sslEngineOptions);
    //     return this;
    // }

    // override
    // NetServerOptions setJdkSslEngineOptions(JdkSSLEngineOptions sslEngineOptions) {
    //     return cast(NetServerOptions) super.setSslEngineOptions(sslEngineOptions);
    // }

    override NetServerOptions setOpenSslEngineOptions(OpenSSLEngineOptions sslEngineOptions) {
        return cast(NetServerOptions) super.setOpenSslEngineOptions(sslEngineOptions);
    }

    // override
    // NetServerOptions setKeyCertOptions(KeyCertOptions options) {
    //     super.setKeyCertOptions(options);
    //     return this;
    // }

    // override
    // NetServerOptions setKeyStoreOptions(JksOptions options) {
    //     super.setKeyStoreOptions(options);
    //     return this;
    // }

    // override
    // NetServerOptions setPfxKeyCertOptions(PfxOptions options) {
    //     return cast(NetServerOptions) super.setPfxKeyCertOptions(options);
    // }

    // override
    // NetServerOptions setPemKeyCertOptions(PemKeyCertOptions options) {
    //     return cast(NetServerOptions) super.setPemKeyCertOptions(options);
    // }

    // override
    // NetServerOptions setTrustOptions(TrustOptions options) {
    //     super.setTrustOptions(options);
    //     return this;
    // }

    // override
    // NetServerOptions setTrustStoreOptions(JksOptions options) {
    //     super.setTrustStoreOptions(options);
    //     return this;
    // }

    // override
    // NetServerOptions setPfxTrustOptions(PfxOptions options) {
    //     return cast(NetServerOptions) super.setPfxTrustOptions(options);
    // }

    // override
    // NetServerOptions setPemTrustOptions(PemTrustOptions options) {
    //     return cast(NetServerOptions) super.setPemTrustOptions(options);
    // }

    // override
    // NetServerOptions addEnabledCipherSuite(string suite) {
    //     super.addEnabledCipherSuite(suite);
    //     return this;
    // }

    // override
    // NetServerOptions addEnabledSecureTransportProtocol(string protocol) {
    //     super.addEnabledSecureTransportProtocol(protocol);
    //     return this;
    // }

    // override
    // NetServerOptions removeEnabledSecureTransportProtocol(string protocol) {
    //     return cast(NetServerOptions) super.removeEnabledSecureTransportProtocol(protocol);
    // }

    override NetServerOptions setTcpFastOpen(bool tcpFastOpen) {
        return cast(NetServerOptions) super.setTcpFastOpen(tcpFastOpen);
    }

    override NetServerOptions setTcpCork(bool tcpCork) {
        return cast(NetServerOptions) super.setTcpCork(tcpCork);
    }

    override NetServerOptions setTcpQuickAck(bool tcpQuickAck) {
        return cast(NetServerOptions) super.setTcpQuickAck(tcpQuickAck);
    }

    // override
    // NetServerOptions addCrlPath(string crlPath) {
    //     return cast(NetServerOptions) super.addCrlPath(crlPath);
    // }

    // override
    // NetServerOptions addCrlValue(Buffer crlValue) {
    //     return cast(NetServerOptions) super.addCrlValue(crlValue);
    // }

    // override
    // NetServerOptions setEnabledSecureTransportProtocols(Set!(string) enabledSecureTransportProtocols) {
    //     return cast(NetServerOptions) super.setEnabledSecureTransportProtocols(enabledSecureTransportProtocols);
    // }

    override NetServerOptions setSslHandshakeTimeout(Duration sslHandshakeTimeout) {
        return cast(NetServerOptions) super.setSslHandshakeTimeout(sslHandshakeTimeout);
    }

    // override
    // NetServerOptions setSslHandshakeTimeoutUnit(TimeUnit sslHandshakeTimeoutUnit) {
    //     return cast(NetServerOptions) super.setSslHandshakeTimeoutUnit(sslHandshakeTimeoutUnit);
    // }

    /**
     * @return the value of accept backlog
     */
    int getAcceptBacklog() {
        return acceptBacklog;
    }

    /**
     * Set the accept back log
     *
     * @param acceptBacklog accept backlog
     * @return a reference to this, so the API can be used fluently
     */
    NetServerOptions setAcceptBacklog(int acceptBacklog) {
        this.acceptBacklog = acceptBacklog;
        return this;
    }

    /**
     *
     * @return the port
     */
    ushort getPort() {
        return port;
    }

    /**
     * Set the port
     *
     * @param port  the port
     * @return a reference to this, so the API can be used fluently
     */
    NetServerOptions setPort(ushort port) {
        this.port = port;
        return this;
    }

    /**
     *
     * @return the host
     */
    string getHost() {
        return host;
    }

    /**
     * Set the host
     * @param host  the host
     * @return a reference to this, so the API can be used fluently
     */
    NetServerOptions setHost(string host) {
        this.host = host;
        return this;
    }

    ClientAuth getClientAuth() {
        return clientAuth;
    }

    /**
     * Set whether client auth is required
     *
     * @param clientAuth One of "NONE, REQUEST, REQUIRED". If it's set to "REQUIRED" then server will require the
     *                   SSL cert to be presented otherwise it won't accept the request. If it's set to "REQUEST" then
     *                   it won't mandate the certificate to be presented, basically make it optional.
     * @return a reference to this, so the API can be used fluently
     */
    NetServerOptions setClientAuth(ClientAuth clientAuth) {
        this.clientAuth = clientAuth;
        return this;
    }

    override NetServerOptions setLogActivity(bool logEnabled) {
        return cast(NetServerOptions) super.setLogActivity(logEnabled);
    }

    /**
     * @return whether the server supports Server Name Indication
     */
    bool isSni() {
        return sni;
    }

    /**
     * Set whether the server supports Server Name Indiciation
     *
     * @return a reference to this, so the API can be used fluently
     */
    NetServerOptions setSni(bool sni) {
        this.sni = sni;
        return this;
    }

    override bool opEquals(Object o) {
        if (this is o)
            return true;
        if (!super.opEquals(o))
            return false;

        NetServerOptions that = cast(NetServerOptions) o;
        if (that is null)
            return false;

        if (acceptBacklog != that.acceptBacklog)
            return false;
        if (clientAuth != that.clientAuth)
            return false;
        if (port != that.port)
            return false;
        if (host != that.host)
            return false;
        if (sni != that.sni)
            return false;

        return true;
    }

    override size_t toHash() @trusted nothrow {
        size_t result = super.toHash();
        result = 31 * result + port;
        result = 31 * result + (host !is null ? host.hashOf() : 0);
        result = 31 * result + acceptBacklog;
        result = 31 * result + clientAuth.hashOf();
        result = 31 * result + (sni ? 1 : 0);
        return result;
    }

    private void init() {
        this.port = DEFAULT_PORT;
        this.host = DEFAULT_HOST;
        this.acceptBacklog = DEFAULT_ACCEPT_BACKLOG;
        this.clientAuth = DEFAULT_CLIENT_AUTH;
        this.sni = DEFAULT_SNI;
        _ioThreadSize = totalCPUs - 1;

        this.setTcpKeepAlive(true);
    }
}
