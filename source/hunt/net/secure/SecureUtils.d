module hunt.net.secure.SecureUtils;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.ssl.SSLContext;
import hunt.net.Connection;
import hunt.net.KeyCertOptions;
import hunt.net.secure.SecureSession;
import hunt.net.secure.SecureSessionFactory;
import hunt.net.secure.conscrypt.AbstractConscryptSSLContextFactory;
import hunt.net.secure.conscrypt.ConscryptSecureSessionFactory;

import std.array;
import std.concurrency : initOnce;

/**
 * 
 */
struct SecureUtils {
    /**
     * Get the SSL/TLS connection factory.
     *
     * @return the SSL/TLS connection factory.
     */
    static SecureSessionFactory secureSessionFactory() {
        __gshared ConscryptSecureSessionFactory inst;
        return initOnce!inst(new ConscryptSecureSessionFactory());
    }

    static void setServerCertificate(KeyCertOptions options) {
        assert(options !is null);
        FileCredentialConscryptSSLContextFactory fc = 
            new FileCredentialConscryptSSLContextFactory(options);
        // SSLContext context = fc.getSSLContext();
        secureSessionFactory().setServerSSLContextFactory(fc);
    }

    static SecureSession createClientSession(Connection connection, SecureSessionHandshakeListener handler) {
        return secureSessionFactory().create(connection, true, handler);
    }

    static SecureSession createClientSession(Connection connection, SecureSessionHandshakeListener handler, 
            KeyCertOptions options) {
        return secureSessionFactory().create(connection, true, handler, options);
    }

    static SecureSession createServerSession(Connection connection, SecureSessionHandshakeListener handler) {
        return secureSessionFactory().create(connection, false, handler);
    }

    SSLContext getServerSslContext() {
        AbstractConscryptSSLContextFactory factory = 
            cast(AbstractConscryptSSLContextFactory)secureSessionFactory().getServerSSLContextFactory();
        return factory.getSSLContext();
    }

}
