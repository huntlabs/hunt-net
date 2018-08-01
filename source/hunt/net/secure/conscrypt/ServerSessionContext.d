module hunt.net.secure.conscrypt.ServerSessionContext;

import hunt.net.secure.conscrypt.AbstractSessionContext;
import hunt.net.secure.conscrypt.NativeSslSession;
import hunt.net.secure.conscrypt.SSLServerSessionCache;

import hunt.net.ssl.SSLSessionContext;

import hunt.util.exception;

/**
 * Caches server sessions. Indexes by session ID. Users typically look up
 * sessions using the ID provided by an SSL client.
 *
 * @hide
 */
final class ServerSessionContext : AbstractSessionContext {
    private SSLServerSessionCache persistentCache;

    this() {
        super(100);

        // TODO make sure SSL_CTX does not automaticaly clear sessions we want it to cache
        // SSL_CTX_set_session_cache_mode(sslCtxNativePointer, SSL_SESS_CACHE_NO_AUTO_CLEAR);

        // TODO remove SSL_CTX session cache limit so we can manage it
        // SSL_CTX_sess_set_cache_size(sslCtxNativePointer, 0);

        // TODO override trimToSize and removeEldestEntry to use
        // SSL_CTX_sessions to remove from native cache

        // Set a trivial session id context. OpenSSL uses this to make
        // sure you don't reuse sessions externalized with i2d_SSL_SESSION
        // between apps. However our sessions are either in memory or
        // exported to a app's SSLServerSessionCache.
        implementationMissing();
        // NativeCrypto.SSL_CTX_set_session_id_context(sslCtxNativePointer, this, [' ']);
    }

    /**
     * Applications should not use this method. Instead use {@link
     * Conscrypt#setServerSessionCache(SSLContext, SSLServerSessionCache)}.
     */
    void setPersistentCache(SSLServerSessionCache persistentCache) {
        this.persistentCache = persistentCache;
    }

    override
    NativeSslSession getSessionFromPersistentCache(byte[] sessionId) {
        if (persistentCache !is null) {
            byte[] data = persistentCache.getSessionData(sessionId);
            if (data !is null) {
                NativeSslSession session = NativeSslSession.newInstance(this, data, null, -1);
                if (session !is null && session.isValid()) {
                    cacheSession(session);
                    return session;
                }
            }
        }

        return null;
    }

    override
    void onBeforeAddSession(NativeSslSession session) {
        // TODO: Do this in background thread.
        if (persistentCache !is null) {
            byte[] data = session.toBytes();
            if (data !is null) {
                persistentCache.putSessionData(session.toSSLSession(), data);
            }
        }
    }

    override
    void onBeforeRemoveSession(NativeSslSession session) {
        // Do nothing.
    }
}
