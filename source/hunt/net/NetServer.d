module hunt.net.NetServer;

import hunt.net.Result;
import hunt.net.NetSocket;
import kiss.net;
import kiss.event.EventLoop;

alias ListenHandler = void delegate(Result!NetServer);

class NetServer
{
    int actualPort()
    {
        import std.conv;
        return to!int(_listener.localAddress.toPortString());
    }

    void close()
    {
        _listener.close();
    }

    NetServer connectHandler(Handler handler)
    {
        _handler = handler;
        _listener.onConnectionAccepted(
            (TcpListener sender, TcpStream stream){
                NetSocket sock = new NetSocket(stream);
                _handler(sock);
            }
        );
        return this;
    }

    NetServer listen(int port = 0 , string host = "0.0.0.0" ,
    ListenHandler handler = null)
    {
        bool suc = true;
        Result!NetServer result = null;
        try{
            _listener = new TcpListener(_loop);
            _listener.bind(host , cast(ushort)port);
            _listener.listen(1024);
            _listener.start();
        }
        catch(Throwable e)
        {
            result = new Result!NetServer(e);
        }
        
        if(result !is null)
        {
            result = new Result!NetServer(this);
        }

        if(handler !is null)
            handler(result);

        return this;
    }

package:
    this(EventLoop loop)
    {
        _loop = loop;
    }

private:
        EventLoop       _loop;
        TcpListener     _listener;
        Handler         _handler;
}