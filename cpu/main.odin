package frontend

import "core:fmt"

Instr_Type :: enum {
	
}

InstrI :: bit_field u32 {
  imm: u16   | 16,
  rt:  u8    | 5,
  rs:  u8    | 5,
  opc: u8    | 6
}

InstrJ :: bit_field u32 {
  imm: u32   | 26,
  opc: u8    | 6
}

InstrR :: bit_field u32 {
  funct: u8 | 6,
  sa: u8    | 5,
  rd: u8    | 5,
  rt: u8    | 5,
  rs: u8    | 5,
  op: u8    | 6,
}

Instr_Desc :: struct {
	
}
