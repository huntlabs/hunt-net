module hunt.net.ConnectionExtInfo;

import hunt.net.ConnectionType;

/**
 * 
 */
interface ConnectionExtInfo {

    ConnectionType getConnectionType();

    bool isEncrypted();

}
