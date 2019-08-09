[![Build Status](https://travis-ci.org/huntlabs/hunt-net.svg?branch=master)](https://travis-ci.org/huntlabs/hunt-net)

# hunt-net
A net library for dlang, hunt library based.

## How to use it?
hunt-net have codec to encoding and decoding tcp streaming.

### Use codec to build a TcpServer
```D
import hunt.net;
import hunt.net.codec.textline;
import hunt.logging;

void main() {

    NetServerOptions options = new NetServerOptions();
    NetServer server = NetUtil.createNetServer!(ThreadMode.Single)(options);

    server.setCodec(new class Codec {

        private TextLineEncoder encoder;
        private TextLineDecoder decoder;

        this() {
            encoder = new TextLineEncoder();
            decoder = new TextLineDecoder();
        }

        Encoder getEncoder() {
            return encoder;
        }

        Decoder getDecoder() {
            return decoder;
        }
    });

    server.setHandler(new class ConnectionEventHandler
    {
        override void messageReceived(Connection connection, Object message)
        {
            import std.format;

            string str = format("data received: %s", message.toString());
            connection.write(str);
        }
    }).listen("0.0.0.0", 9999);
}
```

### Use codec to build a client
```D
import hunt.net;
import hunt.net.codec.textline;
import hunt.logging;

void main()
{
    int count = 0;

    NetClient client = NetUtil.createNetClient();

    client.setCodec(new class Codec {

        private TextLineEncoder encoder;
        private TextLineDecoder decoder;

        this() {
            encoder = new TextLineEncoder();
            decoder = new TextLineDecoder();
        }

        Encoder getEncoder() {
            return encoder;
        }

        Decoder getDecoder() {
            return decoder;
        }
    });

    client.setHandler(new class ConnectionEventHandler
    {
        override void messageReceived(Connection connection, Object message)
        {
            import std.format;
            import hunt.String;

            string str = format("data received: %s", message.toString());
            if(count < 10) {
                connection.encode(new String(str));
            }

            count++;
        }
    }).connect("10.1.222.120", 9999);
}
```

## TODO
- [ ] Improve support for SSL
- [ ] Improve APIs
