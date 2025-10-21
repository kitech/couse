import time
import rand
import couse.libnotify

fn main() {
	denotify_demo(vnil)
}

// every ~5s send a notification and loop forever
fn denotify_demo(argx voidptr) {
	mut bigstr := ''
	mut nty := xlibv.newnotify(8000)
	for i := 0;; i ++ {
		if bigstr.len > 56000{
			bigstr = 'x'.repeat(rand.int()%1000+1)
		}else{
			bigstr += 'y'.repeat(rand.int()%3000+1)
		}
		if i % 100 == 0 {
			s1 := 'aaa啊 $i'.repeat(8)
			s2 := 'bbb 哦 $i'.repeat(8)
			s3 := 'ccc $i'.repeat(8)
			if rand.int()%2 == 1 {
				nty.replace(s1, s2, s3, 8000)
			}else{
				nty.add(s1, s2, s3, 8000)
			}
		}
		time.sleep(55*time.millisecond)
	}
}
