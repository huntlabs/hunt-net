/*
 * Copyright (c) 2011-2017 Contributors to the Eclipse Foundation
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0, or the Apache License, Version 2.0
 * which is available at https://www.apache.org/licenses/LICENSE-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0 OR Apache-2.0
 */

module hunt.net.NetClient;

import hunt.net.Connection;
import hunt.util.Lifecycle;

import hunt.net.codec.Codec;

/**
 * A TCP client.
 * <p>
 * Multiple connections to different servers can be made using the same instance.
 * <p>
 * This client supports a configurable number of connection attempts and a configurable
 * delay between attempts.
 *
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
interface NetClient {

    /**
     * Open a connection to a server at the specific {@code port} and {@code host}.
     * <p>
     * {@code host} can be a valid host name or IP address. The connect is done asynchronously and on success, a
     * {@link NetSocket} instance is supplied via the {@code connectHandler} instance
     *
     * @param port  the port
     * @param host  the host
     * @return a reference to this, so the API can be used fluently
     */
    
    void connect(int port, string host); // , AsyncConnectHandler connectHandler

    /**
     * Open a connection to a server at the specific {@code port} and {@code host}.
     * <p>
     * {@code host} can be a valid host name or IP address. The connect is done asynchronously and on success, a
     * {@link NetSocket} instance is supplied via the {@code connectHandler} instance
     *
     * @param port the port
     * @param host the host
     * @param serverName the SNI server name
     * @return a reference to this, so the API can be used fluently
     */
    
    void connect(int port, string host, string serverName); // , AsyncConnectHandler connectHandler

    /**
     * Open a connection to a server at the specific {@code remoteAddress}.
     * <p>
     * The connect is done asynchronously and on success, a {@link NetSocket} instance is supplied via the {@code connectHandler} instance
     *
     * @param remoteAddress the remote address
     * @return a reference to this, so the API can be used fluently
     */
    
    // NetClient connect(SocketAddress remoteAddress, AsyncConnectHandler connectHandler);

    /**
     * Open a connection to a server at the specific {@code remoteAddress}.
     * <p>
     * The connect is done asynchronously and on success, a {@link NetSocket} instance is supplied via the {@code connectHandler} instance
     *
     * @param remoteAddress the remote address
     * @param serverName the SNI server name
     * @return a reference to this, so the API can be used fluently
     */
    
    // NetClient connect(SocketAddress remoteAddress, string serverName, AsyncConnectHandler connectHandler);


    /**
     * Close the client.
     * <p>
     * Any sockets which have not been closed manually will be closed here. The close is asynchronous and may not
     * complete until some time after the method has returned.
     */
    void close();

    NetClient setCodec(Codec codec);

    NetClient setHandler(ConnectionEventHandler handler);
}


abstract class AbstractClient : AbstractLifecycle, NetClient { 
}
