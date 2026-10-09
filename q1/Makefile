CC = gcc
CFLAGS = -D_POSIX_C_SOURCE=200809L -std=c11 -O2 -Wall -Wextra -pedantic
LIBS = -lm

.PHONY: all run run_test test clean

all: calc

calc: calc.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $@ calc.tab.c lex.yy.c $(LIBS)

calc.tab.c calc.tab.h: calc.y
	bison -d -Wall -o calc.tab.c calc.y

lex.yy.c: calc.l calc.tab.h
	flex -o lex.yy.c calc.l

run: calc
	./calc

run_test: test

test: calc
	@bash testes.sh

clean:
	rm -f calc calc.tab.c calc.tab.h lex.yy.c
