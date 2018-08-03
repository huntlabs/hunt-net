module hunt.net.secure.conscrypt.PeerInfoProvider;

private __gshared static PeerInfoProvider NULL_PEER_INFO_PROVIDER;

shared static this()
{
    NULL_PEER_INFO_PROVIDER = new class PeerInfoProvider {
        override
        string getHostname() {
            return null;
        }

        override
        public string getHostnameOrIP() {
            return null;
        }

        override
        public int getPort() {
            return -1;
        }
    };
}    


/**
 * A provider for the peer host and port information.
 */
abstract class PeerInfoProvider {

    /**
     * Returns the hostname supplied during engine/socket creation. No DNS resolution is
     * attempted before returning the hostname.
     */
    abstract string getHostname();

    /**
     * This method attempts to create a textual representation of the peer host or IP. Does
     * not perform a reverse DNS lookup. This is typically used during session creation.
     */
    abstract string getHostnameOrIP();

    /**
     * Gets the port of the peer.
     */
    abstract int getPort();

    static PeerInfoProvider nullProvider() {
        return NULL_PEER_INFO_PROVIDER;
    }

    static PeerInfoProvider forHostAndPort(string host, int port) {
        return new class PeerInfoProvider {
            override
            string getHostname() {
                return host;
            }

            override
            public string getHostnameOrIP() {
                return host;
            }

            override
            public int getPort() {
                return port;
            }
        };
    }
}
