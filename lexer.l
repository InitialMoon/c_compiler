%{
#include "parser.hpp"
%}

%%

[ \t\n]+                  ; // Ignore whitespace
"void"                    yylval.identifier = strdup(yytext); return VOID; 
"int"                     yylval.identifier = strdup(yytext); return INT;
"float"                   yylval.identifier = strdup(yytext); return FLOAT;
"return"                  yylval.identifier = strdup(yytext); return RETURN;
"if"                      yylval.identifier = strdup(yytext); return IF;
"else"                    yylval.identifier = strdup(yytext); return ELSE;
"while"                   yylval.identifier = strdup(yytext); return WHILE;
"continue"                yylval.identifier = strdup(yytext); return CONTINUE;
"break"                   yylval.identifier = strdup(yytext); return BREAK;
"=="                      yylval.identifier = strdup(yytext); return EQ;
"!="                      yylval.identifier = strdup(yytext); return NE;
"<="                      yylval.identifier = strdup(yytext); return LE;
">="                      yylval.identifier = strdup(yytext); return GE;
"<"                       yylval.identifier = strdup(yytext); return LT;
">"                       yylval.identifier = strdup(yytext); return GT;
"&&"                      yylval.identifier = strdup(yytext); return AND;
"||"                      yylval.identifier = strdup(yytext); return OR;
"&"                       yylval.identifier = strdup(yytext); return BIT_AND;
"|"                       yylval.identifier = strdup(yytext); return BIT_OR;
"^"                       yylval.identifier = strdup(yytext); return BIT_XOR;
"!"                       yylval.identifier = strdup(yytext); return NOT;
"~"                       yylval.identifier = strdup(yytext); return BIT_NOT;
"+"                       yylval.identifier = strdup(yytext); return PLUS;
"-"                       yylval.identifier = strdup(yytext); return MINUS;
"*"                       yylval.identifier = strdup(yytext); return MUL;
"/"                       yylval.identifier = strdup(yytext); return DIV;
"%"                       yylval.identifier = strdup(yytext); return MOD;
[0-9]+                    yylval.number = atoi(yytext); return NUMBER;
[a-zA-Z_][a-zA-Z0-9_]*    yylval.identifier = strdup(yytext); return IDENTIFIER;
";"                       yylval.identifier = strdup(yytext); return SEMICOLON;
","                       yylval.identifier = strdup(yytext); return COMMA;
"("                       yylval.identifier = strdup(yytext); return LPAREN;
")"                       yylval.identifier = strdup(yytext); return RPAREN;
"{"                       yylval.identifier = strdup(yytext); return LBRACE;
"}"                       yylval.identifier = strdup(yytext); return RBRACE;
"="                       yylval.identifier = strdup(yytext); return ASSIGN;

.                         return yytext[0]; // Return single character tokens as is

%%

int yywrap(void) {
    return 1;
}
