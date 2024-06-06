#include "ast.h"
#include "codegen.hpp"
#include <iostream>
#include <map>
#include <string>
#include <set>
#include <list>
#include <vector>

using namespace std;

struct function_info {
    string name;
    list<string> args; // 因为参数只可能是int类型，因此只需要记录变量名即可
    list<string> assemble_body; // 记录函数对应的汇编代码
    map<string, int> variable_address;// 记录所有的变量名，以及其对应的地址
    string return_type;
};

map<string, int> Variable_Address;// 记录所有的变量名，以及其对应的地址
vector<function_info> function_list;
map<string, list<string>> function_assemble;// 记录所有的变量名，以及其对应的地址
list<string> compiler_src; // 汇编结果


void analysis_function_call(ASTNode *node) {
    if (!node) return;
}

void analysis_initial_var(ASTNode *node) { // 需要递归处理
    if (!node) return;
}

void analysis_return(ASTNode *node) { // 需要递归处理
    if (!node) return;
}

void analysis_if_else(ASTNode *node) { // 需要递归处理
    if (!node) return;
}

void analysis_while(ASTNode *node) { // 需要递归处理
    if (!node) return;
}

void analysis_assign(ASTNode *node) { // 需要递归处理
    if (!node) return;
}

list<string> analysis_statements(ASTNode *node) {
    if (!node) return compiler_src;
    switch (node->type) {
        case NODE_RETURN_STATEMENT:
            analysis_return(node);
            break;
        case NODE_CONTINUE_STATEMENT:
            break;
        case NODE_BREAK_STATEMENT:
            break;
        case NODE_ASSIGNMENT_STATEMENT:
            analysis_assign(node);
            break;
        case NODE_INITIALIZER:
            analysis_initial_var(node);
            break;
        case NODE_FUNCTION_CALL:
            analysis_function_call(node);
            break;
        case NODE_IF_ELSE_STATEMENT:
            analysis_if_else(node);
            break;
        case NODE_WHILE_STATEMENT:
            analysis_while(node);
            break;
        case NODE_IF_STATEMENT:
            analysis_if_else(node);
            break;
        case NODE_COMPOUND_STATEMENT:
            printf("NODE_STATEMENT_LIST\n"); 
            analysis_statements(node);
            break;
    }
}

list<string> analysis_parameter_list(ASTNode *node) {
    if (!node) return compiler_src;
    switch (node->type) {
        case NODE_COMPOUND_STATEMENT:
            printf("NODE_STATEMENT_LIST\n"); 
            analysis_statements(node);
            break;
    }
}

void analysis_function_definition(ASTNode *node) {
    if (!node) return ;
    function_info new_function;
    new_function.name = node->data.four.n1->data.identifier;
    new_function.return_type = node->data.four.n0->data.identifier;
    new_function.args = analysis_parameter_list(node->data.four.n2);
    new_function.assemble_body = analysis_statements(node->data.four.n3);
    function_list.push_back(new_function);
}

void analysis_function_list (ASTNode *node) {
    if (!node) return;
    switch (node->type) {
        case NODE_FUNCTION_LIST:
            printf("NODE_FUNCTION_LIST\n"); 
            analysis_function_list(node->data.binary.left);
            analysis_function_list(node->data.binary.right);
            break;
        case NODE_FUNCTION_DEFINITION:
            printf("NODE_FUNCTION_DEFINITION\n"); 
            analysis_function_definition(node);
            break;
        default:
            printf("Unknown node type in function list\n");
            break;
    }
}

void translateAST(ASTNode *node) {
    if (!node) return;
    switch (node->type) {
        case NODE_TRANSLATION_UNIT:
            printf("NODE_TRANSLATION_UNIT\n"); 
            analysis_function_list(node->data.unary.operand);
            break;
        default:
            printf("Unknown node type at root\n");
            break;
    }
}

void print_global_function() {
	printf(".global main\n");
    for(auto it = function_list.begin(); it != function_list.end(); it++) {
        if (it->name == "println_int" || it->name == "main") {
            continue;
        }
        printf(".global %s\n", (it->name).c_str());
    }
}

// 以备lab5
// void print_global_variable() { 
// 	printf(".global main\n");
//     for(auto it = Variable_Address.begin(); it != Variable_Address.end(); it++){
//         printf(".global %s\n", it->first.c_str());
//     }
// }

void generateAssembly(ASTNode *root) {
    translateAST(root);
	printf(".intel_syntax noprefix\n");
    print_global_function();
	printf(".data\n");
	printf("format_str:\n");
    printf(".asciz \"%%d\\n\"\n");
	printf(".extern printf\n");
	printf(".text\n");
	// printf("main:\n");
	// printf("push ebp\n");
	// printf("mov ebp, esp\n");
	// printf("sub esp, 0x100\n");
    // printf("section .text\n");
    // printf("global _start\n");


    printf("leave\n");
    printf("ret\n");
}
