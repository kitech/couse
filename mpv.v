module mpv

import vcp

#flag -lmpv -Dvcpmpv_lmpv

#include <mpv/client.h>

//////////
pub fn command_async(h voidptr, cmdno u64, args ...string) int {
	mut argv := []charptr{len: args.len + 1}
	for idx, arg in args {
		argv[idx] = arg.str
	}
	rv := C.mpv_command_async(h, 12345, argv.data)
	return rv
}

pub fn event_name0(evid cint) charptr {
	return C.mpv_event_name(evid)
}

pub fn event_name(evid cint) string {
	return tosbca(C.mpv_event_name(evid))
}

pub fn set_property_string(h voidptr, name string, data string) int {
	vcp.info(h, name, data)
	rv := C.mpv_set_property_string(h, name.str, data.str)
	return rv
}

pub fn set_property(h voidptr, name string, valx Anyer) int {
	val := castptr[Itfacein](&valx)
	data := val.ptr
	mut fmt := 0
	match valx {
		bool {
			fmt = format_flag
		}
		string {
			fmt = format_string
			data = derefvar[string](val.ptr).str
		}
		else {
			vcp.info('nocat', h, name)
		}
	}
	rv := C.mpv_set_property(h, name.str, fmt, data)
	return rv
}

pub fn get_property[T](h voidptr, name string) T {
	mut fmt := format_none
	$if T is bool {
		fmt = format_flag
	} $else $if T is string {
		fmt = format_string
		// data = derefvar[string](val.ptr).str
		if true {
			// zval := [128]i8{}
			zval := charptr(0)
			rv := C.mpv_get_property(h, name.str, fmt, &zval)
			s := tosbca(charptr(zval)).clone()
			// vcp.info(name, s)
			C.mpv_free(zval)
			return s
		}
	} $else $if T is i64 {
		fmt = format_int64
	} $else {
		vcp.info('nocat', h, name)
	}
	zval := zeroof[T]()
	rv := C.mpv_get_property(h, name.str, fmt, &zval)
	return zval
}

pub fn propfmt_fromtmpl[T]() cint {
	mut fmt := format_none
	$if T is bool {
		fmt = format_flag
	} $else $if T is string {
		fmt = format_string
		// data = derefvar[string](val.ptr).str
	} $else $if T is i64 {
		fmt = format_int64
	} $else {
		vcp.info('nocat', h, name)
	}
	return fmt
}

pub fn observe_property[T](h voidptr, name string) int {
	fmt := propfmt_fromtmpl[T]()
	rv := C.mpv_observe_property(h, 12345, name.str, fmt)
	return rv
}

//////////

fn C.mpv_client_api_version() usize
fn C.mpv_error_string(int) charptr
fn C.mpv_free(voidptr)
fn C.mpv_create() voidptr
fn C.mpv_initialize(voidptr) cint
fn C.mpv_destroy(voidptr)
fn C.mpv_terminate_destroy(voidptr)
fn C.mpv_create_client(voidptr, charptr) voidptr
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
fn C.mpv_request_event(...voidptr) cint

fn C.mpv_set_property(...voidptr) cint
fn C.mpv_set_property_string(...voidptr) cint
fn C.mpv_get_property(...voidptr) cint
fn C.mpv_get_property_string(...voidptr) charptr
fn C.mpv_observe_property(...voidptr) cint
fn C.mpv_unobserve_property(...voidptr) cint

// MPV_EXPORT int mpv_request_log_messages(mpv_handle *ctx, const char *min_level);
fn C.mpv_request_log_messages(...voidptr) cint
fn C.mpv_client_name(voidptr) charptr
fn C.mpv_client_id(voidptr) i64

fn init() {
	vo := Event{}
	co := C.mpv_event{}
	assert sizeof(vo) == sizeof(co), 'C/V struct size not match'
	assert sizeofx[Event]() == sizeof[C.mpv_event](), 'C/V struct size not match'
}

@[typedef]
struct C.mpv_event {}

pub struct Event {
pub mut:
	event_id       cint
	error          cint
	reply_userdata u64
	data           voidptr
	// mpv_event_id event_id;
	// int error;
	// uint64_t reply_userdata;
	// void *data;
}

pub struct EventLogMessage {
pub:
	prefix    charptr
	level     charptr
	text      charptr
	log_level cint
	// const char *prefix;
	// const char *level;
	// const char *text;
	// mpv_log_level log_level;
}

pub union NodeValue {
	str    charptr
	flag   cint
	i64val i64
	f64val f64
	list   voidptr
	ba     voidptr
}

pub struct Node {
pub:
	u      NodeValue
	format cint
}

