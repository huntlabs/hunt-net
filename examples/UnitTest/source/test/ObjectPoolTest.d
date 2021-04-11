module test.ObjectPoolTest;

import hunt.net;
import hunt.net.codec.textline;
import hunt.logging.ConsoleLogger;
import hunt.String;
import hunt.event.EventLoop;
import hunt.util.UnitTest;


import std.format;
import std.stdio;

import core.memory;
import core.thread;
import core.time;

import std.parallelism;

// enum Host = "127.0.0.1";
enum Host = "10.1.23.222";
enum Port = 80;

string requestString = "GET / HTTP/1.1\r\nAccept: */*\r\nHost: 10.1.23.222:80\r\nConnection: keep-alive\r\n\r\n";

import hunt.util.pool;

alias EventLoopPool = ObjectPool!EventLoop;

class ObjectPoolTest {

    @Test
    void basic() {

        PoolOptions options = new PoolOptions();
        options.size = 5;

        buildEventLoopPool(options);

        // Thread.sleep(5.seconds);
        MonoTime startTime = MonoTime.currTime;

        int[] a = new int[10];

        foreach (size_t index, int element; parallel(a)) {
            // foreach(int index; 0..10) {
            // EventLoop loop;

            // try {
            //     loop = objPool.borrow();
            //     // loop = objPool.borrow(500.msecs);
            // } catch(Exception ex) {
            //     warning(ex.msg);
            // }

            // if(loop is null) {
            //     warningf("Borrowing %d failed.", index);
            //     continue;
            // }

            // tracef(objPool.toString());
            testClient(cast(int) index, (id) {
                Thread.sleep(2000.msecs);
                infof("returning %d now", id);
                // objPool.returnObject(lp);
            });
        }

        MonoTime endTime = MonoTime.currTime;
        warningf("elapsed: %s", endTime - startTime);
        getchar();

        // objPool.close();
        shutdownEventLoopPool();
        GC.collect();
        GC.minimize();
        getchar();
    }
}

// void main() {

//     EventLoopPool objPool = new EventLoopPool(new EventLoopObjectFactory(), 6);

//     // Thread.sleep(5.seconds);
//     MonoTime startTime = MonoTime.currTime;

//     // EventLoop loop = NetUtil.eventLoop();
//     // Thread.sleep(5.seconds);
//     import std.parallelism;
//     int[] a = new int[10];

//     // foreach(int index; 0..5) {
//     foreach(size_t index, int element; parallel(a)) {
//         EventLoop loop = objPool.borrow();
//         if(loop is null) {
//             warningf("Borrowing %d failed.", index);
//             continue;
//         }

//         scope(exit) {
//             Thread.sleep(2000.msecs);
//             objPool.returnObject(loop);
//         }
//         tracef(objPool.toString());
//         testClient(cast(int)index, loop);
//     }

//     MonoTime endTime = MonoTime.currTime;
//     warningf("elapsed: %s", endTime - startTime);
//     getchar();

//     // loop.stop();
//     objPool.close();
//     GC.collect();
//     GC.minimize();
//     getchar();
// }

void testClient(int index, void delegate(int) handler = null) {

    tracef("%d testing...", index);

    NetClient client = NetUtil.createNetClient();

    // client.setCodec(new TextLineCodec);

    // dfmt off
    client.setHandler(new class NetConnectionHandler {

        override void connectionOpened(Connection connection) {
            version(HUNT_DEBUG) infof("Connection created: %s", connection.getRemoteAddress());

            // connection.write("Hi, I'm client");
            connection.write(requestString);
            // connection.encode(new String("Hi, I'm client\r"));
        }

        override void connectionClosed(Connection connection) {
            version(HUNT_DEBUG)  infof("Connection closed: %s", connection.getRemoteAddress());
            // client.close();
        }

        override DataHandleStatus messageReceived(Connection connection, Object message) {
            // version(HUNT_DEBUG) tracef("message type: %s", typeid(message).name);
            string str = format("data received: %s", message.toString());
            tracef(str);

            import hunt.io.ByteBuffer;
            ByteBuffer buffer = cast(ByteBuffer)message;
            string content = cast(string)buffer.peekRemaining();

            // warning(content);
            // if(content == "quit") {
            //     client.close();
            // }

            client.close();

            warningf("%d done.", index);

            if(handler !is null) {
                handler(index);
            }
            return DataHandleStatus.Done;
        }

        override void exceptionCaught(Connection connection, Throwable t) {
            warning(t);
        }

        override void failedOpeningConnection(int connectionId, Throwable t) {
            warning(t);
            client.close(); 
        }

        override void failedAcceptingConnection(int connectionId, Throwable t) {
            warning(t);
        }
    }).connect(Host, Port);

    // dfmt on

    // getchar();
    // warning("Returning.....");
}
