flex lexer.l
bison -dv parser.y
g++ parser.tab.c lex.yy.c  
.\a.exe
rm a.exe
rm lex.yy.c 
rm parser.tab.h
rm parser.tab.c 
