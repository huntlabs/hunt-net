module hunt.net.ssl.SSLParameters;


import hunt.Exceptions;
import hunt.collection;

import std.conv;

/**
 * Encapsulates parameters for an SSL/TLS connection. The parameters
 * are the list of ciphersuites to be accepted in an SSL/TLS handshake,
 * the list of protocols to be allowed, the endpoint identification
 * algorithm during SSL/TLS handshaking, the Server Name Indication (SNI),
 * the algorithm constraints and whether SSL/TLS servers should request
 * or require client authentication, etc.
 * <p>
 * SSLParameters can be created via the constructors in this class.
 * Objects can also be obtained using the <code>getSSLParameters()</code>
 * methods in
 * {@link SSLSocket#getSSLParameters SSLSocket} and
 * {@link SSLServerSocket#getSSLParameters SSLServerSocket} and
 * {@link SSLEngine#getSSLParameters SSLEngine} or the
 * {@link SSLContext#getDefaultSSLParameters getDefaultSSLParameters()} and
 * {@link SSLContext#getSupportedSSLParameters getSupportedSSLParameters()}
 * methods in <code>SSLContext</code>.
 * <p>
 * SSLParameters can be applied to a connection via the methods
 * {@link SSLSocket#setSSLParameters SSLSocket.setSSLParameters()} and
 * {@link SSLServerSocket#setSSLParameters SSLServerSocket.setSSLParameters()}
 * and {@link SSLEngine#setSSLParameters SSLEngine.setSSLParameters()}.
 *
 * @see SSLSocket
 * @see SSLEngine
 * @see SSLContext
 *
 */
class SSLParameters {

    private string[] cipherSuites;
    private string[] protocols;
    private bool wantClientAuth;
    private bool needClientAuth;
    private string identificationAlgorithm;
    // private Map!(int, SNIServerName) sniNames = null;
    // private Map!(int, SNIMatcher) sniMatchers = null;
    private bool preferLocalCipherSuites;

    /**
     * Constructs SSLParameters.
     * <p>
     * The values of cipherSuites, protocols, cryptographic algorithm
     * constraints, endpoint identification algorithm, server names and
     * server name matchers are set to <code>null</code>, useCipherSuitesOrder,
     * wantClientAuth and needClientAuth are set to <code>false</code>.
     */
    this() {
        // empty
    }

    /**
     * Constructs SSLParameters from the specified array of ciphersuites.
     * <p>
     * Calling this constructor is equivalent to calling the no-args
     * constructor followed by
     * <code>setCipherSuites(cipherSuites);</code>.
     *
     * @param cipherSuites the array of ciphersuites (or null)
     */
    this(string[] cipherSuites) {
        setCipherSuites(cipherSuites);
    }

    /**
     * Constructs SSLParameters from the specified array of ciphersuites
     * and protocols.
     * <p>
     * Calling this constructor is equivalent to calling the no-args
     * constructor followed by
     * <code>setCipherSuites(cipherSuites); setProtocols(protocols);</code>.
     *
     * @param cipherSuites the array of ciphersuites (or null)
     * @param protocols the array of protocols (or null)
     */
    this(string[] cipherSuites, string[] protocols) {
        setCipherSuites(cipherSuites);
        setProtocols(protocols);
    }

    private static string[] clone(string[] s) {
        return (s is null) ? null : s.dup;
    }

    /**
     * Returns a copy of the array of ciphersuites or null if none
     * have been set.
     *
     * @return a copy of the array of ciphersuites or null if none
     * have been set.
     */
    string[] getCipherSuites() {
        return clone(cipherSuites);
    }

    /**
     * Sets the array of ciphersuites.
     *
     * @param cipherSuites the array of ciphersuites (or null)
     */
    void setCipherSuites(string[] cipherSuites) {
        this.cipherSuites = clone(cipherSuites);
    }

    /**
     * Returns a copy of the array of protocols or null if none
     * have been set.
     *
     * @return a copy of the array of protocols or null if none
     * have been set.
     */
    string[] getProtocols() {
        return clone(protocols);
    }

    /**
     * Sets the array of protocols.
     *
     * @param protocols the array of protocols (or null)
     */
    void setProtocols(string[] protocols) {
        this.protocols = clone(protocols);
    }

    /**
     * Returns whether client authentication should be requested.
     *
     * @return whether client authentication should be requested.
     */
    bool getWantClientAuth() {
        return wantClientAuth;
    }

