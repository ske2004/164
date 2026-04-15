@echo off

set target=%1%

if "%target%"=="" (
  if not exist out mkdir out
  if not exist out\tests mkdir out\tests
  tools\armips tests\make.mips.s
  odin run cpu -linker=radlink
  goto end
)

if "%target%"=="RunMain" (
  if NOT exist sokol-odin\sokol\app\sokol_app_windows_x64_d3d11_release.lib (
    cd sokol-odin\sokol
    build_clibs_windows.cmd
    cd ..\..
  )

  odin run main --collection:sokol=sokol-odin/sokol
  goto end
)

:end
