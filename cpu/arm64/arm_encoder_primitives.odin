package arm64

import "core:log"
import "core:fmt"
// part of instruction
Piece :: u32

Reg :: distinct int
Sf  :: enum { B32, B64 }
Sh  :: enum { Shift0, Shift12 }
Hw  :: distinct int
Imm :: distinct uint
Simm :: distinct int

@(private)
_reg_r :: #force_inline proc(reg: Reg, shift: uint) -> Piece {
	assert(reg >= 0 && reg <= 31 && shift < 32-5)
	return Piece(reg)<<shift
}

@(private)
_reg_w :: #force_inline proc(reg: Reg, shift: uint) -> Piece {
	assert(reg >= 0 && reg <= 31 && shift < 32-5)
	return Piece(reg)<<shift
}

@(private)
_sf :: #force_inline proc(sf: Sf, shift: uint = 31) -> Piece {
	assert(shift < 32)
	return Piece(sf) << shift
}

@(private)
_sh :: #force_inline proc(sh: Sh, shift: uint) -> Piece {
	assert(shift < 32)
	return Piece(sh) << shift
}

@(private)
_hw :: #force_inline proc(hw: Hw, shift: uint) -> Piece {
	assert(hw >= 0 && hw <= 3 && shift < 32-2)
	return Piece(hw) << shift
}

@(private)
_imm16 :: #force_inline proc(imm16: Imm, shift: uint) -> Piece {
	assert(imm16 <= 0xFFFF && shift < 32-16)
	return Piece(imm16) << shift
}

@(private)
_imm12 :: #force_inline proc(imm12: Imm, shift: uint) -> Piece {
	assert(imm12 <= 0xFFF && shift < 32-12)
	return Piece(imm12) << shift
}

@(private)
_simm7 :: #force_inline proc(simm: Simm, shift: uint) -> Piece {
	assert(simm <= 63 && simm >= -64)
	return Piece(transmute(uint)(simm&0x7F)) << shift
}
