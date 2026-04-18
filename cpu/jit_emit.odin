package cpu

jit_emit_begin_block :: proc(jit: ^JIT_Runtime) {
	jit.index = 0
}

jit_emit_end_block :: proc(jit: ^JIT_Runtime) {
	// Write the end block instruction (ret)
	jit_runtime_emit(jit, []byte{ 0xC3 })
}

jit_emit_lui :: proc(jit: ^JIT_Runtime, instr: InstrI) {
	jit_runtime_emit(jit, []byte{ 0x48, 0xB8 })
	jit_runtime_emit(jit, []^u64{ &jit.gp_regs[instr.rt] })
	
	jit_runtime_emit(jit, []byte{ 0x48, 0xC7, 0x00 })
	jit_runtime_emit(jit, []u32{ cast(u32)instr.imm<<16 })
}

jit_emit_mtc0 :: proc(jit: ^JIT_Runtime, instr: InstrI) {
	// nothing for now
}

jit_emit_ori :: proc(jit: ^JIT_Runtime, instr: InstrI) {
	jit_runtime_emit(jit, []byte{ 0xA1 })
	jit_runtime_emit(jit, []^u64{ &jit.gp_regs[instr.rs] })

	jit_runtime_emit(jit, []byte{ 0x0D })
	jit_runtime_emit(jit, []u32{ cast(u32)instr.imm })
	
	jit_runtime_emit(jit, []byte{ 0xA3 })
	jit_runtime_emit(jit, []^u64{ &jit.gp_regs[instr.rt] })
}

jit_exec_instr :: proc(jit: ^JIT_Runtime, instr: u32be) -> int {
	jit_emit_begin_block(jit)
	op := (cast(Instr_Unknown)instr).op
	decoded := instr_decode(instr)
	switch op {
	case 0x0F: jit_emit_lui(jit, decoded.(InstrI))
	case 0x10: jit_emit_mtc0(jit, decoded.(InstrI))
	case 0x0D: jit_emit_ori(jit, decoded.(InstrI))
	}
	jit_emit_end_block(jit)
	
	return jit_runtime_exec(jit)
}
