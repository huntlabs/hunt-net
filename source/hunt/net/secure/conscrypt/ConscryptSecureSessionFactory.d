module hunt.net.secure.conscrypt.ConscryptSecureSessionFactory;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.conscrypt.AbstractConscryptSSLContextFactory;
import hunt.net.secure.conscrypt.ApplicationProtocolSelector;
import hunt.net.secure.conscrypt.ConscryptSSLSession;

import hunt.net.secure.ProtocolSelector;
import hunt.net.secure.SecureSession;
import hunt.net.secure.SecureSessionFactory;
import hunt.net.secure.SSLContextFactory;

import hunt.net.Connection;
import hunt.net.KeyCertOptions;
import hunt.net.ssl;

import hunt.Exceptions;
import hunt.logging;
import hunt.util.TypeUtils;

import std.typecons;

/**
 * 
 */
class ConscryptSecureSessionFactory : SecureSessionFactory {

    private SSLContextFactory clientSSLContextFactory; 
    private SSLContextFactory serverSSLContextFactory; 
    private string[] supportedProtocols;

    this() {
        // clientSSLContextFactory = new NoCheckConscryptSSLContextFactory();
        // serverSSLContextFactory = new DefaultCredentialConscryptSSLContextFactory();
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

    SecureSession create(Connection session, bool clientMode, 
        SecureSessionHandshakeListener secureSessionHandshakeListener) {

        SSLContextFactory sslContextFactory = from(clientMode);
        sslContextFactory.setSupportedProtocols(supportedProtocols);
        Pair!(SSLEngine, ProtocolSelector) p = sslContextFactory.createSSLEngine(clientMode);
        return new ConscryptSSLSession(session, p.first, p.second, secureSessionHandshakeListener);
    }

    SecureSession create(Connection session, bool clientMode,
            SecureSessionHandshakeListener secureSessionHandshakeListener, 
            KeyCertOptions options) {
        
        // assert(clientMode, "only client"); // only client

        SSLContextFactory sslContextFactory = new FileCredentialConscryptSSLContextFactory(options);
        sslContextFactory.setSupportedProtocols(supportedProtocols);
        Pair!(SSLEngine, ProtocolSelector) p = sslContextFactory.createSSLEngine(clientMode);
        
        return new ConscryptSSLSession(session, p.first, p.second, secureSessionHandshakeListener);
    }

    protected SSLContextFactory from(bool clientMode) {
        version(HUNT_NET_DEBUG) warning("clientMode: ", clientMode);
        return clientMode ? clientSSLContextFactory : serverSSLContextFactory;
    }

    string[] getSupportedProtocols() {
        return supportedProtocols;
    }

    void setSupportedProtocols(string[] supportedProtocols) {
        this.supportedProtocols = supportedProtocols;
    }

}
