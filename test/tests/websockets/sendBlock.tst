/*
    sendBlock.tst - WebSocket sendBlock API test
 */

/* FUTURE
const PORT = App.config.test.http_port || "4100"
const WS = "ws://127.0.0.1:" + PORT + "/websockets/basic/sendBlock"
const TIMEOUT = 5000

assert(WebSocket)
let ws = new WebSocket(WS)
assert(ws)
assert(ws.readyState == WebSocket.CONNECTING)

let opened
ws.onopen = function (event) {
    opened = true
    len = ws.sendBlock("Hello World", { last: false, mode: WebSocket.BUFFER, type: WebSocket.MSG_TEXT })
    len = ws.sendBlock("Hello World", { last: false, mode: WebSocket.BLOCK, type: WebSocket.MSG_TEXT })
    len = ws.sendBlock("Hello World", { last: false, mode: WebSocket.NON_BLOCK, type: WebSocket.MSG_TEXT })

    - vary last
    - vary buffering
    - vary message type
    ws.sendBlock("Hello World", { last: false, mode: WebSocket.NON_BLOCK, type: WebSocket.MSG_TEXT })
}

ws.wait(WebSocket.OPEN, TIMEOUT)
assert(opened)

ws.close()
assert(ws.readyState == WebSocket.CLOSING)
ws.wait(WebSocket.CLOSED, TIMEOUT)
assert(ws.readyState == WebSocket.CLOSED)
*/
