module hunt.net.secure.conscrypt.OpenSSLContextImpl;


// dfmt off
import hunt.net.VersionUtil;
mixin(checkVersions());
version(WITH_HUNT_SECURITY) :
// dfmt on

import hunt.net.secure.conscrypt.ClientSessionContext;
import hunt.net.secure.conscrypt.ConscryptEngine;
import hunt.net.secure.conscrypt.NativeCrypto;
import hunt.net.secure.conscrypt.SSLParametersImpl;
import hunt.net.secure.conscrypt.ServerSessionContext;

import hunt.net.ssl.KeyManager;
import hunt.net.ssl.SSLContextSpi;
import hunt.net.ssl.SSLEngine;
import hunt.net.ssl.SSLServerSocketFactory;
import hunt.net.ssl.SSLSocketFactory;

import hunt.security.key;

import hunt.Exceptions;

/**
 * OpenSSL-backed SSLContext service provider interface.
 *
 * <p>Public to allow contruction via the provider framework.
 *
 * @hide
 */
abstract class OpenSSLContextImpl : SSLContextSpi {
    /**
     * The default SSLContextImpl for use with
     * SSLContext.getInstance("Default"). Protected by the
     * DefaultSSLContextImpl.class monitor.
     */
    private static DefaultSSLContextImpl defaultSslContextImpl;

    /** TLS algorithm to initialize all sockets. */
    private string[] algorithms;

    /** Client session cache. */
    private ClientSessionContext clientSessionContext;

    /** Server session cache. */
    private ServerSessionContext serverSessionContext;

    SSLParametersImpl sslParameters;

    /** Allows outside callers to get the preferred SSLContext. */
    // static OpenSSLContextImpl getPreferred() {
    //     return new TLSv12();
    // }

    this(string[] algorithms, string certificate, string privatekey) {
        this.algorithms = algorithms;
        clientSessionContext = new ClientSessionContext();
        serverSessionContext = new ServerSessionContext(certificate, privatekey);
    }

    /**
     * Constuctor for the DefaultSSLContextImpl.
     */
    this(string certificate, string privatekey) {
        synchronized {
            this.algorithms = null;
            if (defaultSslContextImpl is null) {
                clientSessionContext = new ClientSessionContext();
                serverSessionContext = new ServerSessionContext(certificate, privatekey);
                defaultSslContextImpl = cast(DefaultSSLContextImpl) this;
            } else {
                clientSessionContext = defaultSslContextImpl.engineGetClientSessionContext();
                serverSessionContext = defaultSslContextImpl.engineGetServerSessionContext();
            }
            sslParameters = new SSLParametersImpl(defaultSslContextImpl.getKeyManagers(),
                    defaultSslContextImpl.getTrustManagers(), clientSessionContext,
                    serverSessionContext, algorithms);
        }
    }

    /**
     * Initializes this {@code SSLContext} instance. All of the arguments are
     * optional, and the security providers will be searched for the required
     * implementations of the needed algorithms.
     *
     * @param kms the key sources or {@code null}
     * @param tms the trust decision sources or {@code null}
     * @param sr the randomness source or {@code null}
     * @throws KeyManagementException if initializing this instance fails
     */
    override
    void engineInit(KeyManager[] kms, TrustManager[] tms) {
        sslParameters = new SSLParametersImpl(
                kms, tms, clientSessionContext, serverSessionContext, algorithms);
    }

    override
    SSLSocketFactory engineGetSocketFactory() {
        if (sslParameters is null) {
            throw new IllegalStateException("SSLContext is not initialized.");
        }
        // return Platform.wrapSocketFactoryIfNeeded(new OpenSSLSocketFactoryImpl(sslParameters));

implementationMissing();
return null;
    }

    // override
    // SSLServerSocketFactory engineGetServerSocketFactory() {
    //     if (sslParameters is null) {
    //         throw new IllegalStateException("SSLContext is not initialized.");
    //     }
    //     return new OpenSSLServerSocketFactoryImpl(sslParameters);
    // }

    override
    SSLEngine engineCreateSSLEngine(string host, int port) {
        if (sslParameters is null) {
            throw new IllegalStateException("SSLContext is not initialized.");
        }
        SSLParametersImpl p = cast(SSLParametersImpl) sslParameters; //.clone();
        p.setUseClientMode(false);
        // return wrapEngine(new ConscryptEngine(host, port, p));

implementationMissing();
return null;
    }

    override
    SSLEngine engineCreateSSLEngine() {
        if (sslParameters is null) {
            throw new IllegalStateException("SSLContext is not initialized.");
        }
        SSLParametersImpl p = cast(SSLParametersImpl) sslParameters; //.clone();
        p.setUseClientMode(false);
        // return wrapEngine(new ConscryptEngine(p));
        return new ConscryptEngine(p);

// implementationMissing();
// return null;
    }

