module hunt.net.secure.conscrypt.ActiveSession;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.conscrypt.AbstractSessionContext;
import hunt.net.secure.conscrypt.ConscryptSession;
import hunt.net.secure.conscrypt.NativeSsl;
import hunt.net.secure.conscrypt.NativeConstants;
import hunt.net.secure.conscrypt.SSLNullSession;
import hunt.net.secure.conscrypt.SSLUtils;

import hunt.net.ssl.SSLSessionContext;

// import hunt.security.cert.Certificate;
// import hunt.security.cert.X509Certificate;
// import hunt.security.Principal;

import hunt.net.ssl.SSLSession;
import hunt.net.Exceptions;

import hunt.collection;

import hunt.util.DateTime;
import hunt.Exceptions;

import hunt.logging;

import std.datetime;

/**
 * A session that is dedicated a single connection and operates directly on the underlying
 * {@code SSL}.
 */
final class ActiveSession : ConscryptSession {
    private NativeSsl ssl;
    private AbstractSessionContext sessionContext;
    private byte[] id;
    private long creationTime;
    private string protocol;
    private string peerHost;
    private int peerPort = -1;
    private long lastAccessedTime = 0;
    // private X509Certificate[] peerCertificateChain;
    // private X509Certificate[] localCertificates;
    // private X509Certificate[] peerCertificates;
    private byte[] peerCertificateOcspData;
    private byte[] peerTlsSctData;

    this(NativeSsl ssl, AbstractSessionContext sessionContext) {
        this.ssl = ssl;
        this.sessionContext = sessionContext;
    }

    override
    byte[] getId() {
        if (id is null) {
            synchronized (ssl) {
                id = ssl.getSessionId();
            }
        }
        return id !is null ? id.dup : [];
    }

    /**
     * Indicates that this session's ID may have changed and should be re-cached.
     */
    void resetId() {
        id = null;
    }

    override
    SSLSessionContext getSessionContext() {
        return isValid() ? sessionContext : null;
    }

    override
    long getCreationTime() {
        if (creationTime == 0) {
            synchronized (ssl) {
                creationTime = ssl.getTime();
            }
        }
        return creationTime;
    }

    /**
     * Returns the last time this SSL session was accessed. Accessing
     * here is to mean that a new connection with the same SSL context data was
     * established.
     *
     * @return the session's last access time in milliseconds since the epoch
     */
    // TODO(nathanmittler): Does lastAccessedTime need to account for session reuse?
    override
    long getLastAccessedTime() {
        return lastAccessedTime == 0 ? getCreationTime() : lastAccessedTime;
    }

    void setLastAccessedTime(long accessTimeMillis) {
        lastAccessedTime = accessTimeMillis;
    }

    /**
     * Returns the OCSP stapled response. Returns a copy of the internal arrays.
     *
     * The method signature matches
     * <a
     * href="http://download.java.net/java/jdk9/docs/api/javax/net/ssl/ExtendedSSLSession.html#getStatusResponses--">Java
     * 9</a>.
     *
     * @see <a href="https://tools.ietf.org/html/rfc6066">RFC 6066</a>
     * @see <a href="https://tools.ietf.org/html/rfc6961">RFC 6961</a>
     */
    override
    List!(byte[]) getStatusResponses() {
        if (peerCertificateOcspData is null) {
            return new EmptyList!(byte[])();
        }

        return Collections.singletonList(peerCertificateOcspData.dup);
    }

    /**
     * Returns the signed certificate timestamp (SCT) received from the peer. Returns a
     * copy of the internal array.
     *
     * @see <a href="https://tools.ietf.org/html/rfc6962">RFC 6962</a>
     */
    override
    byte[] getPeerSignedCertificateTimestamp() {
        if (peerTlsSctData is null) {
            return null;
        }
        return peerTlsSctData.dup;
    }

    override
    string getRequestedServerName() {
        synchronized (ssl) {
            return ssl.getRequestedServerName();
        }
    }

    override
    void invalidate() {
        synchronized (ssl) {
            ssl.setTimeout(0L);
        }
    }

    override
    bool isValid() {
        synchronized (ssl) {
            long creationTimeMillis = ssl.getTime();
            long timeoutMillis = ssl.getTimeout();
            long now = convert!(TimeUnit.HectoNanosecond, TimeUnit.Millisecond)(Clock.currStdTime);
            return (now - timeoutMillis) < creationTimeMillis;
        }
    }

