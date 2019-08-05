module hunt.net.codec.Decoder;

import hunt.net.Connection;
import hunt.collection.ByteBuffer;

import hunt.Exceptions;

interface Decoder {
    void decode(ByteBuffer buf, Connection connection);
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

    void decode(ByteBuffer buf, Connection connection) {
        implementationMissing();
    }

}
