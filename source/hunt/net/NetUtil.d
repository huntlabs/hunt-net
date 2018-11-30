module hunt.net.NetUtil;
import hunt.event;

import hunt.net.NetClient;
import hunt.net.NetServer;
import hunt.net.Config;

/**
*/
class NetUtil {
    static NetServer createNetServer() {
        return new NetServer(_loopGroup);
    }

    static NetClient createNetClient() {
        return new NetClient(loop);
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

    static EventLoop loop() @property {
        static size_t index = 0;
        // if (_loopGroup is null)
        // {
        //     _loopGroup = new EventLoopGroup();
        //     _loopGroup.start();
        // }
        return _loopGroup[++index];
    }
}
