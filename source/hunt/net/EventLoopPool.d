module hunt.net.EventLoopPool;

import hunt.logging.ConsoleLogger;
import hunt.event.EventLoop;
import hunt.util.pool;

import std.concurrency : initOnce;

alias EventLoopPool = ObjectPool!EventLoop;

private __gshared EventLoopPool inst;

EventLoopPool eventLoopPool() {
    return initOnce!inst(buildEventLoopPool());
}    

void buildEventLoopPool(PoolOptions options) {
    initOnce!inst(new EventLoopPool(new EventLoopObjectFactory(), options));
}

private EventLoopPool buildEventLoopPool() {
    PoolOptions options = new PoolOptions();
    options.size = 64;
    EventLoopPool objPool = new EventLoopPool(new EventLoopObjectFactory(), options);
    return objPool;
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

}