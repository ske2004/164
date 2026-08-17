package main

import "core:fmt"
import "core:mem"
import "core:sys/posix"
import "src:cpu"

import rl "vendor:raylib"

sample := #load("../out/tests/instr_decode.bin", []u32)

main :: proc() {
	vms := cpu.jit_exec_instr(transmute(u32be)sample[0])
	fmt.printf("vms: %x", vms.gp_regs)
	// rl.InitWindow(1024, 768, "164")
	// rl.SetTargetFPS(60)
	// defer rl.CloseWindow()

	// for !rl.WindowShouldClose() {
	// 	rl.BeginDrawing()
	// 		rl.ClearBackground(rl.WHITE)
	// 		rl.DrawText(fmt.ctprintf("goodbye world %d %dfps", 123, rl.GetFPS()), 0, 0, 20, rl.RED)
	// 	rl.EndDrawing()
	// }
}
