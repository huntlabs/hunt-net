module hunt.net.ssl.SSLContextFactory;

import hunt.net.ApplicationProtocolSelector;
import hunt.net.ssl.SSLEngine;

// import std.typecons;
import hunt.util.TypeUtils;

interface SSLContextFactory {

    Pair!(SSLEngine, ApplicationProtocolSelector) createSSLEngine(bool clientMode);

    Pair!(SSLEngine, ApplicationProtocolSelector) createSSLEngine(bool clientMode, string peerHost, int peerPort);

    string[] getSupportedProtocols();

    void setSupportedProtocols(string[] supportedProtocols);
}