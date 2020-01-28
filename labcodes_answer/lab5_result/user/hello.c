#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("Hello world!!.\n");
    cprintf("I am process %d.\n", getpid());
    cprintf("hello pass.\n");
    test(1,2,3,4);
    return 0;
}

// [LAB5 SCC] test stack
int test(val1,val2,val3,val4) {
    cprintf("val1 ptr : %d\n", &val1) ;
    cprintf("val2 ptr : %d\n", &val2) ;
    cprintf("val3 ptr : %d\n", &val3) ;
    cprintf("val4 ptr : %d\n", &val4) ;
}