    /**
     * Sets whether client authentication should be requested. Calling
     * this method clears the <code>needClientAuth</code> flag.
     *
     * @param wantClientAuth whether client authentication should be requested
     */
    void setWantClientAuth(bool wantClientAuth) {
        this.wantClientAuth = wantClientAuth;
        this.needClientAuth = false;
    }

    /**
     * Returns whether client authentication should be required.
     *
     * @return whether client authentication should be required.
     */
    bool getNeedClientAuth() {
        return needClientAuth;
    }

    /**
     * Sets whether client authentication should be required. Calling
     * this method clears the <code>wantClientAuth</code> flag.
     *
     * @param needClientAuth whether client authentication should be required
     */
    void setNeedClientAuth(bool needClientAuth) {
        this.wantClientAuth = false;
        this.needClientAuth = needClientAuth;
    }

    /**
     * Returns the cryptographic algorithm constraints.
     *
     * @return the cryptographic algorithm constraints, or null if the
     *     constraints have not been set
     *
     * @see #setAlgorithmConstraints(AlgorithmConstraints)
     *
     */
    // AlgorithmConstraints getAlgorithmConstraints() {
    //     return algorithmConstraints;
    // }

    /**
     * Sets the cryptographic algorithm constraints, which will be used
     * in addition to any configured by the runtime environment.
     * <p>
     * If the <code>constraints</code> parameter is non-null, every
     * cryptographic algorithm, key and algorithm parameters used in the
     * SSL/TLS handshake must be permitted by the constraints.
     *
     * @param constraints the algorithm constraints (or null)
     *
     */
    // void setAlgorithmConstraints(AlgorithmConstraints constraints) {
    //     // the constraints object is immutable
    //     this.algorithmConstraints = constraints;
    // }

    /**
     * Gets the endpoint identification algorithm.
     *
     * @return the endpoint identification algorithm, or null if none
     * has been set.
     *
     * @see X509ExtendedTrustManager
     * @see #setEndpointIdentificationAlgorithm(string)
     *
     */
    string getEndpointIdentificationAlgorithm() {
        return identificationAlgorithm;
    }

    /**
     * Sets the endpoint identification algorithm.
     * <p>
     * If the <code>algorithm</code> parameter is non-null or non-empty, the
     * endpoint identification/verification procedures must be handled during
     * SSL/TLS handshaking.  This is to prevent man-in-the-middle attacks.
     *
     * @param algorithm The standard string name of the endpoint
     *     identification algorithm (or null).  See Appendix A in the <a href=
     *   "{@docRoot}/../technotes/guides/security/crypto/CryptoSpec.html#AppA">
     *     Java Cryptography Architecture API Specification &amp; Reference </a>
     *     for information about standard algorithm names.
     *
     * @see X509ExtendedTrustManager
     *
     */
    void setEndpointIdentificationAlgorithm(string algorithm) {
        this.identificationAlgorithm = algorithm;
    }

    /**
     * Sets the desired {@link SNIServerName}s of the Server Name
     * Indication (SNI) parameter.
     * <P>
     * This method is only useful to {@link SSLSocket}s or {@link SSLEngine}s
     * operating in client mode.
     * <P>
     * Note that the {@code serverNames} list is cloned
     * to protect against subsequent modification.
     *
     * @param  serverNames
     *         the list of desired {@link SNIServerName}s (or null)
     *
     * @throws NullPointerException if the {@code serverNames}
     *         contains {@code null} element
     * @throws IllegalArgumentException if the {@code serverNames}
     *         contains more than one name of the same name type
     *
     * @see SNIServerName
     * @see #getServerNames()
     *
     */
    // void setServerNames(List!SNIServerName serverNames) {
    //     if (serverNames !is null) {
    //         if (!serverNames.isEmpty()) {
    //             sniNames = new HashMap!(int, SNIServerName)(serverNames.size()); // LinkedHashMap<>(serverNames.size());
    //             foreach (SNIServerName serverName ; serverNames) {
    //                 if (sniNames.put(serverName.getType(),
    //                                             serverName) !is null) {
    //                     throw new IllegalArgumentException(
    //                                 "Duplicated server name of type " ~
    //                                 serverName.getType().to!string());
    //                 }
    //             }
    //         } else {
    //             sniNames = Collections.emptyMap!(int, SNIServerName)();
    //         }
    //     } else {
    //         sniNames = null;
    //     }
    // }

