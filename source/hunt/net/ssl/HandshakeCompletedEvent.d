
module hunt.net.ssl.HandshakeCompletedEvent;

import hunt.net.ssl.common;
import hunt.net.ssl.SSLSession;
import hunt.net.ssl.SSLSocket;

import hunt.lang.object;

/**
 * This event indicates that an SSL handshake completed on a given
 * SSL connection.  All of the core information about that handshake's
 * result is captured through an "SSLSession" object.  As a convenience,
 * this event class provides direct access to some important session
 * attributes.
 *
 * <P> The source of this event is the SSLSocket on which handshaking
 * just completed.
 *
 * @see SSLSocket
 * @see HandshakeCompletedListener
 * @see SSLSession
 *
 * @since 1.4
 * @author David Brownell
 */
class HandshakeCompletedEvent : EventObject
{
    private SSLSession session;

    /**
     * Constructs a new HandshakeCompletedEvent.
     *
     * @param sock the SSLSocket acting as the source of the event
     * @param s the SSLSession this event is associated with
     */
    this(SSLSocket sock, SSLSession s)
    {
        super(sock);
        session = s;
    }


    /**
     * Returns the session that triggered this event.
     *
     * @return the <code>SSLSession</code> for this handshake
     */
    SSLSession getSession()
    {
        return session;
    }


    /**
     * Returns the cipher suite in use by the session which was produced
     * by the handshake.  (This is a convenience method for
     * getting the ciphersuite from the SSLsession.)
     *
     * @return the name of the cipher suite negotiated during this session.
     */
    string getCipherSuite()
    {
        return session.getCipherSuite();
    }


    /**
     * Returns the certificate(s) that were sent to the peer during
     * handshaking.
     * Note: This method is useful only when using certificate-based
     * cipher suites.
     *
     * When multiple certificates are available for use in a
     * handshake, the implementation chooses what it considers the
     * "best" certificate chain available, and transmits that to
     * the other side.  This method allows the caller to know
     * which certificate chain was actually used.
     *
     * @return an ordered array of certificates, with the local
     *          certificate first followed by any
     *          certificate authorities.  If no certificates were sent,
     *          then null is returned.
     * @see #getLocalPrincipal()
     */
    // java.security.cert.Certificate [] getLocalCertificates()
    // {
    //     return session.getLocalCertificates();
    // }


    /**
     * Returns the identity of the peer which was established as part
     * of defining the session.
     * Note: This method can be used only when using certificate-based
     * cipher suites; using it with non-certificate-based cipher suites,
     * such as Kerberos, will throw an SSLPeerUnverifiedException.
     *
     * @return an ordered array of the peer certificates,
     *          with the peer's own certificate first followed by
     *          any certificate authorities.
     * @exception SSLPeerUnverifiedException if the peer is not verified.
     * @see #getPeerPrincipal()
     */
    // java.security.cert.Certificate [] getPeerCertificates()
    // {
    //     return session.getPeerCertificates();
    // }


    /**
     * Returns the identity of the peer which was identified as part
     * of defining the session.
     * Note: This method can be used only when using certificate-based
     * cipher suites; using it with non-certificate-based cipher suites,
     * such as Kerberos, will throw an SSLPeerUnverifiedException.
     *
     * <p><em>Note: this method exists for compatibility with previous
     * releases. New applications should use
     * {@link #getPeerCertificates} instead.</em></p>
     *
     * @return an ordered array of peer X.509 certificates,
     *          with the peer's own certificate first followed by any
     *          certificate authorities.  (The certificates are in
     *          the original JSSE
     *          {@link javax.security.cert.X509Certificate} format).
     * @exception SSLPeerUnverifiedException if the peer is not verified.
     * @see #getPeerPrincipal()
     */
    // javax.security.cert.X509Certificate [] getPeerCertificateChain()
    // {
    //     return session.getPeerCertificateChain();
    // }

    /**
     * Returns the identity of the peer which was established as part of
     * defining the session.
     *
     * @return the peer's principal. Returns an X500Principal of the
     * end-entity certiticate for X509-based cipher suites, and
     * KerberosPrincipal for Kerberos cipher suites.
     *
     * @ if the peer's identity has not
     *          been verified
     *
     * @see #getPeerCertificates()
     * @see #getLocalPrincipal()
     *
     * @since 1.5
     */
    // Principal getPeerPrincipal()
    // {
    //     Principal principal;
    //     try {
    //         principal = session.getPeerPrincipal();
    //     } catch (AbstractMethodError e) {
    //         // if the provider does not support it, fallback to peer certs.
    //         // return the X500Principal of the end-entity cert.
    //         Certificate[] certs = getPeerCertificates();
    //         principal = (cast(X509Certificate)certs[0]).getSubjectX500Principal();
    //     }
    //     return principal;
    // }

    /**
     * Returns the principal that was sent to the peer during handshaking.
     *
     * @return the principal sent to the peer. Returns an X500Principal
     * of the end-entity certificate for X509-based cipher suites, and
     * KerberosPrincipal for Kerberos cipher suites. If no principal was
     * sent, then null is returned.
     *
     * @see #getLocalCertificates()
     * @see #getPeerPrincipal()
     *
     * @since 1.5
     */
    // Principal getLocalPrincipal()
    // {
    //     Principal principal;
    //     try {
    //         principal = session.getLocalPrincipal();
    //     } catch (AbstractMethodError e) {
    //         principal = null;
    //         // if the provider does not support it, fallback to local certs.
    //         // return the X500Principal of the end-entity cert.
    //         Certificate[] certs = getLocalCertificates();
    //         if (certs != null) {
    //             principal =
    //                     (cast(X509Certificate)certs[0]).getSubjectX500Principal();
    //         }
    //     }
    //     return principal;
    // }

    /**
     * Returns the socket which is the source of this event.
     * (This is a convenience function, to let applications
     * write code without type casts.)
     *
     * @return the socket on which the connection was made.
     */
    SSLSocket getSocket()
    {
        return cast(SSLSocket) getSource();
    }
}
