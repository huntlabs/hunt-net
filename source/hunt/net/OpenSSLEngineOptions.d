/*
 * Copyright (c) 2011-2017 Contributors to the Eclipse Foundation
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0, or the Apache License, Version 2.0
 * which is available at https://www.apache.org/licenses/LICENSE-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0 OR Apache-2.0
 */

module hunt.net.OpenSSLEngineOptions;


/**
 * Configures a {@link TCPSSLOptions} to use OpenSsl.
 *
 * @author <a href="mailto:julien@julienviet.com">Julien Viet</a>
 */
class OpenSSLEngineOptions {

    /**
     * @return when OpenSSL is available
     */
    static bool isAvailable() {
        // return OpenSsl.isAvailable();
        // FIXME: Needing refactor or cleanup -@zxp at 7/31/2019, 9:14:58 AM        
        // 
        return false;
    }

    /**
     * @return when alpn support is available via OpenSSL engine
     */
    static bool isAlpnAvailable() {
        // return OpenSsl.isAlpnSupported();
        return false;
    }

    /**
     * Default value of whether connection cache is enabled in open SSL connection server context = true
     */
    enum bool DEFAULT_SESSION_CACHE_ENABLED = true;

    private bool connectionCacheEnabled;

    this() {
        connectionCacheEnabled = DEFAULT_SESSION_CACHE_ENABLED;
    }

    this(OpenSSLEngineOptions other) {
        this.connectionCacheEnabled = other.isConnectionCacheEnabled();
    }

    /**
     * Set whether connection cache is enabled in open SSL connection server context
     *
     * @param connectionCacheEnabled true if connection cache is enabled
     * @return a reference to this, so the API can be used fluently
     */
    OpenSSLEngineOptions setConnectionCacheEnabled(bool connectionCacheEnabled) {
        this.connectionCacheEnabled = connectionCacheEnabled;
        return this;
    }

    /**
     * Whether connection cache is enabled in open SSL connection server context
     *
     * @return true if connection cache is enabled
     */
    bool isConnectionCacheEnabled() {
        return connectionCacheEnabled;
    }

    override
    bool opEquals(Object o) {
        if (this is o) return true;

        OpenSSLEngineOptions that = cast(OpenSSLEngineOptions) o;
        if(that is null)
            return false;

        if (connectionCacheEnabled != that.connectionCacheEnabled) return false;

        return true;
    }

    override
    size_t toHash() @trusted nothrow {
        return connectionCacheEnabled ? 1 : 0;
    }

    OpenSSLEngineOptions clone() {
        return new OpenSSLEngineOptions(this);
    }

}
