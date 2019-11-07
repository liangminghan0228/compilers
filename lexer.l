%{
    #include"tree.h"
    #include"parser.tab.h"
    extern YYSTYPE yylval;
    map<string, int> table;
    void add(string id) {
        //默认值都存储为0
        table.insert(pair<string, int>(id, 0));
    }
    int* getID(string id) {
         return &table[id];
    }
    int line = 1;
    int col = 0;
%}

WS                  [\t ]+
number              [0-9]
letter              [A-Za-z_]
NUMBER              [1-9]{number}*|0
ID                  {letter}({letter}|{number})*
ERROR               {number}+{letter}+

%s                  DCOMMENTS
%s                  SCOMMENTS
%%

<INITIAL>\/\*                {BEGIN DCOMMENTS;}
<DCOMMENTS>\*\/              {BEGIN INITIAL;}
<INITIAL>\/\/                {BEGIN SCOMMENTS;}
<SCOMMENTS>\n                {BEGIN INITIAL;}    

<INITIAL>{WS}                {col += yyleng;}
<INITIAL>{NUMBER}            {col += yyleng;string temp(yytext);yylval.node=new Node(temp, atoi(yytext), line, col);return NUMBER;}
<INITIAL>"+"                 {col += yyleng;return PLUS;}
<INITIAL>"-"                 {col += yyleng;return MINUS;}
<INITIAL>"*"                 {col += yyleng;return MULTIPLY;}
<INITIAL>"/"                 {col += yyleng;return DIVIDE;}
<INITIAL>"%"                 {col += yyleng;return MODEL;}
<INITIAL>"^"                 {col += yyleng;return POW;}
<INITIAL>">"                 {col += yyleng;return GREATER;}
<INITIAL>">="                {col += yyleng;return GREATEREQ;}
<INITIAL>"<"                 {col += yyleng;return LESS;}
<INITIAL>"<="                {col += yyleng;return LESSEQ;}
<INITIAL>"!="                {col += yyleng;return NEQUAL;}
<INITIAL>"=="                {col += yyleng;return EQUAL;}
<INITIAL>"++"                {col += yyleng;return SELFPLUS;}
<INITIAL>"--"                {col += yyleng;return SELFMINUS;}
<INITIAL>"!"                 {col += yyleng;return NOT;}

<INITIAL>"return"            {col += yyleng;yylval.node=new Node("", 0, line, col);return RETURN;}
<INITIAL>"main"              {col += yyleng;return MAIN;}
<INITIAL>"void"              {col += yyleng;return VOID;}
<INITIAL>"int"               {col += yyleng;return INT;}
<INITIAL>"if"                {col += yyleng;return IF;}
<INITIAL>"else"              {col += yyleng;return ELSE;}
<INITIAL>"while"             {col += yyleng;return WHILE;}
<INITIAL>"for"               {col += yyleng;return FOR;}
<INITIAL>"printf"            {col += yyleng;return PRINTF;}
<INITIAL>"scanf"             {col += yyleng;return SCANF;}
<INITIAL>"="                 {col += yyleng;return ASSIGN;}
<INITIAL>"("                 {col += yyleng;return LP;}
<INITIAL>")"                 {col += yyleng;return RP;}
<INITIAL>"{"                 {col += yyleng;return LBRACE;}
<INITIAL>"}"                 {col += yyleng;return RBRACE;}
<INITIAL>"["                 {col += yyleng;return LMB;}
<INITIAL>"]"                 {col += yyleng;return RMB;}
<INITIAL>";"                 {col += yyleng;return SEMICOLON;}
<INITIAL>{ID}                {col += yyleng;string temp(yytext);add(temp);yylval.node=new Node(yytext, 0, line, col);return ID;}
<INITIAL>{ERROR}             {col += yyleng;return ERROR;}
.                            {col++;}
\n                           {line++;col=0;}
%%
int yywrap()
{
    return 1;
}