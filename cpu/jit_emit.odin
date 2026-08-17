package cpu

// conventions (stub list)
// x0 stores address to Vm_State

import "arm64"

JIT_EMIT_DEFAULT_WEX_SIZE :: 1024

Jit_Emit :: struct {
	wex: Jit_Wex,
	idx: int
}

jit_emit_begin :: proc() -> Jit_Emit {
	return {
		wex = jit_wex_alloc(JIT_EMIT_DEFAULT_WEX_SIZE),
		idx = 0
	}
}

jit_emit_free :: proc(w: ^Jit_Emit) {
	jit_wex_free(&w.wex)
}

jit_emit_end :: proc(w: ^Jit_Emit) {
	jit_emit_u32(w, arm64.encode_ret(30))
}

jit_emit_u32 :: proc(w: ^Jit_Emit, val: u32) {
	assert(w.idx + 4 < len(w.wex.mem))
	(cast([^]u32)raw_data(w.wex.mem))[w.idx] = val
	w.idx += 1
}

jit_emit_vm_writeback_64 :: proc(w: ^Jit_Emit, offs: int, rs: arm64.Reg) {
	assert((offs >> 3 << 3) == offs, "Unaligned field")
	jit_emit_u32(w, arm64.encode_str_imm_uns(.B64, arm64.Imm12(offs >> 3), 0, rs))
}

jit_emit_vm_readback_64 :: proc(w: ^Jit_Emit, offs: int, rd: arm64.Reg) {
	assert((offs >> 3 << 3) == offs, "Unaligned field")
	jit_emit_u32(w, arm64.encode_ldr_imm_uns(.B64, arm64.Imm12(offs >> 3), 0, rd))
}

jit_emit_lui :: proc(w: ^Jit_Emit, instr: InstrI) {
	jit_emit_u32(w, arm64.encode_movz(.B32, 1, 1, arm64.Imm16(instr.imm)))
	jit_emit_vm_writeback_64(w, cast(int)offset_of_by_string(Vm_State, "gp_regs")+cast(int)instr.rt*4, 1)
}

jit_exec_instr :: proc(instr: u32be) -> Vm_State {
	w := jit_emit_begin()
	defer jit_emit_free(&w)

	op := (cast(Instr_Unknown)instr).op
	decoded := instr_decode(instr)
	switch op {
	case 0x0F: jit_emit_lui(&w, decoded.(InstrI))
	// case 0x10: jit_emit_mtc0(jit, decoded.(InstrI))
	// case 0x0D: jit_emit_ori(jit, decoded.(InstrI))
	}
	jit_emit_end(&w)

	vm_state := Vm_State{}

	jit_wex_execute_1(&w.wex, uintptr(&vm_state))

	return vm_state
}
