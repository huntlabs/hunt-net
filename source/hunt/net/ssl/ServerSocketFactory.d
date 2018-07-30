module hunt.net.ssl.ServerSocketFactory;

import std.socket;

class ServerSocket
{
    this() {}
    this(int port, int backlog) {}
    this(int port) {}
    this(int port, int backlog, InternetAddress bindAddr){}
}

/**
 * This class creates server sockets.  It may be subclassed by other
 * factories, which create particular types of server sockets.  This
 * provides a general framework for the addition of socket-level
 * functionality.  It is the server side analogue of a socket factory,
 * and similarly provides a way to capture a variety of policies related
 * to the sockets being constructed.
 *
 * <P> Like socket factories, server Socket factory instances have
 * methods used to create sockets. There is also an environment
 * specific default server socket factory; frameworks will often use
 * their own customized factory.
 *
 * @since 1.4
 * @see SocketFactory
 *
 * @author David Brownell
 */
abstract class ServerSocketFactory
{
    //
    // NOTE:  JDK 1.1 bug in class GC, this can get collected
    // even though it's always accessible via getDefault().
    //
    private static ServerSocketFactory          theFactory;


    /**
     * Creates a server socket factory.
     */
    protected this() { /* NOTHING */ }

    /**
     * Returns a copy of the environment's default socket factory.
     *
     * @return the <code>ServerSocketFactory</code>
     */
    static ServerSocketFactory getDefault()
    {
        synchronized {
            if (theFactory is null) {
                //
                // Different implementations of this method could
                // work rather differently.  For example, driving
                // this from a system property, or using a different
                // implementation than JavaSoft's.
                //
                theFactory = new DefaultServerSocketFactory();
            }
        }

        return theFactory;
    }


    /**
     * Returns an unbound server socket.  The socket is configured with
     * the socket options (such as accept timeout) given to this factory.
     *
     * @return the unbound socket
     * @ if the socket cannot be created
     * @see java.net.ServerSocket#bind(java.net.SocketAddress)
     * @see java.net.ServerSocket#bind(java.net.SocketAddress, int)
     * @see java.net.ServerSocket#ServerSocket()
     */
    ServerSocket createServerSocket()  {
        throw new SocketException("Unbound server sockets not implemented");
    }

    /**
     * Returns a server socket bound to the specified port.
     * The socket is configured with the socket options
     * (such as accept timeout) given to this factory.
     * <P>
     * If there is a security manager, its <code>checkListen</code>
     * method is called with the <code>port</code> argument as its
     * argument to ensure the operation is allowed. This could result
     * in a SecurityException.
     *
     * @param port the port to listen to
     * @return the <code>ServerSocket</code>
     * @ for networking errors
     * @throws SecurityException if a security manager exists and its
     *         <code>checkListen</code> method doesn't allow the operation.
     * @throws IllegalArgumentException if the port parameter is outside the
     *         specified range of valid port values, which is between 0 and
     *         65535, inclusive.
     * @see    SecurityManager#checkListen
     * @see java.net.ServerSocket#ServerSocket(int)
     */
    abstract ServerSocket createServerSocket(int port)
        ;


    /**
     * Returns a server socket bound to the specified port, and uses the
     * specified connection backlog.  The socket is configured with
     * the socket options (such as accept timeout) given to this factory.
     * <P>
     * The <code>backlog</code> argument must be a positive
     * value greater than 0. If the value passed if equal or less
     * than 0, then the default value will be assumed.
     * <P>
     * If there is a security manager, its <code>checkListen</code>
     * method is called with the <code>port</code> argument as its
     * argument to ensure the operation is allowed. This could result
     * in a SecurityException.
     *
     * @param port the port to listen to
     * @param backlog how many connections are queued
     * @return the <code>ServerSocket</code>
     * @ for networking errors
     * @throws SecurityException if a security manager exists and its
     *         <code>checkListen</code> method doesn't allow the operation.
     * @throws IllegalArgumentException if the port parameter is outside the
     *         specified range of valid port values, which is between 0 and
     *         65535, inclusive.
     * @see    SecurityManager#checkListen
     * @see java.net.ServerSocket#ServerSocket(int, int)
     */
    abstract ServerSocket
    createServerSocket(int port, int backlog)
    ;


    /**
     * Returns a server socket bound to the specified port,
     * with a specified listen backlog and local IP.
     * <P>
     * The <code>ifAddress</code> argument can be used on a multi-homed
     * host for a <code>ServerSocket</code> that will only accept connect
     * requests to one of its addresses. If <code>ifAddress</code> is null,
     * it will accept connections on all local addresses. The socket is
     * configured with the socket options (such as accept timeout) given
     * to this factory.
     * <P>
     * The <code>backlog</code> argument must be a positive
     * value greater than 0. If the value passed if equal or less
     * than 0, then the default value will be assumed.
     * <P>
     * If there is a security manager, its <code>checkListen</code>
     * method is called with the <code>port</code> argument as its
     * argument to ensure the operation is allowed. This could result
     * in a SecurityException.
     *
     * @param port the port to listen to
     * @param backlog how many connections are queued
     * @param ifAddress the network interface address to use
     * @return the <code>ServerSocket</code>
     * @ for networking errors
     * @throws SecurityException if a security manager exists and its
     *         <code>checkListen</code> method doesn't allow the operation.
     * @throws IllegalArgumentException if the port parameter is outside the
     *         specified range of valid port values, which is between 0 and
     *         65535, inclusive.
     * @see    SecurityManager#checkListen
     * @see java.net.ServerSocket#ServerSocket(int, int, java.net.InetAddress)
     */
    abstract ServerSocket
    createServerSocket(int port, int backlog, InternetAddress ifAddress)
    ;
}


//
// The default factory has NO intelligence.  In fact it's not clear
// what sort of intelligence servers need; the onus is on clients,
// who have to know how to tunnel etc.
//
class DefaultServerSocketFactory : ServerSocketFactory {

    this()
    {
        /* NOTHING */
    }

    override ServerSocket createServerSocket()
    
    {
        return new ServerSocket();
    }

    override ServerSocket createServerSocket(int port)
    
    {
        return new ServerSocket(port);
    }

    override ServerSocket createServerSocket(int port, int backlog)
    
    {
        return new ServerSocket(port, backlog);
    }

    override ServerSocket createServerSocket(int port, int backlog, InternetAddress ifAddress)
    
    {
        return new ServerSocket(port, backlog, ifAddress);
    }
}
