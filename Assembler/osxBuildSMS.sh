Assembler/osx/wla-z80 -o main.o main.asm

echo [objects]>linkfile
echo main.o>>linkfile

Assembler/osx/wlalink -d -r -S -v linkfile output.sms
 
rm linkfile
rm main.o

