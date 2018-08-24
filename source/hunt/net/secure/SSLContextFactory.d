module hunt.net.secure.SSLContextFactory;

import hunt.net.secure.ProtocolSelector;
import hunt.net.ssl.SSLEngine;

// import std.typecons;
import hunt.util.TypeUtils;

interface SSLContextFactory {

    Pair!(SSLEngine, ProtocolSelector) createSSLEngine(bool clientMode);

    // Pair!(SSLEngine, ProtocolSelector) createSSLEngine(string certificate, string privatekey, 
    //     string keystorePassword, string keyPassword);

    Pair!(SSLEngine, ProtocolSelector) createSSLEngine(bool clientMode, string peerHost, int peerPort);

    string[] getSupportedProtocols();

    void setSupportedProtocols(string[] supportedProtocols);

    // string sslCertificate();
    // void sslCertificate(string fileName);
    // string sslPrivateKey();
    // void sslPrivateKey(string fileName);
}