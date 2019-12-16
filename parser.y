%{
	#include"tree.h"
	#include"parser.h"
	#include"table.h"
	#include"threeaddress.h"
	#include"toasm.h"
	extern int yylex();
	int yyerror(const char* msg);
	Node* root;
%}

%union{
	char* str;
	class Node* node;
}
%token<node> NUMBER
%token<node> ID
%token<node> RETURN SELFPLUS SELFMINUS LP RP PRINT IF FOR WHILE MAIN COMMA VOID DOT COLON
%token<node> PLUS MINUS MULTIPLY DIVIDE POW MODEL POINT ADDR TYPE
%token<node> ELSE SCANF ASSIGN STRUCT
%token<node> LBRACE RBRACE LMB RMB SEMICOLON ERROR
%token<node> GREATER LESS NEQUAL EQUAL NOT GREATEREQ LESSEQ AND OR
%type<node> CompoundK Content Conclude VarInt Expr AssignExprInt StructStmt StructInner StructInnerVar BeforeMain MainFunc
%type<node> Opnum OpnumNull VarOpnum RepeatK Condition IDdec Const s ReturnStmt Writek ForHeader Readk
%type<node> VarStruct AssignExprStruct AssignExprStructInner Array VarArray

%nonassoc LOWEST //解决去掉一些东西后相关的冲突，额外定义的终结符
%right ASSIGN
%left AND
%left OR
%left EQUAL NEQUAL
%left GREATER LESS GREATEREQ LESSEQ
%left PLUS MINUS
%left MULTIPLY DIVIDE MODEL
%right POW
%nonassoc RETURN PRINT SCANF IF FOR WHILE RBRACE STRUCT TYPE
%right SELFPLUS SELFMINUS NOT ADDR POINT

%left LP RP
%nonassoc ID NUMBER //当读到return时用来先移进number和id后归约return
%nonassoc LBRACE
%nonassoc ELSE //解决else相关的冲突
%nonassoc SEMICOLON //解决去掉分号后的表达式归约移进相关的冲突

%%
 /* 开始符号 */
s:		BeforeMain MainFunc
	{$$=new Node("Program", 0);insertChildren($$, $1, $2, new Node("$", 0));print($$, 2);root = $$;}
	|	MainFunc
	{$$=new Node("Program", 0);insertChildren($$, $1,  new Node("$", 0));print($$, 2);root = $$;}
 ;

 /* 主函数之前的声明*/
 BeforeMain: StructStmt
	{$$=new Node("BeforeMain", 0);insertChildren($$, $1, new Node("$", 0));}
	|					BeforeMain StructStmt
	{insertChildren($$, $2, new Node("$", 0));}
	;

  /* 主函数*/
MainFunc: 	TYPE MAIN LP RP CompoundK
	{returnError($5, $5, true);$$=new Node("MainFunc", 0);
	insertChildren($$, $1, $2, $5, new Node("$", 0));}
	|	TYPE MAIN RP CompoundK 
	{returnError($4, $4, true);$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $4, new Node("$", 0));cout<<"need a '(' in line "<<$2->line<<endl;}
	|	TYPE MAIN LP CompoundK 
	{returnError($4, $4, true);$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $4, new Node("$", 0));cout<<"need a ')' in line "<<$3->line<<endl;}
	|	TYPE MAIN CompoundK 
	{returnError($3, $3, true);$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $3, new Node("$", 0));cout<<"need a '(' and a ')' in line "<<$2->line<<endl;}
	|	VOID MAIN LP RP CompoundK 
	{returnError($5, $5, true);$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $5, new Node("$", 0));returnError($$, $$, false);}
	|	VOID MAIN RP CompoundK 
	{returnError($4, $4, true);$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $4, new Node("$", 0));cout<<"need a '(' in line "<<$2->line<<endl;}
	|	VOID MAIN LP CompoundK 
	{returnError($4, $4, true);$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $4, new Node("$", 0));cout<<"need a ')' in line "<<$3->line<<endl;}
	|	VOID MAIN CompoundK 
	{returnError($3, $3, true);$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $3, new Node("$", 0));cout<<"need a '(' and a ')' in line "<<$2->line<<endl;}
	;


 /* 大括号包起来的部分*/
