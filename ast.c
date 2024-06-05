#include "ast.h"
#include <stdlib.h>
#include <string.h>

ASTNode *createBinaryNode(NodeType type, ASTNode *left, ASTNode *right) {
    ASTNode *node = malloc(sizeof(ASTNode));
    node->type = type;
    node->data.binary.left = left;
    node->data.binary.right = right;
    node->next = NULL;
    return node;
}

ASTNode *createUnaryNode(NodeType type, ASTNode *operand) {
    ASTNode *node = malloc(sizeof(ASTNode));
    node->type = type;
    node->data.unary.operand = operand;
    node->next = NULL;
    return node;
}

ASTNode *createNumberNode(int number) {
    ASTNode *node = malloc(sizeof(ASTNode));
    node->type = NODE_EXPRESSION;
    node->data.number = number;
    node->next = NULL;
    return node;
}

ASTNode *createIdentifierNode(const char *identifier) {
    ASTNode *node = malloc(sizeof(ASTNode));
    node->type = NODE_EXPRESSION;
    node->data.identifier = strdup(identifier);
    node->next = NULL;
    return node;
}

void freeAST(ASTNode *root) {
    if (!root) return;
    switch (root->type) {
        case NODE_PROGRAM:
        case NODE_FUNCTION:
        case NODE_STATEMENT:
        case NODE_EXPRESSION:
            freeAST(root->data.binary.left);
            freeAST(root->data.binary.right);
            break;
        // 处理其他类型节点
        default:
            break;
    }
    free(root);
}
