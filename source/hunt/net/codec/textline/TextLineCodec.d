module hunt.net.codec.textline.TextLineCodec;

import hunt.net.codec.Codec;
import hunt.net.codec.Encoder;
import hunt.net.codec.Decoder;

import hunt.net.codec.textline.TextLineDecoder;
import hunt.net.codec.textline.TextLineEncoder;

class TextLineCodec : Codec
{
    private TextLineEncoder encoder;
    private TextLineDecoder decoder;

    this() {
        encoder = new TextLineEncoder();
        decoder = new TextLineDecoder();
    }

    Encoder getEncoder()
    {
        return encoder;
    }

    Decoder getDecoder()
    {
        return decoder;
    }
}
