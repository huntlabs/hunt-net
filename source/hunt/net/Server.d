module hunt.net.Server;

import hunt.net.Config;
import hunt.util.Lifecycle;


public interface Server {

    void setConfig(Config config);

    void listen(string host, int port);

    // ExecutorService getNetExecutorService();
}

abstract class AbstractServer : AbstractLifecycle, Server {
}