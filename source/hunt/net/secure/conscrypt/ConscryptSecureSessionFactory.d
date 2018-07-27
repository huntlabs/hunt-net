module hunt.net.secure.conscrypt.ConscryptSecureSessionFactory;

import hunt.net.secure.conscrypt.AbstractConscryptSSLContextFactory;
import hunt.net.secure.conscrypt.ConscryptSSLSession;

import hunt.net.secure.SecureUtils;

import hunt.net.SecureSession;
import hunt.net.ssl;

import hunt.io.ByteArrayInputStream;
import hunt.util.exception;

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
        Tuple!(SSLEngine, ApplicationProtocolSelector) p = sslContextFactory.createSSLEngine(clientMode);
        return new ConscryptSSLSession(session, p.first, p.second, secureSessionHandshakeListener);
    }

    override
    SecureSession create(Session session, bool clientMode, string peerHost, int peerPort, 
        SecureSessionHandshakeListener secureSessionHandshakeListener) {
        SSLContextFactory sslContextFactory = from(clientMode);
        sslContextFactory.setSupportedProtocols(supportedProtocols);
        Tuple!(SSLEngine, ApplicationProtocolSelector) p = sslContextFactory.createSSLEngine(clientMode, peerHost, peerPort);
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


/**
*/
public class NoCheckConscryptSSLContextFactory : AbstractConscryptSSLContextFactory {
    override
    public SSLContext getSSLContext() {
        try {
            // return getSSLContextWithManager(null, new TrustManager[]{SecureUtils.createX509TrustManagerNoCheck()}, null);
            implementationMissing(false);
            return null;
        } catch (Exception e) {
            errorf("get SSL context error", e);
            return null;
        }
    }
}

public class DefaultCredentialConscryptSSLContextFactory : AbstractConscryptSSLContextFactory {
    override
    public SSLContext getSSLContext() {
        try {
            return getSSLContext(new ByteArrayInputStream(SecureUtils.DEFAULT_CREDENTIAL), "ptmima1234", "ptmima4321");
        } catch (Exception e) {
            errorf("get SSL context error", e);
            return null;
        }
    }
}
