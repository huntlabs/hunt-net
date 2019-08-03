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
    private EventLoop _loop;
    private int _loopIdleTime = -1;

    this() {
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
        if(isConnected()) {
            throw new IOException("The options can't be set after the connection created.");
        }

        this._host = host;
        this._port = port;
        this._serverName = serverName;

        super.start();
    }

    override protected void initialize() { // doConnect

        _loop.onStarted(&initializeClient);
        _loop.runAsync(_loopIdleTime);

    }

    private void initializeClient(){

        TcpStreamOptions options = _options.toStreamOptions();
        _client = new TcpStream(_loop, options);
        _tcpSession = new TcpConnection(_sessionId++,
                _options, _netHandler, _codec, _client);

        _client.onClosed(() {
            // if (_netHandler !is null)
            //     _netHandler.sessionClosed(_tcpSession);
            version(HUNT_NET_DEBUG) {
                info("session closed");
            }
            this.close();
        });

        _client.onError((string message) {
            if (_netHandler !is null)
                _netHandler.exceptionCaught(_tcpSession, new Exception(message));
        });

        _client.onConnected((bool suc) {
            if (suc) {
			    version (HUNT_DEBUG) 
                trace("connected to: ", _client.remoteAddress.toString()); 

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
    }

    void close() {
        this.stop();

    }

    override protected void destroy() {
        if (_tcpSession !is null) {
            tracef("isRunning: %s, isConnected: %s, isClosing: %s", isRunning(), 
            _tcpSession.isConnected(), _tcpSession.isClosing());
            
            // if(isRunning()) 
            {
                if(!_tcpSession.isClosing()) {
                    _tcpSession.close();
                }
                if (_tcpSession.isClosing() && _netHandler !is null)
                    _netHandler.sessionClosed(_tcpSession);
            }

            _tcpSession = null;
            _loop.stop();
        }
    }

    bool isConnected() {
        if(_tcpSession is null)
            return false;
        else
            return _tcpSession.isConnected();
    }
}
