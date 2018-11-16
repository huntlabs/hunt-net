module hunt.net.Client;

import hunt.net.Config;
import hunt.util.Lifecycle;

interface Client {

    void setConfig(Config config);

    int connect(string host, int port);

    void connect(string host, int port, int id);

    // ExecutorService getNetExecutorService();

}

abstract class AbstractClient : AbstractLifecycle, Client {
}
