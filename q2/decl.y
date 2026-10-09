%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *mensagem);
extern FILE *yyin;
extern int yylineno;

typedef struct {
    char *nome;
    const char *tipo;
} Entrada;

static Entrada *tabela = NULL;
static size_t total = 0;
static size_t capacidade = 0;
static const char *tipo_atual = NULL;

static void registrar_variavel(char *nome);
static void liberar_tabela(void);
%}

%union {
    char *nome;
}

%token INT DOUBLE CHAR VIRGULA PONTO_VIRGULA INVALIDO
%token <nome> ID
%destructor { free($$); } <nome>
%start programa

%%

programa:
      %empty
    | programa declaracao
    ;

declaracao:
      tipo lista_nomes PONTO_VIRGULA
    ;

tipo:
      INT    { tipo_atual = "int"; }
    | DOUBLE { tipo_atual = "double"; }
    | CHAR   { tipo_atual = "char"; }
    ;

lista_nomes:
      ID                     { registrar_variavel($1); }
    | lista_nomes VIRGULA ID { registrar_variavel($3); }
    ;

%%

static void registrar_variavel(char *nome)
{
    for (size_t i = 0; i < total; ++i) {
        if (strcmp(tabela[i].nome, nome) == 0) {
            printf("erro: %s já foi declarada\n", nome);
            free(nome);
            return;
        }
    }

    if (total == capacidade) {
        size_t nova_capacidade = capacidade == 0 ? 16 : capacidade * 2;
        Entrada *nova_tabela = realloc(tabela, nova_capacidade * sizeof(*tabela));
        if (nova_tabela == NULL) {
            perror("realloc");
            free(nome);
            liberar_tabela();
            exit(EXIT_FAILURE);
        }
        tabela = nova_tabela;
        capacidade = nova_capacidade;
    }

    tabela[total].nome = nome;
    tabela[total].tipo = tipo_atual;
    ++total;
    printf("%s %s\n", tipo_atual, nome);
}

static void liberar_tabela(void)
{
    for (size_t i = 0; i < total; ++i)
        free(tabela[i].nome);
    free(tabela);
    tabela = NULL;
    total = 0;
    capacidade = 0;
}

void yyerror(const char *mensagem)
{
    fprintf(stderr, "Linha %d: %s\n", yylineno, mensagem);
}

int main(int argc, char **argv)
{
    if (argc > 2) {
        fprintf(stderr, "Uso: %s [arquivo_de_entrada]\n", argv[0]);
        return EXIT_FAILURE;
    }

    if (argc == 2) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            perror("Erro ao abrir arquivo");
            return EXIT_FAILURE;
        }
    }

    int resultado = yyparse();
    if (resultado == 0)
        printf("+++++ %zu variáveis declaradas\n", total);

    if (argc == 2)
        fclose(yyin);

    liberar_tabela();
    return resultado == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
