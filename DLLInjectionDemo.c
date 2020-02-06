// vim: set shiftwidth=4 tabstop=4 expandtab:

#include "stdlib.h"
#include "stdio.h"
#include "stdarg.h"
#ifdef __WIN32
  #include "windef.h"
  #include "winbase.h"
#else
  #include <dlfcn.h>
  #define LoadLibrary dlopen
  #define GetProcAddress dlsym
#endif

int main(int argc, char **argv) {
    printf("Loading library victim\n");
    void *LibHandle;
#ifdef __WIN32
    LibHandle = LoadLibrary("victim");
#else
    LibHandle = LoadLibrary("libvictim.so", RTLD_LAZY);
#endif
    if (!LibHandle) {
       fprintf(stderr, "Unable to load library victim\n");
       fprintf(stderr, "%s\n", dlerror());
       exit(EXIT_FAILURE);
    }
    if (argc > 1) {
        void *InjectorLibHandle;
#ifdef __WIN32
            InjectorLibHandle = LoadLibrary(argv[1]);
#else
            InjectorLibHandle = LoadLibrary(argv[1], RTLD_LAZY);
#endif
            if (!InjectorLibHandle) {
               fprintf(stderr, "Unable to load library %s\n", argv[1]);
               fprintf(stderr, "%s\n", dlerror());
               exit(EXIT_FAILURE);
            }
            BOOL (*TryToInjectFunc)();
            *(void **)&TryToInjectFunc = GetProcAddress(InjectorLibHandle, "TryToInject");
            if (TryToInjectFunc) {
                TryToInjectFunc();
            }
    }
    void (*PrintLineFunc)(char*, int);
    *(void **)&PrintLineFunc = GetProcAddress(LibHandle, "PrintLine");
    if (PrintLineFunc) {
        PrintLineFunc("123\0", 10);
        PrintLineFunc("CRASH!\0", 5);
    }

    return 0;
}

