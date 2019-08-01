module client;


import hunt.net;
import hunt.logging;

void main() {
    import std.stdio;

    NetClient client = NetUtil.createNetClient();
    client.setHandler(new class ConnectionEventHandler {

        override void sessionOpened(Connection session) {
            info("Connection created");
        }

        override void sessionClosed(Connection session) {
            info("Connection closed");
        }

        override void messageReceived(Connection session, Object message) {
            trace(message.toString());
        }

        override void exceptionCaught(Connection session, Exception t) {
            warning(t);
        }

        override void failedOpeningSession(int sessionId, Exception t) {
            warning(t);
        }

        override void failedAcceptingSession(int sessionId, Exception t) {
            warning(t);
        }
    }
);

    client.connect("10.1.222.120", 8080);

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
}
