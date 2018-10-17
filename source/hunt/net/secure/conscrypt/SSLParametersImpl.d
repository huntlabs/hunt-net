module hunt.net.secure.conscrypt.SSLParametersImpl;

version(BoringSSL) {
    version=WithSSL;
} else version(OpenSSL) {
    version=WithSSL;
}
version(WithSSL):

import hunt.net.secure.conscrypt.AbstractSessionContext;
import hunt.net.secure.conscrypt.ApplicationProtocolSelectorAdapter;
import hunt.net.secure.conscrypt.ClientSessionContext;
import hunt.net.secure.conscrypt.NativeCrypto;
import hunt.net.secure.conscrypt.ServerSessionContext;
import hunt.net.secure.conscrypt.SSLUtils;

import hunt.net.ssl.KeyManager;
import hunt.net.ssl.KeyManagerFactory;
import hunt.net.ssl.X509KeyManager;
import hunt.net.ssl.X509TrustManager;

import hunt.security.key;
import hunt.security.cert.X509Certificate;
import hunt.security.x500.X500Principal;
// import hunt.net.ssl.TrustManager;

import hunt.lang.exception;
import hunt.logging;

/**
 * The instances of this class encapsulate all the info
 * about enabled cipher suites and protocols,
 * as well as the information about client/server mode of
 * ssl socket, whether it require/want client authentication or not,
 * and controls whether new SSL sessions may be established by this
 * socket or not.
 */
final class SSLParametersImpl  {

    // // default source of X.509 certificate based authentication keys
    private static X509KeyManager defaultX509KeyManager;
    // default source of X.509 certificate based authentication trust decisions
    private static X509TrustManager defaultX509TrustManager;
    // // default SSL parameters
    private static SSLParametersImpl defaultParameters;

    // client session context contains the set of reusable
    // client-side SSL sessions
    private ClientSessionContext clientSessionContext;
    // server session context contains the set of reusable
    // server-side SSL sessions
    private ServerSessionContext serverSessionContext;
    // source of X.509 certificate based authentication keys or null if not provided
    private X509KeyManager x509KeyManager;
    // source of Pre-Shared Key (PSK) authentication keys or null if not provided.
    // @SuppressWarnings("deprecation") // PSKKeyManager is deprecated, but in our own package
    // private PSKKeyManager pskKeyManager;
    // source of X.509 certificate based authentication trust decisions or null if not provided
    private X509TrustManager x509TrustManager;

    // protocols enabled for SSL connection
    string[] enabledProtocols;
    // set to indicate when obsolete protocols are filtered
    bool isEnabledProtocolsFiltered;
    // cipher suites enabled for SSL connection
    string[] enabledCipherSuites;

    // if the peer with this parameters tuned to work in client mode
    private bool client_mode = true;
    // if the peer with this parameters tuned to require client authentication
    private bool need_client_auth = false;
    // if the peer with this parameters tuned to request client authentication
    private bool want_client_auth = false;
    // if the peer with this parameters allowed to cteate new SSL session
    private bool enable_session_creation = true;
    // Endpoint identification algorithm (e.g., HTTPS)
    private string endpointIdentificationAlgorithm;
    // Whether to use the local cipher suites order
    private bool useCipherSuitesOrder;

    // client-side only, bypasses the property based configuration, used for tests
    private bool ctVerificationEnabled;

    // server-side only. SCT and OCSP data to send to clients which request it
    byte[] sctExtension;
    byte[] ocspResponse;

    ubyte[] applicationProtocols = [];
    ApplicationProtocolSelectorAdapter applicationProtocolSelector;
    bool useSessionTickets;
    private bool useSni;

    /**
     * Whether the TLS Channel ID extension is enabled. This field is
     * server-side only.
     */
    bool channelIdEnabled;

