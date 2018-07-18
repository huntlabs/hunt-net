module hunt.net.Client;

import hunt.net.Config;
import hunt.util.LifeCycle;

public interface Client : LifeCycle {

    void setConfig(Config config);

    int connect(string host, int port);

    void connect(string host, int port, int id);

    // ExecutorService getNetExecutorService();

}
