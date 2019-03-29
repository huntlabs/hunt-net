module hunt.net.secure.SecureSessionFactory;

// dfmt off
version(Have_hunt_security):
// dfmt on

import hunt.net.secure.SecureSession;
import hunt.net.secure.SSLContextFactory;
import hunt.net.Session;


/**
 * 
 */
interface SecureSessionFactory {

    SecureSession create(Session session, bool clientMode,
                         SecureSessionHandshakeListener secureSessionHandshakeListener);

    SecureSession create(Session session, bool clientMode,
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
