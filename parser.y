%{
	#include"tree.h"
	#include"parser.h"
	extern int yylex();
	int yyerror(const char* msg);
%}

%union{
	char* str;
	class Node* node;
}
%token<node>NUMBER
%token<node>ID
%token<node>RETURN
%token RETURN MAIN VOID PLUS MINUS MULTIPLY DIVIDE POW MODEL
%token INT IF ELSE WHILE FOR PRINTF SCANF ASSIGN 
%token LP RP LBRACE RBRACE LMB RMB SEMICOLON ERROR
%token GREATER LESS NEQUAL EQUAL SELFPLUS SELFMINUS NOT GREATEREQ LESSEQ
%type<node> CompoundK Content Conclude Var Expr Type Opnum RepeatK Condition IDdec Const s ReturnStmt ExprNull VarExprNull

%right ASSIGN
%left EQUAL NEQUAL
%left GREATER LESS GREATEREQ LESSEQ
%left PLUS MINUS
%left MULTIPLY DIVIDE MODEL
%right POW
%right SELFPLUS SELFMINUS NOT
%left LP RP
%nonassoc LOW
%nonassoc ELSE
%%
 /* 开始符号 */
s : 	INT MAIN LP RP CompoundK 
		{
			$$=$5;
			if(!returnError($$, $$, true))
			{
				print($$, 2);
			}
		}
	|	VOID MAIN LP RP CompoundK 
		{
			$$=$5;
			if(!returnError($$, $$, false))
			{
				print($$, 2);
			}
		}
	;


 /* 大括号包起来的部分*/
CompoundK :		LBRACE Content RBRACE {$$=$2;}
	;

 /* 大括号里包含的内容*/
Content :		Conclude		
		{$$=new Node("CompoundK statement", 0);insertChildren($$,$1,new Node("$", 0));}
	|			Content Conclude	
		{insertChildren($$,$2,new Node("$", 0));}
	;
 /* 大括号里包含的内容的具体归纳 */
Conclude :		Var			{$$=$1;}
	|			Expr SEMICOLON		{$$=$1;}
	|			RepeatK				{$$=$1;}
	|			Condition			{$$=$1;}
	|			ReturnStmt			{$$=$1;}
	;
 /*返回的语句*/
 ReturnStmt :	RETURN SEMICOLON
		{$$=$1;$$->key="Return statement"}
	|			RETURN Opnum SEMICOLON
		{$$=$1;$$->key="Return expr statement";insertChildren($$, $2,new Node("$", 0));}
 /* 条件结构 */
Condition :		IF LP Expr RP CompoundK %prec LOW		
{$$=new Node("Condition statement,only if", 0);insertChildren($$,$3,$5,new Node("$", 0));}
	|			IF LP Expr RP CompoundK ELSE CompoundK		
	{$$=new Node("Condition statement,with else", 0);insertChildren($$,$3,$5,$7,new Node("$", 0));}
	|			IF LP Expr RP CompoundK ELSE Condition		
	{$$=new Node("Condition statement,with else if", 0);insertChildren($$,$3,$5,$7,new Node("$", 0));}
	;
 /* 循环体结构 */
RepeatK :		FOR LP  VarExprNull ExprNull SEMICOLON ExprNull RP CompoundK		
{$$=new Node("RepeatK statement, for ", 0);insertChildren($$,$3,$4,$6,$8,new Node("$", 0));}
	|			WHILE LP Expr RP CompoundK		
{$$=new Node("RepeatK statement, while ", 0);insertChildren($$,$3,$5,new Node("$", 0));}
	;
 /* 声明变量 或者 声明变量并赋值 */
Var :		Type IDdec ASSIGN Opnum SEMICOLON
{$$=new Node("Var Declaration with Assign", 0);insertChildren($$,$1,$2,$4,new Node("$", 0));}
	|		Type IDdec	SEMICOLON	
{$$=new Node("Var Declaration ", 0);insertChildren($$,$1,$2,new Node("$", 0));}
	;
 /* 类型声明 */
Type :		INT {$$=new Node("Type Specifier, int", 0);}
	;
 /*声明或者表达式或者空*/
VarExprNull :	Var {$$=$1;}
	|			Expr SEMICOLON {$$=$1;}
	|			SEMICOLON {$$=NULL;}
 /*表达式或者空*/
ExprNull :	Expr	{$$ = $1;}			
	|		{$$=NULL;}
 /* 表达式*/
Expr :		Opnum PLUS Opnum	
	{$$=new Node("Expr,op : +", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum MINUS Opnum		
	{$$=new Node("Expr,op : -", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum MULTIPLY Opnum		
	{$$=new Node("Expr,op : *", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum DIVIDE Opnum		
	{$$=new Node("Expr,op : /", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum MODEL Opnum		
	{$$=new Node("Expr,op : %", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum POW Opnum		
	{$$=new Node("Expr,op : ^", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum GREATER Opnum		
	{$$=new Node("Expr,op : >", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum GREATEREQ Opnum		
	{$$=new Node("Expr,op : >=", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum LESS Opnum		
	{$$=new Node("Expr,op : <", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum LESSEQ Opnum		
	{$$=new Node("Expr,op : <=", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum NEQUAL Opnum		
	{$$=new Node("Expr,op : !=", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum EQUAL Opnum		
	{$$=new Node("Expr,op : ==", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum ASSIGN Opnum		
	{$$=new Node("Expr,op : =", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum SELFPLUS		
	{$$=new Node("Expr,op : i++", 0);insertChildren($$,$1,new Node("$", 0));}
	|		Opnum SELFMINUS		
	{$$=new Node("Expr,op : i--", 0);insertChildren($$,$1,new Node("$", 0));}
	|		SELFPLUS Opnum		
	{$$=new Node("Expr,op : ++i", 0);insertChildren($$,$2,new Node("$", 0));}
	|		SELFMINUS Opnum		
	{$$=new Node("Expr,op : --i", 0);insertChildren($$,$2,new Node("$", 0));}
	|		NOT Opnum		
	{$$=new Node("Expr,op : !", 0);insertChildren($$,$2,new Node("$", 0));}
	|		LP Opnum RP
	{$$=new Node("Expr,op : ()", 0);insertChildren($$,$2,new Node("$", 0));}
	;
 /*操作数*/
Opnum :		Const	{$$=$1;}
	|		IDdec	{$$=$1;}
	|		Expr	{$$=$1;}
	;
 /* 标识符声明 */
IDdec :		ID		{$$=$1;}
	;
 /*常量*/
Const :		NUMBER		{$$=$1;}
	;
%%

int yyerror(const char* msg)
{
	printf("%s", msg);
	return 0;
}
int main()
{
	extern FILE* yyin;
	yyin=fopen("5.c", "r");
	yyparse();
}
