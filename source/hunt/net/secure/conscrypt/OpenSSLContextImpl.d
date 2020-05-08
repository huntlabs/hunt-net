module hunt.net.secure.conscrypt.OpenSSLContextImpl;


// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.conscrypt.ClientSessionContext;
import hunt.net.secure.conscrypt.ConscryptEngine;
import hunt.net.secure.conscrypt.NativeCrypto;
import hunt.net.secure.conscrypt.SSLParametersImpl;
import hunt.net.secure.conscrypt.ServerSessionContext;

// import hunt.net.ssl.KeyManager;
import hunt.net.ssl.SSLContextSpi;
import hunt.net.ssl.SSLEngine;

import hunt.net.KeyCertOptions;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
// import hunt.security.Key;

import std.array;


/**
 * OpenSSL-backed SSLContext service provider interface.
 *
 * <p>Public to allow contruction via the provider framework.
 *
 */
abstract class OpenSSLContextImpl : SSLContextSpi {
    /**
     * The default SSLContextImpl for use with
     * SSLContext.getInstance("Default"). Protected by the
     * DefaultSSLContextImpl.class monitor.
     */
    private __gshared DefaultSSLContextImpl defaultSslContextImpl;

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

    this(KeyCertOptions options) {
        this.algorithms = null;
        if (defaultSslContextImpl is null) {
            // TODO: Tasks pending completion -@zhangxueping at 2019-12-17T22:17:15+08:00
            // Create different sessionContext for client and server
            clientSessionContext = new ClientSessionContext();
            serverSessionContext = new ServerSessionContext();

            version(HUNT_NET_DEBUG) warning("Initializing OpenSSL Context...");

            if(options !is null) {
                string caFile = options.getCaFile();
                if(!caFile.empty()) {
                    // serverSessionContext.setVerify();
                    serverSessionContext.useCaCertificate(caFile, options.getCaPassword());
                }

                serverSessionContext.useCertificate(options.getCertFile(), options.getKeyFile(),
                    options.getCertPassword(), options.getKeyPassword());
            }
            
            defaultSslContextImpl = cast(DefaultSSLContextImpl) this;
        } else {
            version(HUNT_NET_DEBUG) warning("Using existed defaultSslContextImpl");
            clientSessionContext = defaultSslContextImpl.engineGetClientSessionContext();
            serverSessionContext = defaultSslContextImpl.engineGetServerSessionContext();
        }
        sslParameters = new SSLParametersImpl(options, clientSessionContext,
                serverSessionContext, algorithms);
    }

    // this(string[] algorithms, string certificate, string privatekey) {
    //     this.algorithms = algorithms;
    //     // clientSessionContext = new ClientSessionContext();
    //     serverSessionContext = new ServerSessionContext(certificate, privatekey);
    // }

    /**
     * Constuctor for the DefaultSSLContextImpl.
     */
    // this(string certificate, string privatekey) {
    //     // synchronized {
    //         this.algorithms = null;
    //         if (defaultSslContextImpl is null) {
    //             clientSessionContext = new ClientSessionContext();
    //             serverSessionContext = new ServerSessionContext(certificate, privatekey);
    //             defaultSslContextImpl = cast(DefaultSSLContextImpl) this;
    //         } else {
    //             clientSessionContext = defaultSslContextImpl.engineGetClientSessionContext();
    //             serverSessionContext = defaultSslContextImpl.engineGetServerSessionContext();
    //         }
    //         sslParameters = new SSLParametersImpl(defaultSslContextImpl.getKeyManagers(),
    //                 defaultSslContextImpl.getTrustManagers(), clientSessionContext,
    //                 serverSessionContext, algorithms);
    //     // }
    // }

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
    // void engineInit(KeyManager[] kms, TrustManager[] tms) {
    //     sslParameters = new SSLParametersImpl(
    //             kms, tms, clientSessionContext, serverSessionContext, algorithms);
    // }

    void engineInit(KeyCertOptions options) {
        sslParameters = new SSLParametersImpl(options, clientSessionContext, serverSessionContext, algorithms);
    }    

    // override
    // SSLSocketFactory engineGetSocketFactory() {
    //     if (sslParameters is null) {
    //         throw new IllegalStateException("SSLContext is not initialized.");
    //     }
    //     // return Platform.wrapSocketFactoryIfNeeded(new OpenSSLSocketFactoryImpl(sslParameters));

    //     implementationMissing();
    //     return null;
    // }

    // override
    // SSLServerSocketFactory engineGetServerSocketFactory() {
    //     if (sslParameters is null) {
    //         throw new IllegalStateException("SSLContext is not initialized.");
    //     }
    //     return new OpenSSLServerSocketFactoryImpl(sslParameters);
    // }

