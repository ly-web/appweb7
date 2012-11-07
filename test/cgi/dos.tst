/*
    CGI Denial of service testing
 */

const HTTP: Uri = App.config.uris.http || "127.0.0.1:4100"

//  Check server available
http = new Http
http.get(HTTP + "/index.html")
assert(http.status == 200)
http.close()

//  Try to crash with DOS attack
for (i in 800) {
    let http = new Http
    http.get(HTTP + '/cgi-bin/cgiProgram')
    http.close()
}

//  Check server still there
http = new Http
http.get(HTTP + "/index.html")
assert(http.status == 200)
http.close()
