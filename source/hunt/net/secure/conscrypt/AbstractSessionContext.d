module hunt.net.secure.conscrypt.AbstractSessionContext;

// dfmt off
import hunt.net.VersionUtil;
mixin(checkVersions());
version(WITH_HUNT_SECURITY) :
// dfmt on

import hunt.net.ssl.SSLSession;
import hunt.net.ssl.SSLSessionContext;

import hunt.net.secure.conscrypt.ByteArray;
import hunt.net.secure.conscrypt.NativeCrypto;
import hunt.net.secure.conscrypt.NativeSslSession;

import hunt.collection;
import hunt.Exceptions;

import hunt.logging;
/**
 * Supports SSL session caches.
 */
abstract class AbstractSessionContext : SSLSessionContext {

    /**
     * Maximum lifetime of a session (in seconds) after which it's considered invalid and should not
     * be used to for new connections.
     */
    private enum int DEFAULT_SESSION_TIMEOUT_SECONDS = 8 * 60 * 60;

    private int maximumSize;
    private int timeout = DEFAULT_SESSION_TIMEOUT_SECONDS;

    package long sslCtxNativePointer; 

    // private final Map<ByteArray, NativeSslSession> sessions =
    //         new LinkedHashMap<ByteArray, NativeSslSession>() {
    //             override
    //             protected bool removeEldestEntry(
    //                     Map.Entry<ByteArray, NativeSslSession> eldest) {
    //                 // NOTE: does not take into account any session that may have become
    //                 // invalid.
    //                 if (maximumSize > 0 && size() > maximumSize) {
    //                     // Let the subclass know.
    //                     onBeforeRemoveSession(eldest.getValue());
    //                     return true;
    //                 }
    //                 return false;
    //             }
    //         };

    /**
     * Constructs a new session context.
     *
     * @param maximumSize of cache
     */
    this(int maximumSize) {
        this.maximumSize = maximumSize;
        sslCtxNativePointer = NativeCrypto.SSL_CTX_new();
    }

    this(int maximumSize, string certificate, string privatekey ) {
        this.maximumSize = maximumSize;
        sslCtxNativePointer = NativeCrypto.SSL_CTX_new();
        
        trace("using certificate: " ~ certificate);
        // NativeCrypto.SSL_CTX_use_certificate_file(sslCtxNativePointer, "/home/zxp/cert/server.crt");
        // NativeCrypto.SSL_CTX_use_PrivateKey_file(sslCtxNativePointer, "/home/zxp/cert/server.key");
        NativeCrypto.SSL_CTX_use_certificate_file(sslCtxNativePointer, certificate);
        NativeCrypto.SSL_CTX_use_PrivateKey_file(sslCtxNativePointer, privatekey);
    }

    /**
     * This method is provided for API-compatibility only, not intended for use. No guarantees
     * are made WRT performance.
     */
    override
    final Enumeration!(byte[]) getIds() {
        // Make a copy of the IDs.
        // Iterator<NativeSslSession> iter;
        // synchronized (sessions) {
        //     iter = Arrays.asList(sessions.values().toArray(new NativeSslSession[sessions.size()]))
        //             .iterator();
        // }
        // return new Enumeration!(byte[])() {
        //     private NativeSslSession next;

        //     override
        //     bool hasMoreElements() {
        //         if (next != null) {
        //             return true;
        //         }
        //         while (iter.hasNext()) {
        //             NativeSslSession session = iter.next();
        //             if (session.isValid()) {
        //                 next = session;
        //                 return true;
        //             }
        //         }
        //         next = null;
        //         return false;
        //     }

        //     override
        //     byte[] nextElement() {
        //         if (hasMoreElements()) {
        //             byte[] id = next.getId();
        //             next = null;
        //             return id;
        //         }
        //         throw new NoSuchElementException();
        //     }
        // };
        implementationMissing();
        return null;
    }

    /**
     * This is provided for API-compatibility only, not intended for use. No guarantees are
     * made WRT performance or the validity of the returned session.
     */
    override
    final SSLSession getSession(byte[] sessionId) {
        if (sessionId == null) {
            throw new NullPointerException("sessionId");
        }
        // ByteArray key = new ByteArray(sessionId);
        // NativeSslSession session;
        // synchronized (sessions) {
        //     session = sessions.get(key);
        // }
        // if (session != null && session.isValid()) {
        //     return session.toSSLSession();
        // }

        implementationMissing();
        return null;
    }

