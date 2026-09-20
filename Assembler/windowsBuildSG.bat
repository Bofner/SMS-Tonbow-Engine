@echo off

Assembler\windows\wla-z80.exe -o main.o main.asm

echo [objects]>linkfile
echo main.o>>linkfile

Assembler\windows\wlalink.exe -d -r -S -v linkfile output.sg

REM Clean up our folder
del linkfile
del main.o


