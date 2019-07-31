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

module hunt.net.ProxyOptions;

import hunt.net.ProxyType;
import hunt.Exceptions;

import std.array;
import std.conv;

/**
 * Proxy options for a net client or a net client.
 *
 * @author <a href="http://oss.lehmann.cx/">Alexander Lehmann</a>
 */
class ProxyOptions {

    /**
     * The default proxy type (HTTP)
     */
    enum ProxyType DEFAULT_TYPE = ProxyType.HTTP;

    /**
     * The default port for proxy connect = 3128
     *
     * 3128 is the default port for e.g. Squid
     */
    enum int DEFAULT_PORT = 3128;

    /**
     * The default hostname for proxy connect = "localhost"
     */
    enum string DEFAULT_HOST = "localhost";

    private string host;
    private int port;
    private string username;
    private string password;
    private ProxyType type;

    /**
     * Default constructor.
     */
    this() {
        host = DEFAULT_HOST;
        port = DEFAULT_PORT;
        type = DEFAULT_TYPE;
    }

    /**
     * Copy constructor.
     *
     * @param other  the options to copy
     */
    this(ProxyOptions other) {
        host = other.getHost();
        port = other.getPort();
        username = other.getUsername();
        password = other.getPassword();
        type = other.getType();
    }

    /**
     * Get proxy host.
     *
     * @return  proxy hosts
     */
    string getHost() {
        return host;
    }

    /**
     * Set proxy host.
     *
     * @param host the proxy host to connect to
     * @return a reference to this, so the API can be used fluently
     */
    ProxyOptions setHost(string host) {
        assert(!host.empty(), "Proxy host may not be null");
        this.host = host;
        return this;
    }

    /**
     * Get proxy port.
     *
     * @return  proxy port
     */
    int getPort() {
        return port;
    }

    /**
     * Set proxy port.
     *
     * @param port the proxy port to connect to
     * @return a reference to this, so the API can be used fluently
     */
    ProxyOptions setPort(int port) {
        if (port < 0 || port > 65535) {
            throw new IllegalArgumentException("Invalid proxy port " ~ port.to!string);
        }
        this.port = port;
        return this;
    }

    /**
     * Get proxy username.
     *
     * @return  proxy username
     */
    string getUsername() {
        return username;
    }

    /**
     * Set proxy username.
     *
     * @param username the proxy username
     * @return a reference to this, so the API can be used fluently
     */
    ProxyOptions setUsername(string username) {
        this.username = username;
        return this;
    }

    /**
     * Get proxy password.
     *
     * @return  proxy password
     */
    string getPassword() {
        return password;
    }

    /**
     * Set proxy password.
     *
     * @param password the proxy password
     * @return a reference to this, so the API can be used fluently
     */
    ProxyOptions setPassword(string password) {
        this.password = password;
        return this;
    }

    /**
     * Get proxy type.
     *
     *<p>ProxyType can be HTTP, SOCKS4 and SOCKS5
     *
     * @return  proxy type
     */
    ProxyType getType() {
        return type;
    }

    /**
     * Set proxy type.
     *
     * <p>ProxyType can be HTTP, SOCKS4 and SOCKS5
     *
     * @param type the proxy type to connect to
     * @return a reference to this, so the API can be used fluently
     */
    ProxyOptions setType(ProxyType type) {
        this.type = type;
        return this;
    }

    override
    bool opEquals(Object o) {
        if (this is o) return true;
        if (!super.opEquals(o)) return false;

        ProxyOptions that = cast(ProxyOptions) o;
        if(that is null)
            return false;

        if (type != that.type) return false;
        if (host != that.host) return false;
        if (port != that.port) return false;
        if (password != that.password) return false;
        if (username != that.username) return false;

        return true;
    }

    override
    size_t toHash() @trusted nothrow {
        size_t result = super.toHash();
        result = 31 * result + type.hashOf();
        result = 31 * result + host.hashOf();
        result = 31 * result + port;
        result = 31 * result + (password !is null ? password.hashOf() : 0);
        result = 31 * result + (username !is null ? username.hashOf() : 0);
        return result;
    }
}
