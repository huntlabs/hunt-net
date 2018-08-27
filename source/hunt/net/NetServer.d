module hunt.net.NetServer;

import hunt.net.AsynchronousTcpSession;
import hunt.net.NetEvent;
import hunt.net.Result;
import hunt.net.NetSocket;
import hunt.net.Server;
import hunt.net.Config;

import hunt.logger;
import hunt.io;
import hunt.event.EventLoop;

alias ListenHandler = void delegate(Result!NetServer);

class NetServer : Server
{
    private string _host = "0.0.0.0";
    private int _port = 8080;
    private int _sessionId;
    private Config _config;
    private NetEvent netEvent;
    private AsynchronousTcpSession tcpSession;

    int actualPort()
    {
        import std.conv;
        return to!int(_listener.localAddress.toPortString());
    }

    void close()
    {
        // _listener.close();
        stop();
    }

    NetServer connectHandler(Handler handler)
    {
        _handler = handler;

        return this;
    }

    NetServer listen(int port = 0 , string host = "0.0.0.0" ,
        ListenHandler handler = null)
    {
        // if (config == null)
        //     throw new NetException("server configuration is null");

        _host = host;
        _port = port;
        bool suc = true;
        Result!NetServer result = null;
        try{
            
            _listener = new TcpListener(_loop);
            _listener.bind(_host , cast(ushort)_port);
            _listener.listen(1024);
            
            _listener.onConnectionAccepted( (TcpListener sender, TcpStream stream) {
                    _sessionId++;
                    AsynchronousTcpSession session = new AsynchronousTcpSession(_sessionId, _config, netEvent, stream); // NetSocket(stream);
                    netEvent.notifySessionOpened(session);
                    if(_handler !is  null)
                        _handler(session);
                }
            );

            _listener.start();
            _isStarted = true;
        }
        catch(Exception e)
        {
            result = new Result!NetServer(e);
             _config.getHandler().failedOpeningSession(0, e);
        }
        
        if(result !is null)
        {
            result = new Result!NetServer(this);
        }

        if(handler !is null)
            handler(result);

        return this;
    }

    void setConfig(Config config)
    {
        _config = config;
        netEvent = new DefaultNetEvent(config);
    }

    void listen(string host, int port)
    {
        listen(port, host);
    }

    override
    bool isStarted() {
        return _isStarted;
    }

    override
    bool isStopped() {
        return !_isStarted;
    }

    override
    void start() {
        if (isStarted())
            return;

        synchronized (this) {
            if (isStarted())
                return;

            // init();
            listen(_port, _host);
            _isStarted = true;
        }
    }

    override
    void stop() {
        if (isStopped())
            return;

        synchronized (this) {
            if (isStopped())
                return;

            // destroy();
            _listener.close();

            _isStarted = false;
        }
    }


package:
    this(EventLoop loop)
    {
        _loop = loop;
    }


    protected bool _isStarted;

private:
        EventLoop       _loop;
        TcpListener     _listener;
        Handler         _handler;
}