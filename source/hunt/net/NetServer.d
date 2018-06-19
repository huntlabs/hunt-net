module hunt.net.NetServer;


import hunt.net.NetSocket;
import kiss.net;
import kiss.event.EventLoop;

alias CompletionServerHandler = void delegate(bool suc , NetServer server);

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

    NetServer connectHandler(ConnectHandler handler)
    {
        _connectHandler = handler;
        _listener.onConnectionAccepted(
            (TcpListener sender, TcpStream stream){
                NetSocket sock = new NetSocket(stream);
                handler(sock);
            }
        );
        return this;
    }

    NetServer listen(int port = 0 , string host = "0.0.0.0" ,
    CompletionServerHandler handler = null)
    {
        bool suc = true;
        try{
            _listener = new TcpListener(_loop);
            _listener.bind(host , cast(ushort)port);
            _listener.listen(1024);
            _listener.start();
        }
        catch(Throwable e)
        {
            suc = false;
        }
        if(handler !is null)
        {
            handler(suc , this);
        }
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
        ConnectHandler  _connectHandler;
}