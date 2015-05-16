/*
    condition.tst - Test conditional routing based on certificate data
 */

if (!Config.SSL) {
    tskip("ssl not enabled in ejs")

} else if (thas('ME_SSL')) {
    let http: Http

    /*
        Note: these providers are client-side. i.e. those supported in testme, not in appweb.
     */
    for each (let provider in Http.providers) {
        if (provider == 'matrixssl') {
            //  MatrixSSL doesn't support certificate state yet
            continue
        }
        http = new Http
        http.provider = provider;
        // http.ca = '../../src/certs/ca.crt'
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
        http.key = '../../src/certs/test.key'
        http.certificate = '../../src/certs/test.crt'
        http.get(endpoint + '/ssl-match/index.html')
        ttrue(http.status == 200) 
        http.close()
    }

} else {
    tskip("ssl not enabled")
}
