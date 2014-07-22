/*
    upload.tst - File upload tests
 */

require ejs.unix

const HTTP = tget('TM_HTTP') || "127.0.0.1:4100"
let http: Http = new Http

//  TODO - rewrite to not use ejs

if (thas('ME_EJS')) {
    http.upload(HTTP + "/upload.ejs", { myfile: "test.dat"} )
    ttrue(http.status == 200)
    ttrue(http.response.contains('"clientFilename": "test.dat"'))
    ttrue(http.response.contains('Uploaded'))
    http.wait()

    http.upload(HTTP + "/upload.ejs", { myfile: "test.dat"}, {name: "John Smith", address: "100 Mayfair"} )
    ttrue(http.status == 200)
    ttrue(http.response.contains('"clientFilename": "test.dat"'))
    ttrue(http.response.contains('Uploaded'))
    ttrue(http.response.contains('"address": "100 Mayfair"'))
    http.close()

} else {
    tskip("Ejscript not enabled")
}
