module ffi

import log

// error: Cannot find "libffi" pkgconfig file
// #pkgconfig libffi
#flag -lffi
#flag -I@VMODROOT/
#flag @VMODROOT/ffiv.o
#flag darwin -I/Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk/usr/include/ffi
// #flag darwin -I/nix/store/f6z7lsax5dzdn60m1xsxsm9l0hlcmjkq-libffi-3.4.6-dev/include/
#include "ffiv.h"
#include "ffi.h"

pub const default_abi = C.FFI_DEFAULT_ABI

pub const ok = C.FFI_OK
pub const bad_typedef = C.FFI_BAD_TYPEDEF
pub const bad_abi = C.FFI_BAD_ABI

pub const ctype_void       = C.FFI_TYPE_VOID
pub const ctype_int        = C.FFI_TYPE_INT
pub const ctype_float      = C.FFI_TYPE_FLOAT
pub const ctype_double     = C.FFI_TYPE_DOUBLE		//#if 1               =
pub const ctype_longdouble = C.FFI_TYPE_LONGDOUBLE
 //#else               =
 //FFI_TYPE_LONGDOUBLE = FFI_TYPE_DOUBLE
 //#endif              =
pub const ctype_uint8      = C.FFI_TYPE_UINT8
pub const ctype_sint8      = C.FFI_TYPE_SINT8
pub const ctype_uint16     = C.FFI_TYPE_UINT16
pub const ctype_sint16     = C.FFI_TYPE_SINT16
pub const ctype_uint32     = C.FFI_TYPE_UINT32
pub const ctype_sint32     = C.FFI_TYPE_SINT32
pub const ctype_uint64     = C.FFI_TYPE_UINT64
pub const ctype_sint64     = C.FFI_TYPE_SINT64
pub const ctype_struct     = C.FFI_TYPE_STRUCT
pub const ctype_pointer    = C.FFI_TYPE_POINTER
pub const ctype_complex    = C.FFI_TYPE_COMPLEX
// pub const FFI_TYPE_LAST       FFI_TYPE_COMPLEX


// type: &int

pub const    type_void    = &C.ffi_type_void
pub const    type_uint8   = &C.ffi_type_uint8
pub const    type_sint8   = &C.ffi_type_sint8
pub const    type_uint16  = &C.ffi_type_uint16
pub const    type_sint16  = &C.ffi_type_sint16
pub const    type_uint32  = &C.ffi_type_uint32
pub const    type_sint32  = &C.ffi_type_sint32
pub const    type_uint64  = &C.ffi_type_uint64
pub const    type_sint64  = &C.ffi_type_sint64
pub const    type_float   = &C.ffi_type_float
pub const    type_double  = &C.ffi_type_double
pub const    type_pointer = &C.ffi_type_pointer
pub const	type_int = $if x64 || amd64 || arm64 { type_sint64 } $else { type_sint32}
pub const	type_uint = $if x64 || amd64 || arm64 { type_uint64 } $else { type_uint32}


@[typedef]
struct C.ffi_type {}

pub type Type = C.ffi_type
// pub type Type = voidptr
fn C.ffi_get_type_obj(int) &C.ffi_type
//@[deprecated]
fn get_type_obj(ty int) voidptr { return voidptr(C.ffi_get_type_obj(ty)) }

pub fn get_type_obj2(ty int) &Type {
    // mut tyobj := &Type{}
	// mut tyobj := &int{}
	mut tyobj := voidptr(0)

    match ty {
		ctype_void { tyobj = type_void }
		ctype_int { tyobj = type_sint32 }
		ctype_sint16 { tyobj = type_sint16 }
		ctype_uint16 { tyobj = type_uint16 }
		ctype_sint64 { tyobj = type_sint64 }
		ctype_uint64 { tyobj = type_uint64 }
		ctype_float { tyobj = type_float }
		ctype_double { tyobj = type_double }
		ctype_pointer { tyobj = type_pointer }

        else { panic("not impled ${ty}") }
    }

    return tyobj
}
pub fn get_type_obj3(ty int) voidptr {
	vx := get_type_obj2(ty)
	return voidptr(vx)
}

@[typedef]
pub struct C.ffi_cif {}
pub type Cif = C.ffi_cif

