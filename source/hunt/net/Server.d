module hunt.net.Server;

import hunt.net.Config;
import hunt.net.Result;
import hunt.util.Lifecycle;


alias ListenHandler = void delegate(Result!Server);

interface Server {

    void setConfig(Config config);

    void listen(string host, int port, ListenHandler handler);

    // ExecutorService getNetExecutorService();
}

abstract class AbstractServer : AbstractLifecycle, Server {
}