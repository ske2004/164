package cpu
import "arm64"

JIT_TEMP_REG_START :: 6

jit_emit_lui :: proc(w: ^Jit_Emit, instr: InstrI) {
	jit_emit_u32(w, arm64.encode_movz(.B32, 1, arm64.Imm(instr.imm), JIT_TEMP_REG_START))
	jit_emit_vm_write_reg(w, instr.rt, JIT_TEMP_REG_START)
}

jit_emit_sw :: proc(w: ^Jit_Emit, instr: InstrI) {
	jit_emit_vm_read_reg(w, instr.rs, JIT_TEMP_REG_START)
	jit_emit_vm_read_reg(w, instr.rt, JIT_TEMP_REG_START+1)
	jit_emit_vm_dispatch(w, {.Write32, instr.imm}, JIT_TEMP_REG_START, JIT_TEMP_REG_START+1)
}
