module hunt.net.secure.conscrypt.ApplicationProtocolSelectorAdapter;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.conscrypt.ApplicationProtocolSelector;
import hunt.net.secure.conscrypt.SSLUtils;

import hunt.net.ssl.SSLEngine;
import hunt.net.ssl.SSLSocket;

import hunt.text.Common;
import std.array;


/**
 * An adapter to bridge between the native code and the {@link ApplicationProtocolSelector} API.
 */
final class ApplicationProtocolSelectorAdapter {
    private enum int NO_PROTOCOL_SELECTED = -1;

    private SSLEngine engine;
    private SSLSocket socket;
    private ApplicationProtocolSelector selector;

    this(SSLEngine engine, ApplicationProtocolSelector selector) {
        this.engine = engine;
        this.socket = null;
        this.selector = selector;
    }

    this(SSLSocket socket, ApplicationProtocolSelector selector) {
        this.engine = null;
        this.socket = socket;
        this.selector = selector;
    }

    /**
     * Performs the ALPN protocol selection from the given list of length-delimited peer protocols.
     * @param encodedProtocols the peer protocols in length-delimited form.
     * @return If successful, returns the offset into the {@code lenghPrefixedList} array of the
     * selected protocol (i.e. points to the length prefix). Otherwise, returns
     * {@link #NO_PROTOCOL_SELECTED}.
     */
    int selectApplicationProtocol(ubyte[] encodedProtocols) {
        if (encodedProtocols.length == 0) {
            return NO_PROTOCOL_SELECTED;
        }

        // Decode the protocols.
        string[] protocols = SSLUtils.decodeProtocols(encodedProtocols);

        // Select the protocol.
        string selected;
        if (engine !is null ) {
            selected = selector.selectApplicationProtocol(engine, protocols);
        } else {
            selected = selector.selectApplicationProtocol(socket, protocols);
        }
        if (selected.empty()) {
            return NO_PROTOCOL_SELECTED;
        }

        int offset = 0;
        foreach (string protocol ; protocols) {
            if (selected.equals(protocol)) {
                // Found the selected protocol. Return the index position of the beginning of
                // the protocol.
                return offset;
            }

            // Add 1 byte for the length prefix.
            offset += 1 + cast(int)protocol.length;
        }

        return NO_PROTOCOL_SELECTED;
    }
}

