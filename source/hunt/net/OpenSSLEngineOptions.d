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
     * Default value of whether session cache is enabled in open SSL session server context = true
     */
    enum bool DEFAULT_SESSION_CACHE_ENABLED = true;

    private bool sessionCacheEnabled;

    this() {
        sessionCacheEnabled = DEFAULT_SESSION_CACHE_ENABLED;
    }

    this(OpenSSLEngineOptions other) {
        this.sessionCacheEnabled = other.isSessionCacheEnabled();
    }

    /**
     * Set whether session cache is enabled in open SSL session server context
     *
     * @param sessionCacheEnabled true if session cache is enabled
     * @return a reference to this, so the API can be used fluently
     */
    OpenSSLEngineOptions setSessionCacheEnabled(bool sessionCacheEnabled) {
        this.sessionCacheEnabled = sessionCacheEnabled;
        return this;
    }

    /**
     * Whether session cache is enabled in open SSL session server context
     *
     * @return true if session cache is enabled
     */
    bool isSessionCacheEnabled() {
        return sessionCacheEnabled;
    }

    override
    bool equals(Object o) {
        if (this is o) return true;

        OpenSSLEngineOptions that = cast(OpenSSLEngineOptions) o;
        if(that is null)
            return false;

        if (sessionCacheEnabled != that.sessionCacheEnabled) return false;

        return true;
    }

    override
    size_t toHash() @trusted nothrow {
        return sessionCacheEnabled ? 1 : 0;
    }

    OpenSSLEngineOptions clone() {
        return new OpenSSLEngineOptions(this);
    }

}
