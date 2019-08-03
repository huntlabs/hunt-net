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

module hunt.net.NetworkOptions;

/**
 * @author <a href="http://tfox.org">Tim Fox</a>
 */
class NetworkOptions {

    /**
     * The default value of TCP send buffer size
     */
    enum int DEFAULT_SEND_BUFFER_SIZE = -1;

    /**
     * The default value of TCP receive buffer size
     */
    enum int DEFAULT_RECEIVE_BUFFER_SIZE = -1;

    /**
     * The default value of traffic class
     */
    enum int DEFAULT_TRAFFIC_CLASS = -1;

    /**
     * The default value of reuse address
     */
    enum bool DEFAULT_REUSE_ADDRESS = true;

    /**
     * The default value of reuse port
     */
    enum bool DEFAULT_REUSE_PORT = false;

    /**
     * The default log enabled = false
     */
    enum bool DEFAULT_LOG_ENABLED = false;

    private int sendBufferSize;
    private int receiveBufferSize;
    private int trafficClass;
    private bool reuseAddress;
    private bool logActivity;
    private bool reusePort;

    /**
     * Default constructor
     */
    this() {
        sendBufferSize = DEFAULT_SEND_BUFFER_SIZE;
        receiveBufferSize = DEFAULT_RECEIVE_BUFFER_SIZE;
        reuseAddress = DEFAULT_REUSE_ADDRESS;
        trafficClass = DEFAULT_TRAFFIC_CLASS;
        logActivity = DEFAULT_LOG_ENABLED;
        reusePort = DEFAULT_REUSE_PORT;
    }

    /**
     * Copy constructor
     *
     * @param other  the options to copy
     */
    this(NetworkOptions other) {
        this.sendBufferSize = other.getSendBufferSize();
        this.receiveBufferSize = other.getReceiveBufferSize();
        this.reuseAddress = other.isReuseAddress();
        this.reusePort = other.isReusePort();
        this.trafficClass = other.getTrafficClass();
        this.logActivity = other.logActivity;
    }

    /**
     * Return the TCP send buffer size, in bytes.
     *
     * @return the send buffer size
     */
    int getSendBufferSize() {
        return sendBufferSize;
    }

    /**
     * Set the TCP send buffer size
     *
     * @param sendBufferSize  the buffers size, in bytes
     * @return a reference to this, so the API can be used fluently
     */
    NetworkOptions setSendBufferSize(int sendBufferSize) {
        assert(sendBufferSize > 0 || sendBufferSize == DEFAULT_SEND_BUFFER_SIZE,
                "sendBufferSize must be > 0");
        this.sendBufferSize = sendBufferSize;
        return this;
    }

    /**
     * Return the TCP receive buffer size, in bytes
     *
     * @return the receive buffer size
     */
    int getReceiveBufferSize() {
        return receiveBufferSize;
    }

    /**
     * Set the TCP receive buffer size
     *
     * @param receiveBufferSize  the buffers size, in bytes
     * @return a reference to this, so the API can be used fluently
     */
    NetworkOptions setReceiveBufferSize(int receiveBufferSize) {
        assert(receiveBufferSize > 0 || receiveBufferSize == DEFAULT_RECEIVE_BUFFER_SIZE,
                "receiveBufferSize must be > 0");
        this.receiveBufferSize = receiveBufferSize;
        return this;
    }

    /**
     * @return  the value of reuse address
     */
    bool isReuseAddress() {
        return reuseAddress;
    }

    /**
     * Set the value of reuse address
     * @param reuseAddress  the value of reuse address
     * @return a reference to this, so the API can be used fluently
     */
    NetworkOptions setReuseAddress(bool reuseAddress) {
        this.reuseAddress = reuseAddress;
        return this;
    }

    /**
     * @return  the value of traffic class
     */
    int getTrafficClass() {
        return trafficClass;
    }

    /**
     * Set the value of traffic class
     *
     * @param trafficClass  the value of traffic class
     * @return a reference to this, so the API can be used fluently
     */
    NetworkOptions setTrafficClass(int trafficClass) {
        assert(trafficClass > DEFAULT_TRAFFIC_CLASS && trafficClass <= 255,
                "trafficClass tc must be 0 <= tc <= 255");
        this.trafficClass = trafficClass;
        return this;
    }

    /**
     * @return true when network activity logging is enabled
     */
    bool getLogActivity() {
        return logActivity;
    }

    /**
     * Set to true to enabled network activity logging: Netty's pipeline is configured for logging on Netty's logger.
     *
     * @param logActivity true for logging the network activity
     * @return a reference to this, so the API can be used fluently
     */
    NetworkOptions setLogActivity(bool logActivity) {
        this.logActivity = logActivity;
        return this;
    }

    /**
     * @return  the value of reuse address - only supported by native transports
     */
    bool isReusePort() {
        return reusePort;
    }

    /**
     * Set the value of reuse port.
     * <p/>
     * This is only supported by native transports.
     *
     * @param reusePort  the value of reuse port
     * @return a reference to this, so the API can be used fluently
     */
    NetworkOptions setReusePort(bool reusePort) {
        this.reusePort = reusePort;
        return this;
    }

    override bool opEquals(Object o) {
        if (this is o)
            return true;

        NetworkOptions that = cast(NetworkOptions) o;
        if (that is null)
            return false;

        if (receiveBufferSize != that.receiveBufferSize)
            return false;
        if (reuseAddress != that.reuseAddress)
            return false;
        if (reusePort != that.reusePort)
            return false;
        if (sendBufferSize != that.sendBufferSize)
            return false;
        if (trafficClass != that.trafficClass)
            return false;

        return true;
    }

    override size_t toHash() @trusted nothrow {
        size_t result = sendBufferSize;
        result = 31 * result + receiveBufferSize;
        result = 31 * result + trafficClass;
        result = 31 * result + (reuseAddress ? 1 : 0);
        result = 31 * result + (reusePort ? 1 : 0);
        return result;
    }
}
