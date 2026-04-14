package cpu

import "core:slice"
import "core:sys/windows"

JIT_Block_Exec :: proc "c" (param: int) -> int

JIT_Block :: struct {
	memory: []byte,
}

jit_alloc_block :: proc(size: uint) -> JIT_Block {
	memory := slice.from_ptr(cast([^]byte)windows.VirtualAlloc(nil, size, windows.MEM_COMMIT, windows.PAGE_EXECUTE_READWRITE), cast(int)size)
	return {
		memory = memory,
	}
}

jit_block_execute :: proc(block: ^JIT_Block, param: int) -> int {
	block_exec := cast(JIT_Block_Exec)(cast(rawptr)raw_data(block.memory))
	
	return block_exec(param)
}
