/*
    ssl.tst - WebSocket over SSL tests
 */

/*


        WebSocketFilter  RxHead
        ChunkFilter RxHead

        Handler Filter Connector TxHead
let http = new Http
http.post(':4100/index.html', 'abc')
print(http.status)
print(http.response)
 */

const SSL_PORT = App.config.test.http_port || "4110"
const WS = "wss://127.0.0.1:" + SSL_PORT + "/websockets/basic/send"

assert(WebSocket)
print("WS", WS)
let ws = new WebSocket(WS)
ws.verify = false
assert(ws)
assert(ws.readyState == WebSocket.CONNECTING)

let opened
ws.onopen = function (event) {
print("ON-OPEN")
    opened = true
    ws.send("Dear Server: Thanks for listening")
}
ws.onclose = function (event) {
print("ON-CLOSE")
}

ws.wait(WebSocket.OPEN, 5000)
assert(opened)

// ws.close()
// assert(ws.readyState == WebSocket.CLOSING)

ws.wait(WebSocket.CLOSED, 5000000)
assert(ws.readyState == WebSocket.CLOSED)

