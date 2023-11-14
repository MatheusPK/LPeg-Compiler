#include <stdlib.h>
#include <stdio.h>

int * foo() {
    int *** a = malloc(10*sizeof(int**));
    a[1][2][3] = 10;
    return a;
}