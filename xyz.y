%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
void yyerror(const char *s);

/* --- ESTRUTURAS DE DADOS PARA ARMAZENAR O CONTEXTO --- */

// Estrutura para Variáveis
typedef struct VarNode {
    char *name;
    char *type;
    char *init_val; // Armazena o valor inicial como string simples para exibição
    struct VarNode *next;
} VarNode;

// Estrutura para Fluxo de Controle
typedef struct FlowNode {
    char *type; // "if" ou "while"
    struct FlowNode *next;
} FlowNode;

// Estrutura para Funções
typedef struct FuncNode {
    char *name;
    VarNode *vars;     // Lista de variáveis declaradas nesta função
    FlowNode *flow;    // Lista de fluxos (if/while) nesta função
    struct FuncNode *next;
} FuncNode;

FuncNode *head_func = NULL;
FuncNode *current_func = NULL; // Ponteiro para a função sendo analisada no momento

// --- FUNÇÕES AUXILIARES ---

// Adiciona uma nova função à lista global
void add_function(char *name) {
    FuncNode *new_node = (FuncNode *)malloc(sizeof(FuncNode));
    new_node->name = strdup(name);
    new_node->vars = NULL;
    new_node->flow = NULL;
    new_node->next = NULL;

    if (head_func == NULL) {
        head_func = new_node;
    } else {
        FuncNode *temp = head_func;
        while (temp->next != NULL) temp = temp->next;
        temp->next = new_node;
    }
    current_func = new_node;
}

// Adiciona variável à função atual
void add_variable(char *name, char *type, char *val) {
    if (current_func == NULL) return;
    VarNode *new_var = (VarNode *)malloc(sizeof(VarNode));
    new_var->name = strdup(name);
    new_var->type = strdup(type);
    new_var->init_val = val ? strdup(val) : NULL;
    new_var->next = NULL;

    if (current_func->vars == NULL) {
        current_func->vars = new_var;
    } else {
        VarNode *temp = current_func->vars;
        while (temp->next != NULL) temp = temp->next;
        temp->next = new_var;
    }
}

// Adiciona fluxo à função atual
void add_flow(char *type) {
    if (current_func == NULL) return;
    FlowNode *new_flow = (FlowNode *)malloc(sizeof(FlowNode));
    new_flow->type = strdup(type);
    new_flow->next = NULL;

    if (current_func->flow == NULL) {
        current_func->flow = new_flow;
    } else {
        FlowNode *temp = current_func->flow;
        while (temp->next != NULL) temp = temp->next;
        temp->next = new_flow;
    }
}

// Variáveis globais auxiliares para capturar declarações compostas
char *current_decl_type = NULL; 

%}

%union {
    char *sval;
}

%token <sval> ID LIT_INT LIT_FLOAT TYPE_I64 TYPE_F64
%token FN RETURN VAR IF ELSE WHILE
%token PLUS MINUS MULT DIV MOD ASSIGN
%token EQ NEQ LT GT LTE GTE AND OR NOT BIT_NOT INC DEC
%token LPAREN RPAREN LBRACE RBRACE COMMA COLON SEMICOLON

%type <sval> literal expression

%start program

%%

program:
    function_list
    ;

function_list:
    function_list function
    | function
    ;

function:
    FN ID LPAREN params RPAREN { add_function($2); } LBRACE body RBRACE
    ;

params:
    param_list
    | /* vazio */
    ;

param_list:
    param_list COMMA param
    | param
    ;

param:
    ID COLON type { 
        /* Parâmetros também são variáveis no escopo da função */
        add_variable($1, $<sval>3, "param"); 
    }
    ;

type:
    TYPE_I64 { $<sval>$ = $1; }
    | TYPE_F64 { $<sval>$ = $1; }
    ;

body:
    statement_list
    ;

statement_list:
    statement_list statement
    | /* vazio */
    ;

statement:
    var_decl
    | assignment
    | inc_dec
    | return_stmt
    | function_call_stmt
    | if_stmt
    | while_stmt
    | block
    | SEMICOLON /* proposição vazia */
    ;

