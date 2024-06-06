%{
#include "parser.hpp"
%}

%%

[ \t\n]+                  ; // Ignore whitespace
"void"                    return VOID;
"int"                     return INT;
"float"                   return FLOAT;
"return"                  return RETURN;
"if"                      return IF;
"else"                    return ELSE;
"while"                   return WHILE;
"continue"                return CONTINUE;
"break"                   return BREAK;
"=="                      return EQ;
"!="                      return NE;
"<="                      return LE;
">="                      return GE;
"<"                       return LT;
">"                       return GT;
"&&"                      return AND;
"||"                      return OR;
"&"                       return BIT_AND;
"|"                       return BIT_OR;
"^"                       return BIT_XOR;
"!"                       return NOT;
"~"                       return BIT_NOT;
"+"                       return PLUS;
"-"                       return MINUS;
"*"                       return MUL;
"/"                       return DIV;
"%"                       return MOD;
[0-9]+                    return NUMBER;
[a-zA-Z_][a-zA-Z0-9_]*    return IDENTIFIER;
";"                       return SEMICOLON;
","                       return COMMA;
"("                       return LPAREN;
")"                       return RPAREN;
"{"                       return LBRACE;
"}"                       return RBRACE;
"="                       return ASSIGN;

.                         return yytext[0]; // Return single character tokens as is

%%

int yywrap(void) {
    return 1;
}
