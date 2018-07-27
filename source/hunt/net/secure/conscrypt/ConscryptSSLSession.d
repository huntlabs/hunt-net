module hunt.net.secure.conscrypt.ConscryptSSLSession;

public class ConscryptSSLSession : AbstractSecureSession {

    public this(Session session, SSLEngine sslEngine,
                               ApplicationProtocolSelector applicationProtocolSelector,
                               SecureSessionHandshakeListener handshakeListener) {
        super(session, sslEngine, applicationProtocolSelector, handshakeListener);
    }
}
