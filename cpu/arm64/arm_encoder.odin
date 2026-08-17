package arm64

import "core:fmt"
import "core:testing"

// part of instruction
Piece :: u32
Reg :: distinct int
Sf :: enum { B32, B64 }
Hw :: distinct int
Imm16 :: distinct u32
Imm12 :: distinct u32

@(private)
_reg_r :: #force_inline proc(reg: Reg, shift: uint) -> Piece {
	assert(reg >= 0 && reg <= 30 && shift < 31-5)
	return Piece(reg)<<shift
}

@(private)
_reg_w :: #force_inline proc(reg: Reg, shift: uint) -> Piece {
	assert(reg >= 0 && reg <= 30 && shift < 32-5)
	return Piece(reg)<<shift
}

@(private)
_sf :: #force_inline proc(sf: Sf, shift: uint = 31) -> Piece {
	return Piece(sf) << shift
}

@(private)
_hw :: #force_inline proc(hw: Hw, shift: uint) -> Piece {
	assert(hw >= 0 && hw <= 3 && shift < 32-2)
	return Piece(hw) << shift
}

@(private)
_imm16 :: #force_inline proc(imm16: Imm16, shift: uint) -> Piece {
	assert(imm16 <= 0xFFFF && shift < 32-16)
	return Piece(imm16) << shift
}

@(private)
_imm12 :: #force_inline proc(imm12: Imm12, shift: uint) -> Piece {
	assert(imm12 <= 0xFFF && shift < 32-12)
	return Piece(imm12) << shift
}

encode_ret :: proc(reg: Reg = 30) -> Piece {
	return 0b1101011_0_0_10_11111_0000_0_0_00000_00000 | _reg_r(reg, 5)
}

encode_movz :: proc(sf: Sf, hw: Hw, rd: Reg, imm16: Imm16) -> Piece {
	return 0b0_10_100101_00_0000000000000000_00000 | _sf(sf) | _hw(hw, 21) | _imm16(imm16, 5) | _reg_w(rd, 0)
}

// Warning: imm12 is in granularity of
//    8 bytes - sf = .B64
//    4 bytes - sf = .B32
encode_str_imm_uns :: proc(sf: Sf, imm12: Imm12, rn, rt: Reg) -> Piece {
	return 0b10_111_0_01_00_000000000000_00000_00000 | _sf(sf, 30) | _imm12(imm12, 10) | _reg_r(rn, 5) | _reg_w(rt, 0)
}

// Warning: imm12 is in granularity of
//    8 bytes - sf = .B64
//    4 bytes - sf = .B32
encode_ldr_imm_uns :: proc(sf: Sf, imm12: Imm12, rn, rt: Reg) -> Piece {
	return 0b10_111_0_01_01_000000000000_00000_00000 | _sf(sf, 30) | _imm12(imm12, 10) | _reg_r(rn, 5) | _reg_w(rt, 0)
}

@(test)
encoding_test :: proc(t: ^testing.T) {
	verify :: proc(t: ^testing.T, ref: Piece, res: Piece, ref_expr := #caller_expression(ref), res_expr := #caller_expression(res), loc := #caller_location) {
		testing.expect(t, ref == res, fmt.tprintf("%08X | %08X", ref, res), ref_expr, loc)
	}

	verify(t, 0xD65F0000, encode_ret(0))
	verify(t, 0xD65F0020, encode_ret(1))
	verify(t, 0xD65F03C0, encode_ret(30))
	verify(t, 0x52A24680, encode_movz(.B32, 1, 0, 0x1234))
	verify(t, 0xD2A24680, encode_movz(.B64, 1, 0, 0x1234))
	verify(t, 0x52824681, encode_movz(.B32, 0, 1, 0x1234))
	verify(t, 0xD2824681, encode_movz(.B64, 0, 1, 0x1234))
	verify(t, 0xD2C24682, encode_movz(.B64, 2, 2, 0x1234))
	verify(t, 0xD2E24682, encode_movz(.B64, 3, 2, 0x1234))
	verify(t, 0xF9000800, encode_str_imm_uns(.B64, 2, 0, 0))
	verify(t, 0xB9001021, encode_str_imm_uns(.B32, 4, 1, 1))
	verify(t, 0xF9400800, encode_ldr_imm_uns(.B64, 2, 0, 0))
	verify(t, 0xB9401021, encode_ldr_imm_uns(.B32, 4, 1, 1))
}
