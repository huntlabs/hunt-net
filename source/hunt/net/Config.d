module hunt.net.Config;

import hunt.net.Decoder;
import hunt.net.Encoder;
import hunt.net.SessionEventHandler;
import hunt.io.TcpStream;

/**
*/
class Config {

    enum int defaultTimeout = 30 * 1000; 
    enum int defaultPoolSize = 20; 

    private int timeout = defaultTimeout;
    private int connectionTimeout = defaultTimeout;

    // I/O thread pool size
    private int asynchronousCorePoolSize = defaultPoolSize;

    private string serverName = "hunt-server";
    private string clientName = "hunt-client";

    private Decoder decoder;
    private Encoder encoder;
    private SessionEventHandler handler;
    private TcpStreamOption _tcpStreamOption;

    private bool monitorEnable = true;

    this() {
		_tcpStreamOption = TcpStreamOption.createOption();
    }

    TcpStreamOption tcpStreamOption() {
        return _tcpStreamOption;
    }

    int getConnectionTimeout() {
        return connectionTimeout;
    }

    void setConnectionTimeout(int timeout) {
        this.connectionTimeout = timeout;
    }


    /**
     * Get the max I/O idle time, the default value is 10 seconds.
     *
     * @return Max I/O idle time. The unit is millisecond.
     */
    int getTimeout() {
        return timeout;
    }

    /**
     * Set the I/O timeout, if the last I/O timestamp before present over timeout
     * value, the session will close.
     *
     * @param timeout Max I/O idle time. The time unit is millisecond.
     */
    void setTimeout(int timeout) {
        this.timeout = timeout;
    }

    /**
     * Get the server name. The I/O thread name contains server name. It helps you debug codes.
     *
     * @return server name
     */
    string getServerName() {
        return serverName;
    }

    /**
     * Set the server name. The I/O thread name contains server name. It helps you debug codes.
     *
     * @param serverName Server name.
     */
    void setServerName(string serverName) {
        this.serverName = serverName;
    }

    /**
     * Get the client name. If you start a client, the I/O thread name contains client name. It helps you debug codes.
     *
     * @return client name
     */
    string getClientName() {
        return clientName;
    }

    /**
     * Set the client name. If you start a client, the I/O thread name contains client name. It helps you debug codes.
     *
     * @param clientName client name
     */
    void setClientName(string clientName) {
        this.clientName = clientName;
    }

    
    /**
     * Get the decoder. When the server or client receives data, it will call the Decoder. You can write the protocol parser in Decoder.
     *
     * @return decoder
     */
    Decoder getDecoder() {
        return decoder;
    }

    /**
     * Set the decoder. When the server or client receives data, it will call the Decoder. You can write the protocol parser in Decoder.
     *
     * @param decoder decoder
     */
    void setDecoder(Decoder decoder) {
        this.decoder = decoder;
    }

    /**
     * Get the encoder. You can write the protocol generator in Encoder.
     *
     * @return encoder
     */
    Encoder getEncoder() {
        return encoder;
    }

    /**
     * Set the encoder. You can write the protocol generator in Encoder.
     *
     * @param encoder encoder
     */
    void setEncoder(Encoder encoder) {
        this.encoder = encoder;
    }

    /**
     * Get the handler. It is the handler of network events.
     * Such as creating a session, closing session, receiving a message and throwing the exception.
     *
     * @return Handler
     */
    SessionEventHandler getHandler() {
        return handler;
    }

    /**
     * Set the handler. It is the handler of network events.
     * Such as creating a session, closing session, receiving a message and throwing the exception.
     *
     * @param handler SessionEventHandler
     */
    void setHandler(SessionEventHandler handler) {
        this.handler = handler;
    }    


    /**
     * If the monitorEnable is true, the server or client will record runtime performance data to a metric reporter.
     *
     * @return monitorEnable The default value is true.
     */
    bool isMonitorEnable() {
        return monitorEnable;
    }

    /**
     * If the monitorEnable is true, the server or client will record runtime performance data to a metric reporter.
     *
     * @param monitorEnable monitorEnable. The default value is true.
     */
    void setMonitorEnable(bool monitorEnable) {
        this.monitorEnable = monitorEnable;
    }

}