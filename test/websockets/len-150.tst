/*
    len-150.tst - Test a message requires multiple bytes for its length

    WebSockets uses one byte for a length <= 125 bytes
 */

const PORT = App.config.test.http_port || "4100"
const WS = "ws://127.0.0.1:" + PORT + "/websockets/basic/len"
const TIMEOUT = 5000
const LEN = 150

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
let msg = "0123456789".times(LEN / 10)
assert(msg.length >= 126)
ws.send(msg)

ws.wait(WebSocket.CLOSED, TIMEOUT)
assert(ws.readyState == WebSocket.CLOSED)
assert(reply == "got:" + msg)
