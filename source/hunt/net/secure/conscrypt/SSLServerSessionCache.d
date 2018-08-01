module hunt.net.secure.conscrypt.SSLServerSessionCache;

import hunt.net.ssl.SSLSession;


/**
 * A persistent {@link javax.net.ssl.SSLSession} cache used by
 * {@link javax.net.ssl.SSLSessionContext} to share server-side SSL sessions
 * across processes. For example, this cache enables one server to resume
 * a session started by a different server based on a session ID provided
 * by the client.
 *
 * <p>The {@code SSLSessionContext} implementation converts
 * {@code SSLSession}s into raw bytes and vice versa. The exact makeup of the
 * session data is dependent upon the caller's implementation and is opaque to
 * the {@code SSLServerSessionCache} implementation.
 */
interface SSLServerSessionCache {
    /**
     * Gets the session data for given session ID.
     *
     * @param id from {@link javax.net.ssl.SSLSession#getId()}
     * @return the session data or null if none is cached
     * @throws NullPointerException if id is null
     */
    byte[] getSessionData(byte[] id);

    /**
     * Stores session data for the given session.
     *
     * @param session to cache data for
     * @param sessionData to cache
     * @throws NullPointerException if session or data is null
     */
    void putSessionData(SSLSession session, byte[] sessionData);
}