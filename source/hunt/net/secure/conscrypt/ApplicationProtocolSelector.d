module hunt.net.secure.conscrypt.ApplicationProtocolSelector;

import hunt.net.ssl.SSLSocket;

import hunt.net.ssl;

/**
 * Server-side selector for the ALPN protocol. This is a backward-compatibility shim for Java 9's
 * new {@code setHandshakeApplicationProtocolSelector} API, which takes a {@code BiFunction}
 * (available in Java 8+). This interface is provided to support protocol selection in Java < 8.
 */
public abstract class ApplicationProtocolSelector {
    /**
     * Selects the appropriate ALPN protocol.
     *
     * @param engine the server-side engine
     * @param protocols The list of client-supplied protocols
     * @return The function's result is an application protocol name, or {@code null} to indicate
     * that none of the advertised names are acceptable. If the return value is an empty
     * {@link string} then application protocol indications will not be used. If the return value
     * is {@code null} (no value chosen) or is a value that was not advertised by the peer, a
     * "no_application_protocol" alert will be sent to the peer and the connection will be
     * terminated.
     */
    public abstract string selectApplicationProtocol(SSLEngine engine, string[] protocols);

    /**
     * Selects the appropriate ALPN protocol.
     *
     * @param socket the server-side socket
     * @param protocols The list of client-supplied protocols
     * @return The function's result is an application protocol name, or {@code null} to indicate
     * that none of the advertised names are acceptable. If the return value is an empty
     * {@link string} then application protocol indications will not be used. If the return value
     * is {@code null} (no value chosen) or is a value that was not advertised by the peer, a
     * "no_application_protocol" alert will be sent to the peer and the connection will be
     * terminated.
     */
    public abstract string selectApplicationProtocol(SSLSocket socket, string[] protocols);
}

