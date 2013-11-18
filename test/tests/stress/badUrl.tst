/*
    badUrl.tst - Stress test malformed URLs 
 */

const HTTP = App.config.uris.http || "127.0.0.1:4100"
let http: Http = new Http

http.get(HTTP + "/index\x01.html")

let caught
try {
    assert(http.status == 0)
    assert(http.status == 404)
    assert(http.response.contains("Not Found"))
} catch (e) {
    caught = true
}
assert(caught)
http.close()
