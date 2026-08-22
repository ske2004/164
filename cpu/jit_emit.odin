package cpu

import "core:slice"
import "core:fmt"
// conventions (stub list)
// x0 stores address to Vm_State

import "arm64"

JIT_EMIT_DEFAULT_WEX_SIZE :: 1024
JIT_TEMP_REG_START :: 6

Jit_Emit :: struct {
	wex: Jit_Wex,
	idx: int
}

jit_emit_begin :: proc() -> Jit_Emit {
	w := Jit_Emit {
		wex = jit_wex_alloc(JIT_EMIT_DEFAULT_WEX_SIZE),
		idx = 0
	}

	// Prelude
	// Save VM state + dispatch function + context
	jit_emit_vm_writeback_64(&w, cast(int)offset_of_by_string(Vm_State, "temp")+cast(int)+0, 0)
	jit_emit_vm_writeback_64(&w, cast(int)offset_of_by_string(Vm_State, "temp")+cast(int)+8, 1)
	jit_emit_vm_writeback_64(&w, cast(int)offset_of_by_string(Vm_State, "temp")+cast(int)+16, 2)

	return w
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

jit_emit_vm_dispatch :: proc(w: ^Jit_Emit, msg: Vm_Dispatch_Msg, wparam_reg, lparam_reg: arm64.Reg) {
	// Restore context into x3
	jit_emit_vm_readback_64(w, cast(int)offset_of_by_string(Vm_State, "temp")+cast(int)+8, 3)

	// Move dispatch from x1 to x5
	jit_emit_u32(w, arm64.encode_mov(.B64, 1, 5))

	// Move wparam and lparam to x1 and x2 respectively
	// TODO: assuming there's no register aliasing for now
	jit_emit_u32(w, arm64.encode_mov(.B64, wparam_reg, 2))
	jit_emit_u32(w, arm64.encode_mov(.B64, lparam_reg, 3))

	// assume msg < 16 bit, store into x1
	// VM state already in x0, so we skip that
	jit_emit_u32(w, arm64.encode_movz(.B64, 0, arm64.Imm16(msg), 1))
	jit_emit_u32(w, arm64.encode_blr(5)) // x5 contains the dispatch function

	// Restore x0, x1 after callback
	jit_emit_vm_readback_64(w, cast(int)offset_of_by_string(Vm_State, "temp")+cast(int)+0, 0)
	jit_emit_vm_readback_64(w, cast(int)offset_of_by_string(Vm_State, "temp")+cast(int)+8, 1)
}

jit_emit_call_reg :: proc(w: ^Jit_Emit, )

jit_exec_instrs :: proc(instrs: []u32be) -> Vm_State {
	w := jit_emit_begin()
	defer jit_emit_free(&w)

	for instr in instrs {
		op := (cast(Instr_Unknown)instr).op
		decoded := instr_decode(instr)
		fmt.printf("Decoded: %v\n", decoded)
		switch op {
		case 0x0F: jit_emit_lui(&w, decoded.(InstrI))
		case 0x2B: jit_emit_sw(&w, decoded.(InstrI))
		// case 0x10: jit_emit_mtc0(&w, decoded.(InstrI))
		// case 0x0D: jit_emit_ori(&w, decoded.(InstrI))
		}
	}

	jit_emit_end(&w)


	for i := 0; i < w.idx; i += 1 {
		fmt.printf("%02X%02X%02X%02X ", w.wex.mem[i*4], w.wex.mem[i*4+1], w.wex.mem[i*4+2], w.wex.mem[i*4+3])
	}
	fmt.printf("\n")

	vm := jit_vm_create()
	defer jit_vm_destroy()

	jit_vm_exec_wex(&vm, &w.wex)

	return vm.vm_state
}
