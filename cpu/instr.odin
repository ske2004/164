package cpu

import "core:fmt"
OPCODE_COUNT :: 1<<6

InstrI :: bit_field u32 {
	imm: u16  | 16,
	rt:  u8   | 5,
	rs:  u8   | 5,
	op: u8    | 6
}

InstrJ :: bit_field u32 {
	imm: u32  | 26,
	op: u8    | 6
}

InstrR :: bit_field u32 {
	funct: u8 | 6,
	sa: u8    | 5, // shift amount
	rd: u8    | 5,
	rt: u8    | 5,
	rs: u8    | 5,
	op: u8    | 6,
}

Instr_Unknown :: bit_field u32 {
	_:  uint | 26,
	op: u8   | 6,
}

Instr :: union #no_nil {
	InstrI,
	InstrJ,
	InstrR,
}

Instr_Type :: enum {
	Unknown,
	I,
	J,
	R,
}

@(rodata)
g_instr_type_table := [OPCODE_COUNT]Instr_Type{
	0x0D = .I, // ORI 
	0x0F = .I, // LUI 
	0x10 = .I, // MTC0
}

instr_decode :: proc(instr: u32be) -> Instr {
	fmt.printf("Decoding instr: %x\n", instr)
	
	instr := cast(Instr_Unknown)(instr)
	
	switch g_instr_type_table[instr.op] {
	case .Unknown: fmt.panicf("invalid opcode: %x (%06b)", instr.op, instr.op)
	case .I: return cast(InstrI)(instr)
	case .J: return cast(InstrJ)(instr)
	case .R: return cast(InstrR)(instr)
	}
	
	unreachable()
}
