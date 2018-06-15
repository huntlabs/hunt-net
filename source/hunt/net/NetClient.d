module hunt.net.NetClient;

import kiss.net.TcpStream;
import hunt.net.NetSocket;
import kiss.event.EventLoop;
///
class NetClient
{
    void close()
    {
        _sock.close();
    }

    NetClient connect(int port , string host , CompletionSockHanlder handler)
    {
        auto client = new TcpStream(_loop);
        client.onConnected(
            (bool suc){
                if(suc)
                {
                    _sock = new NetSocket(client);
                }
                handler(suc , _sock);
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

