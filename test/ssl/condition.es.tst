/*
    condition.tst - Test conditional routing based on certificate data
 */

if (!Config.SSL) {
    tskip("ssl not enabled in ejs")

} else if (thas('ME_SSL')) {
    let http: Http
    let bin = Path(App.getenv('TM_BIN'))

    //  NanoSSL does not support verifying client certificates
    if (!App.getenv('ME_NANOSSL') == 1) {
        http = new Http
        // http.ca = bin.join('ca.crt')
        http.verify = false

        //  Should fail if no cert is provided
        endpoint = tget('TM_CLIENTCERT') || "https://127.0.0.1:6443"
        let caught
        try {
            // Server should deny and handshake should fail
            http.get(endpoint + '/ssl-match/index.html')
            ttrue(http.status == 200) 
        } catch {
            caught = true
        }
        ttrue(caught)
        http.close()

        //  Should pass with a cert
        endpoint = tget('TM_CLIENTCERT') || "https://127.0.0.1:6443"
        http.key = bin.join('test.key')
        http.certificate = bin.join('test.crt')
        http.get(endpoint + '/ssl-match/index.html')
        ttrue(http.status == 200) 
        http.close()
    }

} else {
    tskip("ssl not enabled")
}
