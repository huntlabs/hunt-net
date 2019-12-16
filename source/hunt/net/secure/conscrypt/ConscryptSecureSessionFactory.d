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

    SecureSession create(Connection session, bool clientMode, 
        SecureSessionHandshakeListener secureSessionHandshakeListener) {

        SSLContextFactory sslContextFactory = from(clientMode);
        sslContextFactory.setSupportedProtocols(supportedProtocols);
        Pair!(SSLEngine, ProtocolSelector) p = sslContextFactory.createSSLEngine(clientMode);
        
        // if(clientMode)
        //     p = sslContextFactory.createSSLEngine(clientMode);
        // else
        //     p = sslContextFactory.createSSLEngine(_sslCertificate, _sslPrivateKey, "hunt2018", "hunt2018");
        return new ConscryptSSLSession(session, p.first, p.second, secureSessionHandshakeListener);
    }

    deprecated("Unsupported anymore!")
    SecureSession create(Connection session, bool clientMode, string peerHost, int peerPort, 
        SecureSessionHandshakeListener secureSessionHandshakeListener) {
            
        SSLContextFactory sslContextFactory = from(clientMode);
        sslContextFactory.setSupportedProtocols(supportedProtocols);
        Pair!(SSLEngine, ProtocolSelector) p = sslContextFactory.createSSLEngine(clientMode, peerHost, peerPort);
        return new ConscryptSSLSession(session, p.first, p.second, secureSessionHandshakeListener);
    }

    SecureSession create(Connection session, bool clientMode,
            SecureSessionHandshakeListener secureSessionHandshakeListener, 
            KeyCertOptions options) {
        
        assert(clientMode); // only client

        FileCredentialConscryptSSLContextFactory fc = 
            new FileCredentialConscryptSSLContextFactory(options);
        // SSLContext context = fc.getSSLContext();

        SSLContextFactory sslContextFactory = fc;
        sslContextFactory.setSupportedProtocols(supportedProtocols);
        Pair!(SSLEngine, ProtocolSelector) p = sslContextFactory.createSSLEngine(clientMode);
        
        // if(clientMode)
        //     p = sslContextFactory.createSSLEngine(clientMode);
        // else
        //     p = sslContextFactory.createSSLEngine(_sslCertificate, _sslPrivateKey, "hunt2018", "hunt2018");
        return new ConscryptSSLSession(session, p.first, p.second, secureSessionHandshakeListener);
                
    }

    protected SSLContextFactory from(bool clientMode) {
        return clientMode ? clientSSLContextFactory : serverSSLContextFactory;
    }

    string[] getSupportedProtocols() {
        return supportedProtocols;
    }

    void setSupportedProtocols(string[] supportedProtocols) {
        this.supportedProtocols = supportedProtocols;
    }

    // string sslCertificate() {
    //     return _sslCertificate;
    // }

    // void sslCertificate(string fileName) {
    //     _sslCertificate = fileName;
    // }

    // string sslPrivateKey() {
    //     return _sslPrivateKey;
    // }

    // void sslPrivateKey(string fileName) {
    //     _sslPrivateKey = fileName;
    // }


    // private string _sslCertificate;
    // private string _sslPrivateKey;

}