fn C.ffi_prep_cif(&Cif, voidptr, int, voidptr, voidptr) int

pub fn prep_cif(cif &Cif, abi int, rtype &Type) int {
    ret := C.ffi_prep_cif(cif, abi, 0, rtype, 0)
    return ret
}
pub fn prep_cif2(cif &Cif, abi int, rtype &int) int {
    ret := C.ffi_prep_cif(cif, abi, 0, rtype, 0)
    return ret
}
pub fn prep_cif0(cif &Cif, rtype &int, atypes []&int) int {
	// log.info("${@LOCATION}, ${rtype}, ${atypes.len}")
    ret := C.ffi_prep_cif(cif, default_abi, atypes.len, rtype, atypes.data)
    return ret
}

fn C.ffi_call(&Cif, voidptr, &u64, voidptr)

pub fn call(cif &Cif, f voidptr /*fn()*/, rvalue voidptr, avalues []voidptr) voidptr {
    // mut rvalue := u64(0)
    C.ffi_call(cif, f, rvalue, avalues.data)
	return voidptr(rvalue)
}

fn atypes2obj(atypes []int) []&Type {
    mut res := []&Type{}
    for atype in atypes {
        o := get_type_obj2(atype)
        res << o
    }
    return res
}

fn getarray_elemaddr<T>(val []T, n int) voidptr {
	return voidptr(usize(val.data)+sizeof(T))
}

pub fn callfca6<T>(sym voidptr, args...Any) T {
	mut argctys := [9]int{}
	mut argotys := [9]&int{}
	mut argvals := [9]voidptr{}

	for i, arg in args {
		mut fficty := 0
		mut ffioty := unsafe{&int(vnil)}
		mut argadr := vnil

		match arg {
			f32 { fficty = ctype_float;
				ffioty = type_float;
				argadr = voidptr(&arg)
			}
			f64 { fficty = ctype_double;
				ffioty = type_double;
				argadr = voidptr(&arg)
			}
			int { fficty = ctype_int;
				ffioty = type_int;
				argadr = voidptr(&arg)
			}
			usize { fficty = ctype_pointer;
				ffioty = type_pointer;
				argadr = voidptr(&arg)
			}
			i64 { fficty = ctype_sint64;
				ffioty = type_sint64;
				argadr = voidptr(&arg)
			}
			u64 { fficty = ctype_uint64;
				ffioty = type_uint64;
				argadr = voidptr(&arg)
			}
			u32 { fficty = ctype_sint32;
				ffioty = type_uint32;
				argadr = voidptr(&arg)
			}
			i16 { fficty = ctype_int;
				ffioty = type_int;
				argadr = voidptr(&arg)
			}
			i8 { fficty = ctype_int;
				ffioty = type_int;
				argadr = voidptr(&arg)
			}
			// C 中没有bool类型，是整数类型，所以对C函数应该可能。
			// 但是对V的bool并不适用。需要V打开开关-d 4bytebool。
			bool { fficty = ctype_int;
				ffioty = type_int;
				argadr = voidptr(&arg)
			}
			voidptr { fficty = ctype_pointer;
				ffioty = type_pointer;
				argadr = voidptr(&arg)
				}
			charptr {fficty = ctype_pointer;
				ffioty = type_pointer;
				argadr = voidptr(&arg)
				}
			byteptr {fficty = ctype_pointer;
				ffioty = type_pointer;
				argadr = voidptr(&arg)
				}
			string { fficty = ctype_pointer;
				ffioty = type_pointer;
				argadr = voidptr(&arg.str)
				}
			else {
				log.warn("${@LOCATION} not support a${i} ${arg}")
			}
		}
		argctys[i] = fficty
		argotys[i] = ffioty
		argvals[i] = argadr
	}

	///
	retoty :=
	match typeof[T]().idx {
		typeof[f64]().idx {type_double}
		typeof[f32]().idx {type_float}
		-1 {type_pointer}
		else{type_pointer}
	}

	cif := Cif{}
	stv := prep_cif0(&cif, retoty, argotys[..args.len])
	assert stv == ok

	retval := Cif{}
	assert sizeof(retval)>=16
	rv := call(&cif, sym, &retval, argvals[..args.len])
	// assert rv == &retval
	if true {
		return *(&T(rv))
	}
	return T{}
}

