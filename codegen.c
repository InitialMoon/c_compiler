#include "ast.h"
#include <stdio.h>

void generateExpression(ASTNode *node) {
    if (!node) return;
    switch (node->type) {
        case NODE_EXPRESSION:
            if (node->data.binary.left && node->data.binary.right) {
                //这里先执行左边递归再执行右边
                generateExpression(node->data.binary.left);
                generateExpression(node->data.binary.right);
                printf("    ADD\n"); // 示例，实际需要根据运算符生成相应汇编代码
            } else if (node->data.unary.operand) {
                generateExpression(node->data.unary.operand);
                printf("    NEG\n"); // 示例，实际需要根据运算符生成相应汇编代码
            } else if (node->data.number) {
                printf("    PUSH %d\n", node->data.number);
            } else if (node->data.identifier) {
                printf("    LOAD %s\n", node->data.identifier);
            }
            break;
        // 处理其他类型的表达式节点
        default:
            break;
    }
}

void generateStatement(ASTNode *node) {
    if (!node) return;
    switch (node->type) {
        case NODE_STATEMENT:
            generateExpression(node->data.binary.left);
            printf("    RET\n"); // 示例，实际需要根据语句类型生成相应汇编代码
            break;
        // 处理其他类型的语句节点
        default:
            break;
    }
}

void generateAssembly(ASTNode *root) {
	printf(".intel_syntax noprefix\n");
	printf(".global main\n");
	printf(".extern printf\n");
	printf(".data\n");
	printf("format_str:\n");
	printf(".asciz \"%d\\n\"\n");
	printf(".text\n");
	printf("main:\n");
	printf("push ebp\n");
	printf("mov ebp, esp\n");
	printf("sub esp, 0x100\n");
    printf("section .text\n");
    printf("global _start\n");

    generateStatement(root);

    printf("leave\n");
    printf("ret\n");
}