    override
    SSLEngine engineCreateSSLEngine(bool clientMode, string host, int port) {
        if (sslParameters is null) {
            throw new IllegalStateException("SSLContext is not initialized.");
        }
        SSLParametersImpl p = cast(SSLParametersImpl) sslParameters.clone();
        p.setUseClientMode(clientMode);
        return new ConscryptEngine(host, port, p);
    }

    override
    SSLEngine engineCreateSSLEngine(bool clientMode) {
        if (sslParameters is null) {
            throw new IllegalStateException("SSLContext is not initialized.");
        }

        SSLParametersImpl p = cast(SSLParametersImpl) sslParameters.clone();
        p.setUseClientMode(clientMode);

        return new ConscryptEngine(p);
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
 */

final class DefaultSSLContextImpl : OpenSSLContextImpl {

    /**
     * Accessed by SSLContextImpl(DefaultSSLContextImpl) holding the
     * DefaultSSLContextImpl.class monitor
     */
    // private static KeyManager[] KEY_MANAGERS;

    /**
     * Accessed by SSLContextImpl(DefaultSSLContextImpl) holding the
     * DefaultSSLContextImpl.class monitor
     */
    // private static TrustManager[] TRUST_MANAGERS;

    /**
     * DefaultSSLContextImpl delegates the work to the super class since there
     * is no way to put a synchronized around both the call to super and the
     * rest of this constructor to guarantee that we don't have races in
     * creating the state shared between all default SSLContexts.
     */
    this(KeyCertOptions options) {
        // warning("No certificates provided!");
        super(options);
    }

    // this(string certificate, string privatekey) {
    //     super(certificate, privatekey);
    // }

    // TODO javax.net.ssl.keyStoreProvider system property
    // KeyManager[] getKeyManagers () {
    //     if (KEY_MANAGERS !is null) {
    //         return KEY_MANAGERS;
    //     }
    //     // find KeyStore, KeyManagers
    //     // string keystore = System.getProperty("javax.net.ssl.keyStore");
    //     // if (keystore is null) {
    //     //     return null;
    //     // }
    //     // string keystorepwd = System.getProperty("javax.net.ssl.keyStorePassword");
    //     // char[] pwd = (keystorepwd is null) ? null : keystorepwd.toCharArray();

    //     // KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
    //     // InputStream is = null;
    //     // try {
    //     //     is = new BufferedInputStream(new FileInputStream(keystore));
    //     //     ks.load(is, pwd);
    //     // } finally {
    //     //     if (is !is null) {
    //     //         is.close();
    //     //     }
    //     // }

    //     // string kmfAlg = KeyManagerFactory.getDefaultAlgorithm();
    //     // KeyManagerFactory kmf = KeyManagerFactory.getInstance(kmfAlg);
    //     // kmf.init(ks, pwd);
    //     // KEY_MANAGERS = kmf.getKeyManagers();
    //     // implementationMissing();
    //     return KEY_MANAGERS;
    // }

    // TODO javax.net.ssl.trustStoreProvider system property
    // TrustManager[] getTrustManagers() {
    //     if (TRUST_MANAGERS !is null) {
    //         return TRUST_MANAGERS;
    //     }

    //     // find TrustStore, TrustManagers
    //     // string keystore = System.getProperty("javax.net.ssl.trustStore");
    //     // if (keystore is null) {
    //     //     return null;
    //     // }
    //     // string keystorepwd = System.getProperty("javax.net.ssl.trustStorePassword");
    //     // char[] pwd = (keystorepwd is null) ? null : keystorepwd.toCharArray();

    //     // // TODO Defaults: jssecacerts; cacerts
    //     // KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
    //     // InputStream is = null;
    //     // try {
    //     //     is = new BufferedInputStream(new FileInputStream(keystore));
    //     //     ks.load(is, pwd);
    //     // } finally {
    //     //     if (is !is null) {
    //     //         is.close();
    //     //     }
    //     // }
    //     // string tmfAlg = TrustManagerFactory.getDefaultAlgorithm();
    //     // TrustManagerFactory tmf = TrustManagerFactory.getInstance(tmfAlg);
    //     // tmf.init(ks);
    //     // TRUST_MANAGERS = tmf.getTrustManagers();

    //     // implementationMissing();
    //     return TRUST_MANAGERS;
    // }

    // override
    // void engineInit(KeyManager[] kms, TrustManager[] tms) {
    //     throw new KeyManagementException("Do not init() the default SSLContext ");
    // }
}

