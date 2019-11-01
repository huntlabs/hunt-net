module hunt.net.NetServer;

import hunt.net.Connection;
import hunt.net.codec;
import hunt.net.NetServerOptions;
import hunt.util.Lifecycle;
import std.socket;


// alias ListenHandler = NetEventHandler!(AsyncResult!NetServer);


/**
 * Represents a TCP server
 *
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
interface NetServer {

    NetServerOptions getOptions();

    NetServer setOptions(NetServerOptions options);

    Codec getCodec();

    NetServer setCodec(Codec codec);

    /**
     * @return the handler which will handle all connections managed by this server.
     */
    NetConnectionHandler getHandler();

    /**
     * Sets the handler which will handle all connections managed by this server.
     * 
     * @param handler The NetConnectionHandler to use
     */
    NetServer setHandler(NetConnectionHandler handler);


    /**
     * Return the connect stream for this server. The server can only have at most one handler at any one time.
     * As the server accepts TCP or SSL connections it creates an instance of {@link Connection} and passes it to the
     * connect stream {@link ReadStream#handler(hunt.net.NetEventHandler)}.
     *
     * @return the connect stream
     */
    // ReadStream!(Connection) connectStream();

    /**
     * Supply a connect handler for this server. The server can only have at most one connect handler at any one time.
     * As the server accepts TCP or SSL connections it creates an instance of {@link Connection} and passes it to the
     * connect handler.
     *
     * @return a reference to this, so the API can be used fluently
     */
    // NetServer connectHandler(ConnectHandler handler);

    
    // ConnectHandler connectHandler();

    /**
     * Start listening on the port and host as configured in the {@link hunt.net.NetServerOptions} used when
     * creating the server.
     * <p>
     * The server may not be listening until some time after the call to listen has returned.
     *
     * @return a reference to this, so the API can be used fluently
     */
    
    void listen();

    /**
     * Start listening on the specified port and host, ignoring port and host configured in the {@link hunt.net.NetServerOptions} used when
     * creating the server.
     * <p>
     * Port {@code 0} can be specified meaning "choose an random port".
     * <p>
     * Host {@code 0.0.0.0} can be specified meaning "listen on all available interfaces".
     * <p>
     * The server may not be listening until some time after the call to listen has returned.
     *
     * @return a reference to this, so the API can be used fluently
     */
    
    void listen(string host, int port);

    /**
     * Start listening on the specified port and host "0.0.0.0", ignoring port and host configured in the
     * {@link hunt.net.NetServerOptions} used when creating the server.
     * <p>
     * Port {@code 0} can be specified meaning "choose an random port".
     * <p>
     * The server may not be listening until some time after the call to listen has returned.
     *
     * @return a reference to this, so the API can be used fluently
     */
    
    void listen(int port);

    /**
     * Start listening on the specified local address, ignoring port and host configured in the {@link hunt.net.NetServerOptions} used when
     * creating the server.
     * <p>
     * The server may not be listening until some time after the call to listen has returned.
     *
     * @param localAddress the local address to listen on
     * @return a reference to this, so the API can be used fluently
     */
    
    // NetServer listen(SocketAddress localAddress);

    /**
     * Like {@link #listen(SocketAddress)} but providing a handler that will be notified when the server is listening, or fails.
     *
     * @param localAddress the local address to listen on
     * @param listenHandler handler that will be notified when listening or failed
     * @return a reference to this, so the API can be used fluently
     */
    
    // NetServer listen(SocketAddress localAddress, ListenHandler listenHandler);


    /**
     * Close the server. This will close any currently open connections. The close may not complete until after this
     * method has returned.
     */
    void close();

    /**
     * Like {@link #close} but supplying a handler that will be notified when close is complete.
     *
     * @param completionHandler  the handler
     */
    // void close(AsyncVoidResultHandler completionHandler);

    /**
     * The actual port the server is listening on. This is useful if you bound the server specifying 0 as port number
     * signifying an ephemeral port
     *
     * @return the actual port the server is listening on.
     */
    int actualPort();

    bool isOpen();
}


/**
*/
// abstract class AbstractServer : AbstractLifecycle, NetServer { 
// 	protected Address _address;
//     // protected ConnectHandler _connectHandler;

//     @property Address bindingAddress() {
// 		return _address;
// 	}
    
//     NetConnectionHandler getHandler() {

//     }

//     /**
//      * Sets the handler which will handle all connections managed by this server.
//      * 
//      * @param handler The NetConnectionHandler to use
//      */
//     void setHandler(NetConnectionHandler handler);

//     void close() {
//         stop();
//     }

//     // AbstractServer connectHandler(ConnectHandler handler) {
//     //     _connectHandler = handler;
//     //     return this;
//     // }

//     abstract void listen(string host = "0.0.0.0", int port = 0);
// }