module hunt.net.NetSocket;

import hunt.net.Result;
import hunt.io.socket.Common;

import hunt.Functions;
import hunt.io.TcpStream;
import hunt.logging;
import hunt.util.Common;

import std.socket;

alias ConnectHandler = void delegate(Result!NetSocket);

alias Handler = void delegate(NetSocket sock);
// alias DataHandler = void delegate(in ubyte[] data);

///
class NetSocket {
    private SimpleEventHandler _closeHandler;
    private DataReceivedHandler _dataReceivedHandler;

    ///
    this(TcpStream tcp) {
        _tcp = tcp;
        _tcp.closeHandler = &onClosed;
        _tcp.dataReceivedHandler = &onDataReceived;
    }

    ///
    NetSocket handler(DataReceivedHandler handler) {
        _dataReceivedHandler = handler;
        return this;
    }

    protected void onDataReceived(const ubyte[] data) {
        version(HUNT_DEBUG) { 
            infof("data received (%d bytes): ", data.length); 
            if(data.length<=64)
                infof("%(%02X %)", data[0 .. $]);
            else
                infof("%(%02X %) ...", data[0 .. 64]);
            // infof(cast(string) data); 
        }      

        if(_dataReceivedHandler !is null) {
            version(HUNT_THREADPOOL) {
                import std.parallelism;
                auto connectionTask = task(_dataReceivedHandler, data);
                taskPool.put(connectionTask);
            } else {
                _dataReceivedHandler(data);
            }
        }
    }

    ///
    void close() {
        _tcp.close();
    }
    ////
    NetSocket closeHandler(SimpleEventHandler handler) {
        _closeHandler = handler;
        return this;
    }

    protected void onClosed() {
        if(_closeHandler !is null)
            _closeHandler();
    }
    

    ///
    @property Address localAddress() {
        return _tcp.localAddress;
    }
    
    ////
    @property Address remoteAddress() {
        return _tcp.remoteAddress;
    }

    ////
    NetSocket write(const ubyte[] data , SimpleEventHandler finish = null) {
        version (HUNT_DEBUG) {
            if (data.length <= 32)
                infof("%d bytes: %(%02X %)", data.length, data[0 .. $]);
            else
                infof("%d bytes: %(%02X %)", data.length, data[0 .. 32]);
        }
        _tcp.write(data , (const ubyte[] , size_t) {
            if( finish !is null)
                finish();
        });
        return this;
    }

    ////
    NetSocket write(string str , SimpleEventHandler finish = null) {
        return write(cast(ubyte[]) str , finish);
    }

    protected {
        TcpStream _tcp;
    }

}
