#include <stdint.h>

int dyn_printf(const char *restrict fmt, uint64_t args[], size_t n);

int main() {
    double f = 514.0;
    const char *s = "810";
    uint64_t args[] = { 114, *(uint64_t*)&f, 1919, (uint64_t)s };
    dyn_printf("%ld %lf %ld %s\n", args, 4);
}
