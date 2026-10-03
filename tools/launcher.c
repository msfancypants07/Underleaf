#include <mach-o/dyld.h>
#include <libgen.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
int main(int argc, char **argv) {
    char raw[PATH_MAX], path[PATH_MAX], engine[PATH_MAX], pack[PATH_MAX];
    uint32_t size = sizeof(raw);
    if (_NSGetExecutablePath(raw, &size) != 0 || !realpath(raw, path)) return 1;
    char *base = dirname(path);
    snprintf(engine, sizeof(engine), "%s/Engine", base);
    snprintf(pack, sizeof(pack), "%s/../Resources/Underleaf.pck", base);
    char **args = calloc((size_t)argc + 4, sizeof(char *));
    args[0] = engine; args[1] = "--main-pack"; args[2] = pack;
    for (int i = 1; i < argc; ++i) args[i+2] = argv[i];
    execv(engine, args);
    perror("Underleaf could not start");
    free(args);
    return 1;
}
