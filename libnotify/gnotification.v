module xlibv

// seems gnotification is successor of libnotify

import time

#flag -lgio-2.0
// #include "gio/gnotification.h"
#include "gio/gio.h"

fn C.g_notification_new(title byteptr) voidptr
fn C.g_notification_set_title(voidptr, byteptr)
fn C.g_notification_set_body(voidptr, byteptr)
fn C.g_notification_set_icon(voidptr, byteptr)
fn C.g_notification_set_urgent(voidptr, byte)
fn C.g_notification_set_priority(voidptr, int)
fn C.g_notification_add_button(voidptr, byteptr, byteptr)
fn C.g_notification_set_default_action(voidptr, byteptr)
fn C.g_notification_set_default_action_and_target_value(voidptr, byteptr, byteptr)

struct Gnotification {
mut:
	notion voidptr
	ctime time.Time
	timeoutms int
	title string
	body string
	icon string
	urgent bool
}
fn new_gnotification() &Gnotification{
	mut nter := &Gnotification{}
	nter.ctime = time.now()
	return nter
}
fn (nter mut Gnotification) set_timeout(timeoutms int) {
	nter.timeoutms = timeoutms
}
fn (nter mut Gnotification) set_title(title string) {
	nter.title = title
}
fn (nter mut Gnotification) set_body(body string) {
	nter.body = body
}
fn (nter mut Gnotification) set_icon(icon string) {
	nter.icon = icon
}
fn (nter mut Gnotification) close() {
	nter.notion = 0
}

pub struct Gnotify {
mut:
	nters []u64
	timeoutms int
}

pub fn newgnotify(timeoutms int) &Gnotify {
	mut nty := &Gnotify{}
	nty.timeoutms = timeoutms
	return nty
}

pub fn (nty mut Gnotify) add(summary string, body string, icon string, timeoutms int) {
	mut nter := new_gnotification()
	nty.nters << u64(nter)
	nter.set_timeout(timeoutms)
	nter.set_title(summary)
	nter.set_body(body)
	nter.set_icon(icon)

	nty.clear_expires()
}

pub fn (nty mut Gnotify) replace(summary string, body string, icon string, timeoutms int) {
	if nty.nters.len <= 0 {
		nty.add(summary, body, icon, timeoutms)
		return
	}
	nterx := nty.nters[nty.nters.len-1]
	mut nter := (*Gnotification)(nterx)
	nter.set_title(summary)
	nter.set_body(body)
	nter.set_icon(icon)

	nty.clear_expires()
}

fn (nty mut Gnotify) clear_expires() {
	if false {
		nty.timeoutms = nty.timeoutms
	}
	n := nty.nters.len
	println('totn=$n')
	nowt := time.now()

	mut news := []u64
	for nterx in nty.nters {
		mut nter := (*Gnotification)(nterx)
		if nowt.uni - nter.ctime.uni > 2*nter.timeoutms/1000 {
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
		println('deln=$deln')
		olds.free()
	}else{
		news.free()
	}
}


