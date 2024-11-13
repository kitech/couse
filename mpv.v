module mpv

#flag -lmpv -Dvcpmpv_lmpv

#include <mpv/client.h>

fn C.mpv_client_api_version() usize
fn C.mpv_error_string(int) charptr
fn C.mpv_free(voidptr)
fn C.mpv_create() voidptr
fn C.mpv_initialize(voidptr) int
fn C.mpv_destroy(voidptr)
fn C.mpv_terminate_destroy(voidptr)
fn C.mpv_set_option(voidptr, charptr, int, voidptr) int
fn C.mpv_set_option_string(voidptr, charptr, voidptr) int
fn C.mpv_command(voidptr, &charptr) int
fn C.mpv_command_string(voidptr, charptr) int
fn C.mpv_event_name(int) charptr
fn C.mpv_wait_event(voidptr, f64) voidptr
fn C.mpv_wakeup(voidptr) 
fn C.mpv_set_wakeup_callback(voidptr, voidptr, voidptr)


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

// some options
// --player-operation-mode=pseudo-gui cmdline show window, or pure command line output
//