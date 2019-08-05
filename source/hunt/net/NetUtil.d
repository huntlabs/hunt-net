module hunt.net.NetUtil;
import hunt.event;

// import hunt.net.Config;
import hunt.net.NetClient;
import hunt.net.NetServer;
import hunt.net.NetClientImpl;
import hunt.net.NetClientOptions;
import hunt.net.NetServerImpl;
import hunt.net.NetServerOptions;

/**
*/
class NetUtil {
    static NetServer createNetServer(ThreadMode threadModel = ThreadMode.Single)() {
        return new NetServerImpl!(threadModel)(_loopGroup);
    }

    static NetServer createNetServer(ThreadMode threadModel = ThreadMode.Single)(NetServerOptions options) {
        return new NetServerImpl!(threadModel)(_loopGroup, options);
    }

    static NetClient createNetClient() {
        return new NetClientImpl();
    }

    static NetClient createNetClient(NetClientOptions options) {
        return new NetClientImpl(options);
    }

    static void startEventLoop(long timeout = -1) {
        _loopGroup.start(timeout);
    }

    static void stopEventLoop() {
        _loopGroup.stop();
    }

    static EventLoopGroup defaultEventLoopGroup() {
        return _loopGroup;
    }

    static void eventLoopGroup(EventLoopGroup g) {
        this._loopGroup = g;
    }    

    shared static this() {
        _loopGroup = new EventLoopGroup();
        // _loopGroup.start();  // 
    }

private:
    __gshared EventLoopGroup _loopGroup = null;
}
