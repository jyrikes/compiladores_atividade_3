
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <math.h>

    int yylex(void);
    void yyerror(const char *s);
    extern FILE *yyin;
    extern int yylineno;

    typedef struct {
        char *nome;
        double valor;
    } Variavel;

    Variavel tabela[1000];
    int total = 0;

    void atribuir(char *nome, double valor);
    double buscar(char *nome);
    void imprimir_variaveis(void);
%}

%union {
    char *variavel;
    double flutuante;
}

%token <variavel> IDENTIFICADOR
%token <flutuante> NUMERO

%token PRINTAR_VARIAVEIS ATRIBUICAO
%token PLUS MINUS MULT DIV POTENCIA
%token LPARENT RPARENT NEWLINE

%type <flutuante> expressao termo unario potencia fator

%destructor { free($$); } <variavel>

%%

programa:
      %empty
    | programa linha
    ;

linha:
      NEWLINE
    | comando NEWLINE
    ;

comando:
      atribuicao
    | expressao {
          printf("= %g\n", $1);
      }
    | impressao
    ;

atribuicao:
      IDENTIFICADOR ATRIBUICAO expressao {
          atribuir($1, $3);
          free($1);
      }
    ;

impressao:
      PRINTAR_VARIAVEIS {
          imprimir_variaveis();
      }
    ;

expressao:
      expressao PLUS termo {
          $$ = $1 + $3;
      }
    | expressao MINUS termo {
          $$ = $1 - $3;
      }
    | termo {
          $$ = $1;
      }
    ;

termo:
      termo MULT unario {
          $$ = $1 * $3;
      }
    | termo DIV unario {
          if ($3 == 0) {
              yyerror("Divisao por zero!");
              YYABORT;
          } else {
              $$ = $1 / $3;
          }
      }
    | unario {
          $$ = $1;
      }
    ;

unario:
      MINUS unario {
          $$ = -$2;
      }
    | potencia {
          $$ = $1;
      }
    ;

potencia:
      fator POTENCIA unario {
          $$ = pow($1, $3);
      }
    | fator {
          $$ = $1;
      }
    ;

fator:
      NUMERO {
          $$ = $1;
      }
    | IDENTIFICADOR {
          $$ = buscar($1);
          free($1);
      }
    | LPARENT expressao RPARENT {
          $$ = $2;
      }
    ;

%%

void atribuir(char *nome, double valor)
{
    for (int i = 0; i < total; i++) {
        if (strcmp(tabela[i].nome, nome) == 0) {
            tabela[i].valor = valor;
            return;
        }
    }

    if (total >= 1000) {
        fprintf(stderr, "Erro: limite de 1000 variaveis atingido\n");
        exit(EXIT_FAILURE);
    }

    tabela[total].nome = strdup(nome);
    if (tabela[total].nome == NULL) {
        perror("strdup");
        exit(EXIT_FAILURE);
    }

    tabela[total].valor = valor;
    total++;
}

double buscar(char *nome)
{
    for (int i = 0; i < total; i++) {
        if (strcmp(tabela[i].nome, nome) == 0) {
            return tabela[i].valor;
        }
    }

    fprintf(stderr, "Variavel nao definida: %s\n", nome);
    exit(EXIT_FAILURE);
}

void imprimir_variaveis(void)
{
    for (int i = 0; i < total; i++) {
        printf("%s >>> %g\n",
               tabela[i].nome,
               tabela[i].valor);
    }
}

void yyerror(const char *s)
{
    fprintf(stderr, "Linha %d: %s\n", yylineno, s);
}

int main(int argc, char **argv)
{
    if (argc > 1) {
        yyin = fopen(argv[1], "r");

        if (yyin == NULL) {
            perror("Erro ao abrir arquivo");
            return 1;
        }
    }

    int resultado = yyparse();

    if (argc > 1) {
        fclose(yyin);
    }

    for (int i = 0; i < total; i++) {
        free(tabela[i].nome);
    }

    return resultado;
}
