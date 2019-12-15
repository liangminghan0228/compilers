flex lexer.l
bison -dv parser.y
g++ parser.tab.c lex.yy.c  
./a.out
nasm -f elf target.asm -o target.o
gcc -m32 target.o -o target
./target
rm target
rm target.o
rm a.out
rm lex.yy.c 
rm parser.tab.h
rm parser.tab.c 