CompoundK:		LBRACE Content RBRACE {$$=$2;}
	|			LBRACE RBRACE {$$=new Node("CompoundK", 0);}
	/* 缺右括号 */
	|			LBRACE Content %prec LOWEST
	{$$=$2;cout<<"need a '}' in line "<<$$->line<<endl;}
	|			LBRACE %prec LOWEST
	{$$=new Node("CompoundK", 0);cout<<"need a '}' in line "<<$$->line<<endl;}
	
	;

 
 /* 结构体声明*/
 StructStmt:		STRUCT IDdec LBRACE  StructInner RBRACE SEMICOLON
 	{$$=new Node("StructStmt ", 0);insertChildren($$, $2, $4, new Node("$", 0));}
 ;

  /* 结构体内部内容*/
StructInnerVar:		TYPE IDdec 
	{$$=new Node("StructInnerVar", 0);insertChildren($$, $1, $2, new Node("$", 0));}
	|				StructInnerVar COMMA IDdec
	{insertChildren($$, $3, new Node("$", 0));}
	;

StructInner: 		StructInnerVar SEMICOLON
	{$$=new Node("StructInner", 0);insertChildren($$, $1,  new Node("$", 0));}
	|						StructInner StructInnerVar SEMICOLON
	{insertChildren($$, $2, new Node("$", 0));}
	;

 /* 大括号里包含的内容*/
Content:		Conclude
		{$$=new Node("CompoundK", 0);insertChildren($$,$1,new Node("$", 0));}
	|			Content Conclude
		{insertChildren($$,$2,new Node("$", 0));}
	;
 /* 大括号里包含的内容的具体归纳 */
Conclude:		VarInt	SEMICOLON			{$$=$1;}
	|			VarStruct	SEMICOLON		{$$=$1;}
	|			VarArray	SEMICOLON		{$$=$1;}
	|			VarInt						{$$=$1;cout<<"need a ';' in line "<<$$->line<<endl;}
	|			VarStruct					{$$=$1;cout<<"need a ';' in line "<<$$->line<<endl;}
	|			Opnum SEMICOLON				{$$ = $1;}
	|			Opnum %prec LOWEST			{$$=$1;cout<<"need a ';' in line "<<$$->line<<endl;}
	|			RepeatK						{$$=$1;}
	|			Condition					{$$=$1;}
	|			ReturnStmt					{$$=$1;}
	|			Writek						{$$=$1;}
	|			Readk						{$$=$1;}
	;
 
 /* 输出的语句 */
Writek:		PRINT OpnumNull SEMICOLON 
	{$$=new Node("Writek", 0);insertChildren($$, $2, new Node("$", 0));
	if($2->key == "NULL")cout<<"need a expr in line "<<$2->line<<endl;}
	|			PRINT OpnumNull/*缺少分号*/
	{$$=new Node("Writek", 0);insertChildren($$, $2, new Node("$", 0));
	if($2->key == "NULL")cout<<"need a expr in line "<<$2->line<<endl;
	cout<<"need a ';' in line "<<$2->line<<endl;}
	;

Readk:			SCANF IDdec SEMICOLON
	{$$=new Node("Readk", 0); insertChildren($$, $2, new Node("$", 0));}
	|			SCANF IDdec
	{$$=new Node("Readk", 0); insertChildren($$, $2, new Node("$", 0));
	cout<<"need a ';' in line "<<$2->line<<endl;}
 /* 返回的语句 */
 ReturnStmt:	RETURN SEMICOLON
		{$$=$1;$$->key="Return statement";}
	|			RETURN %prec LOWEST /*return后缺少了分号报错*/
		{$$=$1;$$->key="Return statement";cout<<"need a ';' in line "<<$$->line<<endl;}
	|			RETURN Opnum SEMICOLON
		{$$=$1;$$->key="Return expr statement";insertChildren($$, $2,new Node("$", 0));}
	|			RETURN Opnum %prec LOWEST  /*return后缺少了分号报错*/
		{$$=$1;$$->key="Return expr statement";insertChildren($$, $2,new Node("$", 0));cout<<"need a ';' in line "<<$$->line<<endl;}
 /* 条件结构 */
