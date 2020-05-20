module hunt.net.secure.conscrypt.AbstractConscryptEngine;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.conscrypt.AllocatedBuffer;
import hunt.net.secure.conscrypt.ApplicationProtocolSelector;
import hunt.net.ssl;

import hunt.io.ByteBuffer;
import hunt.Functions;
// import hunt.security.Key;

alias HandshakeListener = Action;


/**
 * Abstract base class for all Conscrypt {@link SSLEngine} classes.
 */
abstract class AbstractConscryptEngine : SSLEngine {
    // abstract void setBufferAllocator(BufferAllocator bufferAllocator);

    /**
     * Returns the maximum overhead, in bytes, of sealing a record with SSL.
     */
    abstract int maxSealOverhead();

//     /**
//      * Enables/disables TLS Channel ID for this server engine.
//      *
//      * <p>This method needs to be invoked before the handshake starts.
//      *
//      * @throws IllegalStateException if this is a client engine or if the handshake has already
//      *         started.
//      */
//     abstract void setChannelIdEnabled(bool enabled);

//     /**
//      * Gets the TLS Channel ID for this server engine. Channel ID is only available once the
//      * handshake completes.
//      *
//      * @return channel ID or {@code null} if not available.
//      *
//      * @throws IllegalStateException if this is a client engine or if the handshake has not yet
//      * completed.
//      * @ if channel ID is available but could not be obtained.
//      */
//     abstract byte[] getChannelId() ;

    /**
     * Sets the {@link PrivateKey} to be used for TLS Channel ID by this client engine.
     *
     * <p>This method needs to be invoked before the handshake starts.
     *
     * @param privateKey private key (enables TLS Channel ID) or {@code null} for no key (disables
     *        TLS Channel ID). The private key must be an Elliptic Curve (EC) key based on the NIST
     *        P-256 curve (aka SECG secp256r1 or ANSI X9.62 prime256v1).
     *
     * @throws IllegalStateException if this is a server engine or if the handshake has already
     *         started.
     */
    // abstract void setChannelIdPrivateKey(PrivateKey privateKey);

    /**
     * Sets the listener for the completion of the TLS handshake.
     */
    abstract void setHandshakeListener(HandshakeListener handshakeListener);

    /**
     * This method enables Server Name Indication (SNI) and overrides the {@link PeerInfoProvider}
     * supplied during engine creation.
     */
    abstract void setHostname(string hostname);

    /**
     * Returns the hostname from {@link #setHostname(string)} or supplied by the
     * {@link PeerInfoProvider} upon creation. No DNS resolution is attempted before
     * returning the hostname.
     */
    abstract string getHostname();

    override abstract string getPeerHost();

    override abstract int getPeerPort();

//     /* override */
//     @SuppressWarnings("MissingOverride") // For compilation with Java 6.
//     SSLSession getHandshakeSession() {
//         return handshakeSession();
//     }

    /**
     * Work-around to allow this method to be called on older versions of Android.
     */
    abstract SSLSession handshakeSession();

    override
    abstract SSLEngineResult unwrap(ByteBuffer src, ByteBuffer dst);

    override
    abstract SSLEngineResult unwrap(ByteBuffer src, ByteBuffer[] dsts);

    override
    abstract SSLEngineResult unwrap(ByteBuffer src, ByteBuffer[] dsts,
            int offset, int length) ;

    abstract SSLEngineResult unwrap(ByteBuffer[] srcs, ByteBuffer[] dsts);

    abstract SSLEngineResult unwrap(ByteBuffer[] srcs, int srcsOffset, int srcsLength,
            ByteBuffer[] dsts, int dstsOffset, int dstsLength);

    override
    abstract SSLEngineResult wrap(ByteBuffer src, ByteBuffer dst) ;

    override
    abstract SSLEngineResult wrap(
            ByteBuffer[] srcs, int srcsOffset, int srcsLength, ByteBuffer dst) ;

    /**
     * This method enables session ticket support.
     *
     * @param useSessionTickets True to enable session tickets
     */
    abstract void setUseSessionTickets(bool useSessionTickets);

    /**
     * Sets the list of ALPN protocols.
     *
     * @param protocols the list of ALPN protocols
     */
    abstract void setApplicationProtocols(string[] protocols);

    /**
     * Returns the list of supported ALPN protocols.
     */
    abstract string[] getApplicationProtocols();

    abstract string getApplicationProtocol();

    abstract string getHandshakeApplicationProtocol();

//     /**
//      * Sets an application-provided ALPN protocol selector. If provided, this will override
//      * the list of protocols set by {@link #setApplicationProtocols(string[])}.
//      */
    abstract void setApplicationProtocolSelector(ApplicationProtocolSelector selector);

//     /**
//      * Returns the tls-unique channel binding value for this connection, per RFC 5929.  This
//      * will return {@code null} if there is no such value available, such as if the handshake
//      * has not yet completed or this connection is closed.
//      */
//     abstract byte[] getTlsUnique();

//     /**
//      * Enables token binding parameter negotiation on this engine, or disables it if an
//      * empty set of parameters are provided.
//      *
//      * <p>This method needs to be invoked before the handshake starts.
//      *
//      * @param params a list of Token Binding key parameters in descending order of preference,
//      * as described in draft-ietf-tokbind-negotiation-09.
//      * @throws IllegalStateException if the handshake has already started.
//      * @ if the setting could not be applied.
//      */
// //     abstract void setTokenBindingParams(int... params) ;

//     /**
//      * Returns the token binding parameters that were negotiated during the handshake, or -1 if
//      * token binding parameters were not negotiated, the handshake has not yet completed,
//      * or the connection has been closed.
//      */
// //     abstract int getTokenBindingParams();

//     /**
//      * Exports a value derived from the TLS master secret as described in RFC 5705.
//      *
//      * @param label the label to use in calculating the exported value.  This must be
//      * an ASCII-only string.
//      * @param context the application-specific context value to use in calculating the
//      * exported value.  This may be {@code null} to use no application context, which is
//      * treated differently than an empty byte array.
//      * @param length the number of bytes of keying material to return.
//      * @return a value of the specified length, or {@code null} if the handshake has not yet
//      * completed or the connection has been closed.
//      * @ if the value could not be exported.
//      */
//     abstract byte[] exportKeyingMaterial(string label, byte[] context, int length);
}
