#include <stdlib.h>
#include <stdio.h>

int foo() {
    int * b = malloc(5*sizeof(int));
    b[0] = 1;
    b[1] = 2;
    b[2] = 3;
    b[3] = 4;
    b[4] = 5;
    return 10;
}