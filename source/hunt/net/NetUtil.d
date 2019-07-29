module hunt.net.NetUtil;
import hunt.event;

import hunt.net.Config;
import hunt.net.NetClient;
import hunt.net.NetServer;
import hunt.net.Server;

/**
*/
class NetUtil {
    static AbstractServer createNetServer(ServerThreadMode threadModel = ServerThreadMode.Single)() {
        return new NetServer!(threadModel)(_loopGroup);
    }

    static NetClient createNetClient() {
        return new NetClient();
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
