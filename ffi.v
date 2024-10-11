module ffi

#flag -lffi
// #flag -I@VMODROOT/
#flag darwin -I/nix/store/f6z7lsax5dzdn60m1xsxsm9l0hlcmjkq-libffi-3.4.6-dev/include/
// #flag @VROOT/ffiv.o
// #include "ffiv.h"
#include "ffi.h"

pub const (
	default_abi = C.FFI_DEFAULT_ABI
)
pub const (
	ok = C.FFI_OK
    bad_typedef = C.FFI_BAD_TYPEDEF
    bad_abi = C.FFI_BAD_ABI
)
pub const (
    ctype_void       = C.FFI_TYPE_VOID
    ctype_int        = C.FFI_TYPE_INT
    ctype_float      = C.FFI_TYPE_FLOAT
    ctype_double     = C.FFI_TYPE_DOUBLE
    //#if 1               =
    ctype_longdouble = C.FFI_TYPE_LONGDOUBLE
    //#else               =
    //FFI_TYPE_LONGDOUBLE = FFI_TYPE_DOUBLE
    //#endif              =
    ctype_uint8      = C.FFI_TYPE_UINT8
    ctype_sint8      = C.FFI_TYPE_SINT8
    ctype_uint16     = C.FFI_TYPE_UINT16
    ctype_sint16     = C.FFI_TYPE_SINT16
    ctype_uint32     = C.FFI_TYPE_UINT32
    ctype_sint32     = C.FFI_TYPE_SINT32
    ctype_uint64     = C.FFI_TYPE_UINT64
    ctype_sint64     = C.FFI_TYPE_SINT64
    ctype_struct     = C.FFI_TYPE_STRUCT
    ctype_pointer    = C.FFI_TYPE_POINTER
    ctype_complex    = C.FFI_TYPE_COMPLEX
    // FFI_TYPE_LAST       FFI_TYPE_COMPLEX
)

pub const (
    type_void    = &C.ffi_type_void
    type_uint8   = &C.ffi_type_uint8
    type_sint8   = &C.ffi_type_sint8
    type_uint16  = &C.ffi_type_uint16
    type_sint16  = &C.ffi_type_sint16
    type_uint32  = &C.ffi_type_uint32
    type_sint32  = &C.ffi_type_sint32
    type_uint64  = &C.ffi_type_uint64
    type_sint64  = &C.ffi_type_sint64
    type_float   = &C.ffi_type_float
    type_double  = &C.ffi_type_double
    type_pointer = &C.ffi_type_pointer
	type_int = $if x64 || amd64 || arm64 { type_sint64 } $else { type_sint32}
	type_uint = $if x64 || amd64 || arm64 { type_uint64 } $else { type_uint32}
)

@[typedef]
struct C.ffi_type {}

pub type Type = C.ffi_type
// pub type Type = voidptr
fn C.ffi_get_type_obj() &C.ffi_type
//[deprecated]
//fn get_type_obj(ty int) &Type { return C.ffi_get_type_obj(ty) }
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

@[typedef]
struct C.ffi_cif {}
pub type Cif = C.ffi_cif

fn C.ffi_prep_cif(&Cif, voidptr, int, voidptr, voidptr) int

pub fn prep_cif(cif &Cif, abi int, rtype &Type) int {
    ret := C.ffi_prep_cif(cif, abi, 0, rtype, 0)
    return ret
}

fn C.ffi_call(&Cif, voidptr, &u64, voidptr)

pub fn call(cif &Cif, f voidptr /*fn()*/) {
    mut rvalue := u64(0)
    mut avalues := voidptr(0)
    C.ffi_call(cif, f, &rvalue, avalues)
}

pub fn call2(f fn(), args ...voidptr) u64 {
    cif := &Cif{}
    ret := C.ffi_prep_cif(cif, 0, 0, 0, 0)
    C.ffi_call(cif, f, 0, 0)
    return 0
}

fn atypes2obj(atypes []int) []&Type {
    mut res := []&Type{}
    for atype in atypes {
        o := get_type_obj2(atype)
        res << o
    }
    return res
}

pub fn call3(f voidptr, atypes []int, avalues []voidptr) u64 {
    assert atypes.len == avalues.len

    argc := atypes.len
    rtype := type_pointer
    atypeso := atypes2obj(atypes)
    atypesc := atypeso.data

    // prepare
    cif := Cif{}
    rv := C.ffi_prep_cif(&cif, ffi.default_abi, argc, rtype, atypesc)
    match rv {
        ffi.ok {}
        // ffi.BAD_TYPEDEF {}
        //ffi.BAD_ABI {}
        else{}
    }
    if rv == ffi.ok {
    } else if rv == ffi.bad_typedef {
    } else if rv == ffi.bad_abi {
    } else {
	}

    // invoke
    mut avalues2 := avalues.clone()
    avaluesc := avalues2.data
    mut rvalue := u64(0)
    C.ffi_call(&cif, f, &rvalue, avaluesc)
    return rvalue
}


