#include <stdlib.h>
#include <stdio.h>
int main() {
    int a = 1;
    double b = 1.5;
    b++;
    a ++;
    -- a;
    printf("%f\n", b);
    printf("%d\n", a);
    return 0;
}