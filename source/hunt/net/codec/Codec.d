module hunt.net.codec.Codec;

// import hunt.net.Connection;
import hunt.net.codec.Decoder;
import hunt.net.codec.Encoder;

/**
 * Provides {@link Encoder} and {@link Decoder} which translates
 * binary or  specific data into message object and vice versa.
 * <p>
 * Please refer to
 * <a href="../../../../../xref-examples/org/apache/mina/examples/reverser/ReverseProvider.html"><code>ReverserProvider</code></a>
 * example.
 *
 * @author <a href="http://mina.apache.org">Apache MINA Project</a>
 */
interface Codec {
    /**
     * Returns a new (or reusable) instance of {@link Encoder} which
     * encodes message objects into binary or -specific data.
     * 
     * @param session The current session
     * @return The encoder instance
     * @throws Exception If an error occurred while retrieving the encoder
     */
    Encoder getEncoder();

    /**
     * Returns a new (or reusable) instance of {@link Decoder} which
     * decodes binary or -specific data into message objects.
     * 
     * @param session The current session
     * @return The decoder instance
     * @throws Exception If an error occurred while retrieving the decoder
     */
    Decoder getDecoder();
}