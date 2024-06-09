%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

struct var { // 函数内局部变量数据结构
	char* content; //这个词具体是什么符号
	int address; //当这个标识符是变量的时候，用来记录这个变量的地址信息
};

struct function_struct {
    struct var var_list[100]; // 变量的最大数量100
    struct var param_list[100]; // 形参的最大数量100,调用函数次数最多为100
    int param_num;
    int param_stack_address;
    int var_num;
    int var_stack_address;
    char* func_name;
};

struct function_struct funcs[100];
int function_num = 0;

int var_address(char* s, struct function_struct* func) { // 如果存在变量就返回其定义过的地址
    // 先在实参中寻找是否有相同的变量名，如果有就直接返回这个的地址，否则才去找局部变量
    for (int i = 0; i < func->param_num; i++) {
        if (strcmp(s, func->param_list[i].content) == 0) {
            // 下面不直接返回，而是和最大参数地址相对8区补，进行对称的操作是为了巧妙实现倒车入栈
            // 因为传入的参数是顺序的，所以我们只要反向对称取址即可实现同样的效果
            return 8 + func->param_stack_address - func->param_list[i].address;
        }
    }

    for (int i = 0; i < func->var_num; i++) {
        if (strcmp(s, func->var_list[i].content) == 0) {
            return func->var_list[i].address;
        }
    }

    func->var_stack_address -= 4;
    struct var new_var;
    new_var.content = strdup(s);
    new_var.address = func->var_stack_address;
    func->var_list[func->var_num++] = new_var;
    return func->var_stack_address;
}

void param_address(char* s, struct function_struct* func) { // 如果存在变量就返回其定义过的地址
    for (int i = 0; i < func->param_num; i++) {
        if (strcmp(s, func->param_list[i].content) == 0) {
            return;
        }
    }
    func->param_stack_address += 4;
    struct var new_var;
    new_var.content = strdup(s);
    new_var.address = func->param_stack_address;
    func->param_list[func->param_num++] = new_var;
}

struct function_struct* analysised_func;

%}

%union {
    char *identifier;
    int ival;
}

%token <identifier> VOID INT
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
    /* empty */ {
        printf(".intel_syntax noprefix\n");
        printf(".global println_int\n");
        printf(".data\n");
        printf(".extern printf\n");
        printf("format_str:\n");
        printf(".asciz \"%%d\\n\"\n");
        printf(".text\n");
        // 预定义println_int函数
        printf("\nprintln_int:\n");
        printf("push ebp\nmov ebp, esp\nsub esp, 4\n");
        printf("push DWORD PTR[ebp+8]\n");
        printf("push offset format_str\n");
        printf("call printf\n");
        printf("add esp, 8\n");
        printf("leave\n");
        printf("ret\n");
    }
    | translation_unit function_defination {
    }
    ;

function_defination:
    function_name LPAREN params RPAREN LBRACE statements RBRACE {
        printf("leave\n");
        printf("ret\n");
        function_num++;
    }
    ;

function_name:
    return_type IDENTIFIER {
        printf("\n.global %s\n", $2);
        printf("%s:\n", $2);
        printf("push ebp\n");
        printf("mov ebp, esp\n");
        printf("sub esp, 0x100\n");
        struct function_struct nf;
        nf.func_name = strdup($2);
        nf.param_num = 0;
        nf.param_stack_address = 4;
        nf.var_num = 0;
        nf.var_stack_address = 0;
        funcs[function_num] = nf;
        analysised_func = &funcs[function_num];
    }
    ;

// 函数调用
function_call:
    IDENTIFIER LPAREN arguments RPAREN {
        printf("call %s\n", $1);
        // printf("add esp, 4\n");
    }
    ;

// 类型标识定义
return_type:
    INT { }
    | VOID { }
    ;

// 形参定义
params:
    /* empty */ {
    }
    | INT IDENTIFIER { // 带类型的函数参数说明这里是在定义阶段
        param_address($2, analysised_func);
    }
    | params COMMA INT IDENTIFIER {
        param_address($4, analysised_func);
    }
    ;


