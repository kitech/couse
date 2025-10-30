module mpvut

import time

fn test_1() {}

fn test_2() {
    sockpath := '/tmp/xpimgr-playwhendl.socket'
    cder := new(typ:.uds, path:sockpath)
    cder.pause()
    cder.get_version()
    cder.client_name()
    cder.pause()
    time.sleep(3*time.second)
    cder.resume()
    cder.get_property(.filename)
    cder.get_property(.file_size)
    cder.get_property(.media_title)
    cder.get_property(.pid)
    cder.set_property(.title, "wowwwowowow")
    cder.set_title("hahahahahhaha ${@FILE_LINE}")
    println(cder.title())
}
