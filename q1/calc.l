
%option noyywrap yylineno nodefault
%option noinput nounput
%{
    #include <stdlib.h>
    #include <string.h>
    #include "calc.tab.h"
%}

DIGITO      [0-9]
NATURAL     {DIGITO}+
INTEIRO     {NATURAL}
FLOAT       {INTEIRO}\.{NATURAL}
CIENTIFICO  ({INTEIRO}|{FLOAT})[eE][+-]?{NATURAL}

LETRA       [a-zA-Z_]
PALAVRA     {LETRA}+
VARIAVEL    {PALAVRA}({PALAVRA}|{NATURAL})*

%%

"printar_variaveis" { return PRINTAR_VARIAVEIS; }
">>>"               { return ATRIBUICAO; }
"**"|"^"       { return POTENCIA; }
{VARIAVEL} {
    yylval.variavel = strdup(yytext);
    return IDENTIFICADOR;
}

{CIENTIFICO} {
    yylval.flutuante = atof(yytext);
    return NUMERO;
}

{FLOAT} {
    yylval.flutuante = atof(yytext);
    return NUMERO;
}

{INTEIRO} {
    yylval.flutuante = atof(yytext);
    return NUMERO;
}


"+"       { return PLUS; }
"-"       { return MINUS; }
"*"       { return MULT; }
"/"       { return DIV; }
"("       { return LPARENT; }
")"       { return RPARENT; }

[ \t]+    { }
\n        { return NEWLINE; }
<<EOF>>   {
    /* Entrega um ultimo NEWLINE uma unica vez, inclusive se o arquivo
       nao terminar com quebra de linha. A gramatica aceita linhas vazias. */
    static int newline_final_enviado = 0;
    if (!newline_final_enviado) {
        newline_final_enviado = 1;
        return NEWLINE;
    }
    yyterminate();
}
.         { return yytext[0]; }

%%
