module mongoose

import vcp

// binding version: 7.16-202510
#flag -lmongoose
#include <mongoose.h>

struct C.mg_mgr{}
pub type Mgr = C.mg_mgr
struct C.mg_connection{
pub mut:
    // is_closing int // bitfield
    recv C.mg_iobuf
}
struct C.mg_iobuf {
    buf byteptr // unsigned char *buf;  // Pointer to stored data
    size isize // size_t size;         // Total size available
    len isize // size_t len;          // Current number of bytes
    align isize // size_t align;        // Alignment during allocation
}
pub type Mgconn = C.mg_connection
struct C.mg_http_message{
    pub mut:
    method Mgstr
    uri Mgstr
    query Mgstr
    proto Mgstr
    
    body Mgstr
    head Mgstr
    message Mgstr // Request + headers + body
}
pub type MgHttpMsg = C.mg_http_message
pub type MgreqType = MgHttpMsg | usize
pub type MgprocFunc = fn(c &Mgconn, ev Mgev, evdata voidptr)
struct C.mg_str{
    buf charptr
    len usize
}
pub type Mgstr = C.mg_str

pub fn (s Mgstr) tov() string { return unsafe { *&string(voidptr(&s)) } }
pub fn (s Mgstr) dup() string { return tosdup(s.buf, int(s.len)) }

fn C.mg_mgr_init(...voidptr)
fn C.mg_log_set(...voidptr)

pub fn Mgr.new() &Mgr {
    mut mgr := &Mgr{}
    C.mg_mgr_init(mgr)
    C.mg_log_set(C.MG_LL_DEBUG)
    return mgr
}

fn C.mg_mgr_free(...voidptr)
pub fn (r &Mgr) free() { C.mg_mgr_free(&r) }

fn C.mg_http_listen(...voidptr)

// addr http://ip:port/
pub fn (r &Mgr) http_listen(addr string, evproc MgprocFunc) {
    C.mg_http_listen(r, addr.str, voidptr(evproc), vnil)
}

fn C.mg_mgr_poll(...voidptr)

pub fn (r &Mgr) runloop(interval ... int) {
    mut stop := false
    mut ival := firstofv(interval)
    ival = if ival <= 0 { 3000 } else { ival }
    for i:=100; ! stop; i++ {
        C.mg_mgr_poll(r, ival)
    }
}

pub fn mgstr2v(s &C.mg_str) &string {
    return unsafe { &string(voidptr(&s)) }
}
pub fn mgstrofv(s &string) &C.mg_str {
    return unsafe { &C.mg_str(voidptr(&s)) }
}

/*
fn C.mg_match(...voidptr) cint
pub fn mg_match1(s string, d string) bool {
    s2 := *mgstrofv(&s)
    d2 := *mgstrofv(&d)
    rv := C.mg_match(s2, d2, vnil)
    return rv.ok()
}
pub fn mg_match2(s C.mg_str, d string) bool {
    return mg_match1(*mgstr2v(&s), d)
}
*/

/////////

// void mg_http_reply(struct mg_connection *, int status_code, const char *headers,
                   // const char *body_fmt, ...);
fn C.mg_http_reply(...voidptr)

pub type Mgheaders = map[string]string | []string | string

pub fn (c &Mgconn) http_reply_error(stcode int, error string) {
    c.http_reply(stcode, "", error)
}
pub fn (c &Mgconn) http_reply_ok() {
    c.http_reply(200, "", "It's just works\n")
}

// dont too much data, need temp build data string
pub fn (c &Mgconn) http_reply(stcode int, headers Mgheaders, bodys ... string) {
    mut hdrstr := ""
    match headers {
        map[string]string {
            for k, v in headers { hdrstr += "${k}: ${v}\r\n" }
        }
        []string {
            for s in headers { hdrstr += s + "\r\n" }
        }
        string { hdrstr = headers }
    }
    mut data := ""
    for s in bodys { data += s }
    hdrptr := if hdrstr.len == 0 { vnil } else { hdrstr.str }
    datptr := if data.len == 0 { vnil } else { data.str }
    // vcp.info('datalen', data.len)
    C.mg_http_reply(c, stcode, hdrptr, data.str)
}

fn C.mg_close_conn(...voidptr)
pub fn (c &Mgconn) close() { C.mg_close_conn(c) }

pub fn (c &Mgconn) set_closing() { 
    c2 := &C.mg_connection(c)
    c99 {
        c2->is_closing = 1;
    }
}

fn C.mg_send(... voidptr) cint

pub fn (c &Mgconn) send(data voidptr, len usize) bool {
    rv := C.mg_send(c, data, len)
    return rv.ok()
}
pub fn (c &Mgconn) send1(data string) bool {
    return c.send(data.str, usize(data.len))
}

pub enum Mgev  {
    error = C.MG_EV_ERROR      // Error                        char *error_message
    open = C.MG_EV_OPEN       // Connection created           NULL
    poll = C.MG_EV_POLL       // mg_mgr_poll iteration        uint64_t *uptime_millis
    resolve = C.MG_EV_RESOLVE    // Host name is resolved        NULL
    connect = C.MG_EV_CONNECT    // Connection established       NULL
    accept = C.MG_EV_ACCEPT     // Connection accepted          NULL
    tls_hs = C.MG_EV_TLS_HS     // TLS handshake succeeded      NULL
    read = C.MG_EV_READ       // Data received from socket    long *bytes_read
    write = C.MG_EV_WRITE      // Data written to socket       long *bytes_written
    close = C.MG_EV_CLOSE      // Connection closed            NULL
    http_hdrs = C.MG_EV_HTTP_HDRS  // HTTP headers                 struct mg_http_message *
    http_msg = C.MG_EV_HTTP_MSG   // Full HTTP request/response   struct mg_http_message *
    ws_open = C.MG_EV_WS_OPEN    // Websocket handshake done     struct mg_http_message *
    ws_msg = C.MG_EV_WS_MSG     // Websocket msg, text or bin   struct mg_ws_message *
    ws_ctl = C.MG_EV_WS_CTL     // Websocket control msg        struct mg_ws_message *
    mqtt_cmd = C.MG_EV_MQTT_CMD   // MQTT low-level command       struct mg_mqtt_message *
    mqtt_msg = C.MG_EV_MQTT_MSG   // MQTT PUBLISH received        struct mg_mqtt_message *
    mqtt_open = C.MG_EV_MQTT_OPEN  // MQTT CONNACK received        int *connack_status_code
    sntp_time = C.MG_EV_SNTP_TIME  // SNTP time received           uint64_t *epoch_millis
    wakeup = C.MG_EV_WAKEUP     // mg_wakeup() data received    struct mg_str *data
    user = C.MG_EV_USER        // Starting ID for user events
}
