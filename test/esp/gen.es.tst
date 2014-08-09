/*
    gen.tst - ESP generate
 */

const HTTP = tget('TM_HTTP') || "127.0.0.1:4100"
let http: Http = new Http

/* UNUSED
let junk = Path('junk')
junk.removeAll()
ttrue(!junk.exists)

Cmd.run('esp generate app junk')
ttrue(junk.exists)

let junk = Path('junk')
junk.removeAll()
ttrue(!junk.exists)

*/
