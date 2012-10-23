/*
    send - WebSocket send tests
 */

const PORT = App.config.test.http_port || "4100"
const WS = "ws://127.0.0.1:" + PORT + "/websockets/basic/send"

assert(WebSocket)
let ws = new WebSocket(WS)
assert(ws)
assert(ws.readyState == WebSocket.CONNECTING)

let opened
ws.onopen = function (event) {
    opened = true
    ws.send("Dear Server: Thanks for listening")
}

ws.wait(WebSocket.OPEN, 5000)
assert(opened)

ws.close()
assert(ws.readyState == WebSocket.CLOSING)
ws.wait(WebSocket.CLOSED, 5000)
assert(ws.readyState == WebSocket.CLOSED)

