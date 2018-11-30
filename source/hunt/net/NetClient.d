module hunt.net.NetClient;

import hunt.event.EventLoop;
import hunt.io.TcpStream;

import hunt.net.AsynchronousTcpSession;
import hunt.net.Config;
import hunt.net.NetEvent;
import hunt.net.NetSocket;
import hunt.net.Result;
import hunt.net.Client;

import hunt.logging;

///
class NetClient : AbstractClient {
    private string _host = "127.0.0.1";
    private int _port = 8080;
    private int _sessionId;
    private Config _config;
    private NetEvent netEvent;
    private AsynchronousTcpSession tcpSession;

    void close() {
        this.stop();
    }

    NetClient connect(int port, string host, int sessionId = 0, ConnectHandler handler = null) {
        _host = host;
        _port = port;
        _sessionId = sessionId;

        TcpStream client = new TcpStream(_loop);

        tcpSession = new AsynchronousTcpSession(sessionId,
                _config, netEvent, client);
        client.onClosed(() {
            if (netEvent !is null)
                netEvent.notifySessionClosed(tcpSession);
        });

        client.onError((string message) {
            if (netEvent !is null)
                netEvent.notifyExceptionCaught(tcpSession, new Exception(message));
        });

        client.onConnected((bool suc) {
            Result!NetSocket result = null;
            if (suc) {
			    version (HUNT_DEBUG) 
                trace("connected with: ", client.remoteAddress.toString()); 

                if (_handler !is null)
                    _handler(tcpSession);
                result = new Result!NetSocket(tcpSession);
                _isRunning = true;
                if (netEvent !is null)
                    netEvent.notifySessionOpened(tcpSession);
            }
            else {
			    version (HUNT_DEBUG) 
                    warning("connection failed!"); 
                import std.format;
                string msg = format("Can't connect to %s:%d", host, port);
                result = new Result!NetSocket(new Exception(msg));
                _config.getHandler().failedOpeningSession(sessionId,
                    new Exception(msg));
            }

            if (handler !is null)
                handler(result);
        }).connect(host, cast(ushort) port);

        // _loop.run();

        return this;
    }

    NetClient connectHandler(Handler handler) {
        _handler = handler;
        return this;
    }

    int connect(string host, int port) {
        int id = _sessionId + 1;
        connect(port, host, id);
        return id;
    }

    void connect(string host, int port, int sessionId) {
        connect(port, host, sessionId);
    }

    override protected void initilize() {
        connect(_port, _host);
    }

    override protected void destroy() {
        if (tcpSession !is null)
            tcpSession.close();
    }

    void setConfig(Config config) {
        _config = config;
        netEvent = new DefaultNetEvent(config);
    }

package:
    this(EventLoop loop) {
        _loop = loop;
    }

private:
    ///
    EventLoop _loop;
    Handler _handler;
}
