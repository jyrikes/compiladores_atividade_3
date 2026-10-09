CC = gcc
CFLAGS = -D_POSIX_C_SOURCE=200809L -std=c11 -O2 -Wall -Wextra -pedantic

.PHONY: all run run_test test clean

all: decl

decl: decl.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $@ $^

decl.tab.c decl.tab.h: decl.y
	bison -d -Wall -o decl.tab.c decl.y

lex.yy.c: decl.l decl.tab.h
	flex -o lex.yy.c decl.l

run: decl
	./decl entrada.txt

run_test: test

test: decl
	@./decl entrada.txt | diff -u saida_esperada.txt -
	@./decl entrada_multilinha.txt | diff -u saida_multilinha_esperada.txt -
	@./decl entrada_adicional.txt | diff -u saida_adicional_esperada.txt -
	@echo "Todos os testes passaram."

clean:
	rm -f decl decl.tab.c decl.tab.h lex.yy.c
