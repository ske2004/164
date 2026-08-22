package arm64

// part of instruction
Piece :: u32

Reg :: distinct int
Sf :: enum { B32, B64 }
Sh :: enum { Shift0, Shift12 }
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
_sh :: #force_inline proc(sh: Sh, shift: uint) -> Piece {
	return Piece(sh) << shift
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
