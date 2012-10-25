/*
    len-256K.tst - Test a big single frame message

    WebSockets uses one byte for a length <= 125 bytes
 */

const PORT = App.config.test.http_port || "4100"
const WS = "ws://127.0.0.1:" + PORT + "/websockets/basic/len"
const TIMEOUT = 5000 * 1000
const LEN = 256 * 1024

assert(WebSocket)
let ws = new WebSocket(WS)
assert(ws)
assert(ws.readyState == WebSocket.CONNECTING)

let reply
ws.onmessage = function (event) {
    assert(event.data is String)
    reply = event.data
    ws.close()
}

ws.wait(WebSocket.OPEN, TIMEOUT)

let data = new ByteArray(LEN)
for (i in LEN / 50) {
    data.write("01234567890123456789012345678901234567890123456789")
}
print("LENGTH", data.length)
ws.send(data)

ws.wait(WebSocket.CLOSED, TIMEOUT)
assert(ws.readyState == WebSocket.CLOSED)
assert(reply == "got:" + msg)
