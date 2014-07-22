/*
    multiple.tst -- Multiple overlapped requests
 */

const HTTP = tget('TM_HTTP') || "127.0.0.1:4100"

var nap: Http = new Http

//  Issue a nap request. This request takes 2 seconds to complete -- waited on below.
nap.get(HTTP + "/nap.ejs")


//  Overlapped non-blocking request
var http: Http = new Http
for (i in 20) {
    let now = new Date()
    http.get(HTTP + "/index.ejs")
    ttrue(http.status == 200)
    ttrue(now.elapsed < 2000)
}
http.close()


//  Wait for nap request
ttrue(nap.status == 200)
nap.close()
