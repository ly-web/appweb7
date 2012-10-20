/*
    send - WebSocket send C
 */

const PORT = App.config.test.http_port || "4100"
const WS = "ws://127.0.0.1:" + PORT + "/websockets/basic/construct"

assert(WebSocket)
let ws = new WebSocket(WS)
assert(ws)
assert(ws.readyState == WebSocket.CONNECTING)

let openEvent
ws.onopen = function (event) {
    openEvent = true
    // ws.send("Dear Server: Thanks for listening")
}

while (ws.readyState != WebSocket.CONNECTING) {
    App.run(-1, true)
}

ws.close()
assert(ws.readyState == WebSocket.CLOSED)

