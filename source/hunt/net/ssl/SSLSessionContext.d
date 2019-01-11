module hunt.net.ssl.SSLSessionContext;

import hunt.net.ssl.SSLSession;
import hunt.collection;


/**
 * A <code>SSLSessionContext</code> represents a set of
 * <code>SSLSession</code>s associated with a single entity. For example,
 * it could be associated with a server or client who participates in many
 * sessions concurrently.
 * <p>
 * Not all environments will contain session contexts.
 * <p>
 * There are <code>SSLSessionContext</code> parameters that affect how
 * sessions are stored:
 * <UL>
 *      <LI>Sessions can be set to expire after a specified
 *      time limit.
 *      <LI>The number of sessions that can be stored in context
 *      can be limited.
 * </UL>
 * A session can be retrieved based on its session id, and all session id's
 * in a <code>SSLSessionContext</code> can be listed.
 *
 * @see SSLSession
 *
 * @since 1.4
 * @author Nathan Abramson
 * @author David Brownell
 */
interface SSLSessionContext {

    /**
     * Returns the <code>SSLSession</code> bound to the specified session id.
     *
     * @param sessionId the Session identifier
     * @return the <code>SSLSession</code> or null if
     * the specified session id does not refer to a valid SSLSession.
     *
     * @throws NullPointerException if <code>sessionId</code> is null.
     */
    SSLSession getSession(byte[] sessionId);

    /**
     * Returns an Enumeration of all session id's grouped under this
     * <code>SSLSessionContext</code>.
     *
     * @return an enumeration of all the Session id's
     */
    Enumeration!(byte[]) getIds();

    /**
     * Sets the timeout limit for <code>SSLSession</code> objects grouped
     * under this <code>SSLSessionContext</code>.
     * <p>
     * If the timeout limit is set to 't' seconds, a session exceeds the
     * timeout limit 't' seconds after its creation time.
     * When the timeout limit is exceeded for a session, the
     * <code>SSLSession</code> object is invalidated and future connections
     * cannot resume or rejoin the session.
     * A check for sessions exceeding the timeout is made immediately whenever
     * the timeout limit is changed for this <code>SSLSessionContext</code>.
     *
     * @param seconds the new session timeout limit in seconds; zero means
     *          there is no limit.
     *
     * @exception IllegalArgumentException if the timeout specified is {@code < 0}.
     * @see #getSessionTimeout
     */
    void setSessionTimeout(int seconds);

    /**
     * Returns the timeout limit of <code>SSLSession</code> objects grouped
     * under this <code>SSLSessionContext</code>.
     * <p>
     * If the timeout limit is set to 't' seconds, a session exceeds the
     * timeout limit 't' seconds after its creation time.
     * When the timeout limit is exceeded for a session, the
     * <code>SSLSession</code> object is invalidated and future connections
     * cannot resume or rejoin the session.
     * A check for sessions exceeding the timeout limit is made immediately
     * whenever the timeout limit is changed for this
     * <code>SSLSessionContext</code>.
     *
     * @return the session timeout limit in seconds; zero means there is no
     * limit.
     * @see #setSessionTimeout
     */
    int getSessionTimeout();

    /**
     * Sets the size of the cache used for storing
     * <code>SSLSession</code> objects grouped under this
     * <code>SSLSessionContext</code>.
     *
     * @param size the new session cache size limit; zero means there is no
     * limit.
     * @exception IllegalArgumentException if the specified size is {@code < 0}.
     * @see #getSessionCacheSize
     */
    void setSessionCacheSize(int size);

    /**
     * Returns the size of the cache used for storing
     * <code>SSLSession</code> objects grouped under this
     * <code>SSLSessionContext</code>.
     *
     * @return size of the session cache; zero means there is no size limit.
     * @see #setSessionCacheSize
     */
    int getSessionCacheSize();

}