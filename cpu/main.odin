package cpu

import "core:fmt"
import "core:slice"
import "core:os"

main :: proc() {
	data := os.read_entire_file("private/bios_usj.bin", context.temp_allocator) or_else panic("failed to read file")
	fmt.printf("%v\n", data)
	
	data_u32 := slice.reinterpret([]u32be, data)
	fmt.printf("%v\n", data_u32)
	
	fmt.printf("Decoded: %v\n", instr_decode(transmute(u32be)data_u32[0]))
	
	rt := jit_runtime_alloc(1024)
	for i in 0..<6 {
		jit_exec_instr(&rt, transmute(u32be)data_u32[i])
	}
	jit_runtime_dump_regs(&rt)
	
	fmt.printf("OK\n")
}
