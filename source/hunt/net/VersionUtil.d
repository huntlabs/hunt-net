module hunt.net.VersionUtil;

version(WITH_HUNT_SECURITY) {
    version(Have_openssl) {

    } else version (Have_boringssl) {

    } else {
        static assert(false, "Please add package boringssl or openssl into the current project in dub.json!");
    }

    version(Have_hunt_security) {} else {
        static assert(false, "Please add package hunt-security into the current project in dub.json!");
    }
} 

// mixin template checkPackageVersion() {
//     version(WITH_HUNT_SECURITY) {

//     } else {
//         version (Have_boringssl) {
//             version = WITH_HUNT_SECURITY;
//         } else version(Have_openssl) {
//             version = WITH_HUNT_SECURITY;
//         }   
//     }
// }

string checkVersions() {

    string r = `
        version(WITH_HUNT_SECURITY) {

        } else {
            version (Have_boringssl) {
                version = WITH_HUNT_SECURITY;
            } else version(Have_openssl) {
                version = WITH_HUNT_SECURITY;
            }   
        } 
    `;

    return r;    
}