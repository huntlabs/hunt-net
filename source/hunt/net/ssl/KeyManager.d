module hunt.net.ssl.KeyManager;

/**
 * This is the base interface for JSSE key managers.
 * <P>
 * <code>KeyManager</code>s are responsible for managing the
 * key material which is used to authenticate the local SSLSocket
 * to its peer.  If no key material is available, the socket will
 * be unable to present authentication credentials.
 * <P>
 * <code>KeyManager</code>s are created by either
 * using a <code>KeyManagerFactory</code>,
 * or by implementing one of the <code>KeyManager</code> subclasses.
 *
 * @since 1.4
 * @see KeyManagerFactory
 */
interface KeyManager {
}


/**
 * This is the base interface for JSSE trust managers.
 * <P>
 * <code>TrustManager</code>s are responsible for managing the trust material
 * that is used when making trust decisions, and for deciding whether
 * credentials presented by a peer should be accepted.
 * <P>
 * <code>TrustManager</code>s are created by either
 * using a <code>TrustManagerFactory</code>,
 * or by implementing one of the <code>TrustManager</code> subclasses.
 *
 * @see TrustManagerFactory
 * @since 1.4
 */
interface TrustManager {
}