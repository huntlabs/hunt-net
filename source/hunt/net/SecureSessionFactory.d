module hunt.net.SecureSessionFactory;

import hunt.container.List;

import hunt.net.SecureSession;
import hunt.net.Session;

// interface SecureSessionHandshakeListener {

//     void complete(SecureSession secureSession);

// }

alias SecureSessionHandshakeListener = void delegate(SecureSession secureSession);

/**
 * 
 */
interface SecureSessionFactory {

    SecureSession create(Session session, bool clientMode,
                         SecureSessionHandshakeListener secureSessionHandshakeListener);

    SecureSession create(Session session, bool clientMode,
                         string peerHost, int peerPort,
                         SecureSessionHandshakeListener secureSessionHandshakeListener);

    void setSupportedProtocols(List!string supportedProtocols);

    List!string getSupportedProtocols();

}