Condition:		IF LP Opnum RP CompoundK %prec LOWEST		
	{$$=new Node("Conditionif", 0);insertChildren($$,$3,$5,new Node("$", 0));}
	|			IF LP Opnum RP CompoundK ELSE CompoundK		
	{$$=new Node("Conditionelse", 0);insertChildren($$,$3,$5,$7,new Node("$", 0));}
	|			IF LP Opnum RP CompoundK ELSE Condition		
	{$$=new Node("Conditionelse", 0);insertChildren($$,$3,$5,$7,new Node("$", 0));}
 	/* 缺左括号 */
	|			IF Opnum RP CompoundK %prec LOWEST		
	{$$=new Node("Conditionif", 0);insertChildren($$,$2,$4,new Node("$", 0));
	cout<<"need a '(' in line "<<$1->line<<endl;}
	|			IF Opnum RP CompoundK ELSE CompoundK		
	{$$=new Node("Conditionelse", 0);insertChildren($$,$2,$4,$6,new Node("$", 0));
	cout<<"need a '(' in line "<<$1->line<<endl;}
	|			IF Opnum RP CompoundK ELSE Condition		
	{$$=new Node("Conditionelse", 0);insertChildren($$,$2,$4,$6,new Node("$", 0));
	cout<<"need a '(' in line "<<$1->line<<endl;}
	/* 缺右括号 */
	|			IF LP Opnum CompoundK %prec LOWEST		
	{$$=new Node("Conditionif", 0);insertChildren($$,$3,$4,new Node("$", 0));
	cout<<"need a ')' in line "<<$3->line<<endl;}
	|			IF LP Opnum CompoundK ELSE CompoundK		
	{$$=new Node("Conditionelse", 0);insertChildren($$,$3,$4,$6,new Node("$", 0));
	cout<<"need a ')' in line "<<$3->line<<endl;}
	|			IF LP Opnum CompoundK ELSE Condition		
	{$$=new Node("Conditionelse", 0);insertChildren($$,$3,$4,$6,new Node("$", 0));
	cout<<"need a ')' in line "<<$3->line<<endl;}
	/* 缺两个括号 */
	|			IF Opnum CompoundK %prec LOWEST		
	{$$=new Node("Conditionif", 0);insertChildren($$,$2,$3,new Node("$", 0));
	cout<<"need a '(' in line "<<$1->line<<endl;
	cout<<"need a ')' in line "<<$2->line<<endl;}
	|			IF Opnum CompoundK ELSE CompoundK		
	{$$=new Node("Conditionelse", 0);insertChildren($$,$2,$3,$5,new Node("$", 0));
	cout<<"need a '(' in line "<<$1->line<<endl;
	cout<<"need a ')' in line "<<$2->line<<endl;}
	|			IF Opnum CompoundK ELSE Condition		
	{$$=new Node("Conditionelse", 0);insertChildren($$,$2,$3,$5,new Node("$", 0));
	cout<<"need a '(' in line "<<$1->line<<endl;
	cout<<"need a ')' in line "<<$2->line<<endl;}
	;


 /* 循环体结构 */
RepeatK:		FOR LP ForHeader RP CompoundK
	{$$=new Node("RepeatKFor", 0);insertChildren($$, $3, $5, new Node("$", 0));}
	|			WHILE LP Opnum RP CompoundK
	{$$=new Node("RepeatKWhile", 0);insertChildren($$,$3,$5,new Node("$", 0));
	if($3->key == "NULL")cout<<"need a expr in line "<<$2->line<<endl;}
	|			WHILE LP RP CompoundK
	{$$=new Node("RepeatKWhile ", 0);insertChildren($$,new Node("NULL", 0),$4,new Node("$", 0));
	cout<<"need a expr in line "<<$2->line<<endl;}
	/* 缺左括号 */
	|			FOR ForHeader RP CompoundK
	{$$=new Node("RepeatKFor ", 0);insertChildren($$, $2, $4, new Node("$", 0));
	cout<<"need a '(' in line "<<$1->line<<endl;}
	|			WHILE OpnumNull RP CompoundK
	{$$=new Node("RepeatKWhile", 0);insertChildren($$, $2, $4, new Node("$", 0));
	if($2->key == "NULL")cout<<"need a expr in line "<<$1->line<<endl;
	cout<<"need a '(' in line "<<$1->line<<endl;}
	/* 缺右括号 */
	|			FOR LP ForHeader CompoundK
	{$$=new Node("RepeatKFor ", 0);insertChildren($$, $3, $4, new Node("$", 0));
	cout<<"need a ')' in line "<<$3->line<<endl;}
	|			WHILE LP OpnumNull CompoundK
	{$$=new Node("RepeatKWhile", 0);insertChildren($$,$3,$4,new Node("$", 0));
	if($3->key == "NULL")cout<<"need a expr in line "<<$2->line<<endl;
	cout<<"need a ')' in line "<<$2->line<<endl;}
	/* 缺少两个括号 */
	|			FOR ForHeader CompoundK
	{$$=new Node("RepeatKFor", 0);insertChildren($$, $2, $3, new Node("$", 0));
	cout<<"need a '(' in line "<<$1->line<<endl;
	cout<<"need a ')' in line "<<$2->line<<endl;}
	|			WHILE OpnumNull CompoundK
	{$$=new Node("RepeatKWhile", 0);insertChildren($$,$2,$3,new Node("$", 0));
	if($2->key == "NULL")cout<<"need a expr in line "<<$1->line<<endl;
	cout<<"need a '(' in line "<<$1->line<<endl;
	cout<<"need a ')' in line "<<$1->line<<endl;}
	;


 /* for循环小括号内三个表达式 */
