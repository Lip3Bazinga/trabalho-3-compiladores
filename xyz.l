%{
#include <stdio.h>
#include <string.h>
#include "xyz.tab.h"

void yyerror(const char *s);
%}

%option noyywrap

%%

"fn"        { return FN; }
"return"    { return RETURN; }
"var"       { return VAR; }
"i64"       { yylval.sval = strdup(yytext); return TYPE_I64; }
"f64"       { yylval.sval = strdup(yytext); return TYPE_F64; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }

[a-zA-Z][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return ID; }
[0-9]+\.[0-9]+        { yylval.sval = strdup(yytext); return LIT_FLOAT; }
[0-9]+                { yylval.sval = strdup(yytext); return LIT_INT; }

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MULT; }
"/"         { return DIV; }
"%"         { return MOD; }
"="         { return ASSIGN; }
"=="        { return EQ; }
"!="        { return NEQ; }
"<"         { return LT; }
">"         { return GT; }
"<="        { return LTE; }
">="        { return GTE; }
"&&"        { return AND; }
"||"        { return OR; }
"!"         { return NOT; }
"~"         { return BIT_NOT; }
"++"        { return INC; }
"--"        { return DEC; }

"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
","         { return COMMA; }
":"         { return COLON; }
";"         { return SEMICOLON; }

"//".* { /* Ignora comentários de linha única */ }
[ \t\r\n]   { /* Ignora espaços em branco */ }

.           { printf("Caractere desconhecido: %s\n", yytext); }

%%
