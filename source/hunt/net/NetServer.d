module hunt.net.NetServer;

import hunt.net.AsynchronousTcpSession;
import hunt.net.NetEvent;
import hunt.net.Result;
import hunt.net.NetSocket;
import hunt.net.Server;
import hunt.net.Config;

import hunt.event; 
import hunt.io;
import hunt.logging;

import core.atomic;
import std.conv;
import std.socket;


class NetServer : AbstractServer {
    private string _host = "0.0.0.0";
    private int _port = 8080;
    protected bool _isStarted;
    private shared int _sessionId;
    private Config _config;
    private NetEvent netEvent;
    private AsynchronousTcpSession tcpSession;
    protected EventLoopGroup _group = null;
    private TcpListener[] listeners;
    private Handler _handler;

	protected Address _address;
    
    @property Address bindingAddress() {
		return _address;
	}

    void close() {
        stop();
    }

    NetServer connectionHandler(Handler handler) {
        _handler = handler;
        return this;
    }

    void setConfig(Config config) {
        _config = config;
        netEvent = new DefaultNetEvent(config);
    }

    void listen(string host = "0.0.0.0", int port = 0, ListenHandler handler = null) {

        listeners = new TcpListener[_group.length];
       
        _host = host;
        _port = port;

        if (_isStarted)
			return;
        _address = new InternetAddress(host, cast(ushort)port);

		version(HUNT_DEBUG) info("start to listen:");

        Result!Server result = null;
        try {
            for (size_t i = 0; i < _group.length; ++i) {
                listeners[i] = createServer(_group[i]);
                version(HUNT_DEBUG) infof("lister[%d] created", i);
            }
            version(HUNT_DEBUG) infof("All the servers are listening on %s.", _address.toString());
            _group.start();
            _isStarted = true;
        } catch (Exception e) {
            warning(e.message);
            result = new Result!Server(e);
            if (_config !is null)
                _config.getHandler().failedOpeningSession(0, e);
        }

        if (handler !is null)
            handler(result);
    }

    protected TcpListener createServer(EventLoop loop) {
		TcpListener listener = new TcpListener(loop, _address.addressFamily);

		listener.reusePort(true);
		listener.bind(_address).listen(1024);
        listener.onConnectionAccepted((TcpListener sender, TcpStream stream) {
                auto currentId = atomicOp!("+=")(_sessionId, 1);
                version(HUNT_DEBUG) tracef("new session: %d", currentId);
                AsynchronousTcpSession session = new AsynchronousTcpSession(currentId,
                    _config, netEvent, stream);
                if (_config !is null)
                    netEvent.notifySessionOpened(session);
                if (_handler !is null)
                    _handler(session);
            });
		listener.start();

        return listener;
	}

    override protected void initilize() {
        listen(_host, _port);
    }

    override protected void destroy() {
        if(_isStarted) {
            foreach(TcpListener ls; listeners) {
                if (ls !is null)
                    ls.close();
            }
        }
    }

package:
    this(EventLoopGroup loopGroup) {
        this._group = loopGroup;
    }

}