ForHeader:		VarOpnum SEMICOLON OpnumNull SEMICOLON OpnumNull /* 不缺分号 */
	{$$=new Node("ForHeader", 0);insertChildren($$, $1, $3, $5, new Node("$", 0));}
	|			VarOpnum OpnumNull SEMICOLON OpnumNull /* 缺第一个分号 */
	{$$=new Node("ForHeader", 0);insertChildren($$, $1, $2, $4, new Node("$", 0));
	cout<<"need a ';' in line "<<$1->line<<endl;}
	|			VarOpnum SEMICOLON OpnumNull OpnumNull /* 缺第二个分号 */
	{$$=new Node("ForHeader", 0);insertChildren($$, $1, $3, $4, new Node("$", 0));
	cout<<"need a ';' in line "<<$3->line<<endl;}
	|			VarOpnum OpnumNull OpnumNull /* 缺两个分号 */
	{$$=new Node("ForHeader", 0);insertChildren($$, $1, $2, $3, new Node("$", 0));
	cout<<"need a ';' in line "<<$1->line<<endl;
	cout<<"need a ';' in line "<<$2->line<<endl;}
	;


 /* 声明变量 或者 声明变量并赋值 */
VarInt:		TYPE AssignExprInt
	{cout<<"varintpp"<<endl;
		$$=new Node("VarInt", 0);insertChildren($$, $1, $2, new Node("$", 0));
	$2->children[0]->type = $1->key;
	add_to_table($2->children[0]->key, $2->children[0]->type);
	}
	|		TYPE IDdec
	{$$=new Node("VarInt", 0);insertChildren($$, $1, $2, new Node("$", 0));
	$2->type = $1->key;
	$$->type = $1->type;
	add_to_table($2->key, $$->type);}
	|		VarInt COMMA IDdec
	{insertChildren($$, $3, new Node("$", 0));
	$3->type = $$->type;
	add_to_table($3->key, $$->key);}
	|		VarInt COMMA AssignExprInt
	{insertChildren($$, $3, new Node("$", 0));
	$3->children[0]->type = $$->type;
	add_to_table($3->children[0]->key, $3->children[0]->type);}
	;
	 
 /* 定义一个变量 */
AssignExprInt:		IDdec ASSIGN Opnum 
	{cout<<"varintqq"<<endl;
		$$=new Node("AssignExprInt", 0); insertChildren($$, $1, $3, new Node("$", 0));}
	;

 /* 结构体相关的初始化*/
VarStruct:		STRUCT IDdec AssignExprStruct
	{$$=new Node("VarStruct", 0);insertChildren($$, $2, $3, new Node("$", 0));}
	|		STRUCT IDdec IDdec
	{$$=new Node("VarStruct", 0);insertChildren($$, $2, $3, new Node("$", 0));}
	|		VarStruct COMMA IDdec
	{insertChildren($$, $3, new Node("$", 0));}
	|		VarStruct COMMA AssignExprStruct
	{insertChildren($$, $3, new Node("$", 0));}
	;
 /* 结构体的赋值语句*/
AssignExprStruct:	IDdec ASSIGN LBRACE AssignExprStructInner RBRACE
	{$$=new Node("AssignExprStruct", 0);insertChildren($$, $1, $4,  new Node("$", 0));}
	;
 /* 结构体的赋值语句花括号内部的内容*/
