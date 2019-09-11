module hunt.net.NetClientImpl;

import hunt.net.TcpConnection;
import hunt.net.Connection;
import hunt.net.codec.Codec;
import hunt.net.NetClient;
import hunt.net.NetClientOptions;

import hunt.event.EventLoop;
import hunt.Exceptions;
import hunt.io.TcpStream;
import hunt.io.TcpStreamOptions;
import hunt.logging;
import hunt.util.Lifecycle;

import core.atomic;
import std.format;
import core.thread;
import std.parallelism;

///
class NetClientImpl : AbstractLifecycle, NetClient {

    alias void delegate() CallBack;
    enum string DefaultLocalHost = "127.0.0.1";
    enum int DefaultLocalPort = 8080;
    
    private string _host = DefaultLocalHost;
    private int _port = DefaultLocalPort;
    private string _serverName;
    private static shared int _connectionId;
    private int _currentId;
    private NetClientOptions _options;
    private Codec _codec;
    private ConnectionEventHandler _eventHandler;
    private TcpConnection _tcpConnection;
    private TcpStream _client;
    private EventLoop _loop;
    private int _loopIdleTime = -1;
    private CallBack _onClosed = null;
    private bool _isConnected = false;

    this() {
        this(new EventLoop());
    }

    this(NetClientOptions options) {
        this(new EventLoop(), options);
    }

    this(EventLoop loop) {
        this(loop, new NetClientOptions());
    }

    this(EventLoop loop, NetClientOptions options) {
        _loop = loop;
        this._options = options;

        _currentId = atomicOp!("+=")(_connectionId, 1);
        version (HUNT_NET_DEBUG)
            tracef("Client ID: %d", _currentId);
    }

    ~this() {
        this.stop();
    }

    int getId() {
        return _currentId;
    }

    string getHost() {
        return _host;
    }

    // NetClientImpl setHost(string host) {
    //     this._host = host;
    //     return this;
    // }

    int getPort() {
        return _port;
    }

    // NetClientImpl setPort(int port) {
    //     this._port = port;
    //     return this;
    // }

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

    void setOnClosed(CallBack callback)
    {
        if (_onClosed is null)
        {
            _onClosed = callback;
        }
    }

    ConnectionEventHandler getHandler() {
        return this._eventHandler;
    }


    NetClientImpl setHandler(ConnectionEventHandler handler) {
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
            warning("Connecting repeatedly!");
            return;
        }

        this._host = host;
        this._port = port;
        this._serverName = serverName;

        super.start();
    }

    override protected void initialize() { // doConnect
        _loop.runAsync(_loopIdleTime, &initializeClient);
    }

    private void initializeClient(){

        TcpStreamOptions options = _options.toStreamOptions();
        _client = new TcpStream(_loop, options);
        _tcpConnection = new TcpConnection(_currentId,
                _options, _eventHandler, _codec, _client);


        _client.onClosed(() {
            version(HUNT_NET_DEBUG) {
                info("connection closed");
            }
            _tcpConnection.setState(ConnectionState.Closed);
            this.close();
            if (_onClosed !is null)
            {
                _onClosed();
            }

            _isConnected = false;

            //auto runTask = task((){
            //    Thread.sleep(options.retryInterval);
            //    _client.reconnect();
            //});
            //taskPool.put(runTask);

        });

        _client.onError((string message) {
            _tcpConnection.setState(ConnectionState.Error);
            if (_eventHandler !is null)
                _eventHandler.exceptionCaught(_tcpConnection, new Exception(message));
        });

        _client.onConnected((bool suc) {
            if (suc) {
			    version (HUNT_DEBUG) 
                trace("connected to: ", _client.remoteAddress.toString()); 
                // _tcpConnection.setState(ConnectionState.Opened);
                if (_eventHandler !is null)
                {
                    _eventHandler.connectionOpened(_tcpConnection);
                }
                _isConnected = true;
            }
            else {
                string msg = format("Failed to connect to %s:%d", _host, _port);
                warning(msg); 
                _isConnected = false;
                if(_tcpConnection !is null)
                {
                    _tcpConnection.setState(ConnectionState.Error);
                }
                if(_eventHandler !is null)
                    _eventHandler.failedOpeningConnection(_currentId, new IOException(msg));
            }

        });

        // _tcpConnection.setState(ConnectionState.Opening);
        _client.connect(_host, cast(ushort)_port);
    }

    void close() {
        _isConnected = false;
        this.stop();
    }

    override protected void destroy() {
        if (_tcpConnection !is null) {
            version(HUNT_NET_DEBUG) {
                tracef("connection state: %s, isConnected: %s, isClosing: %s", 
                    _tcpConnection.getState(),  
                    _tcpConnection.isConnected(), _tcpConnection.isClosing());
            }
            
            if(!_tcpConnection.isClosing()) {
                _tcpConnection.close();
            } else if (_eventHandler !is null)
                _eventHandler.connectionClosed(_tcpConnection);
            _tcpConnection = null;
            _loop.stop();
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
