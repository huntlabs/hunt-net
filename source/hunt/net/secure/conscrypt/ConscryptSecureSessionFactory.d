module hunt.net.secure.conscrypt.ConscryptSecureSessionFactory;

import hunt.net.secure.SSLContextFactory;
import hunt.net.secure.conscrypt.AbstractConscryptSSLContextFactory;
import hunt.net.secure.conscrypt.ApplicationProtocolSelector;
import hunt.net.secure.conscrypt.ConscryptSSLSession;

import hunt.net.secure.ProtocolSelector;
import hunt.net.secure.SecureSession;

import hunt.net.secure.SecureSessionFactory;
import hunt.net.Session;
import hunt.net.ssl;

import hunt.util.exception;
import hunt.util.TypeUtils;

import kiss.logger;
import std.typecons;

/**
*/
class ConscryptSecureSessionFactory : SecureSessionFactory {

    private SSLContextFactory clientSSLContextFactory; 
    private SSLContextFactory serverSSLContextFactory; 
    private string[] supportedProtocols;

    this() {
        clientSSLContextFactory = new NoCheckConscryptSSLContextFactory();
        serverSSLContextFactory = new DefaultCredentialConscryptSSLContextFactory();
    }

    this(SSLContextFactory clientSSLContextFactory, SSLContextFactory serverSSLContextFactory) {
        this.clientSSLContextFactory = clientSSLContextFactory;
        this.serverSSLContextFactory = serverSSLContextFactory;
    }

    SSLContextFactory getClientSSLContextFactory() {
        return clientSSLContextFactory;
    }

    void setClientSSLContextFactory(SSLContextFactory clientSSLContextFactory) {
        this.clientSSLContextFactory = clientSSLContextFactory;
    }

    SSLContextFactory getServerSSLContextFactory() {
        return serverSSLContextFactory;
    }

    void setServerSSLContextFactory(SSLContextFactory serverSSLContextFactory) {
        this.serverSSLContextFactory = serverSSLContextFactory;
    }

    override
    SecureSession create(Session session, bool clientMode, 
        SecureSessionHandshakeListener secureSessionHandshakeListener) {
        SSLContextFactory sslContextFactory = from(clientMode);
        sslContextFactory.setSupportedProtocols(supportedProtocols);
        Pair!(SSLEngine, ProtocolSelector) p = sslContextFactory.createSSLEngine(clientMode);
        return new ConscryptSSLSession(session, p.first, p.second, secureSessionHandshakeListener);
    }

    override
    SecureSession create(Session session, bool clientMode, string peerHost, int peerPort, 
        SecureSessionHandshakeListener secureSessionHandshakeListener) {
        SSLContextFactory sslContextFactory = from(clientMode);
        sslContextFactory.setSupportedProtocols(supportedProtocols);
        Pair!(SSLEngine, ProtocolSelector) p = sslContextFactory.createSSLEngine(clientMode, peerHost, peerPort);
        return new ConscryptSSLSession(session, p.first, p.second, secureSessionHandshakeListener);
    }

    protected SSLContextFactory from(bool clientMode) {
        return clientMode ? clientSSLContextFactory : serverSSLContextFactory;
    }

    override
    string[] getSupportedProtocols() {
        return supportedProtocols;
    }

    override
    void setSupportedProtocols(string[] supportedProtocols) {
        this.supportedProtocols = supportedProtocols;
    }
}