    override
    ServerSessionContext engineGetServerSessionContext() {
        return serverSessionContext;
    }

    override
    ClientSessionContext engineGetClientSessionContext() {
        return clientSessionContext;
    }

    // /**
    //  * Public to allow construction via the provider framework.
    //  */
    // static final class TLSv12 : OpenSSLContextImpl {
    //     this() {
    //         super(NativeCrypto.TLSV12_PROTOCOLS);
    //     }
    // }

    // /**
    //  * Public to allow construction via the provider framework.
    //  */
    // static final class TLSv11 : OpenSSLContextImpl {
    //     this() {
    //         super(NativeCrypto.TLSV11_PROTOCOLS);
    //     }
    // }

    // /**
    //  * Public to allow construction via the provider framework.
    //  */
    // static final class TLSv1 : OpenSSLContextImpl {
    //     this() {
    //         super(NativeCrypto.TLSV1_PROTOCOLS);
    //     }
    // }
}



/**
 * Support class for this package.
 *
 * @hide
 */

final class DefaultSSLContextImpl : OpenSSLContextImpl {

    /**
     * Accessed by SSLContextImpl(DefaultSSLContextImpl) holding the
     * DefaultSSLContextImpl.class monitor
     */
    private static KeyManager[] KEY_MANAGERS;

    /**
     * Accessed by SSLContextImpl(DefaultSSLContextImpl) holding the
     * DefaultSSLContextImpl.class monitor
     */
    private static TrustManager[] TRUST_MANAGERS;

    /**
     * DefaultSSLContextImpl delegates the work to the super class since there
     * is no way to put a synchronized around both the call to super and the
     * rest of this constructor to guarantee that we don't have races in
     * creating the state shared between all default SSLContexts.
     */
    this() {
        import hunt.logging;
        error(false, "no certificate provided");
        super("cert/server.crt", "cert/server.key");
    }

    this(string certificate, string privatekey) {
        super(certificate, privatekey);
    }

    // TODO javax.net.ssl.keyStoreProvider system property
    KeyManager[] getKeyManagers () {
        if (KEY_MANAGERS != null) {
            return KEY_MANAGERS;
        }
        // find KeyStore, KeyManagers
        // string keystore = System.getProperty("javax.net.ssl.keyStore");
        // if (keystore is null) {
        //     return null;
        // }
        // string keystorepwd = System.getProperty("javax.net.ssl.keyStorePassword");
        // char[] pwd = (keystorepwd is null) ? null : keystorepwd.toCharArray();

        // KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
        // InputStream is = null;
        // try {
        //     is = new BufferedInputStream(new FileInputStream(keystore));
        //     ks.load(is, pwd);
        // } finally {
        //     if (is != null) {
        //         is.close();
        //     }
        // }

        // string kmfAlg = KeyManagerFactory.getDefaultAlgorithm();
        // KeyManagerFactory kmf = KeyManagerFactory.getInstance(kmfAlg);
        // kmf.init(ks, pwd);
        // KEY_MANAGERS = kmf.getKeyManagers();
        // implementationMissing();
        return KEY_MANAGERS;
    }

    // TODO javax.net.ssl.trustStoreProvider system property
    TrustManager[] getTrustManagers() {
        if (TRUST_MANAGERS != null) {
            return TRUST_MANAGERS;
        }

        // find TrustStore, TrustManagers
        // string keystore = System.getProperty("javax.net.ssl.trustStore");
        // if (keystore is null) {
        //     return null;
        // }
        // string keystorepwd = System.getProperty("javax.net.ssl.trustStorePassword");
        // char[] pwd = (keystorepwd is null) ? null : keystorepwd.toCharArray();

        // // TODO Defaults: jssecacerts; cacerts
        // KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
        // InputStream is = null;
        // try {
        //     is = new BufferedInputStream(new FileInputStream(keystore));
        //     ks.load(is, pwd);
        // } finally {
        //     if (is != null) {
        //         is.close();
        //     }
        // }
        // string tmfAlg = TrustManagerFactory.getDefaultAlgorithm();
        // TrustManagerFactory tmf = TrustManagerFactory.getInstance(tmfAlg);
        // tmf.init(ks);
        // TRUST_MANAGERS = tmf.getTrustManagers();

        // implementationMissing();
        return TRUST_MANAGERS;
    }

    // override
    // void engineInit(KeyManager[] kms, TrustManager[] tms) {
    //     throw new KeyManagementException("Do not init() the default SSLContext ");
    // }
}

