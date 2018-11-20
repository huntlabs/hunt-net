module hunt.net.NetUtil;
import hunt.event;

import hunt.net.NetClient;
import hunt.net.NetServer;
import hunt.net.Config;


/**
*/
class NetUtil
{
    static NetServer createNetServer()
    {
        return new NetServer(defaultEventLoopGroup);
    }

    static NetClient createNetClient()
    {
        return new NetClient(loop);
    }

    static EventLoopGroup defaultEventLoopGroup() { return _loop; }

    shared static this() {
        _loop = new EventLoopGroup();
        // _loop.start();  // 
    }

private:
    __gshared EventLoopGroup _loop = null;

    static EventLoop loop() @property 
    {
        static size_t index = 0;
        // if (_loop is null)
        // {
        //     _loop = new EventLoopGroup();
        //     _loop.start();
        // }
        return _loop[++index];
    }
}
