
let ws = new WebSocket('ws://localhost:4100/websock/test', ['amazing', 'chat'])
let done

assert(ws.readyState == WebSocket.CONNECTING)

ws.onopen = function (event) {
    print("t.es: onopen")
    assert(ws.readyState == WebSocket.OPEN)
    print("t.es: sending message from inside onopen")
    ws.send("Dear Server: Thanks for listening")
}

ws.onmessage = function (event) {
    print("t.es: onmessage, type: " + typeOf(event.data))
    print("t.es: got message: \"", event.data + "\"")
    assert(ws.readyState == WebSocket.OPEN)
}

ws.onclose = function (event) {
    print("t.es: closed")
    assert(ws.readyState == WebSocket.CLOSED)
    done = true
}

ws.onerror = function (event) {
    print("t.es: error " + event)
}
// ws.close()

/*
    Test
        ws.binaryType == 'ByteArray'
        readyStates
        send with multiple args
        send with binary
        send with conversion to text
 */
/*
    ws.binaryType = 'arraybuffer'
    event.data.byteLength
    ws.binaryType = 'blob'
    print(ws.extensions)
 */

while (!done) {
    App.run(-1, true)
}

assert(ws.readyState == WebSocket.CLOSED)
