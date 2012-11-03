/*
    pausing.tst - Test pausing reading from server. Should cause flow control
 */

const HTTP = App.config.uris.http || "127.0.0.1:4100"
load("cgi.es")

/*****
// Depths:    0  1  2  3   4   5   6    7    8    9  
let sizes = [ 1, 2, 4, 8, 16, 32, 64, 128, 256, 512 ]
let depth = global.test ? test.depth : 1
let len = sizes[depth] * 1024000
let bytes = len * 12

let http = new Http
http.setHeader("SWITCHES", "-b%20" + len)
http.get(HTTP + "/cgi-bin/cgiProgram")
assert(http.status == 200)

let data = new ByteArray(1024, false)
let count, n
for (i = 0; i < 10; i++) {
    if ((n = http.read(data)) != null) {
        count += data.length
    }
}
print("SLEEP")
App.sleep(10 * 1000);
print("AFTER SLEEP")
while ((n = http.read(data)) != null) {
    count += data.length
}

assert(count == bytes)
http.close()
*/
