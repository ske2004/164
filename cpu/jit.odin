package cpu

import "core:fmt"
import "core:mem"
// TODO: Free the memory

import "core:slice"
import "core:sys/windows"

JIT_Block_Exec :: proc "c" () -> int

JIT_Block :: struct {
	memory: []byte,
}

JIT_Runtime :: struct {
	gp_regs: [32]u64, // General Purpose Registers
	fp_regs: [32]u64, // Floating Point Registers
	
	index: int,
	block: JIT_Block,
}

jit_alloc_block :: proc(size: uint) -> JIT_Block {
	memory := slice.from_ptr(cast([^]byte)windows.VirtualAlloc(nil, size, windows.MEM_COMMIT, windows.PAGE_EXECUTE_READWRITE), cast(int)size)
	return {
		memory = memory,
	}
}

jit_runtime_write :: proc(jit: ^JIT_Runtime, data: []byte) {
	mem.copy(slice.as_ptr(jit.block.memory[jit.index:]), raw_data(data), len(data))
	jit.index += len(data)
}

jit_runtime_emit :: proc(jit: ^JIT_Runtime, data: []$T) {
	fmt.printf("Emitted %T%v\n", data, data)
	mem.copy(raw_data(jit.block.memory[jit.index:]), raw_data(data), slice.size(data))
	jit.index += slice.size(data)
}

jit_runtime_alloc :: proc(size: uint) -> JIT_Runtime {
	return {
		gp_regs = [32]u64{},
		fp_regs = [32]u64{},
		index = 0,
		block = jit_alloc_block(size),
	}
}

jit_runtime_dump_regs :: proc(jit: ^JIT_Runtime) {
	for i := 0; i < 32; i += 1 {
		fmt.println("gp_regs[", i, "] = ", jit.gp_regs[i])
	}
	for i := 0; i < 32; i += 1 {
		fmt.println("fp_regs[", i, "] = ", jit.fp_regs[i])
	}
}

jit_runtime_exec :: proc(rt: ^JIT_Runtime) -> int {
	block_exec := cast(JIT_Block_Exec)(cast(rawptr)raw_data(rt.block.memory))
	fmt.printf("Executing block: %v\n", rt.block.memory[:rt.index])
	result := block_exec()
	// Reset write head after execution
	rt.index = 0
	return result
}
