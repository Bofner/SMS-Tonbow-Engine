../Assembler/wla-z80 -o main.o ../Main/main.asm

 echo [objects]>linkfile
 echo main.o>>linkfile

../Assembler/wlalink -d -r -S -v linkfile ../output.sms
 
 
 rm linkfile
 rm main.o
