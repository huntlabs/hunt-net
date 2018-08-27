module hunt.net.Net;
import hunt.io.event;

import hunt.net.NetClient;
import hunt.net.NetServer;

///bootstrap
class Net {

static NetServer createNetServer()
{
    return new NetServer(Net.loop);
}

static NetClient createNetClient()
{
    return new NetClient(Net.loop);
}



private:
    __gshared EventLoopGroup _loop = null;

    static @property EventLoop loop()
    {
       static size_t index = 0; 
       if( _loop is null )
       {
            _loop = new EventLoopGroup();
            _loop.start();
       }
       return  _loop.at(++index);
    }
}