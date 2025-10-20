module inotify

import os
import log
import net
// import mkuse.vpp.xnet
// import mkuse.vpp.xlog
// import cxrt.coronav

#include <sys/inotify.h>
#include <unistd.h>

// fn C.read(int, voidptr, int) int
// fn C.close(int)
fn C.inotify_init() int
fn C.inotify_init1(flags int) int
fn C.inotify_add_watch(int, charptr, int) int
fn C.inotify_rm_watch(int, int) int

// not working?

pub enum Evty {
	access		 = C.IN_ACCESS
	modify		 = C.IN_MODIFY
	attrib		 = C.IN_ATTRIB
	close_write	 = C.IN_CLOSE_WRITE
	close_nowrite = C.IN_CLOSE_NOWRITE
	close		 = C.IN_CLOSE
	open		 = C.IN_OPEN
	moved_from	 = C.IN_MOVED_FROM
	moved_to	 = C.IN_MOVED_TO
	move		 = C.IN_MOVE
	create		 = C.IN_CREATE
	delete		 = C.IN_DELETE
	delete_self	 = C.IN_DELETE_SELF
	move_self	 = C.IN_MOVE_SELF
	ignored      = C.IN_IGNORED

	isdir        = C.IN_ISDIR

	all_events   = C.IN_ALL_EVENTS

	nonblock     = C.IN_NONBLOCK
	cloexec      = C.IN_CLOEXEC
}

pub const (
	access		 = C.IN_ACCESS
	modify		 = C.IN_MODIFY
	attrib		 = C.IN_ATTRIB
	close_write	 = C.IN_CLOSE_WRITE
	close_nowrite = C.IN_CLOSE_NOWRITE
	close		 = C.IN_CLOSE
	open		 = C.IN_OPEN
	moved_from	 = C.IN_MOVED_FROM
	moved_to	 = C.IN_MOVED_TO
	move		 = C.IN_MOVE
	create		 = C.IN_CREATE
	delete		 = C.IN_DELETE
	delete_self	 = C.IN_DELETE_SELF
	move_self	 = C.IN_MOVE_SELF
	ignored      = C.IN_IGNORED

	isdir        = C.IN_ISDIR

	all_events   = C.IN_ALL_EVENTS

	nonblock     = C.IN_NONBLOCK
	cloexec      = C.IN_CLOEXEC

)

pub const (
	mkdir_mask = create | isdir
	rmdir_mask = delete | isdir
)
const (
	// evtnames = map[int]string{}
)

pub type EvnoType = int | u32
pub fn evtname(evtno EvnoType) string {
    eno := match evtno { u32 { int(evtno) } int { evtno } }
	match eno {
		access        { return 'ACCESS' }
		modify		  { return 'MODIFY' }
		attrib		  { return 'ATTRIB' }
		close_write	  { return 'CLOSE_WRITE' }
		close_nowrite { return 'CLOSE_NOWRITE' }
		close		  { return 'CLOSE' }
		open		  { return 'OPEN' }
		moved_from	  { return 'MOVED_FROM' }
		moved_to	  { return 'MOVED_TO' }
		move		  { return 'MOVE' }
		create		  { return 'CREATE' }
		delete		  { return 'DELETE' }
		delete_self	  { return 'DELETE_SELF' }
		move_self	  { return 'MOVE_SELF' }
		ignored       { return 'IGNORED' }
		isdir         { return 'ISDIR' }
		else{ return 'unknown-evty-0x' + eno.hex() }
	}
}
pub fn maskname(mask u32) string {
	mut arr := []string
	for i := u32(1) ; i <= isdir; i*=2 {
		andval := i & mask
		if andval > 0 {
			name := evtname(int(i))
			// println('i=$i, mask=$mask, andval=$andval name=$name')
			arr << name
		}
	}
	return arr.join(' | ')
}

pub struct Inotify {
mut:
	eventcb fn(evt Event, cbval voidptr) = vnil
	cbval voidptr
	infd int
	watchs map[string]int // path => watch fd
	watchs2 map[int]string // watch fd => path
	useit int
	closed bool
}

type EventRaw = C.inotify_event 
struct C.inotify_event {
pub mut:
	wd int
	mask u32
	cookie u32
	len u32
	name charptr
}
struct Evhead {
    pub mut:
    wd int
	mask u32
	cookie u32
	len u32
	// name charptr
}

pub struct Event {
pub mut:
	orig string
	name string
	mask u32
}

pub fn (e Event) isdir() bool { return int(e.mask) & isdir > 0 }

pub fn new() &Inotify {
	mut this := &Inotify{}
	usecorona := false
	if usecorona {
		this.infd = C.inotify_init1(nonblock|cloexec)
	}else{
		this.infd = C.inotify_init1(0)
	}
	return this
}

