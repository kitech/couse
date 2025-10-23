module ffi
import log
import dl

fn foocc1(a0 int, a1 voidptr, a3 int, a2 charptr, a4 int, a5 int) int {
	log.info("${a0},${a1},${a3},${a4},${a5},${a2}")
	assert tosbca(a2) == "a222"
	return a0 + a3
}
fn foocc2(a0 f32, a1 f64) f32 {
	log.info("${a0}, ${a1}")
	return f32(f64(a0)*a1)
}
fn foocc3(a0 usize, a1 voidptr) voidptr {
	log.info("${a0}, ${a1}")
	return voidptr(a0+usize(a1))
}

fn test_t1() {
	mut fnsym := dl.sym(C.RTLD_DEFAULT, "ffi__foocc1")
	fnsym = voidptr(&foocc1)
	v1 := callfca6[int](fnsym, 123, 8, 7, "a222", true, 5)
	assert v1 == 123 + 7

	fnsym = voidptr(&foocc2)
	v2 := callfca6[f32](fnsym, f32(12.3), f64(8))
	log.info("${v2}")
	assert v2 == f32(12.3)*f64(8)

	fnsym = voidptr(&foocc3)
	v3 := callfca6[voidptr](fnsym, usize(12), voidptr(8))
	log.info("${v3}")
	assert v3 == voidptr(12+8)

	// assert 123 == 321
}