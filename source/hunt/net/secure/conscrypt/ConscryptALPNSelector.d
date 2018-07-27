module hunt.net.secure.conscrypt.ConscryptALPNSelector;

import hunt.net.secure.ProtocolSelector;
import hunt.net.secure.conscrypt.ApplicationProtocolSelector;

class ConscryptALPNSelector : ProtocolSelector {

    private string[] supportedProtocols;
    private string[] supportedProtocolList;

    private SSLEngine sslEngine;

    this(SSLEngine sslEngine, string[] supportedProtocolList) {
        if (CollectionUtils.isEmpty(supportedProtocolList)) {
            this.supportedProtocolList = ["h2", "http/1.1"];
        } else {
            this.supportedProtocolList = supportedProtocolList;
        }
        supportedProtocols = this.supportedProtocolList.toArray(StringUtils.EMPTY_STRING_ARRAY);
        this.sslEngine = sslEngine;
        if (sslEngine.getUseClientMode()) {
            Conscrypt.setApplicationProtocols(sslEngine, supportedProtocols);
        } else {
            Conscrypt.setApplicationProtocolSelector(sslEngine, new ConscryptApplicationProtocolSelector());
        }
    }

    private class ConscryptApplicationProtocolSelector : ApplicationProtocolSelector {

        override
        string selectApplicationProtocol(SSLEngine sslEngine, string[] protocols) {
            return select(protocols);
        }

        override
        string selectApplicationProtocol(SSLSocket sslSocket, string[] protocols) {
            return select(protocols);
        }

        string select(string[] clientProtocols) {
            if (clientProtocols is null)
            return null;

            foreach (string p ; supportedProtocols) {
                if (clientProtocols.contains(p)) {
                    tracef("ALPN local server selected protocol -> %s", p);
                    return p;
                }
            }
        }
    }

    override
    string getApplicationProtocol() {
        return Conscrypt.getApplicationProtocol(sslEngine);
    }

    override
    string[] getSupportedApplicationProtocols() {
        return supportedProtocolList;
    }
}
