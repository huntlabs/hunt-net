module hunt.net.NetClientImpl;

import hunt.net.TcpConnection;
import hunt.net.Connection;
import hunt.net.codec.Codec;
import hunt.net.EventLoopPool;
import hunt.net.NetClient;
import hunt.net.NetClientOptions;

import hunt.event.EventLoop;
import hunt.Exceptions;
import hunt.Functions;
import hunt.io.TcpStream;
import hunt.io.TcpStreamOptions;
import hunt.io.IoError;
import hunt.logging;
import hunt.util.ByteOrder;
import hunt.util.AbstractLifecycle;
import hunt.util.Lifecycle;
import hunt.util.pool;

import core.atomic;
import core.thread;
import std.format;
import std.parallelism;


/**
 *
 */
class NetClientImpl : AbstractLifecycle, NetClient {

    enum string DefaultLocalHost = "127.0.0.1";
    enum int DefaultLocalPort = 8080;

    private string _host = DefaultLocalHost;
    private int _port = DefaultLocalPort;
    private string _serverName;
    private static shared int _connectionId;
    private int _currentId;
    private NetClientOptions _options;
    private Codec _codec;
    private NetConnectionHandler _eventHandler;
    private TcpConnection _tcpConnection;
    // private TcpStream _tcpStream;
    private EventLoopPool _pool;
    private EventLoop _loop;
    private int _loopIdleTime = -1;
    private Action _onClosed = null;
    private shared bool _isConnected = false;

    this(EventLoop loop, NetClientOptions options) {
        _loop = loop;
        
        this._options = options;

        _currentId = atomicOp!("+=")(_connectionId, 1);
        version (HUNT_NET_DEBUG)
            tracef("Client ID: %d", _currentId);
    }

    this(EventLoopPool pool) {
        this(pool, new NetClientOptions());
    }

    this(EventLoopPool pool, NetClientOptions options) {
        _pool = pool;
        _loop = pool.borrow(options.getConnectTimeout, false);
        
        this._options = options;

        _currentId = atomicOp!("+=")(_connectionId, 1);
        version (HUNT_NET_DEBUG)
            tracef("Client ID: %d", _currentId);
    }

    ~this() @nogc {
        // this.stop();
    }

    int getId() {
        return _currentId;
    }

    string getHost() {
        return _host;
    }

    int getPort() {
        return _port;
    }

    NetClientOptions getOptions() {
        return _options;
    }

    NetClient setOptions(NetClientOptions options) {
        if(isConnected()) {
            throw new IOException("The options can't be set after the connection created.");
        }
        this._options = options;
        return this;
    }

    NetClientImpl setCodec(Codec codec) {
        this._codec = codec;
        return this;
    }

    Codec getCodec() {
        return this._codec;
    }

    void setOnClosed(Action callback)
    {
        if (_onClosed is null)
        {
            _onClosed = callback;
        }
    }

    NetConnectionHandler getHandler() {
        return this._eventHandler;
    }

    NetClientImpl setHandler(NetConnectionHandler handler) {
        this._eventHandler = handler;
        return this;
    }

    void connect() {
        connect(DefaultLocalHost, DefaultLocalPort, "");
    }

    void connect(string host, int port) {
        connect(host, port, "");
    }

    void connect(string host, int port, string serverName) {
        
        if(isConnected()) {
            throw new IOException("The connection has been created.");
        }

        if(isRunning()) {
            warning("Busy with connecting...");
            return;
        }

        this._host = host;
        this._port = port;
        this._serverName = serverName;

        super.start();
    }

    override protected void initialize() { // doConnect

warningf("xxxx=>%s", _loop.isReady());

        if(_loop.isReady()) {
            initializeClient();
        } else {
            _loop.runAsync(_loopIdleTime, &initializeClient);
        }
        // initializeClient();
    }

    private void initializeClient() {
        TcpStreamOptions options = _options.toStreamOptions();
        TcpStream _tcpStream = new TcpStream(_loop, options);
        _tcpConnection = new TcpConnection(_currentId, _options,
                _eventHandler, _codec, _tcpStream);

        _tcpStream.closed(() {
            TcpConnection conn = _tcpConnection;
            if(conn is null) {
                version(HUNT_DEBUG) trace("The connection has already been closed.");
            } else {
                version(HUNT_NET_DEBUG) {
                    infof("Connection %d closed", _tcpConnection.getId());
                }
                conn.setState(ConnectionState.Closed);
            }

            this.close();
            if (_onClosed !is null) {
                _onClosed();
            }

            // _isConnected = false;

            //auto runTask = task((){
            //    Thread.sleep(options.retryInterval);
            //    _tcpStream.reconnect();
            //});
            //taskPool.put(runTask);

        });

        _tcpStream.error((IoError error) {
            if(_tcpConnection !is null)
                _tcpConnection.setState(ConnectionState.Error);
                
            if (_eventHandler !is null)
                _eventHandler.exceptionCaught(_tcpConnection, new Exception(error.errorMsg()));
        });

        _tcpStream.connected((bool suc) {
            if (suc) {
			    version (HUNT_DEBUG) trace("Connected with ", _tcpStream.remoteAddress.toString());
                // _tcpConnection.setState(ConnectionState.Opened);
                _isConnected = true;
                if (_eventHandler !is null) {
                    _eventHandler.connectionOpened(_tcpConnection);
                }
            }
            else {
                string msg = format("Failed to connect to %s:%d", _host, _port);
                version(HUNT_DEBUG) warning(msg);
                _isConnected = false;

                if(_tcpConnection !is null) {
                    _tcpConnection.setState(ConnectionState.Error);
                }

                if(_eventHandler !is null)
                    _eventHandler.failedOpeningConnection(_currentId, new IOException(msg));
            }

        });

        // _tcpConnection.setState(ConnectionState.Opening);
        _tcpStream.connect(_host, cast(ushort)_port);
    }

    void close() {
        // if(cas(&_isConnected, true, false) ) {
        //     this.stop();
        // } else {
        //     version(HUNT_NET_DEBUG) trace("Closed already.");
        // }
        version(HUNT_NET_DEBUG) tracef("isRunning: %s", this.isRunning());
        if(this.isRunning()) {
            this.stop();
        }
    }

    override protected void destroy() {
        TcpConnection conn = _tcpConnection;
        _tcpConnection = null;

        if (conn !is null) {
            version(HUNT_NET_DEBUG) {
                tracef("connection state: %s, isConnected: %s, isClosing: %s",
                    conn.getState(),
                    conn.isConnected(), conn.isClosing());
            }

            if(!conn.isClosing()) {
                conn.close();
            }

            if (_eventHandler !is null) {
                version(HUNT_NET_DEBUG) {
                    infof("Notifying connection %d with %s closed.",
                    conn.getId(), conn.remoteAddress());
                }
                _eventHandler.connectionClosed(conn);
            }
        }
        
        assert(_loop !is null);

        if(_pool is null) {
            _loop.stop();
        } else {
            _pool.returnObject(_loop);
        }
        
        _isConnected = false;
    }

    bool isConnected() {
        return _isConnected;
        //if(_tcpConnection is null)
        //    return false;
        //else
        //    return _tcpConnection.isConnected();
    }
}