    override
    final int getSessionCacheSize() {
        return maximumSize;
    }

    override
    final int getSessionTimeout() {
        return timeout;
    }

    override
    final void setSessionTimeout(int seconds) {
        if (seconds < 0) {
            throw new IllegalArgumentException("seconds < 0");
        }
        implementationMissing();
        // synchronized (sessions) {
        //     // Set the timeout on this context.
        //     timeout = seconds;
        //     // setSessionTimeout(0) is defined to remove the timeout, but passing 0
        //     // to SSL_CTX_set_timeout in BoringSSL sets it to the default timeout instead.
        //     // Pass INT_MAX seconds (68 years), since that's equivalent for practical purposes.
        //     if (seconds > 0) {
        //         NativeCrypto.SSL_CTX_set_timeout(sslCtxNativePointer, this, seconds);
        //     } else {
        //         NativeCrypto.SSL_CTX_set_timeout(sslCtxNativePointer, this, Integer.MAX_VALUE);
        //     }

        //     Iterator<NativeSslSession> i = sessions.values().iterator();
        //     while (i.hasNext()) {
        //         NativeSslSession session = i.next();
        //         // SSLSession's know their context and consult the
        //         // timeout as part of their validity condition.
        //         if (!session.isValid()) {
        //             // Let the subclass know.
        //             onBeforeRemoveSession(session);
        //             i.remove();
        //         }
        //     }
        // }
    }

    override
    final void setSessionCacheSize(int size) {
        if (size < 0) {
            throw new IllegalArgumentException("size < 0");
        }

        int oldMaximum = maximumSize;
        maximumSize = size;

        // Trim cache to size if necessary.
        if (size < oldMaximum) {
            trimToSize();
        }
    }

    protected void finalize() {
        // try {
        //     NativeCrypto.SSL_CTX_free(sslCtxNativePointer, this);
        // } finally {
        //     super.finalize();
        // }
    }

    /**
     * Adds the given session to the cache.
     */
    final void cacheSession(NativeSslSession session) {
        byte[] id = session.getId();
        if (id == null || id.length == 0) {
            return;
        }

        // Let the subclass know.
        onBeforeAddSession(session);

        // ByteArray key = new ByteArray(id);
        // synchronized (sessions) {
        //     sessions.put(key, session);
        // }
        implementationMissing();
    }

    /**
     * Called for server sessions only. Retrieves the session by its ID. Overridden by
     * {@link ServerSessionContext} to
     */
    final NativeSslSession getSessionFromCache(byte[] sessionId) {
        if (sessionId == null) {
            return null;
        }


        implementationMissing();
        return null;
        // First, look in the in-memory cache.
        // NativeSslSession session;
        // synchronized (sessions) {
        //     session = sessions.get(new ByteArray(sessionId));
        // }
        // if (session != null && session.isValid()) {
        //     return session;
        // }

        // // Not found in-memory - look it up in the persistent cache.
        // return getSessionFromPersistentCache(sessionId);
    }

    /**
     * Called when the given session is about to be added. Used by {@link ClientSessionContext} to
     * update its host-and-port based cache.
     *
     * <p>Visible for extension only, not intended to be called directly.
     */
    abstract void onBeforeAddSession(NativeSslSession session);

    /**
     * Called when a session is about to be removed. Used by {@link ClientSessionContext}
     * to update its host-and-port based cache.
     *
     * <p>Visible for extension only, not intended to be called directly.
     */
    abstract void onBeforeRemoveSession(NativeSslSession session);

    /**
     * Called for server sessions only. Retrieves the session by ID from the persistent cache.
     *
     * <p>Visible for extension only, not intended to be called directly.
     */
    abstract NativeSslSession getSessionFromPersistentCache(byte[] sessionId);

    /**
     * Makes sure cache size is < maximumSize.
     */
    private void trimToSize() {

        implementationMissing();
        // synchronized (sessions) {
        //     int size = sessions.size();
        //     if (size > maximumSize) {
        //         int removals = size - maximumSize;
        //         Iterator<NativeSslSession> i = sessions.values().iterator();
        //         while (removals-- > 0) {
        //             NativeSslSession session = i.next();
        //             onBeforeRemoveSession(session);
        //             i.remove();
        //         }
        //     }
        // }
    }
}
