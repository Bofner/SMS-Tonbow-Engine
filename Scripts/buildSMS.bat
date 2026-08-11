 @echo off

../Assembler/wla-z80 -o main.o ../Main/main.asm

 echo [objects]>linkfile
 echo main.o>>linkfile

../Assembler/wlalink -d -r -S -v linkfile ../output.sms
 
 del linkfile
 del main.o
