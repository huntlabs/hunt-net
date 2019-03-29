module hunt.net.secure.conscrypt.SSLClientSessionCache;

// dfmt off
version(Have_hunt_security):
// dfmt on

import hunt.net.ssl.SSLSession;

/**
 * A persistent {@link javax.net.ssl.SSLSession} cache used by
 * {@link javax.net.ssl.SSLSessionContext} to share client-side SSL sessions
 * across processes. For example, this cache enables applications to
 * persist and reuse sessions across restarts.
 *
 * <p>The {@code SSLSessionContext} implementation converts
 * {@code SSLSession}s into raw bytes and vice versa. The exact makeup of the
 * session data is dependent upon the caller's implementation and is opaque to
 * the {@code SSLClientSessionCache} implementation.
 *
 * @hide
 */
public interface SSLClientSessionCache {
    /**
     * Gets data from a pre-existing session for a given server host and port.
     *
     * @param host from {@link javax.net.ssl.SSLSession#getPeerHost()}
     * @param port from {@link javax.net.ssl.SSLSession#getPeerPort()}
     * @return the session data or null if none is cached
     * @throws NullPointerException if host is null
     */
    byte[] getSessionData(string host, int port);

    /**
     * Stores session data for the given session.
     *
     * @param session to cache data for
     * @param sessionData to cache
     * @throws NullPointerException if session, result of
     *  {@code session.getPeerHost()} or data is null
     */
    void putSessionData(SSLSession session, byte[] sessionData);
}