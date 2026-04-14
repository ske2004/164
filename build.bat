@echo off
if not exist out mkdir out
if not exist out\tests mkdir out\tests
tools\armips tests\make.mips.s
odin run cpu -linker=radlink
