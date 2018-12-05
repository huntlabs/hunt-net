module hunt.net.Server;

import hunt.net.Config;
import hunt.net.Result;
import hunt.net.NetSocket;
import hunt.util.Lifecycle;
import std.socket;


alias ListenHandler = void delegate(Result!Server);

interface Server {

    void setConfig(Config config);

    void listen(string host, int port, ListenHandler handler);

    // ExecutorService getNetExecutorService();
}

abstract class AbstractServer : AbstractLifecycle, Server {
	protected Address _address;
    protected Handler _handler;

    @property Address bindingAddress() {
		return _address;
	}

    abstract void setConfig(Config config);

    void close() {
        stop();
    }

    AbstractServer connectionHandler(Handler handler) {
        _handler = handler;
        return this;
    }

    void listen(int port = 0, string host = "0.0.0.0", ListenHandler handler = null) {
        listen(host, port, handler);
    }

    abstract void listen(string host = "0.0.0.0", int port = 0, ListenHandler handler = null);
}