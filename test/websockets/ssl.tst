/*
    ssl.tst - WebSocket over SSL tests
 */

const SSL_PORT = App.config.test.http_port || "4110"
const WS = "wss://127.0.0.1:" + SSL_PORT + "/websockets/basic/ssl"
const TIMEOUT

assert(WebSocket)
let ws = new WebSocket(WS)
ws.verify = false
assert(ws)
assert(ws.readyState == WebSocket.CONNECTING)

let closed, opened, reply
let msg = "Hello Server"
ws.onopen = function (event) {
    opened = true
    ws.send(msg)
}
ws.onclose = function (event) {
    closed = true
}
ws.onmessage = function (event) {
    assert(event.data is String)
    reply = event.data
    ws.close()
}
ws.wait(WebSocket.OPEN, TIMEOUT)
assert(opened)
assert(!closed)

ws.wait(WebSocket.CLOSED, TIMEOUT)
assert(ws.readyState == WebSocket.CLOSED)
assert(reply == "got:" + msg)
