%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

void yyerror(const char *s);
extern int yylex(void);

ASTNode *root;
%}

%union {
    int number;
    char *identifier;
    ASTNode *node;
}

%token INT FLOAT RETURN IF ELSE WHILE CONTINUE BREAK
%token NUMBER IDENTIFIER
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE ASSIGN
%token PLUS MINUS MUL DIV MOD LT LE GT GE EQ NE AND OR BIT_AND BIT_OR BIT_XOR NOT BIT_NOT

%type <node> program function statements statement expression declaration if_statement while_statement

%%

program:
    function { root = $1; }
    ;

function:
    type IDENTIFIER LPAREN params RPAREN LBRACE statements RBRACE {
        $$ = createBinaryNode(NODE_FUNCTION, createIdentifierNode($2), $7);
    }
    ;

type:
    INT | FLOAT
    ;

params:
    /* empty */ | param_list
    ;

param_list:
    param | param_list COMMA param
    ;

param:
    type IDENTIFIER
    ;

statements:
    /* empty */ | statements statement
    ;

statement:
    RETURN expression SEMICOLON {
        $$ = createUnaryNode(NODE_STATEMENT, $2);
    }
    | declaration
    | if_statement
    | while_statement
    | CONTINUE SEMICOLON
    | BREAK SEMICOLON
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
    | type IDENTIFIER SEMICOLON
    ;

expression:
    NUMBER {
        $$ = createNumberNode($1);
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

int main(void) {
    if (yyparse() == 0) {
        // 解析成功，生成汇编代码
        generateAssembly(root);
        freeAST(root);
        return 0;
    } else {
        return 1;
    }
}
