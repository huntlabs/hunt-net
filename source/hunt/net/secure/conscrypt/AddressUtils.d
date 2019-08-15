module hunt.net.secure.conscrypt.AddressUtils;

import hunt.text.Common;
import hunt.text.Pattern;

/**
 * Utilities to check whether IP addresses meet some criteria.
 */
final class AddressUtils {
    /*
     * Regex that matches valid IPv4 and IPv6 addresses.
     */
    private enum string IP_PATTERN = "^(?:(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\\.){3}(?:25[0-5]|2[0-4][0-9]|"
            ~ "[01]?[0-9]?[0-9]))|(?i:(?:(?:[0-9a-f]{1,4}:){7}(?:[0-9a-f]{1,4}|:))|(?:(?:[0-9a-f]{1,4}:){6}(?::[0-9a-f]{1,4}|" 
            ~ "(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(?:\\.(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|"
            ~ "[1-9]?[0-9])){3})|:))|(?:(?:[0-9a-f]{1,4}:){5}(?:(?:(?::[0-9a-f]{1,4}){1,2})|:(?:(?:25[0-5]|" 
            ~ "2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(?:\\.(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|"
            ~ "(?:(?:[0-9a-f]{1,4}:){4}(?:(?:(?::[0-9a-f]{1,4}){1,3})|(?:(?::[0-9a-f]{1,4})?:(?:(?:25[0-5]|"
            ~ "2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(?:\\.(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|"
            ~ "(?:(?:[0-9a-f]{1,4}:){3}(?:(?:(?::[0-9a-f]{1,4}){1,4})|(?:(?::[0-9a-f]{1,4}){0,2}:(?:(?:25[0-5]|"
            ~ "2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(?:\\.(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|"
            ~ "(?:(?:[0-9a-f]{1,4}:){2}(?:(?:(?::[0-9a-f]{1,4}){1,5})|(?:(?::[0-9a-f]{1,4}){0,3}:(?:(?:25[0-5]|"
            ~ "2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(?:\\.(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|"
            ~ ":))|(?:(?:[0-9a-f]{1,4}:){1}(?:(?:(?::[0-9a-f]{1,4}){1,6})|(?:(?::[0-9a-f]{1,4}){0,4}:(?:(?:25[0-5]|"
            ~ "2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(?:\\.(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|"
            ~ "(?::(?:(?:(?::[0-9a-f]{1,4}){1,7})|(?:(?::[0-9a-f]{1,4}){0,5}:(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|"
            ~ "[1-9]?[0-9])(?:\\.(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:)))$";

    private static Pattern ipPattern;

    private this() {}

    /**
     * Returns true when the supplied hostname is valid for SNI purposes.
     */
    static bool isValidSniHostname(string sniHostname) {
        if (sniHostname is null) {
            return false;
        }

// TODO: Tasks pending completion -@zxp at 8/3/2018, 11:41:38 AM
// 
        return true;

        // Must be a FQDN that does not have a trailing dot.
        // return (sniHostname.equalsIgnoreCase("localhost")
        //             || sniHostname.indexOf('.') != -1)
        //         // && !Platform.isLiteralIpAddress(sniHostname)
        //         && !sniHostname.endsWith(".")
        //         && sniHostname.indexOf('\0') == -1;
    }

    /**
     * Returns true if the supplied hostname is an literal IP address.
     */
    // static bool isLiteralIpAddress(string hostname) {
    //     /* This is here for backwards compatibility for pre-Honeycomb devices. */
    //     Pattern ipPattern = AddressUtils.ipPattern;
    //     if (ipPattern is null) {
    //         AddressUtils.ipPattern = ipPattern = Pattern.compile(IP_PATTERN);
    //     }
    //     return ipPattern.matcher(hostname).matches();
    // }
}

