module hunt.net.NetUtil;

import hunt.net.NetClient;
import hunt.net.NetServer;
import hunt.net.NetClientImpl;
import hunt.net.NetClientOptions;
import hunt.net.NetServerImpl;
import hunt.net.NetServerOptions;

// import hunt.event;

import hunt.event.EventLoop;
import std.concurrency : initOnce;

import hunt.logging.ConsoleLogger;

/**
 * 
 */
struct NetUtil {

    static EventLoop eventLoop() {
        __gshared EventLoop inst;
        return initOnce!inst(buildEventLoog());
    }

    static private EventLoop buildEventLoog() {
        EventLoop el = new EventLoop();
        el.runAsync(-1);
        return el;
    }

    static NetServer createNetServer(ThreadMode threadModel = ThreadMode.Single)() {
        return new NetServerImpl!(threadModel)();
    }

    static NetServer createNetServer(ThreadMode threadModel = ThreadMode.Single)(NetServerOptions options) {
        return new NetServerImpl!(threadModel)(options);
    }

    static NetClient createNetClient() {
        return new NetClientImpl(eventLoop());
    }

    static NetClient createNetClient(NetClientOptions options) {
        return new NetClientImpl(eventLoop(), options);
    }
}
