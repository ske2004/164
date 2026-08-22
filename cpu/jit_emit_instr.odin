package cpu
import "arm64"

jit_emit_lui :: proc(w: ^Jit_Emit, instr: InstrI) {
	jit_emit_u32(w, arm64.encode_movz(.B32, 1, arm64.Imm16(instr.imm), JIT_TEMP_REG_START))
	jit_emit_vm_writeback_64(w, cast(int)offset_of_by_string(Vm_State, "gp_regs")+cast(int)instr.rt*8, JIT_TEMP_REG_START)
}

jit_emit_sw :: proc(w: ^Jit_Emit, instr: InstrI) {
	jit_emit_vm_readback_64(w, cast(int)offset_of_by_string(Vm_State, "gp_regs")+cast(int)instr.rs*8, JIT_TEMP_REG_START)
	jit_emit_vm_readback_64(w, cast(int)offset_of_by_string(Vm_State, "gp_regs")+cast(int)instr.rt*8, JIT_TEMP_REG_START+1)
	// TODO: add the offset here
	jit_emit_vm_dispatch(w, .Write32, JIT_TEMP_REG_START, JIT_TEMP_REG_START+1)
}
