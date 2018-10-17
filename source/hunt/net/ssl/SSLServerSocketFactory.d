module hunt.net.ssl.SSLServerSocketFactory;

import hunt.net.ssl.ServerSocketFactory;
import hunt.net.ssl.SSLContext;
// import hunt.net.ssl.SSLSessionContext;
// import hunt.net.ssl.SSLSocket;
// import hunt.net.ssl.SSLParameters;

import std.socket;
import hunt.lang.exception;

import hunt.lang.exception;

/**
 * <code>SSLServerSocketFactory</code>s create
 * <code>SSLServerSocket</code>s.
 *
 * @since 1.4
 * @see SSLSocket
 * @see SSLServerSocket
 * @author David Brownell
 */
abstract class SSLServerSocketFactory : ServerSocketFactory
{
    private static SSLServerSocketFactory theFactory;

    private static bool propertyChecked;

    // private static void log(string msg) {
    //     if (SSLSocketFactory.DEBUG) {
    //         System.out.println(msg);
    //     }
    // }

    /**
     * Constructor is used only by subclasses.
     */
    protected this() { /* NOTHING */ }

    /**
     * Returns the default SSL server socket factory.
     *
     * <p>The first time this method is called, the security property
     * "ssl.ServerSocketFactory.provider" is examined. If it is non-null, a
     * class by that name is loaded and instantiated. If that is successful and
     * the object is an instance of SSLServerSocketFactory, it is made the
     * default SSL server socket factory.
     *
     * <p>Otherwise, this method returns
     * <code>SSLContext.getDefault().getServerSocketFactory()</code>. If that
     * call fails, an inoperative factory is returned.
     *
     * @return the default <code>ServerSocketFactory</code>
     * @see SSLContext#getDefault
     */
    static ServerSocketFactory getDefault() {
        if (theFactory !is null) {
            return theFactory;
        }

        // if (propertyChecked == false) {
        //     propertyChecked = true;
        //     string clsName = SSLSocketFactory.getSecurityProperty
        //                                 ("ssl.ServerSocketFactory.provider");
        //     if (clsName !is null) {
        //         log("setting up default SSLServerSocketFactory");
        //         try {
        //             Class<?> cls = null;
        //             try {
        //                 cls = Class.forName(clsName);
        //             } catch (ClassNotFoundException e) {
        //                 ClassLoader cl = ClassLoader.getSystemClassLoader();
        //                 if (cl !is null) {
        //                     cls = cl.loadClass(clsName);
        //                 }
        //             }
        //             log("class " + clsName + " is loaded");
        //             SSLServerSocketFactory fac = cast(SSLServerSocketFactory)cls.newInstance();
        //             log("instantiated an instance of class " + clsName);
        //             theFactory = fac;
        //             return fac;
        //         } catch (Exception e) {
        //             log("SSLServerSocketFactory instantiation failed: " + e);
        //             theFactory = new DefaultSSLServerSocketFactory(e);
        //             return theFactory;
        //         }
        //     }
        // }

        // try {
        //     return SSLContext.getDefault().getServerSocketFactory();
        // } catch (NoSuchAlgorithmException e) {
        //     return new DefaultSSLServerSocketFactory(e);
        // }
        implementationMissing();
        return null;
    }

    /**
     * Returns the list of cipher suites which are enabled by default.
     * Unless a different list is enabled, handshaking on an SSL connection
     * will use one of these cipher suites.  The minimum quality of service
     * for these defaults requires confidentiality protection and server
     * authentication (that is, no anonymous cipher suites).
     *
     * @see #getSupportedCipherSuites()
     * @return array of the cipher suites enabled by default
     */
    abstract string [] getDefaultCipherSuites();


    /**
     * Returns the names of the cipher suites which could be enabled for use
     * on an SSL connection created by this factory.
     * Normally, only a subset of these will actually
     * be enabled by default, since this list may include cipher suites which
     * do not meet quality of service requirements for those defaults.  Such
     * cipher suites are useful in specialized applications.
     *
     * @return an array of cipher suite names
     * @see #getDefaultCipherSuites()
     */
    abstract string [] getSupportedCipherSuites();
}


//
// The default factory does NOTHING.
//
class DefaultSSLServerSocketFactory : SSLServerSocketFactory {

    private Exception reason;

    this(Exception reason) {
        this.reason = reason;
    }

    private ServerSocket throwException() {
        throw cast(SocketException)
            new SocketException(reason.toString(), reason);
    }

    override
    ServerSocket createServerSocket()  {
        return throwException();
    }


    override
    ServerSocket createServerSocket(int port)
    
    {
        return throwException();
    }

    override
    ServerSocket createServerSocket(int port, int backlog)
    
    {
        return throwException();
    }

    override
    ServerSocket
    createServerSocket(int port, int backlog, InternetAddress ifAddress)
    
    {
        return throwException();
    }

    override
    string [] getDefaultCipherSuites() {
        return new string[0];
    }

    override
    string [] getSupportedCipherSuites() {
        return new string[0];
    }
}
