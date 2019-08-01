module server;

import hunt.net;
import hunt.logging;

import std.format;

void main() {

    NetServerOptions options = new NetServerOptions();
    NetServer server = NetUtil.createNetServer!(ThreadMode.Single)(options);

    server.setHandler(new class ConnectionEventHandler {

        override void sessionOpened(Connection session) {
            infof("Connection created: %s", session.getRemoteAddress());
        }

        override void sessionClosed(Connection session) {
            infof("Connection closed: %s", session.getRemoteAddress());
        }

        override void messageReceived(Connection session, Object message) {
            string str = format("data received: %s", message.toString());
            tracef(str);
            session.write(str);
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
    }).listen("0.0.0.0", 8080);
    // server.getOptions();
    // server.connectionHandler((NetSocket sock) {
    //     logInfo("accepted a connection...");
    //     sock.handler((ByteBuffer buffer) {
    //         logInfo("received from client");
    //         sock.write(buffer);
    //     });
    // }).listen("0.0.0.0", 8080, (Result!Server result) {
    //     if (result.failed())
    //         throw result.cause();
    // });

}
