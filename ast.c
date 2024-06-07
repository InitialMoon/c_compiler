#include "ast.h"
#include <stdlib.h>
#include <string.h>

ASTNode *createFourNode(NodeType type, ASTNode *n0, ASTNode *n1, ASTNode *n2, ASTNode *n3) {
    ASTNode *node = malloc(sizeof(ASTNode));
    node->type = type;
    node->data.four.n0 = n0;
    node->data.four.n1 = n1;
    node->data.four.n2 = n2;
    node->data.four.n3 = n3;
    node->next = NULL;
    return node;
}

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
    node->type = NODE_VALUE;
    node->data.number = number;
    node->next = NULL;
    return node;
}

ASTNode *createIdentifierNode(const char *identifier) {
    ASTNode *node = malloc(sizeof(ASTNode));
    node->type = NODE_IDENTIFIER;
    node->data.identifier = (char *)malloc(strlen(identifier) + 1);
    strcpy(node->data.identifier, identifier);
    node->next = NULL;
    return node;
}

void freeAST(ASTNode *root) {
    if (!root) return;
    switch (root->type) {
        case NODE_ARGUMENT:
            freeAST(root->data.binary.left);
            freeAST(root->data.binary.right);
            break;
        case NODE_TRANSLATION_UNIT:
            freeAST(root->data.unary.operand);
        // 处理其他类型节点
        default:
            break;
    }
    free(root);
}
