module mgs

import log
import time
import sync
import arrays

pub fn (r &Mgr) runloop(interval ... int) {
    mut ival := firstofv(interval)
    ival = if ival <= 0 { 3000 } else { ival }
    mut stop := false
    for i:=100; ! stop; i++ {
        r.poll(ival)
    }
}

pub fn (c &Conn) http_reply_error(stcode int, error string) {
    c.http_reply(stcode, "", error)
}
pub fn (c &Conn) http_reply_ok() {
    c.http_reply(200, "", "It's just works\n")
}

struct Globvars {
    pub mut:
    mu sync.RwMutex
    // keep Funwrap's reference not GC collet
    funs map[u64]&Funwrap // listen connid =>
}

const mgv = &Globvars{}

pub type HttpFunc = fn (&Conn, &HttpMsg, voidptr)
pub type HandleFunc = fn(&Conn, &HttpMsg, voidptr) | fn(&Conn, Ev, voidptr)

struct Funwrap {
    pub mut:
    fun HandleFunc
    cbval voidptr
    proto Protocol
}

pub fn (r &Mgr) listen(url string, fun HandleFunc, cbval voidptr) {
    info := &Funwrap{fun:fun, cbval:cbval}
    match fun {
        fn(&Conn, &HttpMsg, voidptr) {
            info.proto = .http
            c := r.http_listen(url, event_proc, voidptr(info))
            mgv.funs[u64(c.id)] = info
        }
        fn(&Conn, Ev, voidptr) {
            c := C.mg_listen(r, url.str, event_proc, voidptr(info))
            mgv.funs[u64(c.id)] = info
        }
    }
}

fn event_proc(c &Conn, ev Ev, evdata voidptr) {
    info := unsafe { &Funwrap(c.fn_data) }
    fun := info.fun
    match fun{
        fn(&Conn, &HttpMsg,voidptr) {
            if ev == .http_msg {
                fun(c, &HttpMsg(evdata), info.cbval)
            }
        }
        fn(&Conn, Ev, voidptr) {
            fun(c, ev, evdata)
        }
    }
    if c.is_listening == ctrue && ev == .close {
        mgv.funs.delete(u64(c.id))
    }
}
