package ui

import "vendor:raylib"

main :: proc() {
  raylib.InitWindow(1280, 768, "164")
  defer raylib.CloseWindow()

  for !raylib.WindowShouldClose() {
    raylib.BeginDrawing()
    raylib.EndDrawing()
  }
}
