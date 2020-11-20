module xlibv

import time
import mkuse.vpp.xlog

#flag -lnotify
#flag -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/gdk-pixbuf-2.0
#include "libnotify/notify.h"
#include "libnotify/notification.h"

fn C.notify_init(app_name byteptr) byte
fn C.notify_uninit()
fn C.notify_is_initted() byte
fn C.notify_get_app_name() byteptr
fn C.notify_set_app_name(byteptr)
fn C.notify_get_server_caps() voidptr
fn C.notify_get_server_info(ret_name &byteptr, ret_vendor &byteptr,
	ret_version &byteptr, ret_spec_version &byteptr) byte


fn C.notify_notification_get_type() int
fn C.notify_notification_new(summary byteptr, body byteptr, icon byteptr) voidptr
fn C.notify_notification_update() byte
fn C.notify_notification_show() byte
fn C.notify_notification_set_timeout()
fn C.notify_notification_set_category()
fn C.notify_notification_set_urgency()
fn C.notify_notification_set_image_from_pixbuf()
fn C.notify_notification_set_hint()
fn C.notify_notification_set_app_name()
fn C.notify_notification_clear_hints()
fn C.notify_notification_add_action()
fn C.notify_notification_clear_actions()
fn C.notify_notification_close(voidptr, voidptr) byte
fn C.notify_notification_get_closed_reason()

fn notify_init(appname string) bool { return C.notify_init(appname.str) == 1 }
fn notify_uninit() { C.notify_uninit() }
fn notify_is_initted() bool { return C.notify_is_initted() == 1 }

/*
usage:
*/

struct Notification {
mut:
	notion voidptr
	summary string
	body string
	icon string
	timeout int
	ctime time.Time
}

fn newnotification() &Notification {
	if notify_is_initted() == 0 { notify_init('xlibvn'.str) }

	mut nty := &Notification{}
	nty.ctime = time.now()
	summary := 'the summary'
	body := 'the body'
	icon := 'the icon'

	ptr := C.notify_notification_new(summary.str, body.str, icon.str)
	nty.notion = ptr
	return nty
}
fn (nty mut Notification) close() bool {
	rv := C.notify_notification_close(nty.notion, 0)
	nty.notion = 0
	return rv == 1
}

fn (nty &Notification) update(summary string, body string, icon string) bool {
	rv := C.notify_notification_update(nty.notion, summary.str, body.str, icon.str)
	return rv == 1
}
fn (nty &Notification) show() bool {
	rv := C.notify_notification_show(nty.notion, 0)
	return rv == 1
}
// timeout in ms
fn (nty mut Notification) set_timeout(timeoutms int) {
	nty.timeout = timeoutms
	C.notify_notification_set_timeout(nty.notion, timeoutms)
}

// 问题
// 需要g_main_loop
// 可能是 相应 fd没有hook到，并且是阻塞的，不能用于corona fiber
pub struct Notify {
mut:
	nters []u64
	timeoutms int
}

pub fn newnotify(timeoutms int) &Notify {
	mut nty := &Notify{}
	nty.timeoutms = timeoutms
	return nty
}

pub fn (nty mut Notify) add(summary string, body string, icon string, timeoutms int) {
	mut nter := newnotification()
	nty.nters << u64(nter)
	nter.set_timeout(timeoutms)
	nter.update(summary, body, icon)
	nter.show()
	nty.clear_expires()
}

pub fn (nty mut Notify) replace(summary string, body string, icon string, timeoutms int) {
	if nty.nters.len <= 0 {
		nty.add(summary, body, icon, timeoutms)
		return
	}
	nterx := nty.nters[nty.nters.len-1]
	mut nter := &Notification{}
    nter = (nterx)
	nter.update(summary, body, icon)
	nter.show()
	nty.clear_expires()
}

fn (nty mut Notify) clear_expires() {
	if false {
		nty.timeoutms = nty.timeoutms
	}
	n := nty.nters.len
	xlog.info('totn=$n')
	nowt := time.now()

	mut news := []u64
	for nterx in nty.nters {
		mut nter := &Notification{}
        nter = (nterx)
		if nowt.unix - nter.ctime.unix > 2*nter.timeout/1000 {
			nter.close()
			free(nter)
		}else{
			news << nterx
		}
	}
	if news.len != nty.nters.len {
		olds := nty.nters
		nty.nters = news
		deln := olds.len - news.len
		xlog.info('deln=$deln')
		olds.free()
	}else{
		news.free()
	}
}

