module hunt.net.NetUtil;

import hunt.net.EventLoopPool;
import hunt.net.NetClient;
import hunt.net.NetServer;
import hunt.net.NetClientImpl;
import hunt.net.NetClientOptions;
import hunt.net.NetServerImpl;
import hunt.net.NetServerOptions;

import hunt.event.EventLoop;
import hunt.util.pool;
import hunt.logging.ConsoleLogger;

import std.concurrency : initOnce;


/**
 * 
 */
struct NetUtil {

    static EventLoop eventLoop() {
        __gshared EventLoop inst;
        return initOnce!inst(buildEventLoop());
    }

    static private EventLoop buildEventLoop() {
        EventLoop el = new EventLoop();
        el.runAsync(-1);
        import core.thread;
        import core.time;
        while(!el.isReady()) {
            version(HUNT_IO_DEBUG) warning("Waiting for the eventloop got ready...");
        }
        return el;
    }

    static NetServer createNetServer(ThreadMode threadModel = ThreadMode.Single)() {
        return new NetServerImpl!(threadModel)();
    }

    static NetServer createNetServer(ThreadMode threadModel = ThreadMode.Single)(NetServerOptions options) {
        return new NetServerImpl!(threadModel)(options);
    }

    static NetClient createNetClient() {
        return new NetClientImpl(eventLoopPool());
    }

    static NetClient createNetClient(NetClientOptions options) {
        return new NetClientImpl(eventLoopPool(), options);
    }
}

