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

    static EventLoop buildEventLoop() {
        return EventLoopObjectFactory.buildEventLoop();
        // EventLoop el = new EventLoop();
        // version(HUNT_IO_DEBUG) warningf("Waiting for the eventloop[%d] got ready...", el.getId());
        
        // el.runAsync(-1);
        // import core.thread;
        // import core.time;
        
        // while(!el.isReady()) {
        //     version(HUNT_IO_DEBUG_MORE) warning("Waiting for the eventloop got ready...");
        // }
        // version(HUNT_IO_DEBUG) warningf("eventloop[%d] is ready", el.getId());
        // return el;
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

