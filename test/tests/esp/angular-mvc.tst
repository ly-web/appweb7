/*
    angular-mvc.tst - ESP Angular MVC tests
 */

const HTTP = App.config.uris.http || "127.0.0.1:4100"
let http: Http = new Http
let prefix = HTTP + "/angular"

//  /angular
http.followRedirects = true
http.get(prefix)
assert(http.status == 200)
assert(http.response.contains("<title>Blog</title>"))
http.close()

//  /angular/
http.get(prefix + "/")
assert(http.status == 200)
assert(http.response.contains("<title>Blog</title>"))
http.close()

//  /angular/index.esp
http.get(prefix + "/index.esp")
assert(http.status == 200)
assert(http.response.contains("<title>Blog</title>"))
http.close()

//  /angular/all.less
http.get(prefix + "/css/all.less")
assert(http.status == 200)
assert(http.response.contains("Aggregate all stylesheets"))
http.close()

//  /angular/do/post/init - this tests a controller without view
http.get(prefix + "/do/post/init")
assert(http.status == 200)
assert(http.response.contains('"schema":'))
http.close()
