#include <stdlib.h>
#include <stdio.h>

int foo(int a) {
    printf("aa %d\n", a);
    return 2.1;
}

int main() {
    int a = 1.5;
    double b = 1.5;
    b++;
    a ++;
    -- a;
    printf("%f\n", b);
    printf("%d\n", a);
    foo(1.5);
    return 0;
}