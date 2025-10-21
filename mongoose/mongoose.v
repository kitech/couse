module mongoose

// import mkuse.vpp.xnet
// import mkuse.vpp.xlog
import log

// binding version: x.x-2018???
// #flag @VMODROOT/mongoose/mongoose.o
#flag -I@VMODROOT/mongoose/
#include "mongoose.h"
#include "mongoose_typedef.h"

fn C.mg_mgr_init(...voidptr)
fn C.mg_mgr_free(...voidptr)
fn C.mg_mgr_poll(...voidptr) int
fn C.mg_bind(...voidptr) voidptr
// fn C.mg_set_protocol_http_websocket(...voidptr)
fn C.mg_send(...voidptr) cint
fn C.mg_send_head(...voidptr)
fn C.mg_send_response_line(...voidptr)
fn C.mg_http_send_error(...voidptr)
fn C.mg_http_send_redirect(...voidptr)
fn C.mbuf_remove(...voidptr)

const (
	ev_accept = C.MG_EV_ACCEPT
	ev_connect = C.MG_EV_CONNECT
	ev_close = C.MG_EV_CLOSE
	// ev_timer = C.MG_EV_TIMER
	// ev_recv = C.MG_EV_RECV
	// ev_send = C.MG_EV_SEND
	// ev_http_request = C.MG_EV_HTTP_REQUEST
	// ev_http_reply = C.MG_EV_HTTP_REPLY
)

@[typedef] // nothing happend
struct C.mbuf {
}

// type mg_connection1 C.mg_connection
@[typedef]
struct C.mg_connection {
	recv_mbuf C.mbuf
	send_mbuf C.mbuf
}
struct C.mg_mgr {
}
struct C.http_message {
	message C.mg_str
	body C.mg_str
	method C.mg_str
	uri C.mg_str
	proto C.mg_str
	resp_code int
	resp_status_msg C.mg_str
	query_string C.mg_str
	header_names &C.mg_str
	header_values &C.mg_str
	// header_names [C.MG_MAX_HTTP_HEADERS]C.mg_str
	// header_values [C.MG_MAX_HTTP_HEADERS]C.mg_str
}
struct C.mg_str {
	buf byteptr
	len C.size_t
}

pub struct Mgr0 {
	cobjmem [100]u8
mut:
	cobj &C.mg_mgr = vnil
}

const (gmgr = &Mgr0{} )
fn init() {
	mut mgr := gmgr
	// mgr.cobj = mgr.cobjmem as &C.mg_mgr
	// C.mg_mgr_init(mgr.cobj)
}

pub struct Conn {
mut:
	cobj &C.mg_connection
}

// pub fn (c &Conn) set_protocol_http_websocket() { C.mg_set_protocol_http_websocket(c.cobj) }

pub fn serve() {
	for { C.mg_mgr_poll(gmgr.cobj, 1000) }
}
