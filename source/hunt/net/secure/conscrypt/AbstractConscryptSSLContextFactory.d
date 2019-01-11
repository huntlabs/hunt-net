module hunt.net.secure.conscrypt.AbstractConscryptSSLContextFactory;

version(BoringSSL) {
    version=WithSSL;
} else version(OpenSSL) {
    version=WithSSL;
}
version(WithSSL):

import hunt.net.secure.ProtocolSelector;
import hunt.net.secure.conscrypt.ConscryptALPNSelector;
import hunt.net.secure.SecureUtils;
import hunt.net.secure.SSLContextFactory;
import hunt.net.ssl;

import hunt.io.ByteArrayInputStream;
import hunt.io.Common;

import hunt.Exceptions;
import hunt.util.DateTime;
import hunt.util.TypeUtils;

import hunt.logging;

import std.array;
import std.datetime : Clock;
import std.datetime.stopwatch;
import std.typecons;


/**
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

    static string getProvideName() {
        return provideName;
    }

    SSLContext getSSLContextWithManager(KeyManager[] km, TrustManager[] tm){
        version(HUNT_DEBUG) long start = Clock.currStdTime;

        SSLContext sslContext = SSLContext.getInstance("TLSv1.2", provideName);
        sslContext.init(km, tm);

        version(HUNT_DEBUG) {
            long end = Clock.currStdTime;
            long d = convert!(TimeUnit.HectoNanosecond, TimeUnit.Millisecond)(end - start);
            tracef("creating Conscrypt SSL context spends %d ms", d);
        }
        return sslContext;
    }

    SSLContext getSSLContext(InputStream inputStream, string keystorePassword, string keyPassword) {
        return getSSLContext(inputStream, keystorePassword, keyPassword, null, null, null);
    }

    SSLContext getSSLContext(InputStream inputStream, string keystorePassword, string keyPassword,
                                    string keyManagerFactoryType, string trustManagerFactoryType, string sslProtocol) {
        version(HUNT_DEBUG) StopWatch sw = StopWatch(AutoStart.yes);
        SSLContext sslContext;

        // KeyStore ks = KeyStore.getInstance("JKS");
        // ks.load(inputStream, keystorePassword !is null ? keystorePassword.toCharArray() : null);

        // // PKIX,SunX509
        // KeyManagerFactory kmf = KeyManagerFactory.getInstance(keyManagerFactoryType == null ? "SunX509" : keyManagerFactoryType);
        // kmf.init(ks, keyPassword !is null ? keyPassword.toCharArray() : null);

        // TrustManagerFactory tmf = TrustManagerFactory.getInstance(trustManagerFactoryType == null ? "SunX509" : trustManagerFactoryType);
        // tmf.init(ks);

        // TLSv1 TLSv1.2
        sslContext = SSLContext.getInstance(sslProtocol.empty ? "TLSv1.2" : sslProtocol, provideName);
        // sslContext.init(kmf.getKeyManagers(), tmf.getTrustManagers(), null);

        version(HUNT_DEBUG) {
            sw.stop();
            infof("creating Conscrypt SSL context spends %s ms", sw.peek.total!"msecs");
        }

        implementationMissing(false);
        return sslContext;
    }

    SSLContext getSSLContext(string certificate, string privatekey, string keystorePassword, string keyPassword,
                                    string keyManagerFactoryType, string trustManagerFactoryType, string sslProtocol) {
        version(HUNT_DEBUG) StopWatch sw = StopWatch(AutoStart.yes);
        SSLContext sslContext;

        // // PKIX,SunX509
        // KeyManagerFactory kmf = KeyManagerFactory.getInstance(keyManagerFactoryType == null ? "SunX509" : keyManagerFactoryType);
        // kmf.init(ks, keyPassword !is null ? keyPassword.toCharArray() : null);

        // TrustManagerFactory tmf = TrustManagerFactory.getInstance(trustManagerFactoryType == null ? "SunX509" : trustManagerFactoryType);
        // tmf.init(ks);

        // TLSv1 TLSv1.2
        sslContext = SSLContext.getInstance(certificate, privatekey, sslProtocol.empty ? "TLSv1.2" : sslProtocol, provideName);
        // sslContext.init(kmf.getKeyManagers(), tmf.getTrustManagers(), null);

        version(HUNT_DEBUG) {
            sw.stop();
            infof("creating Conscrypt SSL context spends %s ms", sw.peek.total!"msecs");
        }

        implementationMissing(false);
        return sslContext;
    }

    SSLContext getSSLContext() {
        throw new NotImplementedException();
    }

    // SSLContext getSSLContext(string certificate, string privatekey, 
    //     string keystorePassword, string keyPassword) {
    //         throw new NotImplementedException();
    //     }

    Pair!(SSLEngine, ProtocolSelector) createSSLEngine(bool clientMode) {
        SSLEngine sslEngine = getSSLContext().createSSLEngine();
        sslEngine.setUseClientMode(clientMode);
        return makePair(sslEngine, cast(ProtocolSelector)new ConscryptALPNSelector(sslEngine, supportedProtocols));
    }

    // Pair!(SSLEngine, ProtocolSelector) createSSLEngine(string certificate, string privatekey, 
    //     string keystorePassword, string keyPassword) {
    //     SSLEngine sslEngine = getSSLContext(certificate, privatekey,
    //          keystorePassword, keyPassword).createSSLEngine();
    //     sslEngine.setUseClientMode(false);
    //     return makePair(sslEngine, cast(ProtocolSelector)new ConscryptALPNSelector(sslEngine, supportedProtocols));
    // }

    Pair!(SSLEngine, ProtocolSelector) createSSLEngine(bool clientMode, string peerHost, int peerPort) {
        SSLEngine sslEngine = getSSLContext().createSSLEngine(peerHost, peerPort);
        sslEngine.setUseClientMode(clientMode);
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
*/
class NoCheckConscryptSSLContextFactory : AbstractConscryptSSLContextFactory {
    override SSLContext getSSLContext() {
        try {
            return getSSLContextWithManager(null, [SecureUtils.createX509TrustManagerNoCheck()]);
        } catch (Exception e) {
            errorf("get SSL context error: %s", e.msg);
            return null;
        }
    }
}


/**
*/
class DefaultCredentialConscryptSSLContextFactory : AbstractConscryptSSLContextFactory {

    override SSLContext getSSLContext() {
        try {
            return getSSLContext(new ByteArrayInputStream(SecureUtils.DEFAULT_CREDENTIAL), "ptmima1234", "ptmima4321");
        } catch (Exception e) {
            errorf("get SSL context error", e);
            return null;
        }
    }

    alias getSSLContext = AbstractConscryptSSLContextFactory.getSSLContext;
}

/**
*/
class FileCredentialConscryptSSLContextFactory : AbstractConscryptSSLContextFactory {

    private string certificate;
    private string privatekey;
    private string keystorePassword;
    private string keyPassword;

    this(string certificate, string privatekey, 
        string keystorePassword, string keyPassword) {
            this.certificate = certificate; 
            this.privatekey = privatekey;
        }

    override SSLContext getSSLContext() {
        try {
            return getSSLContext(certificate, privatekey, keystorePassword, keyPassword, null, null, null);
        } catch (Exception e) {
            errorf("get SSL context error", e);
            return null;
        }
    }

    alias getSSLContext = AbstractConscryptSSLContextFactory.getSSLContext;
}
