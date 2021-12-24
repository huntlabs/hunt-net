module hunt.net.secure.conscrypt.AbstractConscryptSSLContextFactory;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.ProtocolSelector;
import hunt.net.secure.conscrypt.ConscryptALPNSelector;
import hunt.net.secure.SSLContextFactory;
import hunt.net.ssl;

import hunt.Exceptions;
import hunt.stream.ByteArrayInputStream;
import hunt.stream.Common;
import hunt.logging;
import hunt.net.KeyCertOptions;
// import hunt.security.cert.X509Certificate;
import hunt.util.DateTime;
import hunt.util.TypeUtils;

import std.array;
import std.datetime : Clock;
import std.datetime.stopwatch;
import std.typecons;


/**
 * 
 */
abstract class AbstractConscryptSSLContextFactory : SSLContextFactory {

    private enum string provideName = "Conscrypt";
    private string[] supportedProtocols;

    // static this() {
    //     // Provider provider = Conscrypt.newProvider();
    //     // provideName = provider.getName();
    //     // Security.addProvider(provider);
    //     // provideName = "Conscrypt";
    //     infof("add Conscrypt security provider");
    // }

    // static string getProvideName() {
    //     return provideName;
    // }

    SSLContext getSSLContextWithManager() { // KeyManager[] km, TrustManager[] tm
        version(HUNT_NET_DEBUG) long start = Clock.currStdTime;

        SSLContext sslContext = SSLContext.getInstance(null, "TLSv1.2");
        // sslContext.init(km, tm); // TODO:

        version(HUNT_NET_DEBUG) {
            long end = Clock.currStdTime;
            long d = convert!(TimeUnit.HectoNanosecond, TimeUnit.Millisecond)(end - start);
            tracef("creating Conscrypt SSL context spends %d ms", d);
        }
        return sslContext;
    }

    // SSLContext getSSLContext(InputStream inputStream, string keystorePassword, string keyPassword) {
    //     return getSSLContext(inputStream, keystorePassword, keyPassword, null, null, null);
    // }

    // SSLContext getSSLContext(InputStream inputStream, string keystorePassword, string keyPassword,
    //             string keyManagerFactoryType, string trustManagerFactoryType, string sslProtocol) {
    //     version(HUNT_NET_DEBUG) StopWatch sw = StopWatch(AutoStart.yes);
    //     SSLContext sslContext;

    //     // KeyStore ks = KeyStore.getInstance("JKS");
    //     // ks.load(inputStream, keystorePassword !is null ? keystorePassword.toCharArray() : null);

    //     // // PKIX,SunX509
    //     // KeyManagerFactory kmf = KeyManagerFactory.getInstance(keyManagerFactoryType is null ? "SunX509" : keyManagerFactoryType);
    //     // kmf.init(ks, keyPassword !is null ? keyPassword.toCharArray() : null);

    //     // TrustManagerFactory tmf = TrustManagerFactory.getInstance(trustManagerFactoryType is null ? "SunX509" : trustManagerFactoryType);
    //     // tmf.init(ks);

    //     // TLSv1 TLSv1.2
    //     sslContext = SSLContext.getInstance(sslProtocol.empty ? "TLSv1.2" : sslProtocol, provideName);
    //     // sslContext.init(kmf.getKeyManagers(), tmf.getTrustManagers(), null);

    //     version(HUNT_NET_DEBUG) {
    //         sw.stop();
    //         infof("creating Conscrypt SSL context spends %s ms", sw.peek.total!"msecs");
    //     }

    //     implementationMissing(false);
    //     return sslContext;
    // }

    void initializeSslContext() {
        implementationMissing(false);
    }

    SSLContext getSSLContext(KeyCertOptions options, string sslProtocol) {
        version(HUNT_NET_DEBUG) {
            StopWatch sw = StopWatch(AutoStart.yes);
        }

        SSLContext sslContext;

        // // PKIX,SunX509
        // KeyManagerFactory kmf = KeyManagerFactory.getInstance(keyManagerFactoryType is null ? "SunX509" : keyManagerFactoryType);
        // kmf.init(ks, keyPassword !is null ? keyPassword.toCharArray() : null);

        // TrustManagerFactory tmf = TrustManagerFactory.getInstance(trustManagerFactoryType is null ? "SunX509" : trustManagerFactoryType);
        // tmf.init(ks);

        // TLSv1 TLSv1.2
        // sslContext = SSLContext.getInstance(options.getCertFile(), options.getKeyFile(), 
        //     sslProtocol.empty ? "TLSv1.2" : sslProtocol, provideName);
        sslContext = SSLContext.getInstance(options, sslProtocol.empty ? "TLSv1.2" : sslProtocol);
        // sslContext.init(kmf.getKeyManagers(), tmf.getTrustManagers(), null);
        sslContext.initialize(options);

        version(HUNT_NET_DEBUG) {
            infof("creating Conscrypt SSL context spends %s ms", sw.peek.total!"msecs");
            sw.stop();
        }
        return sslContext;
    }

    SSLContext getSSLContext() {
        throw new NotImplementedException();
    }


    Pair!(SSLEngine, ProtocolSelector) createSSLEngine(bool clientMode) {
        SSLEngine sslEngine = getSSLContext().createSSLEngine(clientMode);
        // sslEngine.setUseClientMode(clientMode);
        return makePair(sslEngine, cast(ProtocolSelector)new ConscryptALPNSelector(sslEngine, supportedProtocols));
    }

    Pair!(SSLEngine, ProtocolSelector) createSSLEngine(bool clientMode, string peerHost, int peerPort) {
        SSLEngine sslEngine = getSSLContext().createSSLEngine(clientMode, peerHost, peerPort);
        // sslEngine.setUseClientMode(clientMode);
        return makePair(sslEngine, cast(ProtocolSelector)new ConscryptALPNSelector(sslEngine, supportedProtocols));
    }

    string[] getSupportedProtocols() {
        return supportedProtocols;
    }

    void setSupportedProtocols(string[] supportedProtocols) {
        this.supportedProtocols = supportedProtocols;
    }
}

/**
 * 
 */
class NoCheckConscryptSSLContextFactory : AbstractConscryptSSLContextFactory {

    override SSLContext getSSLContext() {
        try {
            return getSSLContextWithManager();
        } catch (Exception e) {
            errorf("get SSL context error: %s", e.msg);
            version(HUNT_DEBUG) error(e);
            return null;
        }
    }
    
    alias getSSLContext = AbstractConscryptSSLContextFactory.getSSLContext;
}

/**
 * 
 */
class FileCredentialConscryptSSLContextFactory : AbstractConscryptSSLContextFactory {

    private KeyCertOptions _options;

    this(KeyCertOptions options) {
        this._options = options;
    }

    override SSLContext getSSLContext() {
        try {
            return getSSLContext(_options, "TLSv1.2");
        } catch (Exception e) {
            errorf("get SSL context error: %s", e.msg);
            version(HUNT_DEBUG) error(e);
            return null;
        }
    }

    alias getSSLContext = AbstractConscryptSSLContextFactory.getSSLContext;
}
