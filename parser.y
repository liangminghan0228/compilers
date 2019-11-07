%{
	#include"tree.h"
	extern int yylex();
	int yyerror(const char* msg);
	/*新建一个节点，并且将从下方传递来的节点加入其子结点*/
	void print(Node* p, int interval)
	{
		for(int i=0;i<interval;i++)
		{
			if(i<interval-2)
			{
				cout<<"| ";
			}
			else if(i==interval-2)
			{
				cout<<"|___>";
			}
			
		}
		cout<<p->key<<endl;
		for(int i=0;i<p->children.size();i++)
		{
			print(p->children[i], interval+1);
		}
	}
	void insertChildren(Node*par, ...)
	{
	    va_list list;
	    va_start(list,par);
	    Node *child;
		int count=0;
	    while(1)
	    {
	         count++;
			 child = va_arg(list, Node*);
	         if(child == 0)
	         {    
				   break;
	         }
	         par->addChild(child);    
	     }
	     va_end(list);
	}
	bool returnError(Node*p,bool isInt)//有语法错误返回true
	{
		//如果这个节点不为空且为return、
		if(p && p->key == "Return statement")
		{
			if(isInt)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else if(p && p->key == "Return expr statement")
		{
			if(isInt)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		bool res = false;
		for(int i = 0; i < p->children.size(); i++)
		{
			res = res || returnError(p->children[i], isInt);
		}
		if(!isInt)
		{
			return res;
		}
		return true;
	}
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
%type<node> CompoundK Content Conclude Var Expr Type Opnum RepeatK Condition IDdec Const s

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
%nonassoc RETURN
%%
 /* 开始符号 */
s : 	INT MAIN LP RP CompoundK 
		{
			$$=$5;
			if(!returnError($$,true))
			{
				print($$, 2);
			}
			else
			{
				cout<<"return error : need a return statement or expr after return"<<endl;
			}
		}
	|	VOID MAIN LP RP CompoundK 
		{
			$$=$5;
			if(!returnError($$,false))
			{
				print($$, 2);
			}
			else
			{
				cout<<"return error : unexpected expr after return"<<endl;
			}
		}
	;

 /* 大括号包起来的部分*/
CompoundK :		LBRACE Content RBRACE {$$=$2;}
	;

 /* 大括号里包含的内容*/
Content :		Conclude %prec LOW		
		{$$=new Node("CompoundK statement", 0);insertChildren($$,$1,NULL);}
	|			Content Conclude	%prec LOW	
		{insertChildren($$,$2,NULL);}
	|			Conclude RETURN SEMICOLON	
		{$$=new Node("CompoundK statement", 0);$2=new Node("Return statement", 0);insertChildren($$,$1,$2,NULL);}
	|			Content Conclude RETURN SEMICOLON	
		{$3=new Node("Return statement", 0);insertChildren($$,$2,$3,NULL);}
	|			Conclude RETURN Opnum SEMICOLON	
		{$$=new Node("CompoundK statement", 0);$2=new Node("Return expr statement", 0);insertChildren($2,$3,NULL);insertChildren($$,$1,$2,NULL);}
	|			Content Conclude RETURN Opnum SEMICOLON	
		{$3=new Node("Return expr statement", 0);insertChildren($3,$4,NULL);insertChildren($$,$2,$3,NULL);}
	;
 /* 大括号里包含的内容的具体归纳 */
Conclude :		Var			{$$=$1;}
	|			Expr SEMICOLON		{$$=$1;}
	|			RepeatK				{$$=$1;}
	|			Condition			{$$=$1;}
	;
 /* 条件结构 */
Condition :		IF LP Expr RP CompoundK %prec LOW		
{$$=new Node("Condition statement,only if", 0);insertChildren($$,$3,$5,NULL);}
	|			IF LP Expr RP CompoundK ELSE CompoundK		
	{$$=new Node("Condition statement,with else", 0);insertChildren($$,$3,$5,$7,NULL);}
	|			IF LP Expr RP CompoundK ELSE Condition		
	{$$=new Node("Condition statement,with else if", 0);insertChildren($$,$3,$5,$7,NULL);}
	;
 /* 循环体结构 */
RepeatK :		FOR LP  Var Expr SEMICOLON Expr RP CompoundK		
{$$=new Node("RepeatK statement, for ", 0);insertChildren($$,$3,$4,$6,$8,NULL);}
	|			WHILE LP Expr RP CompoundK		
{$$=new Node("RepeatK statement, while ", 0);insertChildren($$,$3,$5,NULL);}
	;
 /* 声明变量 或者 声明变量并赋值 */
Var :		Type IDdec ASSIGN Opnum SEMICOLON
{$$=new Node("Var Declaration with Assign", 0);insertChildren($$,$1,$2,$4,NULL);}
	|		Type IDdec	SEMICOLON	
{$$=new Node("Var Declaration ", 0);insertChildren($$,$1,$2,NULL);}
	;
 /* 类型声明 */
Type :		INT {$$=new Node("Type Specifier, int", 0);}
	;

 /* 表达式*/
Expr :		Opnum PLUS Opnum	
	{$$=new Node("Expr,op : +", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum MINUS Opnum		
	{$$=new Node("Expr,op : -", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum MULTIPLY Opnum		
	{$$=new Node("Expr,op : *", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum DIVIDE Opnum		
	{$$=new Node("Expr,op : /", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum MODEL Opnum		
	{$$=new Node("Expr,op : %", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum POW Opnum		
	{$$=new Node("Expr,op : ^", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum GREATER Opnum		
	{$$=new Node("Expr,op : >", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum GREATEREQ Opnum		
	{$$=new Node("Expr,op : >=", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum LESS Opnum		
	{$$=new Node("Expr,op : <", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum LESSEQ Opnum		
	{$$=new Node("Expr,op : <=", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum NEQUAL Opnum		
	{$$=new Node("Expr,op : !=", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum EQUAL Opnum		
	{$$=new Node("Expr,op : ==", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum ASSIGN Opnum		
	{$$=new Node("Expr,op : =", 0);insertChildren($$,$1,$3,NULL);}
	|		Opnum SELFPLUS		
	{$$=new Node("Expr,op : i++", 0);insertChildren($$,$1,NULL);}
	|		Opnum SELFMINUS		
	{$$=new Node("Expr,op : i--", 0);insertChildren($$,$1,NULL);}
	|		SELFPLUS Opnum		
	{$$=new Node("Expr,op : ++i", 0);insertChildren($$,$2,NULL);}
	|		SELFMINUS Opnum		
	{$$=new Node("Expr,op : --i", 0);insertChildren($$,$2,NULL);}
	|		NOT Opnum		
	{$$=new Node("Expr,op : !", 0);insertChildren($$,$2,NULL);}
	|		LP Opnum RP
	{$$=new Node("Expr,op : ()", 0);insertChildren($$,$2,NULL);}	
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
