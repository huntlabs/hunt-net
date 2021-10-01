module hunt.net.EventLoopPool;

import hunt.logging.ConsoleLogger;
import hunt.event.EventLoop;
import hunt.util.pool;

import std.concurrency : initOnce;

alias EventLoopPool = ObjectPool!EventLoop;

private __gshared EventLoopPool _pool;

EventLoopPool eventLoopPool() {
    return initOnce!_pool(buildEventLoopPool());
}    

void buildEventLoopPool(PoolOptions options) {
    initOnce!_pool(new EventLoopPool(new EventLoopObjectFactory(), options));
}

private EventLoopPool buildEventLoopPool() {
    PoolOptions options = new PoolOptions();
    options.size = 128;
    options.name = "EventLoopPool";
    EventLoopPool objPool = new EventLoopPool(new EventLoopObjectFactory(), options);
    return objPool;
}

void shutdownEventLoopPool() {
    if(_pool !is null) {
        _pool.close();
    }
}

/**
 * 
 */
class EventLoopObjectFactory : ObjectFactory!(EventLoop) {

    override EventLoop makeObject() {
        // EventLoop r = new EventLoop();
        // r.runAsync();

        // while(!r.isReady()) {
        //     version(HUNT_IO_DEBUG) warning("Waiting for the eventloop got ready...");
        // }

        // return r;
        return buildEventLoop();
    }
    
    static EventLoop buildEventLoop() {
        EventLoop el = new EventLoop();
        version(HUNT_NET_DEBUG) warningf("Waiting for the eventloop[%d] got ready...", el.getId());
        
        el.runAsync(-1);
        import core.thread;
        import core.time;
        
        while(!el.isReady()) {
            version(HUNT_IO_DEBUG_MORE) warning("Waiting for the eventloop got ready...");
        }
        version(HUNT_NET_DEBUG) warningf("eventloop[%d] is ready", el.getId());
        return el;
    }    

    override void destroyObject(EventLoop p) {
        p.stop();
    }

    override bool isValid(EventLoop p) {
        return p.isRuning();
    }
}