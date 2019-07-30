module hunt.net.codec.Decoder;

import hunt.net.Session;
import hunt.collection.ByteBuffer;

import hunt.Exceptions;

interface Decoder {
    void decode(ByteBuffer buf, Session session);
}

/**
*/
class DecoderChain : Decoder {

    protected DecoderChain next;

    this(DecoderChain next) {
        this.next = next;
    }

    DecoderChain getNext() {
        return next;
    }

    void decode(ByteBuffer buf, Session session) {
        NotImplementedException();
    }

}