    /**
     * Initializes the parameters. Naturally this constructor is used
     * in SSLContextImpl.engineInit method which directly passes its
     * parameters. In other words this constructor holds all
     * the functionality provided by SSLContext.init method.
     * See {@link javax.net.ssl.SSLContext#init(KeyManager[],TrustManager[],
     * SecureRandom)} for more information
     */
    this(KeyManager[] kms, TrustManager[] tms,
            ClientSessionContext clientSessionContext,
            ServerSessionContext serverSessionContext, string[] protocols) {
        this.serverSessionContext = serverSessionContext;
        this.clientSessionContext = clientSessionContext;

        // initialize key managers
        if (kms is null) {
            x509KeyManager = getDefaultX509KeyManager();
            // There's no default PSK key manager
            // pskKeyManager = null;
        } else {
            x509KeyManager = findFirstX509KeyManager(kms);
            // pskKeyManager = findFirstPSKKeyManager(kms);
        }

        // initialize x509TrustManager
        if (tms is null) {
            x509TrustManager = getDefaultX509TrustManager();
        } else {
            x509TrustManager = findFirstX509TrustManager(tms);
        }

        // initialize the list of cipher suites and protocols enabled by default
        enabledProtocols = NativeCrypto.checkEnabledProtocols(
                protocols is null ? NativeCrypto.DEFAULT_PROTOCOLS : protocols).dup;
        bool x509CipherSuitesNeeded = (x509KeyManager !is null) || (x509TrustManager !is null);
        bool pskCipherSuitesNeeded = false; // pskKeyManager !is null;
        enabledCipherSuites = getDefaultCipherSuites(
                x509CipherSuitesNeeded, pskCipherSuitesNeeded);

        // We ignore the SecureRandom passed in by the caller. The native code below
        // directly accesses /dev/urandom, which makes it irrelevant.
    }

    static SSLParametersImpl getDefault()  {

        SSLParametersImpl result = defaultParameters;
        if (result is null) {
            // single-check idiom
            defaultParameters = result = new SSLParametersImpl(cast(KeyManager[])null,
                                                               cast(TrustManager[])null,
                                                            //    null,
                                                               new ClientSessionContext(),
                                                               new ServerSessionContext(),
                                                               cast(string[])null);
        }
        return cast(SSLParametersImpl) result; // .clone();
    }

    /**
     * Returns the appropriate session context.
     */
    AbstractSessionContext getSessionContext() {
        return client_mode ? clientSessionContext : serverSessionContext;
    }

    /**
     * @return client session context
     */
    ClientSessionContext getClientSessionContext() {
        return clientSessionContext;
    }

    /**
     * @return X.509 key manager or {@code null} for none.
     */
    X509KeyManager getX509KeyManager() {
        return x509KeyManager;
    }

    // /**
    //  * @return Pre-Shared Key (PSK) key manager or {@code null} for none.
    //  */
    // @SuppressWarnings("deprecation") // PSKKeyManager is deprecated, but in our own package
    // PSKKeyManager getPSKKeyManager() {
    //     return pskKeyManager;
    // }

    // /**
    //  * @return X.509 trust manager or {@code null} for none.
    //  */
    // X509TrustManager getX509TrustManager() {
    //     return x509TrustManager;
    // }

    /**
     * @return the names of enabled cipher suites
     */
    string[] getEnabledCipherSuites() {
        return enabledCipherSuites.dup;
    }

    /**
     * Sets the enabled cipher suites after filtering through OpenSSL.
     */
    void setEnabledCipherSuites(string[] cipherSuites) {
        enabledCipherSuites = NativeCrypto.checkEnabledCipherSuites(cipherSuites).dup;
    }

    /**
     * @return the set of enabled protocols
     */
    string[] getEnabledProtocols() {
        return enabledProtocols.dup;
    }

    /**
     * Sets the list of available protocols for use in SSL connection.
     * @throws IllegalArgumentException if {@code protocols is null}
     */
    void setEnabledProtocols(string[] protocols) {
        if (protocols is null) {
            throw new IllegalArgumentException("protocols is null");
        }
        string[] filteredProtocols =
                filterFromProtocols(protocols, NativeCrypto.OBSOLETE_PROTOCOL_SSLV3);
        isEnabledProtocolsFiltered = protocols.length != filteredProtocols.length;
        enabledProtocols = NativeCrypto.checkEnabledProtocols(filteredProtocols).dup;
    }

    /**
     * Sets the list of ALPN protocols.
     *
     * @param protocols the list of ALPN protocols
     */
    void setApplicationProtocols(string[] protocols) {
        this.applicationProtocols = cast(ubyte[])SSLUtils.encodeProtocols(protocols);
    }

