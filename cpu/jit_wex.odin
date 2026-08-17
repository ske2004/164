// Memory manager for W^E (Write xor Execute) memory.
package cpu

import "core:testing"
import "core:c"
import "core:slice"
import "core:sys/posix"
import "core:fmt"

Jit_Wex_Lvl :: enum {
	Write,
	Execute,
}

Jit_Wex :: struct {
	// TODO: should probably be atomic
	lvl: Jit_Wex_Lvl,
	mem: []byte,
}

jit_wex_alloc :: proc(size: int) -> (result: Jit_Wex) {
	when ODIN_OS == .Windows {
		#panic("JIT WEX: No Windows support for now");
	} else {
		memory := posix.mmap(nil, cast(c.size_t)size, {.READ, .WRITE}, {.PRIVATE, .ANONYMOUS})
		assert(memory != posix.MAP_FAILED, fmt.tprintf("JIT WEX: Failed to allocate executable memory; errno: %v", posix.errno()))
	}

	return {
		mem = slice.bytes_from_ptr(memory, size),
		lvl = .Write,
	}
}

jit_wex_unlock :: proc(block: ^Jit_Wex) {
	assert(block.lvl != .Execute, "JIT WEX: Already unlocked")

	when ODIN_OS == .Windows {
		#panic("JIT WEX: No Windows support for now");
	} else {
		status := posix.mprotect(raw_data(block.mem), len(block.mem), {.READ, .EXEC})
		assert(status != .FAIL, fmt.tprintf("JIT WEX: Failed to change permissions for memory region when unlock; errno: %v", posix.errno()))
		block.lvl = .Execute
	}
}

jit_wex_lock :: proc(block: ^Jit_Wex) {
	assert(block.lvl != .Write, "JIT WEX: Already locked")

	when ODIN_OS == .Windows {
		#panic("JIT WEX: No Windows support for now");
	} else {
		status := posix.mprotect(raw_data(block.mem), len(block.mem), {.READ, .WRITE})
		assert(status != .FAIL, fmt.tprintf("JIT WEX: Failed to change permissions for memory region when lock; errno: %v", posix.errno()))
		block.lvl = .Write
	}
}

// Execute with 0 params, return uint
jit_wex_execute_0 :: proc(block: ^Jit_Wex) -> uint {
	Delegate :: #type proc() -> uint
	jit_wex_unlock(block)
	defer jit_wex_lock(block)

	return (cast(Delegate)cast(rawptr)raw_data(block.mem))()
}

// Execute with 1 param (uint), return uint
jit_wex_execute_1 :: proc(block: ^Jit_Wex, param1: uintptr) -> uint {
	Delegate :: #type proc(param1: uintptr) -> uint
	jit_wex_unlock(block)
	defer jit_wex_lock(block)

	return (cast(Delegate)cast(rawptr)raw_data(block.mem))(param1)
}

jit_wex_free :: proc(block: ^Jit_Wex) {
	assert(block.lvl != .Execute, "JIT WEX: Attempt to free executing block (Race condition?)")
	assert(block.lvl == .Write, "JIT WEX: Just in case (TODO)")

	when ODIN_OS == .Windows {
		#panic("JIT WEX: No Windows support for now");
	} else {
		status := posix.munmap(raw_data(block.mem), len(block.mem))
		assert(status != .FAIL, fmt.tprintf("JIT WEX: Failed to unmap memory region; errno: %v", posix.errno()))
	}
}

@(test)
test_jit_wex_basic :: proc(t: ^testing.T) {
	when ODIN_ARCH == .arm64 {
		// int test(int i) {
    //   return i + 5;
		// }
		//
		// from godbolt ^
		arm64_code := []byte{
			0x00, 0x14, 0x00, 0x11,
			0xC0, 0x03, 0x5F, 0xD6
		}

		wex := jit_wex_alloc(1024)
		defer jit_wex_free(&wex)
		for v, i in arm64_code { wex.mem[i] = v }

		testing.expect(t, jit_wex_execute_1(&wex, 6) == 11)
		testing.expect(t, jit_wex_execute_1(&wex, 67) == 72)
	} else {
		// TODO: x86
	}
}
