module hunt.net.secure.SSLContextFactory;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.ProtocolSelector;
import hunt.net.ssl.SSLEngine;

// import std.typecons;
import hunt.util.TypeUtils;

interface SSLContextFactory {

    void initializeSslContext();

    Pair!(SSLEngine, ProtocolSelector) createSSLEngine(bool clientMode);

    // Pair!(SSLEngine, ProtocolSelector) createSSLEngine(string certificate, string privatekey, 
    //     string keystorePassword, string keyPassword);

    Pair!(SSLEngine, ProtocolSelector) createSSLEngine(bool clientMode, string peerHost, int peerPort);

    string[] getSupportedProtocols();

    void setSupportedProtocols(string[] supportedProtocols);
}