    string[] getApplicationProtocols() {
        return SSLUtils.decodeProtocols(applicationProtocols);
    }

    /**
     * Used for server-mode only. Sets or clears the application-provided ALPN protocol selector.
     * If set, will override the protocol list provided by {@link #setApplicationProtocols(string[])}.
     */
    void setApplicationProtocolSelector(ApplicationProtocolSelectorAdapter applicationProtocolSelector) {
        this.applicationProtocolSelector = applicationProtocolSelector;
    }

    /**
     * Tunes the peer holding this parameters to work in client mode.
     * @param   mode if the peer is configured to work in client mode
     */
    void setUseClientMode(bool mode) {
        client_mode = mode;
    }

    /**
     * Returns the value indicating if the parameters configured to work
     * in client mode.
     */
    bool getUseClientMode() {
        return client_mode;
    }

    /**
     * Tunes the peer holding this parameters to require client authentication
     */
    void setNeedClientAuth(bool need) {
        need_client_auth = need;
        // reset the want_client_auth setting
        want_client_auth = false;
    }

    /**
     * Returns the value indicating if the peer with this parameters tuned
     * to require client authentication
     */
    bool getNeedClientAuth() {
        return need_client_auth;
    }

    /**
     * Tunes the peer holding this parameters to request client authentication
     */
    void setWantClientAuth(bool want) {
        want_client_auth = want;
        // reset the need_client_auth setting
        need_client_auth = false;
    }

    /**
     * Returns the value indicating if the peer with this parameters
     * tuned to request client authentication
     */
    bool getWantClientAuth() {
        return want_client_auth;
    }

    /**
     * Allows/disallows the peer holding this parameters to
     * create new SSL session
     */
    void setEnableSessionCreation(bool flag) {
        enable_session_creation = flag;
    }

    /**
     * Returns the value indicating if the peer with this parameters
     * allowed to cteate new SSL session
     */
    bool getEnableSessionCreation() {
        return enable_session_creation;
    }

    void setUseSessionTickets(bool useSessionTickets) {
        this.useSessionTickets = useSessionTickets;
    }

    /**
     * Whether connections using this SSL connection should use the TLS
     * extension Server Name Indication (SNI).
     */
    void setUseSni(bool flag) {
        useSni = flag;
    }

    /**
     * Returns whether connections using this SSL connection should use the TLS
     * extension Server Name Indication (SNI).
     */
    bool getUseSni() {
        return useSni ? useSni : isSniEnabledByDefault();
    }

    /**
     * For testing only.
     */
    void setCTVerificationEnabled(bool enabled) {
        ctVerificationEnabled = enabled;
    }

    /**
     * For testing only.
     */
    void setSCTExtension(byte[] extension) {
        sctExtension = extension;
    }

    /**
     * For testing only.
     */
    void setOCSPResponse(byte[] response) {
        ocspResponse = response;
    }

    byte[] getOCSPResponse() {
        return ocspResponse;
    }

    /**
     * This filters {@code obsoleteProtocol} from the list of {@code protocols}
     * down to help with app compatibility.
     */
    private static string[] filterFromProtocols(string[] protocols, string obsoleteProtocol) {
        if (protocols.length == 1 && obsoleteProtocol == protocols[0]) {
            return [];
        }

        string[] newProtocols;
        foreach (string protocol ; protocols) {
            if (obsoleteProtocol != protocol) {
                newProtocols ~= protocol;
            }
        }
        return newProtocols;
    }

    /**
     * Returns whether Server Name Indication (SNI) is enabled by default for
     * sockets. For more information on SNI, see RFC 6066 section 3.
     */
    private bool isSniEnabledByDefault() {
        return false;
        // try {
        //     string enableSNI = System.getProperty("jsse.enableSNIExtension", "true");
        //     if ("true".equalsIgnoreCase(enableSNI)) {
        //         return true;
        //     } else if ("false".equalsIgnoreCase(enableSNI)) {
        //         return false;
        //     } else {
        //         throw new RuntimeException(
        //                 "Can only set \"jsse.enableSNIExtension\" to \"true\" or \"false\"");
        //     }
        // } catch (SecurityException e) {
        //     return true;
        // }
    }

