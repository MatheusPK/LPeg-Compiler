#include <stdlib.h>
#include <stdio.h>

void foo(int a) {
    a = 20;
}

void a() {
    int ** c;
    foo(c[0][0] + 1);
}