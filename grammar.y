%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "codegen.h"

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

%token VOID
%token RETURN IF ELSE WHILE CONTINUE BREAK
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE ASSIGN

%left UMINUS // unary minus
%left NOT // not
%left BIT_NOT // bitwise not
%left MUL DIV MOD // * / %
%left PLUS MINUS // + -
%left LT LE GT GE // < <= > >=
%left EQ NE // == !=
%left BIT_AND // &
%left BIT_XOR // ^
%left BIT_OR // |
%left AND // &&
%left OR // ||
%left ASSIGN // =

%token <number> NUMBER INT 
%token <double_v> FLOAT
%token <identifier> IDENTIFIER

%type <node> param translation_unit function function_list statements statement expression declaration if_statement while_statement BREAK CONTINUE


%start translation_unit

%%

translation_unit:
    /* empty */ { root = NULL; printf("empty program\n"); }
    | function_list {
        root = createUnaryNode(NODE_PROGRAM, $1); 
    }
    ;

function_list:
    function_defination { $$ = createUnaryNode(NODE_FUNCTION_LIST, $1); }
    | function_list function_defination { $$ = createBinaryNode(NODE_FUNCTION_LIST, $1); }
    ;

function_defination:
    type IDENTIFIER LPAREN params RPAREN LBRACE statements RBRACE {
        $$ = createBinaryNode(NODE_FUNCTION, createIdentifierNode($2), $7);
    }
    ;

type:
    INT | FLOAT | VOID
    ;

params:
    /* empty */ | param_list
    ;

param_list:
    param | param_list COMMA param
    ;

param: // 函数参数
    type IDENTIFIER { // 带类型的函数参数说明这里是在定义阶段
        $$ = createParamNode($2);
    }
    | expression {/* 任何表达式都可以成为函数传参对象 */
        $$ = createUnaryNode(NODE_PARAM, $1); 
    }
    ;

statements:
    /* empty */ { $$ = NULL; printf("empty statements in this function\n"); }
    | statement {
        $$ = createUnaryNode(NODE_STATEMENT, $1); 
    }
    |statements statement {
        $$ = createBinaryNode(NODE_STATEMENT, $1, $2);
    }
    ;

statement:
    RETURN expression SEMICOLON {
        $$ = createUnaryNode(NODE_STATEMENT, $2);
    }
    | declaration
    | if_statement
    | while_statement
    | CONTINUE SEMICOLON { $$ = createUnaryNode(NODE_STATEMENT, $1);}
    | BREAK SEMICOLON { $$ = createUnaryNode(NODE_STATEMENT, $1);}
    ;

if_statement:
    IF LPAREN expression RPAREN statement {
        $$ = createBinaryNode(NODE_STATEMENT, $3, $5);
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        $$ = createBinaryNode(NODE_STATEMENT, $3, createBinaryNode(NODE_STATEMENT, $5, $7));
    }
    ;

while_statement:
    WHILE LPAREN expression RPAREN statement {
        $$ = createBinaryNode(NODE_STATEMENT, $3, $5);
    }
    ;

declaration:
    type IDENTIFIER ASSIGN expression SEMICOLON {
        $$ = createBinaryNode(NODE_STATEMENT, createIdentifierNode($2), $4);
    }
    | type IDENTIFIER SEMICOLON { $$ = createIdentifierNode($2); }


expression:
    NUMBER {
        $$ = createNumberNode($1);
    }
    | '-' expression %prec UMINUS { 
        $$ = createUnaryNode(NODE_UNARY_MINUS, $2);
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
