# vim: set noexpandtab:
.PHONY: DLLInjectionDemo.c

LDFLAGS += -g
ifeq ($(shell uname -o),GNU/Linux)
LDFLAGS += -ldl
endif

all: DLLInjectionDemo.exe

DLLInjectionDemo.exe: DLLInjectionDemo
	$(CC) $<.c $(LDFLAGS) -o $@
