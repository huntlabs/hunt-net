module hunt.net.DecoderChain;

import hunt.net.Decoder;
import hunt.net.Session;
import hunt.container.ByteBuffer;

import hunt.util.exception;

abstract class DecoderChain : Decoder {

    protected DecoderChain next;

    this(DecoderChain next) {
        this.next = next;
    }

    DecoderChain getNext() {
        return next;
    }

    void decode(ByteBuffer buf, Session session) { implementationMissing(); }

}
