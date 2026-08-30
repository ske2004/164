package cpu

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:slice"

Vm_Dispatch_Msg_Type :: enum(u16) {
	Read8, Read16, Read32,
	Write8, Write16, Write32,
}

Vm_Dispatch_Msg :: struct {
	type: Vm_Dispatch_Msg_Type,
	value: u16,
}

Vm_State :: struct {
	gp_regs: [32]u64, // General Purpose Registers
	fp_regs: [32]u64, // Floating Point Registers
}

Vm :: struct {
	// NOTE: This has to be the first parameter because the runtime relies on the Vm_State to be at offset 0 to place registers etc
	vm_state: Vm_State,
}

jit_vm_state_dump_regs :: proc(vm: Vm_State) {
	for i := 0; i < 32; i += 1 {
		fmt.println("gp_regs[", i, "] = ", vm.gp_regs[i])
	}
	for i := 0; i < 32; i += 1 {
		fmt.println("fp_regs[", i, "] = ", vm.fp_regs[i])
	}
}

jit_vm_create :: proc() -> Vm {
	return {
		vm_state = {},
	}
}

jit_vm_destroy :: proc() {

}

jit_vm_dispatch :: proc (vm: ^Vm, message: Vm_Dispatch_Msg, wparam: uint, lparam: uint) {
	fmt.printf("message: %v, wparam: %x, lparam: %x\n", message, wparam, lparam)
}

jit_vm_exec_wex :: proc(vm: ^Vm, block: ^Jit_Wex) {
	jit_wex_execute(block, uintptr(vm), uintptr(rawptr(jit_vm_dispatch)))
}
