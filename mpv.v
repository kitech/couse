module mpv

#flag -lmpv -Dvcpmpv_lmpv

#include <mpv/client.h>

fn C.mpv_client_api_version() usize
fn C.mpv_error_string(int) charptr
fn C.mpv_free(voidptr)
fn C.mpv_create() voidptr
fn C.mpv_initialize(voidptr) cint
fn C.mpv_destroy(voidptr)
fn C.mpv_terminate_destroy(voidptr)
fn C.mpv_set_option(voidptr, charptr, cint, voidptr) cint
fn C.mpv_set_option_string(voidptr, charptr, voidptr) cint
fn C.mpv_command(voidptr, &charptr) cint
fn C.mpv_command_string(voidptr, charptr) cint
fn C.mpv_command_async(voidptr, u64, &charptr) cint
fn C.mpv_event_name(cint) charptr
fn C.mpv_wait_event(voidptr, f64) voidptr
fn C.mpv_wakeup(voidptr) 
fn C.mpv_set_wakeup_callback(voidptr, voidptr, voidptr)
// fn C.mpv_request_event(mpv_handle *ctx, mpv_event_id event, int enable)
fn C.mpv_request_event(... voidptr) cint
// MPV_EXPORT int mpv_request_log_messages(mpv_handle *ctx, const char *min_level);
fn C.mpv_request_log_messages(... voidptr) cint

fn init() {
	vo := Event{}
	co := C.mpv_event{}
	assert sizeof(vo)==sizeof(co), "C/V struct size not match"
}

@[typedef]
struct C.mpv_event{}

pub struct Event {
pub mut:
	event_id cint
	error cint
	reply_userdata u64
	data voidptr
    // mpv_event_id event_id;
    // int error;
    // uint64_t reply_userdata;
    // void *data;
}

pub struct EventLogMessage {
	pub:
	prefix charptr
	level charptr
	text charptr
	log_level cint
    // const char *prefix;
    // const char *level;
    // const char *text;
    // mpv_log_level log_level;
}

// some options
// --player-operation-mode=pseudo-gui cmdline show window, or pure command line output
//