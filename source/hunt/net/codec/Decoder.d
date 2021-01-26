module hunt.net.codec.Decoder;

import hunt.net.Connection;
import hunt.io.ByteBuffer;
import hunt.io.channel;

import hunt.Exceptions;

interface Decoder {
    DataHandleStatus decode(ByteBuffer buf, Connection connection);
}

/**
*/
class DecoderChain : Decoder {

    protected DecoderChain _nextDecoder;

    this(DecoderChain nextDecoder) {
        this._nextDecoder = nextDecoder;
    }

    DecoderChain getNext() {
        return _nextDecoder;
    }

    DataHandleStatus decode(ByteBuffer buf, Connection connection) {
        implementationMissing();

        return DataHandleStatus.Done;
    }

}
