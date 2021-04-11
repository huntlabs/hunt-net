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
    options.size = 64;
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
        EventLoop r = new EventLoop();
        r.runAsync();

        while(!r.isReady()) {
            version(HUNT_IO_DEBUG) warning("Waiting for the eventloop got ready...");
        }

        return r;
    }    

    override void destroyObject(EventLoop p) {
        p.stop();
    }

    override bool isValid(EventLoop p) {
        return p.isRuning();
    }
}