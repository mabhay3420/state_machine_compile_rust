// A simple switch statement in C

#include <stdio.h>

int main() {
    // take input from user
    int x;
    printf("Enter a number: ");
    scanf("%d", &x);

    switch (x) {
        case 1:
            printf("x is 1\n");
            break;
        case 2:
            printf("x is 2\n");
            break;
        default:
            printf("x is not 1 or 2\n");
    }

    return 0;
}