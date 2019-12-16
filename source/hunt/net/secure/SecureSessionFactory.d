module hunt.net.secure.SecureSessionFactory;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.SecureSession;
import hunt.net.secure.SSLContextFactory;

import hunt.net.Connection;
import hunt.net.KeyCertOptions;


/**
 * 
 */
interface SecureSessionFactory {

    SecureSession create(Connection session, bool clientMode,
                         SecureSessionHandshakeListener secureSessionHandshakeListener);

    deprecated("Unsupported anymore!")
    SecureSession create(Connection session, bool clientMode,
                         string peerHost, int peerPort,
                         SecureSessionHandshakeListener secureSessionHandshakeListener);

    SecureSession create(Connection session, bool clientMode,
                         SecureSessionHandshakeListener secureSessionHandshakeListener, 
                         KeyCertOptions options);

    void setSupportedProtocols(string[] supportedProtocols);

    string[] getSupportedProtocols();

    SSLContextFactory getClientSSLContextFactory();

    void setClientSSLContextFactory(SSLContextFactory clientSSLContextFactory);

    SSLContextFactory getServerSSLContextFactory();

    void setServerSSLContextFactory(SSLContextFactory serverSSLContextFactory);
}
