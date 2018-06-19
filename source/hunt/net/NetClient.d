module hunt.net.NetClient;

import kiss.net.TcpStream;
import hunt.net.NetSocket;
import kiss.event.EventLoop;
import hunt.net.Result;

///
class NetClient
{
    void close()
    {
        _sock.close();
    }

    NetClient connect(int port , string host , ConnectHandler handler)
    {
        auto client = new TcpStream(_loop);
        
        client.onConnected(
            (bool suc){
                Result!NetSocket result = null;
                if(suc)
                {
                    _sock = new NetSocket(client);
                    result = new Result!NetSocket(_sock);
                }
                else
                {
                    result = new Result!NetSocket(new Throwable("can't connect the address"));
                }
                handler(result);
            }
        ).connect(host , cast(ushort)port);
        return this;
    }

package:
    this(EventLoop loop)
    {
        _loop = loop;
    }

private:
    ///
    EventLoop _loop;
    NetSocket _sock;
    
}

