/*
    php.tst - PHP tests
 */

const HTTP = tget('TM_HTTP') || "127.0.0.1:4100"

if (thas('ME_PHP')) {
    let http: Http = new Http

    //  Simple Get 
    http.get(HTTP + "/index.php")
    ttrue(http.status == 200)
    ttrue(http.response.contains("Hello PHP World"))

    //  Get 
    http.get(HTTP + "/form.php")
    ttrue(http.status == 200)
    ttrue(http.response.contains("form.php"))

    //  Form
    http.form(HTTP + "/form.php?a=b&c=d", { name: "John Smith", address: "777 Mulberry Lane" })
    ttrue(http.status == 200)
    ttrue(http.response.contains("name is John Smith"))
    ttrue(http.response.contains("address is 777 Mulberry Lane"))
    http.close()

    //  Big output
    http.get(HTTP + "/big.php")
    ttrue(http.status == 200)
    data = new ByteArray
    while ((count = http.read(data))) {
        ttrue(data.toString().contains("aaaabbbb"))
    }
    http.close()

} else {
    tskip("php not enabled")
}
