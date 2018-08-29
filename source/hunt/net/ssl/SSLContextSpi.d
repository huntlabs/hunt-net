module hunt.net.ssl.SSLContextSpi;

import hunt.net.ssl.KeyManager;
import hunt.net.ssl.SSLEngine;
import hunt.net.ssl.SSLSessionContext;
import hunt.net.ssl.SSLSocket;
import hunt.net.ssl.SSLParameters;
import hunt.net.ssl.SSLSocketFactory;

import hunt.util.exception;

/**
 * This class defines the <i>Service Provider Interface</i> (<b>SPI</b>)
 * for the <code>SSLContext</code> class.
 *
 * <p> All the abstract methods in this class must be implemented by each
 * cryptographic service provider who wishes to supply the implementation
 * of a particular SSL context.
 *
 * @since 1.4
 * @see SSLContext
 */
abstract class SSLContextSpi {
    /**
     * Initializes this context.
     *
     * @param km the sources of authentication keys
     * @param tm the sources of peer authentication trust decisions
     * @param sr the source of randomness
     * @throws KeyManagementException if this operation fails
     * @see SSLContext#init(KeyManager [], TrustManager [], SecureRandom)
     */
    abstract void engineInit(KeyManager[] km, TrustManager[] tm) ;

    /**
     * Returns a <code>SocketFactory</code> object for this
     * context.
     *
     * @return the <code>SocketFactory</code> object
     * @throws IllegalStateException if the SSLContextImpl requires
     *         initialization and the <code>engineInit()</code>
     *         has not been called
     * @see javax.net.ssl.SSLContext#getSocketFactory()
     */
    abstract SSLSocketFactory engineGetSocketFactory();

    /**
     * Returns a <code>ServerSocketFactory</code> object for
     * this context.
     *
     * @return the <code>ServerSocketFactory</code> object
     * @throws IllegalStateException if the SSLContextImpl requires
     *         initialization and the <code>engineInit()</code>
     *         has not been called
     * @see javax.net.ssl.SSLContext#getServerSocketFactory()
     */
    // abstract SSLServerSocketFactory engineGetServerSocketFactory();

    /**
     * Creates a new <code>SSLEngine</code> using this context.
     * <P>
     * Applications using this factory method are providing no hints
     * for an internal session reuse strategy. If hints are desired,
     * {@link #engineCreateSSLEngine(string, int)} should be used
     * instead.
     * <P>
     * Some cipher suites (such as Kerberos) require remote hostname
     * information, in which case this factory method should not be used.
     *
     * @return  the <code>SSLEngine</code> Object
     * @throws IllegalStateException if the SSLContextImpl requires
     *         initialization and the <code>engineInit()</code>
     *         has not been called
     *
     * @see     SSLContext#createSSLEngine()
     *
     * @since   1.5
     */
    abstract SSLEngine engineCreateSSLEngine();

    /**
     * Creates a <code>SSLEngine</code> using this context.
     * <P>
     * Applications using this factory method are providing hints
     * for an internal session reuse strategy.
     * <P>
     * Some cipher suites (such as Kerberos) require remote hostname
     * information, in which case peerHost needs to be specified.
     *
     * @param host the non-authoritative name of the host
     * @param port the non-authoritative port
     * @return  the <code>SSLEngine</code> Object
     * @throws IllegalStateException if the SSLContextImpl requires
     *         initialization and the <code>engineInit()</code>
     *         has not been called
     *
     * @see     SSLContext#createSSLEngine(string, int)
     *
     * @since   1.5
     */
    abstract SSLEngine engineCreateSSLEngine(string host, int port);

    /**
     * Returns a server <code>SSLSessionContext</code> object for
     * this context.
     *
     * @return the <code>SSLSessionContext</code> object
     * @see javax.net.ssl.SSLContext#getServerSessionContext()
     */
    abstract SSLSessionContext engineGetServerSessionContext();

    /**
     * Returns a client <code>SSLSessionContext</code> object for
     * this context.
     *
     * @return the <code>SSLSessionContext</code> object
     * @see javax.net.ssl.SSLContext#getClientSessionContext()
     */
    abstract SSLSessionContext engineGetClientSessionContext();

    private SSLSocket getDefaultSocket() {
        implementationMissing(false);
        return null;
        // try {
        //     SSLSocketFactory factory = engineGetSocketFactory();
        //     return cast(SSLSocket)factory.createSocket();
        // } catch (IOException e) {
        //     throw new UnsupportedOperationException("Could not obtain parameters", e);
        // }
    }

    /**
     * Returns a copy of the SSLParameters indicating the default
     * settings for this SSL context.
     *
     * <p>The parameters will always have the ciphersuite and protocols
     * arrays set to non-null values.
     *
     * <p>The default implementation obtains the parameters from an
     * SSLSocket created by calling the
     * {@linkplain javax.net.SocketFactory#createSocket
     * SocketFactory.createSocket()} method of this context's SocketFactory.
     *
     * @return a copy of the SSLParameters object with the default settings
     * @throws UnsupportedOperationException if the default SSL parameters
     *   could not be obtained.
     *
     * @since 1.6
     */
    SSLParameters engineGetDefaultSSLParameters() {
        SSLSocket socket = getDefaultSocket();
        // return socket.getSSLParameters();
        implementationMissing(false);
        return null;
    }

    /**
     * Returns a copy of the SSLParameters indicating the maximum supported
     * settings for this SSL context.
     *
     * <p>The parameters will always have the ciphersuite and protocols
     * arrays set to non-null values.
     *
     * <p>The default implementation obtains the parameters from an
     * SSLSocket created by calling the
     * {@linkplain javax.net.SocketFactory#createSocket
     * SocketFactory.createSocket()} method of this context's SocketFactory.
     *
     * @return a copy of the SSLParameters object with the maximum supported
     *   settings
     * @throws UnsupportedOperationException if the supported SSL parameters
     *   could not be obtained.
     *
     * @since 1.6
     */
    SSLParameters engineGetSupportedSSLParameters() {
        SSLSocket socket = getDefaultSocket();
        SSLParameters params = new SSLParameters();
        implementationMissing(false);
        // params.setCipherSuites(socket.getSupportedCipherSuites());
        // params.setProtocols(socket.getSupportedProtocols());
        return params;
    }

}


