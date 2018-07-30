module hunt.net.secure.SSLContextFactory;

import hunt.net.secure.ProtocolSelector;
import hunt.net.ssl.SSLEngine;

// import std.typecons;
import hunt.util.TypeUtils;

interface SSLContextFactory {

    Pair!(SSLEngine, ProtocolSelector) createSSLEngine(bool clientMode);

    Pair!(SSLEngine, ProtocolSelector) createSSLEngine(bool clientMode, string peerHost, int peerPort);

    string[] getSupportedProtocols();

    void setSupportedProtocols(string[] supportedProtocols);
}