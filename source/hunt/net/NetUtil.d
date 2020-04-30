module hunt.net.NetUtil;

import hunt.net.NetClient;
import hunt.net.NetServer;
import hunt.net.NetClientImpl;
import hunt.net.NetClientOptions;
import hunt.net.NetServerImpl;
import hunt.net.NetServerOptions;

// import hunt.event;

/**
 * 
 */
class NetUtil {
    static NetServer createNetServer(ThreadMode threadModel = ThreadMode.Single)() {
        return new NetServerImpl!(threadModel)();
    }

    static NetServer createNetServer(ThreadMode threadModel = ThreadMode.Single)(NetServerOptions options) {
        return new NetServerImpl!(threadModel)(options);
    }

    static NetClient createNetClient() {
        return new NetClientImpl();
    }

    static NetClient createNetClient(NetClientOptions options) {
        return new NetClientImpl(options);
    }
}
