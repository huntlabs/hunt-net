module hunt.net.NetClientImpl;

import hunt.net.TcpConnection;
import hunt.net.Connection;
import hunt.net.codec.Codec;
import hunt.net.NetClient;
import hunt.net.NetClientOptions;

import hunt.event.EventLoop;
import hunt.io.TcpStream;
import hunt.logging;
import hunt.util.Lifecycle;

import std.format;

///
class NetClientImpl : AbstractLifecycle, NetClient {
    enum string DefaultLocalHost = "127.0.0.1";
    enum int DefaultLocalPort = 8080;
    private string _host = DefaultLocalHost;
    private int _port = DefaultLocalPort;
    private string _serverName;
    private int _sessionId;
    private NetClientOptions _options;
    private Codec _codec;
    private ConnectionEventHandler _netHandler;
    private TcpConnection _tcpSession;
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
        connect(DefaultLocalHost, DefaultLocalPort, "");
    }

    void connect(string host, int port) {
        connect(host, port, "");
    }

    void connect(string host, int port, string serverName) {
        this._host = host;
        this._port = port;
        this._serverName = serverName;

        super.start();
    }

    override protected void initialize() { // doConnect
        // _sessionId = sessionId;

        _client = new TcpStream(_loop);

        _tcpSession = new TcpConnection(_sessionId++,
                _options, _netHandler, _codec, _client);


        _client.onClosed(() {
            if (_netHandler !is null)
                _netHandler.sessionClosed(_tcpSession);
        });

        _client.onError((string message) {
            if (_netHandler !is null)
                _netHandler.exceptionCaught(_tcpSession, new Exception(message));
        });

        _client.onConnected((bool suc) {
            if (suc) {
			    version (HUNT_DEBUG) 
                trace("connected to: ", _client.remoteAddress.toString()); 

                _isRunning = true;
                if (_netHandler !is null)
                    _netHandler.sessionOpened(_tcpSession);
            }
            else {
                string msg = format("Failed to connect to %s:%d", _host, _port);
			    version (HUNT_DEBUG) 
                    warning(msg); 

                if(_netHandler !is null)
                    _netHandler.failedOpeningSession(_sessionId, new Exception(msg));
            }

        }).connect(_host, cast(ushort)_port);

        _loop.runAsync(_loopIdleTime);
    }

    void close() {
        this.stop();
    }

    override protected void destroy() {
        if (_tcpSession !is null) {
            _loop.stop();
            _tcpSession.close();
        }
    }

    bool isConnected() {
        return _tcpSession.isConnected();
    }

private:
    ///
    EventLoop _loop;
}
