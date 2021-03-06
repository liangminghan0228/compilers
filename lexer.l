%{
    #include"tree.h"
    #include"parser.tab.h"
    extern YYSTYPE yylval;
    int line = 1;
    int col = 0;
    //去空格
    string remove_ws(char* str, int len) {
        string res = "int";
        for(int i = 3; i < len; i++) {
            if(str[i] != ' ' && str[i] != '\t') {
                res += "*";
            }
        }
        return res;
    }
%}

WS                  [\t ]+
number              [0-9]
letter              [A-Za-z_]
NUMBER              [1-9]{number}*|0
ID                  {letter}({letter}|{number})*
ERROR               {number}+{letter}+
TYPE             int({WS}|\*)*

%s                  DCOMMENTS
%s                  SCOMMENTS
%%

<INITIAL>\/\*                {BEGIN DCOMMENTS;}
<DCOMMENTS>\*\/              {BEGIN INITIAL;}
<INITIAL>\/\/                {BEGIN SCOMMENTS;}
<SCOMMENTS>\n                {BEGIN INITIAL;}    

<INITIAL>{WS}                {col += yyleng;}
<INITIAL>{NUMBER}            {col += yyleng;string temp(yytext);yylval.node=new Node(temp, atoi(yytext), line, col);return NUMBER;}
<INITIAL>"+"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return PLUS;}
<INITIAL>"-"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return MINUS;}
<INITIAL>"*"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return MULTIPLY;}
<INITIAL>"/"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return DIVIDE;}
<INITIAL>"%"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return MODEL;}
<INITIAL>"^"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return POW;}
<INITIAL>">"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return GREATER;}
<INITIAL>">="                {col += yyleng;yylval.node = new Node("", 0, line, col);return GREATEREQ;}
<INITIAL>"<"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return LESS;}
<INITIAL>"<="                {col += yyleng;yylval.node = new Node("", 0, line, col);return LESSEQ;}
<INITIAL>"!="                {col += yyleng;yylval.node = new Node("", 0, line, col);return NEQUAL;}
<INITIAL>"=="                {col += yyleng;yylval.node = new Node("", 0, line, col);return EQUAL;}
<INITIAL>"++"                {col += yyleng;yylval.node = new Node("", 0, line, col);return SELFPLUS;}
<INITIAL>"--"                {col += yyleng;yylval.node = new Node("", 0, line, col);return SELFMINUS;}
<INITIAL>"!"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return NOT;}
<INITIAL>","                 {col += yyleng;yylval.node = new Node("", 0, line, col);return COMMA;}
<INITIAL>"."                 {col += yyleng;yylval.node = new Node("", 0, line, col);return DOT;}
<INITIAL>":"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return COLON;}
<INITIAL>"&&"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return AND;}
<INITIAL>"&"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return ADDR;}
<INITIAL>"~"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return POINT;}

<INITIAL>"||"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return OR;}

<INITIAL>"return"            {col += yyleng;yylval.node = new Node("", 0, line, col);return RETURN;}
<INITIAL>"main"              {col += yyleng;yylval.node = new Node("MAIN", 0, line, col);return MAIN;}
<INITIAL>"void"              {col += yyleng;yylval.node = new Node("VOID", 0, line, col);return VOID;}

<INITIAL>{TYPE}           {col += yyleng;yylval.node = new Node(remove_ws(yytext, yyleng), 0, line, col);return TYPE;}
<INITIAL>"if"                {col += yyleng;yylval.node = new Node("", 0, line, col);return IF;}
<INITIAL>"else"              {col += yyleng;yylval.node = new Node("", 0, line, col);return ELSE;}
<INITIAL>"while"             {col += yyleng;yylval.node = new Node("", 0, line, col);return WHILE;}
<INITIAL>"for"               {col += yyleng;yylval.node = new Node("", 0, line, col);return FOR;}
<INITIAL>"print"             {col += yyleng;yylval.node = new Node("", 0, line, col);return PRINT;}
<INITIAL>"scanf"             {col += yyleng;yylval.node = new Node("", 0, line, col);return SCANF;}
<INITIAL>"struct"             {col += yyleng;yylval.node = new Node("", 0, line, col);return STRUCT;}
<INITIAL>"="                 {col += yyleng;yylval.node = new Node("", 0, line, col);return ASSIGN;}
<INITIAL>"("                 {col += yyleng;yylval.node = new Node("", 0, line, col);return LP;}
<INITIAL>")"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return RP;}
<INITIAL>"{"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return LBRACE;}
<INITIAL>"}"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return RBRACE;}
<INITIAL>"["                 {col += yyleng;yylval.node = new Node("", 0, line, col);return LMB;}
<INITIAL>"]"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return RMB;}
<INITIAL>";"                 {col += yyleng;yylval.node = new Node("", 0, line, col);return SEMICOLON;}
<INITIAL>{ID}                {col += yyleng;string temp(yytext);yylval.node=new Node(yytext, 0, line, col);return ID;}
<INITIAL>{ERROR}             {col += yyleng;return ERROR;}
.                            {col++;}
\n                           {line++;col=0;}
%%
int yywrap()
{
    return 1;
}