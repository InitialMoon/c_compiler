%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "codegen.hpp"

extern FILE *yyin;

void yyerror(const char *s);
extern int yylex(void);

struct ASTNode *root;
%}

%union {
    int number;
    float double_v;
    char *identifier;
    struct ASTNode *node;
}

%token RETURN IF ELSE WHILE CONTINUE BREAK
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE 

%right ASSIGN

%left OR // ||
%left AND // &&
%left BIT_OR // |
%left BIT_XOR // ^
%left BIT_AND // &
%left EQ NE // == !=
%left LT LE GT GE // < <= > >=
%left PLUS MINUS // + -
%left MUL DIV MOD // * / %

%right UMINUS BIT_NOT NOT 

%token <number> NUMBER
%token <identifier> IDENTIFIER VOID INT FLOAT

%type <node> translation_unit function_defination function_list statements type function_call
%type <node> statement expression declaration if_statement else_statement while_statement BREAK CONTINUE
%type <node> argument argument_list arguments if_else_statement assign param param_list params

%start translation_unit

%%

// 整个翻译单元定义
translation_unit:
    /* empty */ { root = NULL; printf("empty program\n"); }
    | function_list {
        root = createUnaryNode(NODE_TRANSLATION_UNIT, $1); 
    }
    ;

// 函数定义
function_list:
    function_defination { $$ = createBinaryNode(NODE_FUNCTION_LIST, $1, NULL); }
    | function_list function_defination  { $$ = createBinaryNode(NODE_FUNCTION_LIST, $2, $1); }
    ;

function_defination:
    type IDENTIFIER LPAREN params RPAREN LBRACE statements RBRACE {
        $$ = createFourNode(NODE_FUNCTION_DEFINITION, $1, createIdentifierNode($2), $4, $7);
    }
    ;

// 函数调用
function_call:
    IDENTIFIER LPAREN arguments RPAREN {
        $$ = createBinaryNode(NODE_FUNCTION_CALL, createIdentifierNode($1), $3);
    }
    ;


// 类型标识定义
type:
    INT { $$ = createUnaryNode(NODE_TYPE_SPECIFIER, createIdentifierNode($1));}
    | VOID { $$ = createUnaryNode(NODE_TYPE_SPECIFIER, createIdentifierNode($1));}
    | FLOAT { $$ = createUnaryNode(NODE_TYPE_SPECIFIER, createIdentifierNode($1));}
    ;

// 形参定义
params:
    /* empty */ { $$ = NULL; }
    | param_list { $$ = $1; }
    ;

param_list:
    param { $$ = createBinaryNode(NODE_PARAMETER_LIST, $1, NULL); }
    | param_list COMMA param { $$ = createBinaryNode(NODE_PARAMETER_LIST, $3, $1); }
    ;

param: 
    type IDENTIFIER { // 带类型的函数参数说明这里是在定义阶段
        $$ = createBinaryNode(NODE_PARAMETER, $1, createIdentifierNode($2));
    }
    ;

// 实参形式定义
arguments:
    /* empty */ { $$ = NULL; }
    | argument_list { $$ = $1 ;}
    ;

argument_list:
    argument { $$ = createBinaryNode(NODE_ARGUMENT_LIST, $1, NULL); }
    | argument_list COMMA argument { $$ = createBinaryNode(NODE_ARGUMENT_LIST, $3, $1); }
    ;

argument: 
    expression { $$ = createUnaryNode(NODE_EXPRESSION, $1); }
    ;

// 语句定义
statements:
    /* empty */ { $$ = NULL; printf("empty statements in this function\n"); }
    | statement {
        $$ = createBinaryNode(NODE_COMPOUND_STATEMENT, $1, NULL);
    }
    |statements statement {
        $$ = createBinaryNode(NODE_COMPOUND_STATEMENT, $1, $2);
    }
    ;

statement:
    RETURN expression SEMICOLON {
        $$ = createUnaryNode(NODE_RETURN_STATEMENT, $2);
    }
    | CONTINUE SEMICOLON {
        $$ = createUnaryNode(NODE_CONTINUE_STATEMENT, $1);
    }
    | BREAK SEMICOLON {
        $$ = createUnaryNode(NODE_BREAK_STATEMENT, $1);
    }
    | assign {
        $$ = $1;
    }
    | declaration {
        $$ = $1;
    }
    | function_call SEMICOLON {
        $$ = $1;
    }
    | if_statement {
        $$ = $1;
    }
    | if_else_statement {
        $$ = $1;
    }
    | while_statement {
        $$ = $1;
    }
    ;

// if_else语句定义
if_statement:
    IF LPAREN expression RPAREN LBRACE statement RBRACE {
        $$ = createBinaryNode(NODE_IF_STATEMENT, $3, $6);
    }
    ;
else_statement:
    ELSE LBRACE statement RBRACE {
        $$ = createUnaryNode(NODE_ELSE_STATEMENT, $3);
    }
    ;

if_else_statement:
    if_statement else_statement {
        $$ = createBinaryNode(NODE_IF_ELSE_STATEMENT, $1, $2);
    }
    ;

// while语句定义
while_statement:
    WHILE LPAREN expression RPAREN LBRACE statement RBRACE {
        $$ = createBinaryNode(NODE_WHILE_STATEMENT, $3, $6);
    }
    ;

// 变量赋值
assign:
    IDENTIFIER ASSIGN expression SEMICOLON {
        $$ = createBinaryNode(NODE_ASSIGNMENT_STATEMENT, createIdentifierNode($1), $3);
    }
    ;

// 变量定义
declaration:
    type IDENTIFIER ASSIGN expression SEMICOLON {
        $$ = createBinaryNode(NODE_INITIALIZER, createIdentifierNode($2), $4);
    }
    | type IDENTIFIER SEMICOLON { $$ = createIdentifierNode($2); }
    ;

// 表达式定义
expression:
    NUMBER {
        $$ = createNumberNode($1);
    }
    | '-' expression %prec UMINUS { 
        $$ = createUnaryNode(NODE_UNARY_EXPRESSION, $2);
    }
    | function_call {
        $$ = createUnaryNode(NODE_EXPRESSION, $1);
    }
    | IDENTIFIER {
        $$ = createIdentifierNode($1);
    }
    | expression PLUS expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression MINUS expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression MUL expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression DIV expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression MOD expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression LT expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression LE expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression GT expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression GE expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression EQ expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression NE expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression AND expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression OR expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression BIT_AND expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression BIT_OR expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | expression BIT_XOR expression {
        $$ = createBinaryNode(NODE_EXPRESSION, $1, $3);
    }
    | MINUS expression %prec NOT {
        $$ = createUnaryNode(NODE_EXPRESSION, $2);
    }
    | NOT expression {
        $$ = createUnaryNode(NODE_EXPRESSION, $2);
    }
    | BIT_NOT expression {
        $$ = createUnaryNode(NODE_EXPRESSION, $2);
    }
    | LPAREN expression RPAREN {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input-file>\n", argv[0]);
        return 1;
    }

    // 打开输入文件
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error opening input file");
        return 1;
    }

    // 调用解析器
    if (yyparse() == 0) {
        // 解析成功，生成汇编代码
        generateAssembly(root);
        freeAST(root);
        fclose(yyin);
        return 0;
    } else {
        fclose(yyin);
        return 1;
    }
}