    override
    void putValue(string name, Object value) {
        throw new UnsupportedOperationException(
                "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    }

    override
    Object getValue(string name) {
        throw new UnsupportedOperationException(
                "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    }

    override
    void removeValue(string name) {
        throw new UnsupportedOperationException(
                "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    }

    override
    string[] getValueNames() {
        throw new UnsupportedOperationException(
                "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    }

    // override
    // Certificate[] getPeerCertificates() {
    //     checkPeerCertificatesPresent();
    //     return cast(Certificate[])peerCertificates.dup;
    // }

    // override
    // Certificate[] getLocalCertificates() {
    //     return localCertificates is null ? null : cast(Certificate[])localCertificates.dup;
    // }

    /**
     * Returns the certificate(s) of the peer in this SSL session
     * used in the handshaking phase of the connection.
     * Please notice hat this method is superseded by
     * <code>getPeerCertificates()</code>.
     * @return an array of X509 certificates (the peer's one first and then
     *         eventually that of the certification authority) or null if no
     *         certificate were used during the SSL connection.
     * @throws SSLPeerUnverifiedException if either a non-X.509 certificate
     *         was used (i.e. Kerberos certificates) or the peer could not
     *         be verified.
     */
    // override
    // X509Certificate[] getPeerCertificateChain()
    //         {
    //     checkPeerCertificatesPresent();
    //     // TODO(nathanmittler): Should we clone?
    //     X509Certificate[] result = peerCertificateChain;
    //     if (result is null) {
    //         // single-check idiom
    //         peerCertificateChain = result = SSLUtils.toCertificateChain(peerCertificates);
    //     }
    //     return result;
    // }

    // override
    // Principal getPeerPrincipal() {
    //     checkPeerCertificatesPresent();
    //     return peerCertificates[0].getSubjectX500Principal();
    // }

    // override
    // Principal getLocalPrincipal() {
    //     if (localCertificates !is null && localCertificates.length > 0) {
    //         return localCertificates[0].getSubjectX500Principal();
    //     } else {
    //         return null;
    //     }
    // }

    override
    string getCipherSuite() {
        // Always get the Cipher from the SSL directly since it may have changed during a
        // renegotiation.
        string cipher;
        synchronized (ssl) {
            cipher = ssl.getCipherSuite();
        }
        return cipher is null ? SSLNullSession.INVALID_CIPHER : cipher;
    }

    override
    string getProtocol() {
        string protocol = this.protocol;
        if (protocol is null) {
            synchronized (ssl) {
                protocol = ssl.getVersion();
            }
            this.protocol = protocol;
        }
        return protocol;
    }

    override
    string getPeerHost() {
        return peerHost;
    }

    override
    int getPeerPort() {
        return peerPort;
    }

    override
    int getPacketBufferSize() {
        return NativeConstants.SSL3_RT_MAX_PACKET_SIZE;
    }

    override
    int getApplicationBufferSize() {
        return NativeConstants.SSL3_RT_MAX_PLAIN_LENGTH;
    }

    /**
     * Configures the peer information once it has been received by the handshake.
     */
    // void onPeerCertificatesReceived(
    //         string peerHost, int peerPort, X509Certificate[] peerCertificates) {
    //     configurePeer(peerHost, peerPort, peerCertificates);
    // }

    // private void configurePeer(string peerHost, int peerPort, X509Certificate[] peerCertificates) {
    //     this.peerHost = peerHost;
    //     this.peerPort = peerPort;
    //     this.peerCertificates = peerCertificates;

    //     version(Have_boringssl) {
    //     synchronized (ssl) {
    //         this.peerCertificateOcspData = ssl.getPeerCertificateOcspData();
    //         this.peerTlsSctData = ssl.getPeerTlsSctData();
    //     }
    //     }
    // }

    /**
     * Updates the cached peer certificate after the handshake has completed
     * (or entered False Start).
     */
    void onPeerCertificateAvailable(string peerHost, int peerPort) {
        version(HUNT_NET_DEBUG) {
            implementationMissing(false);
            infof("peerHost: %s, peerPort: %d", peerHost, peerPort);
        }
        // synchronized (ssl) {
        //     id = null;
        //     this.localCertificates = ssl.getLocalCertificates();
        //     if (this.peerCertificates is null) {
        //         // When resuming a session, the cert_verify_callback (which calls
        //         // onPeerCertificatesReceived) isn't called by BoringSSL during the handshake
        //         // because it presumes the certs were verified in the previous connection on that
        //         // session, leaving us without the peer certificates.  If that happens, fetch them
        //         // explicitly.
        //         configurePeer(peerHost, peerPort, ssl.getPeerCertificates());
        //     }
        // }
    }

    /**
     * Throw SSLPeerUnverifiedException on null or empty peerCertificates array
     */
    // private void checkPeerCertificatesPresent() {
    //     if (peerCertificates is null || peerCertificates.length == 0) {
    //         throw new SSLPeerUnverifiedException("No peer certificates");
    //     }
    // }

    // private void notifyUnbound(Object value, string name) {
    //     if (value instanceof SSLSessionBindingListener) {
    //         ((SSLSessionBindingListener) value)
    //                 .valueUnbound(new SSLSessionBindingEvent(this, name));
    //     }
    // }
}