// 实参形式定义
arguments:
    /* empty */
    | expression {
        printf("push eax\n");
    }
    | arguments COMMA expression {
        printf("push eax\n");
    }
    ;

// 语句定义
statements:
    /* empty */ {  }
    | statements statement {
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
    | function_call SEMICOLON
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
        printf("mov DWORD PTR[ebp%+d], eax\n", var_address($1, analysised_func));
    }
    ;

// 变量定义
declaration:
    INT assign 
    | INT IDENTIFIER {
        printf("mov DWORD PTR[ebp%+d], 0\n", var_address($2, analysised_func)); // 默认初始化值为0
    }
    | declaration COMMA IDENTIFIER { //解析形式,a
        printf("mov DWORD PTR[ebp%+d], 0\n", var_address($3, analysised_func)); // 默认初始化值为0
    }
    | declaration COMMA assign 
    ;

// 表达式定义
expression:
    // 3种终结符
    NUMBER {
        printf("mov eax, %d\n", $1);
    }
    | function_call {
    }
    | IDENTIFIER {
        printf("push DWORD PTR[ebp%+d]\n", var_address($1, analysised_func));
    }
    // 3种单目运算符
    | MINUS expression %prec NOT {
        printf("neg eax\npush eax\n");
    }
    | NOT expression {
        printf("test eax, eax\nsetz al\nmovzx eax, al\npush eax\n");
    }
    | BIT_NOT expression {
        printf("not eax\ncmp eax, 0\nsete al\nand eax, 1\npush eax\n");
    }
    // 双目运算符
    | expression PLUS expression {
        printf("pop ebx\npop eax\n");
        printf("add eax, ebx\npush eax\n");
    }
    | expression MINUS expression {
        printf("pop ebx\npop eax\n");
        printf("sub eax, ebx\npush eax\n");
    }
    | expression MUL expression {
        printf("pop ebx\npop eax\n");
        printf("imul eax, ebx\npush eax\n");
    }
    | expression DIV expression {
        printf("pop ebx\npop eax\n");
        printf("cdq\nidiv ebx\npush eax\n");
    }
    | expression MOD expression {
        printf("pop ebx\npop eax\n");
        printf("cdq\nidiv ebx\npush eax\n");
    }
    | expression LT expression {
        printf("pop ebx\npop eax\n");
        printf("cmp eax, ebx\nsetl al\nmovzx eax, al\npush eax\n");
    }
    | expression LE expression {
        printf("pop ebx\npop eax\n");
        printf("cmp eax, ebx\nsetle al\nmovzx eax, al\npush eax\n");
    }
    | expression GT expression {
        printf("pop ebx\npop eax\n");
        printf("cmp eax, ebx\nsetg al\nmovzx eax, al\npush eax\n");
    }
    | expression GE expression {
        printf("pop ebx\npop eax\n");
        printf("cmp eax, ebx\nsetge al\nmovzx eax, al\npush eax\n");
    }
    | expression EQ expression {
        printf("pop ebx\npop eax\n");
        printf("cmp eax, ebx\nsete al\nmovzx eax, al\npush eax\n");
    }
    | expression NE expression {
        printf("pop ebx\npop eax\n");
        printf("cmp eax, ebx\nsetne al\nmovzx eax, al\npush eax\n");
    }
    | expression AND expression {
        printf("pop ebx\npop eax\n");
        printf("and eax, ebx\npush eax\n");
    }
    | expression OR expression {
        printf("pop ebx\npop eax\n");
        printf("or eax, ebx\npush eax\n");
    }
    | expression BIT_AND expression {
        printf("pop ebx\npop eax\n");
        printf("and eax, ebx\npush eax\n");
    }
    | expression BIT_OR expression {
        printf("pop ebx\npop eax\n");
        printf("or eax, ebx\npush eax\n");
    }
    | expression BIT_XOR expression {
        printf("pop ebx\npop eax\n");
        printf("xor eax, ebx\npush eax\n");
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
