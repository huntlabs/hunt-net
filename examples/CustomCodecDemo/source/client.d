module client;

import hunt.net;
import hunt.logging;

import std.format;

void main() {
    import std.stdio;

    int count = 0;

    NetClient client = NetUtil.createNetClient();
    client.setHandler(new class ConnectionEventHandler {

        override void sessionOpened(Connection session) {
            infof("Connection created: %s", session.getRemoteAddress());

            session.write("Hi, I'm client");
        }

        override void sessionClosed(Connection session) {
            infof("Connection closed: %s", session.getRemoteAddress());
        }

        override void messageReceived(Connection session, Object message) {
            tracef("message type: %s", typeid(message).name);
            string str = format("data received: %s", message.toString());
            tracef(str);
            if(count< 3) 
            session.write(str);
            count++;
        }

        override void exceptionCaught(Connection session, Exception t) {
            warning(t);
        }

        override void failedOpeningSession(int sessionId, Exception t) {
            warning(t);
            // client.close(); 
        }

        override void failedAcceptingSession(int sessionId, Exception t) {
            warning(t);
        }
    }).connect("10.1.222.120", 8080);


    // client.connectHandler((NetSocket sock) {
    //     trace("connected-------------------------------------------");
    //     sock.closeHandler(() {
    //         trace("disconnected-------------------------------------");
    //     });
    // });
    // client.connect(8080, "127.0.0.1", 0, (AsyncResult!NetSocket result) {
    //     if (result.failed()) {
    //         trace(result.cause().toString());
    //     } else {
    //         trace("client have connected to server...");
    //     }
    // });
    // client.setCodec();
    // NetUtil.startEventLoop();

    getchar();

    // FIXME: Needing refactor or cleanup -@zxp at 8/1/2019, 6:37:27 PM
    // Invalid memory operation
    client.close(); 
}