AssignExprStructInner:	DOT IDdec ASSIGN Opnum
	{$$=new Node("AssignExprStructInner", 0);insertChildren($$, $2, $4,  new Node("$", 0));}
	|	IDdec COLON Opnum
	{$$=new Node("VarStructInner", 0);insertChildren($$, $1, $3,  new Node("$", 0));}
	|	AssignExprStructInner COMMA DOT IDdec ASSIGN Opnum
	{insertChildren($$, $4, $6,  new Node("$", 0));}
	|	AssignExprStructInner COMMA IDdec COLON Opnum
	{insertChildren($$, $3, $5,  new Node("$", 0));}
	;
 /* 数组声明*/
VarArray:	TYPE IDdec LMB Const RMB
	{$$=new Node("VarArray", 0);insertChildren($$, $2, $4,  new Node("$", 0));}
	|		VarArray COMMA IDdec LMB Const RMB
	{insertChildren($$, $3, $5,  new Node("$", 0));}
	;

 /* 声明或者表达式加上 ';'*/
VarOpnum:	VarInt {$$=$1;}
	|		OpnumNull {$$=$1;}   
	/* for循环第一个式子为opnum的情况*/
	;
  /* Opnum或者NULL */
OpnumNull:		Opnum %prec LOWEST {$$=$1;}
	|			%prec LOWEST {$$=new Node("NULL", 0);}			
	;


 /* 表达式*/
Expr:		Opnum PLUS Opnum	
	{$$=new Node("Expr+", 0);insertChildren($$,$1,$3,new Node("$", 0));
	}
	|		Opnum MINUS Opnum		
	{$$=new Node("Expr-", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum MULTIPLY Opnum		
	{$$=new Node("Expr*", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum DIVIDE Opnum		
	{$$=new Node("Expr/", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum MODEL Opnum		
	{$$=new Node("Expr%", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum POW Opnum		
	{$$=new Node("Expr^", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum GREATER Opnum		
	{$$=new Node("Expr>", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum GREATEREQ Opnum		
	{$$=new Node("Expr>=", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum LESS Opnum		
	{$$=new Node("Expr<", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum LESSEQ Opnum		
	{$$=new Node("Expr<=", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum NEQUAL Opnum		
	{$$=new Node("Expr!=", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum EQUAL Opnum		
	{$$=new Node("Expr==", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum ASSIGN Opnum		
	{$$=new Node("Expr=", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum AND Opnum		
	{$$=new Node("Expr&&", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum OR Opnum		
	{$$=new Node("Expr||", 0);insertChildren($$,$1,$3,new Node("$", 0));}
	|		Opnum SELFPLUS
	{$$=$2;$$->key="Expri++";insertChildren($$,$1,new Node("$", 0));}
	|		Opnum SELFMINUS
	{$$=$2;$$->key="Expri--";insertChildren($$,$1,new Node("$", 0));}
	|		SELFPLUS Opnum		
	{$$=new Node("Expr++i", 0);insertChildren($$,$2,new Node("$", 0));}
	|		SELFMINUS Opnum		
	{$$=new Node("Expr--i", 0);insertChildren($$,$2,new Node("$", 0));}
	|		NOT Opnum		
	{$$=new Node("Expr!", 0);insertChildren($$,$2,new Node("$", 0));}
	|		ADDR Opnum		
	{$$=new Node("Expr&", 0);insertChildren($$,$2,new Node("$", 0));}
	|		POINT Opnum		
	{$$=new Node("Expr~", 0);insertChildren($$,$2,new Node("$", 0));}
	|		LP Opnum RP %prec LOWEST
	{$$=$2;}
	;
 /* 操作数*/
Opnum:		Const	{$$=$1;$$->isexpr = true;}
	|		IDdec	{$$=$1;$$->isexpr = true;}
	|		Expr 	{$$=$1;$$->isexpr = true;}
	|		Array	{$$=$1;$$->isexpr = true;}
	;
 /* 数组中的某个数*/
Array:		IDdec LMB Const RMB 
	{$$=new Node("Array", 0);insertChildren($$, $1, $3, new Node("$", 0));}
	|		IDdec LMB IDdec RMB
	{$$=new Node("Array", 0);insertChildren($$, $1, $3, new Node("$", 0));}
	;


 /* 标识符声明 */
IDdec:		ID
	{$$=$1;cout<<"pqpq"<<$1->key<<endl;}
	;
 /*常量*/
Const:		NUMBER		{$$=$1;cout<<$1->key<<endl;}
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
	// string path = "";
	// cin>>path;
	// yyin=fopen(path.c_str(), "r");
	yyin=fopen("test/1.c", "r");
	yyparse();
	gen_code(root);
	print_code();
	write_to_asm();
}
