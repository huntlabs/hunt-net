module hunt.net.NetSocket;

import kiss.logger;
import kiss.net.TcpStream;

import hunt.net.Result;
import std.socket;

alias ConnectHandler = void delegate(Result!NetSocket);

alias Handler = void delegate(NetSocket sock);
alias VoidHandler = void delegate();
alias DataHandler = void delegate( in ubyte[] data );

///
class NetSocket 
{
    ///
    this(TcpStream tcp)
    {
        _tcp = tcp;
    }
    ///
    void close()
    {
        _tcp.close();
    }
    ////
    NetSocket closeHandler(VoidHandler handler)
    {
        _tcp.closeHandler = handler;
        return this;
    }
    ///
    NetSocket handler(DataHandler handler)
    {
        _tcp.dataReceivedHandler = handler;
        return this;
    }
    ///
    @property Address  localAddress()
    {
        return _tcp.localAddress;
    }
    ////
    @property Address remoteAddress()
    {
        return _tcp.remoteAddress; 
    }
    ////
    NetSocket   write(in ubyte[] data)
    {
        version(HuntDebugMode)
        {
            tracef("writting data %d bytes", data.length);
            tracef("%(%02X %)", data);
        }
         _tcp.write(data);
         return this;
    }
    ////
    NetSocket   write(string str)
    {
        return write(cast(ubyte[])str);
    }

     
    protected {
        TcpStream _tcp;
    }

}