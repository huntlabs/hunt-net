module client;

import hunt.net;
import hunt.net.codec.textline;
import hunt.logging;
import hunt.String;
import hunt.event.EventLoop;


import std.format;
import std.stdio;

import core.memory;
import core.thread;
import core.time;


// enum Host = "127.0.0.1";
enum Host = "10.1.23.222";
enum Port = 8090;

string requestString = "GET / HTTP/1.1\r\nAccept: */*\r\nHost: 10.1.23.222:80\r\nConnection: keep-alive\r\n\r\n";

import std.parallelism;

void main() {
    runClientTest();
    // runEventLoopTest();

    // runThreadTest();
    // runThreadPoolTest();
}


void runThreadPoolTest() {
    import std.parallelism;
    Duration dur = 5.seconds;
    tracef("Waiting for %s seconds", dur);
    Thread.sleep(dur);

    MonoTime startTime = MonoTime.currTime;

    // Thread.sleep(5.seconds);
    
    tracef("Thread: %d", Thread.getAll().length);

    foreach(int index; 0..20) {
        auto testTask = task(() { 
            try {
                tracef("runing Thread: %d", Thread.getAll().length);
                Thread.sleep(5.seconds);
                warningf("ending Thread: %d", Thread.getAll().length);
            } catch (Throwable t) {
                warning(t.msg);
                version(HUNT_DEBUG) warning(t.toString());
            }
        });

        // testTask.executeInNewThread();
        taskPool.put(testTask);

        Thread.sleep(2.seconds);
        tracef("starting %d", index);
    }
    
    getchar();
    
    tracef("Thread: %d", Thread.getAll().length);
}

void runThreadTest() {
    Duration dur = 5.seconds;
    tracef("Waiting for %s seconds", dur);
    Thread.sleep(dur);

    MonoTime startTime = MonoTime.currTime;

    // Thread.sleep(5.seconds);
    
    tracef("Thread: %d", Thread.getAll().length);

    foreach(int index; 0..200) {
        Thread _workThread = new Thread(() { 
                tracef("runing Thread: %d", Thread.getAll().length);
                // Thread.sleep(5.seconds);
                warningf("ending Thread: %d", Thread.getAll().length);

        });

        // _workThread.isDaemon = true;
        _workThread.start();

        Thread.sleep(2.seconds);
        tracef("starting %d", index);
    }
    
    getchar();


    // GC.collect();
    // GC.minimize();

    // getchar();
    
    tracef("Thread: %d", Thread.getAll().length);
}

// void runThreadTest_Bug() {
//     Duration dur = 5.seconds;
//     tracef("Waiting for %s seconds", dur);
//     Thread.sleep(dur);

//     MonoTime startTime = MonoTime.currTime;

//     // Thread.sleep(5.seconds);
    
//     tracef("Thread: %d", Thread.getAll().length);

//     foreach(int index; 0..2000) {
//         Thread _workThread = new Thread(() { 
//             try {
//                 tracef("runing Thread: %d", Thread.getAll().length);
//                 // Thread.sleep(5.seconds);
//                 warningf("ending Thread: %d", Thread.getAll().length);
//             } catch (Throwable t) {
//                 warning(t.msg);
//                 version(HUNT_DEBUG) warning(t.toString());
//             }
//         });

//         _workThread.start();

//         // Thread.sleep(2.seconds);
//         tracef("starting %d", index);
//     }
    
//     getchar();
    
//     tracef("Thread: %d", Thread.getAll().length);
// }

void runEventLoopTest() {
    Duration dur = 5.seconds;
    tracef("Waiting for %s seconds", dur);
    Thread.sleep(dur);

    MonoTime startTime = MonoTime.currTime;

    // Thread.sleep(5.seconds);

    foreach(int index; 0..50) {
        
        EventLoop loop = NetUtil.buildEventLoop();
        // Thread.sleep(5.seconds);

        loop.stop();
        infof("stoppped => %d", index);
        Thread.sleep(2.seconds);
    }

    infof("Press any key to exit");
    getchar();
}

void runClientTest() {

    Duration dur = 5.seconds;
    tracef("Waiting for %s seconds", dur);
    Thread.sleep(dur);

    MonoTime startTime = MonoTime.currTime;

    // Thread.sleep(5.seconds);

    foreach(int index; 0..5) {
        testClient(index + 1);
        // Thread.sleep(10.seconds);
        Thread.sleep(500.msecs);
    }

    MonoTime endTime = MonoTime.currTime;
    warningf("elapsed: %s", endTime - startTime);

    // infof("Press any key to run GC Collection");
    // getchar();

    // // loop.stop();
    // GC.collect();
    // GC.minimize();

    infof("Press any key to exit");
    getchar();
}



void testClient(int index) {

    tracef("testing %d ...", index);
    scope(exit) {
        infof("%d done.", index);
    }

import core.sync.condition;
import core.sync.mutex;


    Mutex locker = new Mutex();
    Condition cond = new Condition(locker);
    bool isWaiting = false;

    NetClient client;
    EventLoop loop = NetUtil.buildEventLoop();
    client = new NetClientImpl(loop, new NetClientOptions()); 

    // dfmt off
    client.setHandler(new class NetConnectionHandler {

        override void connectionOpened(Connection connection) {
            // version(HUNT_DEBUG) infof("Connection created: %s", connection.getRemoteAddress());

            // connection.write("Hi, I'm client");
            connection.write(requestString);
        }

        override void connectionClosed(Connection connection) {
            // version(HUNT_DEBUG)  infof("Connection closed: %s", connection.getRemoteAddress());

            // client.close();

            locker.lock();
            if(isWaiting) cond.notify();
            locker.unlock();
        }

        override DataHandleStatus messageReceived(Connection connection, Object message) {
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

    import core.time;

    locker.lock();
    isWaiting = true;
    cond.wait(100.msecs);
    locker.unlock();

    // getchar();
}