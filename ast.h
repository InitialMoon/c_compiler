#ifndef AST_H
#define AST_H

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    NODE_TRANSLATION_UNIT, // 翻译单元节点: 由自身作为右子式和一个函数定义列表节点作为左子式构成
    NODE_FUNCTION_DEFINITION, // 函数定义节点,由函数名的标识符节点作为左子式，函数体和函数列表作为右子式构成,函数列表作为左子式，复合语句节点为右子式递归构成
    NODE_FUNCTION_LIST, // 函数定义列表节点: 由自身作为右子式，函数定义节点作为左子式递归构成
    NODE_FUNCTION_CALL, // 函数调用节点: 由函数名的标识符节点作为左子式，实参列表作为右子式构成,
    NODE_PARAMETER_LIST, // 形参列表，由自身作为右子式，形参节点作为左子式递归构成
    NODE_PARAMETER, // 形参节点, 终结符，由一个类型指定节点和标识符节点构成
    NODE_ARGUMENT_LIST, // 实参列表, 由自身作为右子式，实参节点作为左子式递归构成
    NODE_ARGUMENT, // 实参节点, 终结符, 由能返回值的一个表达式构成
    NODE_VARIABLE_DECLARATION, // 变量声明的节点,a=1/c/这种单独的一个单元，用,分割的算一个声明段元, 由自身作为右子式，变量定义列表作为左子式递归构成
    NODE_INITIALIZER, // 初始化变量节点,这一个初始化节点可能由多个变量声明节点构成
    NODE_TYPE_SPECIFIER, // 类型指定节点
    NODE_COMPOUND_STATEMENT, // 复合语句节点 {}语句,由多个或0个表达式语句节点构成
    NODE_IF_ELSE_STATEMENT, // if-else语句节点,由一个if和一个else语句构成
    NODE_IF_STATEMENT, // if语句节点
    NODE_ELSE_STATEMENT, // else语句节点
    NODE_WHILE_STATEMENT, // while语句节点,由一个赋值表达式的右式和一个复合语句节点构成
    NODE_RETURN_STATEMENT, // return语句节点, 由一个表达式构成
    NODE_BREAK_STATEMENT, // break语句节点
    NODE_CONTINUE_STATEMENT, // continue语句节点
    NODE_ASSIGNMENT_STATEMENT, // 赋值表达式节点,由一个左值和一个右值构成,左值是一个标识符节点，右值值表达式节点
    NODE_EXPRESSION, // 值表达式节点, 终结符, 例如 1, a, 函数调用,复杂的计算式(是有一元表达式和二元表达式递归构成的)
    NODE_BINARY_EXPRESSION, // 二元表达式节点
    NODE_UNARY_EXPRESSION, // 一元表达式节点
    NODE_VALUE, // 一元表达式节点
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
        struct { struct ASTNode *n0; struct ASTNode *n1; struct ASTNode *n2; struct ASTNode *n3; } four;
        struct { struct ASTNode *left; struct ASTNode *right; } binary;
        struct { struct ASTNode *operand; } unary;
        int number;
        char *identifier;
        // ... 其他字段
    } data;
    struct ASTNode *next;
} ASTNode;

ASTNode *createFourNode(NodeType type, ASTNode *n0, ASTNode *n1, ASTNode *n2, ASTNode *n3);
ASTNode *createBinaryNode(NodeType type, ASTNode *left, ASTNode *right);
ASTNode *createUnaryNode(NodeType type, ASTNode *operand);
ASTNode *createNumberNode(int number);
// ASTNode *createIdentifierNode(NodeType type, const char *identifier);
ASTNode *createIdentifierNode(const char *identifier);

void freeAST(ASTNode *root);

#ifdef __cplusplus
}
#endif

#endif // AST_H
