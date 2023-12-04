#include <stdlib.h>
#include <stdio.h>

int * a() {
    int * b;
    return b;
}

int main() {
}

//   %1 = alloca ptr, align 8
//   %2 = call ptr @malloc(i64 noundef 20) #3
//   store ptr %2, ptr %1, align 8

//   %3 = load ptr, ptr %1, align 8
//   %4 = getelementptr inbounds i32, ptr %3, i64 3
//   store i32 10, ptr %4, align 4

//   %5 = load ptr, ptr %1, align 8
//   %6 = getelementptr inbounds i32, ptr %5, i64 3
//   %7 = load i32, ptr %6, align 4
//   %8 = call i32 (ptr, ...) @printf(ptr noundef @.str, i32 noundef %7)
//   ret i32 0