    // /**
    //  * Returns the clone of this object.
    //  * @return the clone.
    //  */
    // // override
    // // protected Object clone() {
    // //     try {
    // //         return super.clone();
    // //     } catch (CloneNotSupportedException e) {
    // //         throw new AssertionError(e);
    // //     }
    // // }

    private static X509KeyManager getDefaultX509KeyManager()  {
        X509KeyManager result = defaultX509KeyManager;
        if (result is null) {
            // single-check idiom
            defaultX509KeyManager = result = createDefaultX509KeyManager();
        }
        return result;
    }

    private static X509KeyManager createDefaultX509KeyManager()  {
        try {
            // string algorithm = KeyManagerFactory.getDefaultAlgorithm();
            // KeyManagerFactory kmf = KeyManagerFactory.getInstance(algorithm);
            // kmf.init(null, null);
            // KeyManager[] kms = kmf.getKeyManagers();
            // X509KeyManager result = findFirstX509KeyManager(kms);
            // if (result is null) {
            //     throw new KeyManagementException("No X509KeyManager among default KeyManagers: "
            //             ~ kms.to!string());
            // }
            // return result;
            implementationMissing(false);
            return null;
        } catch (NoSuchAlgorithmException e) {
            throw new KeyManagementException(e);
        } catch (KeyStoreException e) {
            throw new KeyManagementException(e);
        } catch (UnrecoverableKeyException e) {
            throw new KeyManagementException(e);
        }
    }

    /**
     * Finds the first {@link X509KeyManager} element in the provided array.
     *
     * @return the first {@code X509KeyManager} or {@code null} if not found.
     */
    private static X509KeyManager findFirstX509KeyManager(KeyManager[] kms) {
        foreach (KeyManager km ; kms) {
            X509KeyManager m = cast(X509KeyManager)km;
            if (m !is null) {
                return m;
            }
        }
        warning("X509KeyManager is null");
        return null;
    }

    // /**
    //  * Finds the first {@link PSKKeyManager} element in the provided array.
    //  *
    //  * @return the first {@code PSKKeyManager} or {@code null} if not found.
    //  */
    // @SuppressWarnings("deprecation") // PSKKeyManager is deprecated, but in our own package
    // private static PSKKeyManager findFirstPSKKeyManager(KeyManager[] kms) {
    //     for (KeyManager km : kms) {
    //         if (km instanceof PSKKeyManager) {
    //             return (PSKKeyManager)km;
    //         } else if (km != null) {
    //             try {
    //                 return DuckTypedPSKKeyManager.getInstance(km);
    //             } catch (NoSuchMethodException ignored) {}
    //         }
    //     }
    //     return null;
    // }

    /**
     * Gets the default X.509 trust manager.
     */
    static X509TrustManager getDefaultX509TrustManager()
             {
        X509TrustManager result = defaultX509TrustManager;
        if (result is null) {
            // single-check idiom
            // defaultX509TrustManager = result = createDefaultX509TrustManager();
        }
        return result;
    }

    // private static X509TrustManager createDefaultX509TrustManager()
    //          {
    //     try {
    //         string algorithm = TrustManagerFactory.getDefaultAlgorithm();
    //         TrustManagerFactory tmf = TrustManagerFactory.getInstance(algorithm);
    //         tmf.init((KeyStore) null);
    //         TrustManager[] tms = tmf.getTrustManagers();
    //         X509TrustManager trustManager = findFirstX509TrustManager(tms);
    //         if (trustManager is null) {
    //             throw new KeyManagementException(
    //                     "No X509TrustManager in among default TrustManagers: "
    //                             + Arrays.toString(tms));
    //         }
    //         return trustManager;
    //     } catch (NoSuchAlgorithmException e) {
    //         throw new KeyManagementException(e);
    //     } catch (KeyStoreException e) {
    //         throw new KeyManagementException(e);
    //     }
    // }

    /**
     * Finds the first {@link X509TrustManager} element in the provided array.
     *
     * @return the first {@code X509ExtendedTrustManager} or
     *         {@code X509TrustManager} or {@code null} if not found.
     */
    private static X509TrustManager findFirstX509TrustManager(TrustManager[] tms) {
        foreach (TrustManager tm ; tms) {
            X509TrustManager m = cast(X509TrustManager) tm; 
            if (m !is null) {
                return m;
            }
        }
        return null;
    }