// onevent must not blocking, more quick more better
pub fn (this mut Inotify) set_onevent(onevent fn(Event, voidptr), cbval voidptr) {
	this.eventcb = onevent
	this.cbval = cbval
}

const evthdrlen = sizeof(Evhead) // 16 // sizeof(C.int)+sizeof(u32)*3

pub fn (this mut Inotify) run() {
	// fix corona
	// xnet.fd_set_nonblocking(this.fd, true)
	// coronav.add_custom_fd(this.fd)

	c99 {
	    // 16
	    // printf("sizeof(struct inotify_event)=%d\n", sizeof(struct inotify_event));
	}
	
	buflen := 4096 // max path len
	evhdr := &Evhead{}
	buf := charptr(malloc(buflen))
	mut ev0 := Event{}
	
	for cnter :=0 ; ; cnter++ {	
		rn1 := C.read(this.infd, buf, buflen)
		if rn1 == -1 {
		    errmsg := tos3(byteptr(C.strerror(C.errno)))
		    log.info('rn1=$rn1, errno=${C.errno}, evlen=$evhdr.len, errmsg=$errmsg')
			if errmsg.len == 0 { return }
		}
		
		mut ev := &EventRaw(vnil)
		for pos := 0;  pos < rn1 && pos < buflen; pos += int(sizeof(Evhead) + ev.len) {
		    ev = &EventRaw(voidptr(&buf[pos]))
			evty := evtname( int(ev.mask))
			ev0.mask = ev.mask
			ev0.name = tos3(ev.name)
			ev0.orig = this.watchs2[ev.wd]
			if this.eventcb != vnil {
			    this.eventcb(ev0, this.cbval)
			}else{
			    log.info("${pos}, ${evty}, ${ev.len}, ${tos3(ev.name)}")			
			}
		}		
	}
}

@[deprecated]
fn (this &Inotify) read_next(buf byteptr) &EventRaw{
    buf2 := [4096]i8{}
    evhdr := &Evhead{}
    
    // read event head
    log.info("reading event header...")
    rv := C.read(this.infd, evhdr, sizeof(Evhead))
    log.info("$rv, len=${evhdr.len}")
    rv = C.read(this.infd, buf2, evhdr.len)
    log.info("$rv=strlen")
    
	// mut evt := &EventRaw{}
	// C.memcpy(evt, buf, evthdrlen)
	// if int(evt.len) > 0 {
		// evt.name = memdup(buf+evthdrlen, int(evt.len))
	// }else{
		// xlog.warn('wtf $evt.len')
		// println(*evt)
	// }
	// return evt
	return vnil
}

fn (this mut Inotify) raw2v(evt &EventRaw) &Event {
	this.useit = 1
	mut e := &Event{}
	if evt.name != 0 {
		e.name = tos_clone(evt.name)
	}
	e.mask = evt.mask
	e.orig = this.watchs2[evt.wd]
	return e
}

pub fn (this mut Inotify) close() {
	fd := this.infd
	this.infd = -1
	C.close(fd)
}

pub fn (this mut Inotify) add_watch(name string, mask int) bool {
	if name in this.watchs {
		return true
	}

	mut mask2 := mask
	mask2 = C.IN_MODIFY | C.IN_CLOSE_WRITE | C.IN_CREATE | C.IN_MOVE | C.IN_DELETE

	// xlog.info('try watch $name ...')
	wd := C.inotify_add_watch(this.infd, name.str, mask2)
	if wd == -1 {
	    println(tos3(C.strerror(C.errno)) + ' ' + name)
		// xlog.warn(tos3(C.strerror(C.errno)) + ' ' + name)
		return false
	}
	this.watchs[name] = wd
	this.watchs2[wd] = name
	// xlog.info('watched $name -> $wd')
	return true
}
pub fn (this mut Inotify) add_watch_recursive(name string, mask int) int {
	this.useit++
	mut dirs := map[string]int
	dirs[name] = 1

	mut addcnt := 0
	for {
		mut curdir := ''
		for k,v in dirs {
			curdir = k
			break
		}
		if curdir == '' {break}
		dirs.delete(curdir)
		addcnt ++
		this.add_watch(curdir, 0)

		files := os.ls(curdir) or { panic(err.str() + ' ' + curdir) }
		for file in files {
			tmpdir := curdir+'/'+file
			if file.starts_with('.') || file.starts_with('..') { continue }
			if !os.is_dir(tmpdir) { continue }
			dirs[tmpdir] = 1
		}
	}
	return addcnt
}

pub fn (this mut Inotify) rm_watch(name string) bool {
	if name !in this.watchs { return true }
	wd := this.watchs[name]
	rv := C.inotify_rm_watch(this.infd, wd)
	this.watchs.delete(name)
	this.watchs2.delete(wd)
	// xlog.warn('watch rmed $rv $name -> $wd')
	return true
}
