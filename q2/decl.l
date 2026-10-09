%option noyywrap yylineno nodefault noinput nounput

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "decl.tab.h"

static char *copiar_identificador(const char *texto)
{
    size_t tamanho = strlen(texto) + 1;
    char *copia = malloc(tamanho);
    if (copia == NULL) {
        perror("malloc");
        exit(EXIT_FAILURE);
    }
    memcpy(copia, texto, tamanho);
    return copia;
}
%}

LETRA   [a-zA-Z_]
DIGITO  [0-9]
ID      {LETRA}({LETRA}|{DIGITO})*

%%

"int"       { return INT; }
"double"    { return DOUBLE; }
"char"      { return CHAR; }
{ID}        {
                yylval.nome = copiar_identificador(yytext);
                return ID;
            }
","         { return VIRGULA; }
";"         { return PONTO_VIRGULA; }
[ \t\r\n]+  { /* Quebras de linha nao separam declaracoes. */ }
.           { return INVALIDO; }

%%
