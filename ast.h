#ifndef AST_H
#define AST_H

typedef enum {
    NODE_TRANSLATION_UNIT, // 翻译单元节点,由自身作为右子式和一个函数定义列表节点作为左子式构成
    NODE_FUNCTION_DEFINITION, // 函数定义节点,由函数名的标识符节点作为左子式，函数体和函数列表作为右子式构成,函数列表作为左子式，复合语句节点为右子式递归构成
    NODE_FUNCTION_LIST, // 函数定义列表节点
    NODE_FUNCTION_CALL, // 函数调用节点
    NODE_PARAMETER_LIST, // 形参列表
    NODE_ARGUMENT_LIST, // 实参列表
    NODE_VARIABLE_DECLARATION, // 变量声明的节点,a=1/c/这种单独的一个单元，用,分割的算一个声明段元
    NODE_INITIALIZER, // 初始化变量节点,这一个初始化节点可能由多个变量声明节点构成
    NODE_TYPE_SPECIFIER, // 类型指定节点
    NODE_COMPOUND_STATEMENT, // 复合语句节点 {}语句,由多个或0个表达式语句节点构成
    NODE_EXPRESSION_STATEMENT, // 表达式语句节点, 例如 return语句, a = 1;, 包括函数调用，不过函数调用是他的其中一种
    NODE_IF_ELSE_STATEMENT, // if-else语句节点,由一个if和一个else语句构成
    NODE_IF_STATEMENT, // if语句节点
    NODE_ELSE_STATEMENT, // else语句节点
    NODE_WHILE_STATEMENT, // while语句节点,由一个赋值表达式的右式和一个复合语句节点构成
    NODE_RETURN_STATEMENT, // return语句节点, 由一个表达式构成
    NODE_BREAK_STATEMENT, // break语句节点
    NODE_CONTINUE_STATEMENT, // continue语句节点
    NODE_BINARY_EXPRESSION, // 二元表达式节点
    NODE_UNARY_EXPRESSION, // 一元表达式节点
    NODE_ASSIGNMENT_EXPRESSION, // 赋值表达式节点,由一个左值和一个右值构成
    NODE_IDENTIFIER, // 标识符节点,各种变量自身名称的节点单元
} NodeType;

/*
    这棵树总是先执行左子树，然后再执行右子树，右子树是不断展开延伸的，需要用到左子树的信息的
    例如：
    1. 在解析函数的时候，需要先解析函数的参数列表，然后再解析函数体，因此参数列表放在左子树，
    按照读入的顺序就是先生成左子树，右子树是否有延伸之后才关注
*/
typedef struct ASTNode {
    NodeType type;
    union {
        struct { struct ASTNode *left; struct ASTNode *right; } binary;
        struct { struct ASTNode *operand; } unary;
        int number;
        char *identifier;
        // ... 其他字段
    } data;
    struct ASTNode *next;
} ASTNode;

ASTNode *createBinaryNode(NodeType type, ASTNode *left, ASTNode *right);
ASTNode *createUnaryNode(NodeType type, ASTNode *operand);
ASTNode *createNumberNode(int number);
ASTNode *createIdentifierNode(const char *identifier);

void freeAST(ASTNode *root);

#endif // AST_H
