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
%}

WS                  [\t\n ]+
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

<INITIAL>{WS}                {}
<INITIAL>{NUMBER}            {string temp(yytext);yylval.node=new Node(temp, atoi(yytext));return NUMBER;}
<INITIAL>"+"                 {return PLUS;}
<INITIAL>"-"                 {return MINUS;}
<INITIAL>"*"                 {return MULTIPLY;}
<INITIAL>"/"                 {return DIVIDE;}
<INITIAL>"%"                 {return MODEL;}
<INITIAL>"^"                 {return POW;}
<INITIAL>">"                 {return GREATER;}
<INITIAL>">="                 {return GREATEREQ;}
<INITIAL>"<"                 {return LESS;}
<INITIAL>"<="                 {return LESSEQ;}
<INITIAL>"!="                 {return NEQUAL;}
<INITIAL>"=="                 {return EQUAL;}
<INITIAL>"++"                 {return SELFPLUS;}
<INITIAL>"--"                 {return SELFMINUS;}
<INITIAL>"!"                 {return NOT;}

<INITIAL>"return"            {return RETURN;}
<INITIAL>"main"              {return MAIN;}
<INITIAL>"void"              {return VOID;}
<INITIAL>"int"               {return INT;}
<INITIAL>"if"                {return IF;}
<INITIAL>"else"              {return ELSE;}
<INITIAL>"while"             {return WHILE;}
<INITIAL>"for"               {return FOR;}
<INITIAL>"printf"            {return PRINTF;}
<INITIAL>"scanf"             {return SCANF;}
<INITIAL>"="                 {return ASSIGN;}
<INITIAL>"("                 {return LP;}
<INITIAL>")"                 {return RP;}
<INITIAL>"{"                 {return LBRACE;}
<INITIAL>"}"                 {return RBRACE;}
<INITIAL>"["                 {return LMB;}
<INITIAL>"]"                 {return RMB;}
<INITIAL>";"                 {return SEMICOLON;}
<INITIAL>{ID}                {string temp(yytext);add(temp);yylval.node=new Node(yytext,0);return ID;}
<INITIAL>{ERROR}             {return ERROR;}
.|\n                         {}

%%
int yywrap()
{
    return 1;
}