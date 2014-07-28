/*
    gen.tst - ESP generate
 */

const HTTP = App.config.uris.http || "127.0.0.1:4100"
let http: Http = new Http

let junk = Path('junk')
junk.removeAll()
assert(!junk.exists)

let esp = test.bin.join("esp").portable
Cmd.run(esp + ' generate app junk esp-server')
assert(junk.exists)

let junk = Path('junk')
junk.removeAll()
assert(!junk.exists)

junk.makeDir()
Cmd.run(esp + ' install esp-html-mvc', {dir: junk})
assert(junk.exists)

let junk = Path('junk')
junk.removeAll()
assert(!junk.exists)

