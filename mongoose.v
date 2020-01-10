module mongoose

import mkuse.vpp.xnet
import mkuse.vpp.xlog

#flag @VMOD/mkuse/mongoose/mongoose.o
#flag -I@VMOD/mkuse/mongoose/
#include "mongoose.h"
#include "mongoose_typedef.h"

fn C.mg_mgr_init()
fn C.mg_mgr_free()
fn C.mg_mgr_poll() int
fn C.mg_bind() voidptr
fn C.mg_set_protocol_http_websocket()
fn C.mg_send()
fn C.mg_send_head()
fn C.mg_send_response_line()
fn C.mg_http_send_error()
fn C.mg_http_send_redirect()
fn C.mbuf_remove()

const (
	EV_ACCEPT = C.MG_EV_ACCEPT
	EV_CONNECT = C.MG_EV_CONNECT
	EV_CLOSE = C.MG_EV_CLOSE
	EV_TIMER = C.MG_EV_TIMER
	EV_RECV = C.MG_EV_RECV
	EV_SEND = C.MG_EV_SEND
	EV_HTTP_REQUEST = C.MG_EV_HTTP_REQUEST
	EV_HTTP_REPLY = C.MG_EV_HTTP_REPLY
)

[typedef] // nothing happend
struct C.mbuf {
}

// type mg_connection1 C.mg_connection
[typedef]
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
	p byteptr
	len C.size_t
}

pub struct Mgr {
	cobjmem [100]byte
mut:
	cobj &C.mg_mgr
}

const (gmgr = &Mgr{} )
fn init() {
	mut mgr := gmgr
	mgr.cobj = mgr.cobjmem as &C.mg_mgr
	C.mg_mgr_init(mgr.cobj, 0)
}

pub struct Conn {
mut:
	cobj &C.mg_connection
}

pub fn (c &Conn) set_protocol_http_websocket() { C.mg_set_protocol_http_websocket(c.cobj) }

pub fn serve() {
	for { C.mg_mgr_poll(gmgr.cobj, 1000) }
}
pub fn listen(address string) &Conn {
	clsn := C.mg_bind(gmgr.cobj, '9999'.str, ev_handler)
	c := &Conn{clsn}
	c.set_protocol_http_websocket()
	return c
}

fn ev_handler(nc *C.mg_connection, ev int, ev_data voidptr) {
	buf := &nc.recv_mbuf
	match ev {
		/* Event handler code that defines behavior of the connection */
		EV_ACCEPT {
			xlog.info('accept $ev')
		}
		EV_RECV {
			xlog.info('recv $ev')
		}
		EV_SEND {
			xlog.info('send $ev')
		}
		EV_CLOSE {
			xlog.info('close $ev')
		}
		EV_HTTP_REQUEST {
			xlog.info('httpreq $ev')
			hm := ev_data as &C.http_message
			xlog.info('httpreq $ev $hm.method.p')
		}
		EV_HTTP_REPLY {
			xlog.info('httprsp $ev')
		}
		else{
			xlog.info('not handled $ev')
		}
	}
}
