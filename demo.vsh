
import mkuse.inotify

import vcp

fn onevent(ev inotify.Event, cbval voidptr) {
    vcp.info(inotify.evtname(int(ev.mask)), ev.isdir(), ev.name, ev.orig, cbval)
}

ino := inotify.new()
ino.set_onevent(onevent, ino)

ino.add_watch("/tmp", inotifyv.all_events)

vcp.info('runloop...')
ino.run()
