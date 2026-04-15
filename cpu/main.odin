package cpu

import "core:fmt"
import "core:slice"
import "core:os"

main :: proc() {
	data := os.read_entire_file("out/tests/instr_decode.bin", context.temp_allocator) or_else panic("failed to read file")
	fmt.printf("%v\n", data)
	
	data_u32 := slice.reinterpret([]u32be, data)
	fmt.printf("%v\n", data_u32)
	
	fmt.printf("Decoded: %v\n", instr_decode(transmute(u32be)data_u32[0]))
	
	block := jit_alloc_block(4096)
	block.memory[0] = 0xB8
	block.memory[1] = 0x11
	block.memory[2] = 0x22
	block.memory[3] = 0x33
	block.memory[4] = 0x44
	block.memory[5] = 0xC3
	
	result := jit_block_execute(&block, 0)
	fmt.printf("Block exec result: %x\n", result)
}
