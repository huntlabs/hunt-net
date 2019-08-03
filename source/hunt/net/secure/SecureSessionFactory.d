module hunt.net.secure.SecureSessionFactory;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.SecureSession;
import hunt.net.secure.SSLContextFactory;
import hunt.net.Connection;


/**
 * 
 */
interface SecureSessionFactory {

    SecureSession create(Connection session, bool clientMode,
                         SecureSessionHandshakeListener secureSessionHandshakeListener);

    SecureSession create(Connection session, bool clientMode,
                         string peerHost, int peerPort,
                         SecureSessionHandshakeListener secureSessionHandshakeListener);

    void setSupportedProtocols(string[] supportedProtocols);

    string[] getSupportedProtocols();

    SSLContextFactory getClientSSLContextFactory();

    void setClientSSLContextFactory(SSLContextFactory clientSSLContextFactory);

    SSLContextFactory getServerSSLContextFactory();

    void setServerSSLContextFactory(SSLContextFactory serverSSLContextFactory);

    // string sslCertificate();
    // void sslCertificate(string fileName);
    // string sslPrivateKey();
    // void sslPrivateKey(string fileName);
}