    // string getEndpointIdentificationAlgorithm() {
    //     return endpointIdentificationAlgorithm;
    // }

    // void setEndpointIdentificationAlgorithm(string endpointIdentificationAlgorithm) {
    //     this.endpointIdentificationAlgorithm = endpointIdentificationAlgorithm;
    // }

    // bool getUseCipherSuitesOrder() {
    //     return useCipherSuitesOrder;
    // }

    // void setUseCipherSuitesOrder(bool useCipherSuitesOrder) {
    //     this.useCipherSuitesOrder = useCipherSuitesOrder;
    // }

    private static string[] getDefaultCipherSuites(
            bool x509CipherSuitesNeeded,
            bool pskCipherSuitesNeeded) {
        if (x509CipherSuitesNeeded) {
            // X.509 based cipher suites need to be listed.
            if (pskCipherSuitesNeeded) {
                // Both X.509 and PSK based cipher suites need to be listed. Because TLS-PSK is not
                // normally used, we assume that when PSK cipher suites are requested here they
                // should be preferred over other cipher suites. Thus, we give PSK cipher suites
                // higher priority than X.509 cipher suites.
                // NOTE: There are cipher suites that use both X.509 and PSK (e.g., those based on
                // RSA_PSK key exchange). However, these cipher suites are not currently supported.
                return NativeCrypto.DEFAULT_PSK_CIPHER_SUITES ~
                        NativeCrypto.DEFAULT_X509_CIPHER_SUITES ~
                        [ NativeCrypto.TLS_EMPTY_RENEGOTIATION_INFO_SCSV ];
            } else {
                // Only X.509 cipher suites need to be listed.
                return NativeCrypto.DEFAULT_X509_CIPHER_SUITES ~
                    [ NativeCrypto.TLS_EMPTY_RENEGOTIATION_INFO_SCSV ];
            }
        } else if (pskCipherSuitesNeeded) {
            // Only PSK cipher suites need to be listed.
            return NativeCrypto.DEFAULT_PSK_CIPHER_SUITES ~
                   [ NativeCrypto.TLS_EMPTY_RENEGOTIATION_INFO_SCSV ];
        } else {
            // Neither X.509 nor PSK cipher suites need to be listed.
            return [ NativeCrypto.TLS_EMPTY_RENEGOTIATION_INFO_SCSV ];
        }
    }

    // private static string[] concat(string[]... arrays) {
    //     int resultLength = 0;
    //     for (string[] array : arrays) {
    //         resultLength += array.length;
    //     }
    //     string[] result = new string[resultLength];
    //     int resultOffset = 0;
    //     for (string[] array : arrays) {
    //         System.arraycopy(array, 0, result, resultOffset, array.length);
    //         resultOffset += array.length;
    //     }
    //     return result;
    // }

    /**
     * Check if SCT verification is enforced for a given hostname.
     */
    bool isCTVerificationEnabled(string hostname) {
        if (hostname is null) {
            return false;
        }

        // Bypass the check. This is used for testing only
        if (ctVerificationEnabled) {
            return true;
        }
        // return Platform.isCTVerificationRequired(hostname);
        implementationMissing();
return false;
    }
}


/**
* For abstracting the X509KeyManager calls between
* {@link X509KeyManager#chooseClientAlias(string[], java.security.Principal[], java.net.Socket)}
* and
* {@link X509ExtendedKeyManager#chooseEngineClientAlias(string[], java.security.Principal[], javax.net.ssl.SSLEngine)}
*/
interface AliasChooser {
    string chooseClientAlias(X509KeyManager keyManager, X500Principal[] issuers,
            string[] keyTypes);

    string chooseServerAlias(X509KeyManager keyManager, string keyType);
}

/**
    * For abstracting the {@code PSKKeyManager} calls between those taking an {@code SSLSocket} and
    * those taking an {@code SSLEngine}.
    */
// @SuppressWarnings("deprecation") // PSKKeyManager is deprecated, but in our own package
interface PSKCallbacks {
    // string chooseServerPSKIdentityHint(PSKKeyManager keyManager);
    // string chooseClientPSKIdentity(PSKKeyManager keyManager, string identityHint);
    // SecretKey getPSKKey(PSKKeyManager keyManager, string identityHint, string identity);
}