    /**
     * Returns a {@link List} containing all {@link SNIServerName}s of the
     * Server Name Indication (SNI) parameter, or null if none has been set.
     * <P>
     * This method is only useful to {@link SSLSocket}s or {@link SSLEngine}s
     * operating in client mode.
     * <P>
     * For SSL/TLS connections, the underlying SSL/TLS provider
     * may specify a default value for a certain server name type.  In
     * client mode, it is recommended that, by default, providers should
     * include the server name indication whenever the server can be located
     * by a supported server name type.
     * <P>
     * It is recommended that providers initialize default Server Name
     * Indications when creating {@code SSLSocket}/{@code SSLEngine}s.
     * In the following examples, the server name could be represented by an
     * instance of {@link SNIHostName} which has been initialized with the
     * hostname "www.example.com" and type
     * {@link StandardConstants#SNI_HOST_NAME}.
     *
     * <pre>
     *     Socket socket =
     *         sslSocketFactory.createSocket("www.example.com", 443);
     * </pre>
     * or
     * <pre>
     *     SSLEngine engine =
     *         sslContext.createSSLEngine("www.example.com", 443);
     * </pre>
     * <P>
     *
     * @return null or an immutable list of non-null {@link SNIServerName}s
     *
     * @see List
     * @see #setServerNames(List)
     *
     */
    // List!SNIServerName getServerNames() {
    //     if (sniNames !is null) {
    //         if (!sniNames.isEmpty()) {
    //             return new ArrayList!(SNIServerName)(sniNames.values());
    //         } else {
    //             return new EmptyList!(SNIServerName)();
    //         }
    //     }

    //     return null;
    // }

    /**
     * Sets the {@link SNIMatcher}s of the Server Name Indication (SNI)
     * parameter.
     * <P>
     * This method is only useful to {@link SSLSocket}s or {@link SSLEngine}s
     * operating in server mode.
     * <P>
     * Note that the {@code matchers} collection is cloned to protect
     * against subsequent modification.
     *
     * @param  matchers
     *         the collection of {@link SNIMatcher}s (or null)
     *
     * @throws NullPointerException if the {@code matchers}
     *         contains {@code null} element
     * @throws IllegalArgumentException if the {@code matchers}
     *         contains more than one name of the same name type
     *
     * @see Collection
     * @see SNIMatcher
     * @see #getSNIMatchers()
     *
     */
    // void setSNIMatchers(Collection!SNIMatcher matchers) {
    //     if (matchers !is null) {
    //         if (!matchers.isEmpty()) {
    //             sniMatchers = new HashMap!(int, SNIMatcher)(matchers.size());
    //             foreach (SNIMatcher matcher ; matchers) {
    //                 if (sniMatchers.put(matcher.getType(),
    //                                             matcher) !is null) {
    //                     throw new IllegalArgumentException(
    //                                 "Duplicated server name of type " ~
    //                                 matcher.getType().to!string());
    //                 }
    //             }
    //         } else {
    //             sniMatchers = Collections.emptyMap!(int, SNIMatcher)(); 
    //         }
    //     } else {
    //         sniMatchers = null;
    //     }
    // }

    /**
     * Returns a {@link Collection} containing all {@link SNIMatcher}s of the
     * Server Name Indication (SNI) parameter, or null if none has been set.
     * <P>
     * This method is only useful to {@link SSLSocket}s or {@link SSLEngine}s
     * operating in server mode.
     * <P>
     * For better interoperability, providers generally will not define
     * default matchers so that by default servers will ignore the SNI
     * extension and continue the handshake.
     *
     * @return null or an immutable collection of non-null {@link SNIMatcher}s
     *
     * @see SNIMatcher
     * @see #setSNIMatchers(Collection)
     *
     */
    // Collection!SNIMatcher getSNIMatchers() {
    //     if (sniMatchers !is null) {
    //         if (!sniMatchers.isEmpty()) {
    //             return new ArrayList!(SNIMatcher)(sniMatchers.values());
    //         } else {
    //             return new EmptyList!(SNIMatcher)();
    //         }
    //     }

    //     return null;
    // }

    /**
     * Sets whether the local cipher suites preference should be honored.
     *
     * @param honorOrder whether local cipher suites order in
     *        {@code #getCipherSuites} should be honored during
     *        SSL/TLS handshaking.
     *
     * @see #getUseCipherSuitesOrder()
     *
     */
    void setUseCipherSuitesOrder(bool honorOrder) {
        this.preferLocalCipherSuites = honorOrder;
    }

    /**
     * Returns whether the local cipher suites preference should be honored.
     *
     * @return whether local cipher suites order in {@code #getCipherSuites}
     *         should be honored during SSL/TLS handshaking.
     *
     * @see #setUseCipherSuitesOrder(bool)
     *
     */
    bool getUseCipherSuitesOrder() {
        return preferLocalCipherSuites;
    }
}