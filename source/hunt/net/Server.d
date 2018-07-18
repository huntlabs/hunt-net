module hunt.net.Server;

import hunt.net.Config;
import hunt.util.LifeCycle;


public interface Server : LifeCycle {

    void setConfig(Config config);

    void listen(string host, int port);

    // ExecutorService getNetExecutorService();
}