block:
    LBRACE statement_list RBRACE
    ;

/* Declaração de variáveis */
var_decl:
    VAR var_list SEMICOLON
    ;

var_list:
    var_item
    | var_list COMMA var_item
    ;

var_item:
    ID COLON type ASSIGN expression {
        add_variable($1, $<sval>3, $5);
    }
    ;

/* Atribuição */
assignment:
    ID ASSIGN expression SEMICOLON
    ;

/* Incremento e Decremento */
inc_dec:
    ID INC SEMICOLON
    | ID DEC SEMICOLON
    ;

/* Retorno */
return_stmt:
    RETURN expression SEMICOLON
    ;

/* Chamada de função como statement */
function_call_stmt:
    function_call SEMICOLON
    ;

function_call:
    ID LPAREN args RPAREN
    ;

args:
    arg_list
    | /* vazio */
    ;

arg_list:
    arg_list COMMA expression
    | expression
    ;

/* Controle de Fluxo */
if_stmt:
    IF expression { add_flow("if"); } block else_part
    ;

else_part:
    ELSE block
    | /* vazio */
    ;

while_stmt:
    WHILE expression { add_flow("while"); } block
    ;

/* Expressões */
expression:
    expression PLUS expression { $$ = "expr"; } /* Simplificação: não avaliamos expressões complexas para o print */
    | expression MINUS expression { $$ = "expr"; }
    | expression MULT expression { $$ = "expr"; }
    | expression DIV expression { $$ = "expr"; }
    | expression MOD expression { $$ = "expr"; }
    | expression EQ expression { $$ = "expr"; }
    | expression NEQ expression { $$ = "expr"; }
    | expression LT expression { $$ = "expr"; }
    | expression GT expression { $$ = "expr"; }
    | expression LTE expression { $$ = "expr"; }
    | expression GTE expression { $$ = "expr"; }
    | expression AND expression { $$ = "expr"; }
    | expression OR expression { $$ = "expr"; }
    | NOT expression { $$ = "expr"; }
    | BIT_NOT expression { $$ = "expr"; }
    | MINUS expression { $$ = "expr"; } /* Unário negativo */
    | LPAREN expression RPAREN { $$ = $2; }
    | ID { $$ = $1; }
    | function_call { $$ = "call"; }
    | literal { $$ = $1; }
    ;

literal:
    LIT_INT { $$ = $1; }
    | LIT_FLOAT { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}

int main(int argc, char **argv) {
    extern FILE *yyin;
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }
    
    yyparse();

    /* --- REQUISITO 3: IMPRIMIR TABELA DE SÍMBOLOS --- */
    printf("\n--- Tabela de Símbolos ---\n");
    FuncNode *f = head_func;
    while (f != NULL) {
        printf("fun %s\n", f->name);
        VarNode *v = f->vars;
        while (v != NULL) {
            if (v->init_val && strcmp(v->init_val, "param") != 0 && strcmp(v->init_val, "expr") != 0 && strcmp(v->init_val, "call") != 0) {
                 printf("\tvar %s: %s %s\n", v->name, v->type, v->init_val);
            } else if (strcmp(v->init_val, "param") == 0) {
                 /* Parâmetros aparecem como var no exemplo, mas sem valor inicial */
                 printf("\tvar %s: %s\n", v->name, v->type);
            } else {
                 /* Caso seja uma expressão complexa */
                 printf("\tvar %s: %s\n", v->name, v->type);
            }
            v = v->next;
        }
        f = f->next;
    }

    /* --- REQUISITO 4: IMPRIMIR FLUXO DE CONTROLE --- */
    printf("\n--- Estruturas de Controle ---\n");
    f = head_func;
    while (f != NULL) {
        printf("%s:\n", f->name);
        FlowNode *fl = f->flow;
        while (fl != NULL) {
            printf("\t%s:\n", fl->type);
            fl = fl->next;
        }
        f = f->next;
    }

    return 0;
}
