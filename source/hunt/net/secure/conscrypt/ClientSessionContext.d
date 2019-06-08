module hunt.net.secure.conscrypt.ClientSessionContext;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.conscrypt.AbstractSessionContext;
import hunt.net.secure.conscrypt.NativeSslSession;
import hunt.net.secure.conscrypt.SSLClientSessionCache;
import hunt.net.secure.conscrypt.SSLServerSessionCache;
import hunt.net.secure.conscrypt.SSLParametersImpl;

import hunt.net.ssl.SSLSession;
import hunt.net.ssl.SSLSessionContext;

import hunt.collection;
import hunt.Exceptions;


/**
 * Caches client sessions. Indexes by host and port. Users are typically
 * looking to reuse any session for a given host and port.
 *
 * @hide
 */
final class ClientSessionContext : AbstractSessionContext {
    /**
     * Sessions indexed by host and port. Protect from concurrent
     * access by holding a lock on sessionsByHostAndPort.
     */
    private Map!(HostAndPort, NativeSslSession) sessionsByHostAndPort;

    private SSLClientSessionCache persistentCache;

    this() {
        super(10);
        sessionsByHostAndPort = new HashMap!(HostAndPort, NativeSslSession)();
    }

    /**
     * Applications should not use this method. Instead use {@link
     * Conscrypt#setClientSessionCache(SSLContext, SSLClientSessionCache)}.
     */
    void setPersistentCache(SSLClientSessionCache persistentCache) {
        this.persistentCache = persistentCache;
    }

    /**
     * Gets the suitable session reference from the session cache container.
     */
    NativeSslSession getCachedSession(string hostName, int port, SSLParametersImpl sslParameters) {
        if (hostName is null) {
            return null;
        }

        NativeSslSession session = getSession(hostName, port);
        if (session is null) {
            return null;
        }

        implementationMissing();

        // string protocol = session.getProtocol();
        // bool protocolFound = false;
        // foreach (string enabledProtocol ; sslParameters.enabledProtocols) {
        //     if (protocol.equals(enabledProtocol)) {
        //         protocolFound = true;
        //         break;
        //     }
        // }
        // if (!protocolFound) {
        //     return null;
        // }

        // string cipherSuite = session.getCipherSuite();
        // bool cipherSuiteFound = false;
        // foreach (string enabledCipherSuite ; sslParameters.enabledCipherSuites) {
        //     if (cipherSuite.equals(enabledCipherSuite)) {
        //         cipherSuiteFound = true;
        //         break;
        //     }
        // }
        // if (!cipherSuiteFound) {
        //     return null;
        // }

        return session;
    }

    int size() {
        return sessionsByHostAndPort.size();
    }

    /**
     * Finds a cached session for the given host name and port.
     *
     * @param host of server
     * @param port of server
     * @return cached session or null if none found
     */
    private NativeSslSession getSession(string host, int port) {
        if (host is null) {
            return null;
        }

        HostAndPort key = new HostAndPort(host, port);
        NativeSslSession session;
        synchronized (sessionsByHostAndPort) {
            session = sessionsByHostAndPort.get(key);
        }
        if (session !is null && session.isValid()) {
            return session;
        }

        // Look in persistent cache.
        if (persistentCache !is null) {
            byte[] data = persistentCache.getSessionData(host, port);
            if (data !is null) {
                session = NativeSslSession.newInstance(this, data, host, port);
                if (session !is null && session.isValid()) {
                    synchronized (sessionsByHostAndPort) {
                        sessionsByHostAndPort.put(key, session);
                    }
                    return session;
                }
            }
        }

        return null;
    }

    override
    void onBeforeAddSession(NativeSslSession session) {
        string host = session.getPeerHost();
        int port = session.getPeerPort();
        if (host is null) {
            return;
        }

        HostAndPort key = new HostAndPort(host, port);
        synchronized (sessionsByHostAndPort) {
            sessionsByHostAndPort.put(key, session);
        }

        // TODO: Do this in a background thread.
        if (persistentCache !is null) {
            byte[] data = session.toBytes();
            if (data !is null) {
                persistentCache.putSessionData(session.toSSLSession(), data);
            }
        }
    }

    override
    void onBeforeRemoveSession(NativeSslSession session) {
        string host = session.getPeerHost();
        if (host is null) {
            return;
        }
        int port = session.getPeerPort();
        HostAndPort hostAndPortKey = new HostAndPort(host, port);
        synchronized (sessionsByHostAndPort) {
            sessionsByHostAndPort.remove(hostAndPortKey);
        }
    }

    override
    NativeSslSession getSessionFromPersistentCache(byte[] sessionId) {
        // Not implemented for clients.
        return null;
    }

    private static final class HostAndPort {
        string host;
        int port;

        this(string host, int port) {
            this.host = host;
            this.port = port;
        }

        override size_t toHash() @trusted nothrow {
            return hashOf(host) * 31 + port;
        }

        override
        bool opEquals(Object o) {
            if (typeid(o) != typeid(HostAndPort)) {
                return false;
            }
            HostAndPort lhs = cast(HostAndPort) o;
            return host == lhs.host && port == lhs.port;
        }
    }
}

