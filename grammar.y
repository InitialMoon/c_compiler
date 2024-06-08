%{
#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;

void yyerror(const char *s);
extern int yylex(void);

int ii = 0, itop = -1, istack[100];
int ww = 0, wtop = -1, wstack[100];

#define _BEG_IF     {istack[++itop] = ++ii;}
#define _END_IF     {itop--;}
#define _i          (istack[itop])

#define _BEG_WHILE  {wstack[++wtop] = ++ww;}
#define _END_WHILE  {wtop--;}
#define _w          (wstack[wtop])

%}

%union {
    char *identifier;
    int ival;
}

%token VOID INT
%token RETURN IF ELSE WHILE CONTINUE BREAK
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE 
%token <identifier> IDENTIFIER
%token <ival> NUMBER

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


%start translation_unit

%%

// 整个翻译单元定义
translation_unit:
    /* empty */ { printf("empty program\n"); }
    | translation_unit function_defination 
    ;

function_defination:
    type IDENTIFIER LPAREN params RPAREN LBRACE statements RBRACE {
        printf("new function %s\n", $2);
    }
    ;

// 函数调用
function_call:
    IDENTIFIER LPAREN arguments RPAREN {
    }
    ;


// 类型标识定义
type:
    INT { }
    | VOID { }
    ;

// 形参定义
params:
    /* empty */ {  }
    | param_list {  }
    ;

param_list:
    param {  }
    | param_list COMMA param {  }
    ;

param: 
    type IDENTIFIER { // 带类型的函数参数说明这里是在定义阶段
    }
    ;

// 实参形式定义
arguments:
    /* empty */ {  }
    | argument_list { }
    ;

argument_list:
    argument {  }
    | argument_list COMMA argument {  }
    ;

argument: 
    expression {  }
    ;

// 语句定义
statements:
    /* empty */ {  }
    |statements statement {
    }
    ;

statement:
    RETURN expression SEMICOLON {
    }
    | CONTINUE SEMICOLON {
    }
    | BREAK SEMICOLON {
    }
    | assign  SEMICOLON {
    }
    | declaration SEMICOLON {
    }
    | function_call SEMICOLON {
    }
    | if_statement {
    }
    | if_else_statement {
    }
    | while_statement {
    }
    ;

// if_else语句定义
if_statement:
    IF LPAREN expression RPAREN LBRACE statement RBRACE {
    }
    ;
else_statement:
    ELSE LBRACE statement RBRACE {
    }
    ;

if_else_statement:
    if_statement else_statement {
    }
    ;

// while语句定义
while_statement:
    WHILE LPAREN expression RPAREN LBRACE statement RBRACE {
    }
    ;

// 变量赋值
assign:
    IDENTIFIER ASSIGN expression {
    }
    ;

// 变量定义
declaration:
    type assign {
    }
    | type IDENTIFIER {
    }
    | declaration COMMA IDENTIFIER { //解析形式,a
    }
    | declaration COMMA assign { //解析, a = expression
    }
    ;

// 表达式定义
expression:
    // 3种终结符
    NUMBER {
    }
    | function_call {
    }
    | IDENTIFIER {
    }
    // 3种单目运算符
    | UMINUS expression { 
    }
    | NOT expression {
    }
    | BIT_NOT expression {
    }
    // 双目运算符
    | expression PLUS expression {
    }
    | expression MINUS expression {
    }
    | expression MUL expression {
    }
    | expression DIV expression {
    }
    | expression MOD expression {
    }
    | expression LT expression {
    }
    | expression LE expression {
    }
    | expression GT expression {
    }
    | expression GE expression {
    }
    | expression EQ expression {
    }
    | expression NE expression {
    }
    | expression AND expression {
    }
    | expression OR expression {
    }
    | expression BIT_AND expression {
    }
    | expression BIT_OR expression {
    }
    | expression BIT_XOR expression {
    }
    // 括号
    | LPAREN expression RPAREN {
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
        fclose(yyin);
        return 0;
    } else {
        fclose(yyin);
        return 1;
    }
}
