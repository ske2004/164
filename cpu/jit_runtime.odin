package cpu

import "core:fmt"
import "core:mem"
import "core:slice"

Vm_State :: struct {
	gp_regs: [32]u64, // General Purpose Registers
	fp_regs: [32]u64, // Floating Point Registers
}

Jit_Runtime :: struct {
	vm_state: Vm_State,
	index: int,
	block: Jit_Wex,
}

jit_vm_state_dump_regs :: proc(vm: Vm_State) {
	for i := 0; i < 32; i += 1 {
		fmt.println("gp_regs[", i, "] = ", vm.gp_regs[i])
	}
	for i := 0; i < 32; i += 1 {
		fmt.println("fp_regs[", i, "] = ", vm.fp_regs[i])
	}
}
