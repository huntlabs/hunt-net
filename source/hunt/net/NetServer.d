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

enum ServerThreadMode {
    Single,
    Multi
}

/**
*/
class NetServer(ServerThreadMode threadModel = ServerThreadMode.Single) : AbstractServer {
    private string _host = "0.0.0.0";
    private int _port = 8080;
    protected bool _isStarted;
    private shared int _sessionId;
    private Config _config;
    private NetEvent netEvent;
    protected EventLoopGroup _group = null;

    this(EventLoopGroup loopGroup) {
        this._group = loopGroup;
        _config = new Config();
    }

    override void setConfig(Config config) {
        _config = config;
        netEvent = new DefaultNetEvent(config);
    }

    override void listen(string host = "0.0.0.0", int port = 0, ListenHandler handler = null) {
        _host = host;
        _port = port;

        if (_isStarted)
			return;
        _address = new InternetAddress(host, cast(ushort)port);

		version(HUNT_DEBUG) info("start to listen:");
        _group.start();

        Result!Server result = null;

        try {

        static if(threadModel == ServerThreadMode.Multi) {   
            listeners = new TcpListener[_group.size];         
            for (size_t i = 0; i < _group.size; ++i) {
                listeners[i] = createServer(_group[i]);
                version(HUNT_DEBUG) infof("lister[%d] created", i);
            }
            version(HUNT_DEBUG) infof("All the servers are listening on %s.", _address.toString());
        } else {
            tcpListener = new TcpSocket();
            tcpListener.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
            tcpListener.bind(_address);
            tcpListener.listen(1000);
            version(HUNT_DEBUG) infof("Servers is listening on %s.", _address.toString());
        }     

		    _isStarted = true;
            result = new Result!Server(this);
            
        } catch (Exception e) {
            warning(e.message);
            result = new Result!Server(e);
            if (_config !is null)
                _config.getHandler().failedOpeningSession(0, e);
        }

        if (handler !is null)
            handler(result);

        static if(threadModel == ServerThreadMode.Single) {
            import std.parallelism;
            auto theTask = task(&waitingForAccept);
            taskPool.put(theTask);
        }
    }

    override protected void initialize() {
        listen(_host, _port);
    }

static if(threadModel == ServerThreadMode.Multi){
    private TcpListener[] listeners;

    protected TcpListener createServer(EventLoop loop) {
		TcpListener listener = new TcpListener(loop, _address.addressFamily);

		listener.reusePort(true);
		listener.bind(_address).listen(1024);
        listener.onConnectionAccepted((TcpListener sender, TcpStream stream) {
                auto currentId = atomicOp!("+=")(_sessionId, 1);
                version(HUNT_DEBUG) tracef("new tcp session: id=%d", currentId);
                AsynchronousTcpSession session = new AsynchronousTcpSession(currentId,
                    _config, netEvent, stream);
                if (netEvent !is null)
                    netEvent.notifySessionOpened(session);
                if (_handler !is null)
                    _handler(session);
            });
		listener.start();

        return listener;
	}

    override protected void destroy() {
        if(_isStarted) {
            foreach(TcpListener ls; listeners) {
                if (ls !is null)
                    ls.close();
            }
        }
    }

} else {
    private Socket tcpListener;

    private void waitingForAccept() {
        while (_isStarted) {
			try {
				version (HUNT_DEBUG)
					trace("Waiting for accept...");
				Socket client = tcpListener.accept();

                version(HUNT_THREADPOOL) {
                    import std.parallelism;
                    auto decodingTask = task(&processClient, client);
                    taskPool.put(decodingTask);
                } else {
                    processClient(client);
                }
			} catch (Exception e) {
				warningf("Failure on accept %s", e);
				_isStarted = false;
			}
		}
    }
    
	private void processClient(Socket socket) {
        version(HUNT_METRIC) {
            import core.time;
            import hunt.datetime;
            debug trace("processing client...");
            MonoTime startTime = MonoTime.currTime;
        }
        
		version (HUNT_DEBUG) {
			infof("new connection from %s, fd=%d", socket.remoteAddress.toString(), socket.handle());
		}
		EventLoop loop = _group.nextLoop();
		TcpStream stream = new TcpStream(loop, socket, _config.tcpStreamOption());

        if (_handler !is null) {
            auto currentId = atomicOp!("+=")(_sessionId, 1);
            version(HUNT_DEBUG) tracef("new tcp session: id=%d", currentId);
            AsynchronousTcpSession session = new AsynchronousTcpSession(currentId,
                _config, netEvent, stream);
            if (netEvent !is null)
                    netEvent.notifySessionOpened(session);
            _handler(session);
        }
		stream.start();

        version(HUNT_METRIC) { 
            Duration timeElapsed = MonoTime.currTime - startTime;
            warningf("client processing done in: %d microseconds",
                timeElapsed.total!(TimeUnit.Microsecond)());
        }
	}

    override protected void destroy() {
        if(_isStarted && tcpListener !is null) {
            tcpListener.close();
        }
    }
}    
}
