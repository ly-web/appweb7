/*
    gen.tst - ESP generate
 */

const HTTP = App.config.uris.http || "127.0.0.1:4100"
let http: Http = new Http

/* UNUSED
let junk = Path('junk')
junk.removeAll()
assert(!junk.exists)

Cmd.run('esp generate app junk')
assert(junk.exists)

let junk = Path('junk')
junk.removeAll()
assert(!junk.exists)

*/