pub enum Eventy {
	// none = int(C.MPV_EVENT_NONE)	
	NONE               = int(C.MPV_EVENT_NONE)               // = 0
	SHUTDOWN           = int(C.MPV_EVENT_SHUTDOWN)           //          = 1,
	LOG_MESSAGE        = int(C.MPV_EVENT_LOG_MESSAGE)        //       = 2,
	GET_PROPERTY_REPLY = int(C.MPV_EVENT_GET_PROPERTY_REPLY) // = 3,
	SET_PROPERTY_REPLY = int(C.MPV_EVENT_SET_PROPERTY_REPLY) //  = 4,
	COMMAND_REPLAY     = int(C.MPV_EVENT_COMMAND_REPLY)      //   = 5,
	START_FILE         = int(C.MPV_EVENT_START_FILE)         //   = 6,
	END_FILE           = int(C.MPV_EVENT_END_FILE)           //   = 7,
	FILE_LOADED        = int(C.MPV_EVENT_FILE_LOADED)        //   = 8,
	IDLE               = int(C.MPV_EVENT_IDLE)               //   = 11,
	TICK               = int(C.MPV_EVENT_TICK)               //   = 14,
	CLIENT_MESSAGE     = int(C.MPV_EVENT_CLIENT_MESSAGE)     //   = 16,
	VIDEO_RECONFIG     = int(C.MPV_EVENT_VIDEO_RECONFIG)     //   = 17,
	AUDIO_RECONFIG     = int(C.MPV_EVENT_AUDIO_RECONFIG)     //   = 18,
	SEEK               = int(C.MPV_EVENT_SEEK)               //   = 20,
	PLAYBACK_RESTART   = int(C.MPV_EVENT_PLAYBACK_RESTART)   //   = 21,
	PROPERTY_CHANGE    = int(C.MPV_EVENT_PROPERTY_CHANGE)    //   = 22,
	QUEUE_OVERFLOW     = int(C.MPV_EVENT_QUEUE_OVERFLOW)     //   = 24,
	HOOK               = int(C.MPV_EVENT_HOOK)               //   = 25,
}

pub const EVENT_NONE = int(C.MPV_EVENT_NONE) // = 0
pub const EVENT_SHUTDOWN = int(C.MPV_EVENT_SHUTDOWN) //          = 1,
pub const EVENT_LOG_MESSAGE = int(C.MPV_EVENT_LOG_MESSAGE) //       = 2,
pub const EVENT_GET_PROPERTY_REPLY = int(C.MPV_EVENT_GET_PROPERTY_REPLY) // = 3,
pub const EVENT_SET_PROPERTY_REPLY = int(C.MPV_EVENT_SET_PROPERTY_REPLY) //  = 4,
pub const EVENT_COMMAND_REPLAY = int(C.MPV_EVENT_COMMAND_REPLY) //   = 5,
pub const EVENT_START_FILE = int(C.MPV_EVENT_START_FILE) //   = 6,
pub const EVENT_END_FILE = int(C.MPV_EVENT_END_FILE) //   = 7,
pub const EVENT_FILE_LOADED = int(C.MPV_EVENT_FILE_LOADED) //   = 8,
pub const EVENT_IDLE = int(C.MPV_EVENT_IDLE) //   = 11,
pub const EVENT_TICK = int(C.MPV_EVENT_TICK) //   = 14,
pub const EVENT_CLIENT_MESSAGE = int(C.MPV_EVENT_CLIENT_MESSAGE) //   = 16,
pub const EVENT_VIDEO_RECONFIG = int(C.MPV_EVENT_VIDEO_RECONFIG) //   = 17,
pub const EVENT_AUDIO_RECONFIG = int(C.MPV_EVENT_AUDIO_RECONFIG) //   = 18,
pub const EVENT_SEEK = int(C.MPV_EVENT_SEEK) //   = 20,
pub const EVENT_PLAYBACK_RESTART = int(C.MPV_EVENT_PLAYBACK_RESTART) //   = 21,
pub const EVENT_PROPERTY_CHANGE = int(C.MPV_EVENT_PROPERTY_CHANGE) //   = 22,
pub const EVENT_QUEUE_OVERFLOW = int(C.MPV_EVENT_QUEUE_OVERFLOW) //   = 24,
pub const EVENT_HOOK = int(C.MPV_EVENT_HOOK) //   = 25,

pub enum Formaty {
	none       = C.MPV_FORMAT_NONE       //  = 0,
	string     = C.MPV_FORMAT_STRING     //     = 1,
	osd_string = C.MPV_FORMAT_OSD_STRING //      = 2,
	flag       = C.MPV_FORMAT_FLAG       // = 3,
	int64      = C.MPV_FORMAT_INT64      //     = 4,
	double     = C.MPV_FORMAT_DOUBLE     //   = 5,
	node       = C.MPV_FORMAT_NODE       //  = 6,
	node_array = C.MPV_FORMAT_NODE_ARRAY //     = 7,
	node_map   = C.MPV_FORMAT_NODE_MAP   //  = 8,
	byte_array = C.MPV_FORMAT_BYTE_ARRAY //  = 9
}

pub const format_none = C.MPV_FORMAT_NONE //  = 0,
pub const format_string = C.MPV_FORMAT_STRING //     = 1,
pub const format_osd_string = C.MPV_FORMAT_OSD_STRING //      = 2,
pub const format_flag = C.MPV_FORMAT_FLAG // = 3,
pub const format_int64 = C.MPV_FORMAT_INT64 //     = 4,
pub const format_double = C.MPV_FORMAT_DOUBLE //   = 5,
pub const format_node = C.MPV_FORMAT_NODE //  = 6,
pub const format_node_array = C.MPV_FORMAT_NODE_ARRAY //     = 7,
pub const format_node_map = C.MPV_FORMAT_NODE_MAP //  = 8,
pub const format_byte_array = C.MPV_FORMAT_BYTE_ARRAY //  = 9

// some options
// --player-operation-mode=pseudo-gui cmdline show window, or pure command line output
// --keep-open=yes --keep-open-pause=false
