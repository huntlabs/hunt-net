module client;

import hunt.net;
import hunt.net.codec.textline;
import hunt.logging.ConsoleLogger;
import hunt.String;

import std.format;
import std.stdio;


enum Host = "127.0.0.1";
enum Port = 8080;


void main() {
    int count = 0;
    NetClient client = NetUtil.createNetClient();

    client.setCodec(new TextLineCodec);

    // dfmt off
    client.setHandler(new class NetConnectionHandler {

        override void connectionOpened(Connection connection) {
            infof("Connection created: %s", connection.getRemoteAddress());

            // connection.write("Hi, I'm client");
            connection.encode(new String("Hi, I'm client\r"));
        }

        override void connectionClosed(Connection connection) {
            infof("Connection closed: %s", connection.getRemoteAddress());

            // client.close();
        }

        override void messageReceived(Connection connection, Object message) {
            tracef("message type: %s", typeid(message).name);
            string str = format("data received: %s", message.toString());
            tracef(str);
            if(count< 10) {
                connection.encode(new String(str));
            } else if(count == 10) {
                connection.encode(new String("No data will be sent from now."));
            }
            count++;
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
}
