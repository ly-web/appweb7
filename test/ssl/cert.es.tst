/*
    cert.tst - Test SSL certificates
 */

if (!Config.SSL) {
    tskip("ssl not enabled in ejs")

} else if (thas('ME_SSL')) {
    let http: Http

    for each (let provider in Http.providers) {
        if (provider == 'matrixssl') {
            //  MatrixSSL doesn't support certificate state yet
            continue
        }
        http = new Http
        http.provider = provider;
        http.ca = '../crt/ca.crt'
        http.verify = true
        http.key = null
        http.certificate = null

        //  Verify the server (without a client cert)
        let endpoint = tget('TM_HTTPS') || "https://127.0.0.1:4443"
        ttrue(http.verify == true)
        ttrue(http.verifyIssuer == true)
        http.get(endpoint + '/index.html')
        ttrue(http.status == 200) 
        ttrue(http.info.SERVER_S_CN == 'localhost')
        ttrue(http.info.SERVER_I_EMAIL == 'licensing@example.com')
        ttrue(http.info.SERVER_I_OU != http.info.SERVER_S_OU)
        ttrue(!http.info.CLIENT_S_CN)
        http.close()

        //  Without verifying the server
        let endpoint = tget('TM_HTTPS') || "https://127.0.0.1:4443"
        http.verify = false
        ttrue(http.verify == false)
        ttrue(http.verifyIssuer == false)
        http.get(endpoint + '/index.html')
        ttrue(http.status == 200) 
        ttrue(http.info.SERVER_S_CN == 'localhost')
        ttrue(http.info.SERVER_I_EMAIL == 'licensing@example.com')
        ttrue(http.info.SERVER_I_OU != http.info.SERVER_S_OU)
        ttrue(!http.info.CLIENT_S_CN)
        http.close()

        //  Test a server self-signed cert. Verify but not the issuer.
        //  Note in a self-signed cert the subject == issuer
        let endpoint = tget('TM_SELFCERT') || "https://127.0.0.1:5443"
        http.verify = true
        http.verifyIssuer = false
        http.get(endpoint + '/index.html')
        ttrue(http.status == 200) 
        ttrue(http.info.SERVER_S_CN == 'localhost')
        ttrue(http.info.SERVER_I_OU == http.info.SERVER_S_OU)
        ttrue(http.info.SERVER_I_EMAIL == 'dev@example.com')
        ttrue(!http.info.CLIENT_S_CN)
        http.close()

        //  Test SSL with a client cert 
        endpoint = tget('TM_CLIENTCERT') || "https://127.0.0.1:6443"
        http.key = '../crt/test.key'
        http.certificate = '../crt/test.crt'
        // http.verify = false
        http.get(endpoint + '/index.html')
        ttrue(http.status == 200) 
        // ttrue(info.PROVIDER == provider)
        ttrue(http.info.CLIENT_S_CN == 'localhost')
        ttrue(http.info.SERVER_S_CN == 'localhost')
        ttrue(http.info.SERVER_I_OU != http.info.SERVER_S_OU)
        ttrue(http.info.SERVER_I_EMAIL == 'licensing@example.com')
        http.close()
    }

} else {
    tskip("ssl not enabled")
}
