# vim: set noexpandtab:
.PHONY: DLLInjectionDemo.c

CC = gcc

LDFLAGS += -g
LDFLAGS += -lvictim -L.
ifneq ($(OS),Windows_NT)
LDFLAGS += -ldl
endif

all: DLLInjectionDemo.exe

DLLInjectionDemo.exe: DLLInjectionDemo
	$(CC) $<.c $(LDFLAGS) -o $@
