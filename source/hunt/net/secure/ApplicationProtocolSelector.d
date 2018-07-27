module hunt.net.secure.ProtocolSelector;


interface ProtocolSelector {

    string getApplicationProtocol();
    
    string[] getSupportedApplicationProtocols();

}