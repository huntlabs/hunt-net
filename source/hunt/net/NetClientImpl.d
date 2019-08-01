module hunt.net.NetClientImpl;

import hunt.event.EventLoop;
import hunt.io.TcpStream;


import hunt.net.TcpConnection;
import hunt.net.NetClientOptions;
import hunt.net.Connection;
import hunt.net.codec.Codec;
import hunt.net.NetClient;
import hunt.util.Lifecycle;

import hunt.logging;

///
class NetClientImpl : AbstractLifecycle, NetClient {
    private string _host = "127.0.0.1";
    private int _port = 8080;
    private int _sessionId;
    private NetClientOptions _options;
    private Codec _codec;
    private ConnectionEventHandler _netHandler;
    private TcpConnection _tcpSession;
    private bool _isConnected = false;
    private TcpStream _client;
    private int _loopIdleTime = -1;

    this() {
        _loop = new EventLoop();
        this(new EventLoop());
    }

    this(EventLoop loop) {
        this(loop, new NetClientOptions());
    }

    this(EventLoop loop, NetClientOptions options) {
        _loop = loop;
        this._options = options;
    }

    ~this() {
        this.stop();
    }

    string getHost() {
        return _host;
    }

    NetClientImpl setHost(string host) {
        this._host = host;
        return this;
    }

    int getPort() {
        return _port;
    }

    NetClientImpl setPort(int port) {
        this._port = port;
        return this;
    }

    NetClientOptions getOptions() {
        return _options;
    }

    NetClient setOptions(NetClientOptions options) {
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

    ConnectionEventHandler getHandler() {
        return this._netHandler;
    }


    NetClientImpl setHandler(ConnectionEventHandler handler) {
        this._netHandler = handler;
        return this;
    }

    void connect() {
        connect(_host, _port, "");
    }

    void connect(string host, int port, string serverName) {
        _host = host;
        _port = port;
        // _sessionId = sessionId;

        _client = new TcpStream(_loop);

        _tcpSession = new TcpConnection(_sessionId++,
                _options, _netHandler, _codec, _client);


        _client.onClosed(() {
            _isConnected = false;
            if (_netHandler !is null)
                _netHandler.sessionClosed(_tcpSession);
        });

        _client.onError((string message) {
            _isConnected = false;
            if (_netHandler !is null)
                _netHandler.exceptionCaught(_tcpSession, new Exception(message));
        });

        _client.onConnected((bool suc) {
            // AsyncResult!NetSocket result = null;
            _isConnected = suc;
            if (suc) {
			    version (HUNT_DEBUG) 
                trace("connected to: ", _client.remoteAddress.toString()); 

                _isRunning = true;
                if (_netHandler !is null)
                    _netHandler.sessionOpened(_tcpSession);
            }
            else {
			    version (HUNT_DEBUG) 
                    warning("connection failed!"); 
                import std.format;
                string msg = format("Failed to connect to %s:%d", host, port);

                if(_netHandler !is null)
                    _netHandler.failedOpeningSession(_sessionId, new Exception(msg));
            }

        }).connect(host, cast(ushort) port);

        _loop.runAsync(_loopIdleTime);
    }


    void connect(string host, int port) {
        // int id = _sessionId + 1;
        connect(host, port, "");
    }


    override protected void initialize() {
        connect(_host, _port);
    }

    void close() {
        this.stop();
    }

    override protected void destroy() {
        if (_tcpSession !is null) {
            _isConnected = false;
            _loop.stop();
            _tcpSession.close();
        }
    }

    bool isConnected() {
        return _isConnected;
    }

private:
    ///
    EventLoop _loop;
}
