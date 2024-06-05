#ifndef AST_H
#define AST_H

typedef enum {
    NODE_PROGRAM,
    NODE_FUNCTION,
    NODE_STATEMENT,
    NODE_EXPRESSION,
    // ... 其他节点类型
} NodeType;

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
