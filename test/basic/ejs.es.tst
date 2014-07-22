/*
    ejs.tst - Ejscript basic tests
 */

const HTTP = tget('TM_HTTP') || "127.0.0.1:4100"
let http: Http = new Http

if (thas('ME_EJS')) {
    /* Tests */

    function basic() {
        http.get(HTTP + "/ejsProgram.ejs")
        ttrue(http.status == 200)
        deserialize(http.response)
    }

    function forms() {
        http.get(HTTP + "/ejsProgram.ejs")
        ttrue(http.status == 200)
        deserialize(http.response)

        /* 
            Not supporting caseless extension matching 

            if (Config.OS == "windows") {
                http.get(HTTP + "/ejsProgRAM.eJS")
                ttrue(http.status == 200)
                deserialize(http.response)
            }
        */
    }

    /*  TODO - not yet supported
    function alias() {
        http.get(HTTP + "/SimpleAlias/ejsProgram.ejs")
        ttrue(http.status == 200)
        let resp = deserialize(http.response)
        ttrue(resp.uri == "/SimpleAlias/ejsProgram.ejs")
        ttrue(resp.query == null)
    }
    */

    function query() {
        http.get(HTTP + "/ejsProgram.ejs?a=b&c=d&e=f")
        let resp = deserialize(http.response)
        ttrue(resp.pathInfo == "/ejsProgram.ejs")
        ttrue(resp.params["a"] == "b")
        ttrue(resp.params["c"] == "d")

        //  Query string vars should not be turned into variables for GETs
        
        http.get(HTTP + "/ejsProgram.ejs?var1=a+a&var2=b%20b&var3=c")
        let resp = deserialize(http.response)
        ttrue(resp.pathInfo == "/ejsProgram.ejs")
        ttrue(resp.query ==  "var1=a+a&var2=b%20b&var3=c")
        ttrue(resp.params["var1"] == "a a")
        ttrue(resp.params["var2"] == "b b")
        ttrue(resp.params["var3"] == "c")

        //  Post data should be turned into variables
        
        http.form(HTTP + "/ejsProgram.ejs?var1=a+a&var2=b%20b&var3=c", 
            { name: "Peter", address: "777 Mulberry Lane" })
        let resp = deserialize(http.response)
        ttrue(resp.query == "var1=a+a&var2=b%20b&var3=c")
        let params = resp.params
        ttrue(params["var1"] == "a a")
        ttrue(params["var2"] == "b b")
        ttrue(params["var3"] == "c")
        ttrue(params["name"] == "Peter")
        ttrue(params["address"] == "777 Mulberry Lane")
    }

    function encoding() {
        http.get(HTTP + "/ejsProgram.ejs?var%201=value%201")
        let resp = deserialize(http.response)
        ttrue(resp.query == "var%201=value%201")
        ttrue(resp.pathInfo == "/ejsProgram.ejs")
        ttrue(resp.params["var 1"] == "value 1")
    }

    function status() {
        http.get(HTTP + "/ejsProgram.ejs?code=711")
        ttrue(http.status == 711)
    }

    function location() {
        let http = new Http
        http.followRedirects = false
        http.get(HTTP + "/ejsProgram.ejs?redirect=http://www.redhat.com/")
        ttrue(http.status == 302)
    }

    function quoting() {
        http.get(HTTP + "/ejsProgram.ejs?a+b+c")
        let resp = deserialize(http.response)
        let params = resp.params
        ttrue(resp.query == "a+b+c")
        ttrue(params["a b c"] == "")

        http.get(HTTP + "/ejsProgram.ejs?a=1&b=2&c=3")
        let resp = deserialize(http.response)
        let params = resp.params
        ttrue(resp.query == "a=1&b=2&c=3")
        ttrue(params["a"] == "1")
        ttrue(params["b"] == "2")
        ttrue(params["c"] == "3")

        http.get(HTTP + "/ejsProgram.ejs?a%20a=1%201+b%20b=2%202")
        let resp = deserialize(http.response)
        let params = resp.params
        ttrue(resp.query == "a%20a=1%201+b%20b=2%202")
        ttrue(params["a a"] == "1 1 b b=2 2")

        http.get(HTTP + "/ejsProgram.ejs?a%20a=1%201&b%20b=2%202")
        let resp = deserialize(http.response)
        let params = resp.params
        ttrue(resp.query == "a%20a=1%201&b%20b=2%202")
        ttrue(params["a a"] == "1 1")
        ttrue(params["b b"] == "2 2")

        http.get(HTTP + "/ejsProgram.ejs?a,b+c#d+e?f+g#h+i'j+kl+m%20n=1234")
        let resp = deserialize(http.response)
        ttrue(resp.params["a,b c#d e?f g#h i'j kl m n"] == 1234)
        ttrue(resp.query == "a,b+c#d+e?f+g#h+i\'j+kl+m%20n=1234")
    }

    basic()
    forms()
    /* TODO - not using aliases
        alias()
    */
    query()
    encoding()
    status()
    location()
    quoting()
    http.close()

} else {
    tskip("Ejscript not enabled")
}
