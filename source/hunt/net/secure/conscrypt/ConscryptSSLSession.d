module hunt.net.secure.conscrypt.ConscryptSSLSession;

import hunt.net.Session;

import hunt.net.ssl.common;
import hunt.net.ssl.SSLEngine;

import hunt.net.secure.AbstractSecureSession;
import hunt.net.secure.SecureSession;
import hunt.net.secure.ProtocolSelector;

public class ConscryptSSLSession : AbstractSecureSession {

    public this(Session session, SSLEngine sslEngine,
                               ProtocolSelector applicationProtocolSelector,
                               SecureSessionHandshakeListener handshakeListener) {
        super(session, sslEngine, applicationProtocolSelector, handshakeListener);
    }
}
