// vim: set shiftwidth=4 tabstop=4 expandtab:

#include "stdlib.h"
#include "stdio.h"
#include "stdarg.h"
#include "unistd.h"
#include <dlfcn.h>
#ifdef __WIN32
  #include "windef.h"
  #include "winbase.h"
#else
  #define LoadLibrary dlopen
  #define GetProcAddress dlsym
  #define __stdcall
#endif

int __stdcall PrintLine(char*, int);

void usage(char **argv) {
    printf("USAGE:\n");
    printf("  %s [-i] [-L LIBRARY] [-n DELAY]", argv[0]);
}

int main(int argc, char **argv) {
    int delay = 100;
    int opt;
    char* lib = 0;
    int interactive = 0;
    opterr = 0;
    while ((opt = getopt(argc, argv, ":iL:n:")) != -1) {
        switch (opt) {
            case 'i':
                interactive = 1;
                break;
            case 'n': {
                char *res;
                int delay_arg = strtol(optarg, &res, 10);
                if (argv[optind] != res) {
                    delay = delay_arg;
                }
                break;
            }
            case 'L': {
                lib = optarg;
                break;
            }
            case '?':
                usage(argv);
                exit(EXIT_FAILURE);
                break;
            case ':':
                usage(argv);
                exit(EXIT_FAILURE);
                break;
            default:
                printf("NEXT\n");
                break;
        }
    }
    if (lib) {
        void *InjectorLibHandle;
#ifdef __WIN32
        InjectorLibHandle = LoadLibrary(lib);
#else
        InjectorLibHandle = LoadLibrary(lib, RTLD_LAZY);
#endif
        if (!InjectorLibHandle) {
           fprintf(stderr, "Unable to load library %s\n", lib);
           fprintf(stderr, "%s\n", dlerror());
        } else {
            int (*TryToInjectFunc)();
            *(void **)&TryToInjectFunc = GetProcAddress(InjectorLibHandle, "TryToInject");
            if (TryToInjectFunc) {
                TryToInjectFunc();
            }
        }
    }
    PrintLine("Done!\0", delay);
    if (interactive) {
        printf("Press ENTER...\n");
        getchar();
    }

    exit(EXIT_SUCCESS);
}

