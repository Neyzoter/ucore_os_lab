#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("Hello world!!.\n");
    cprintf("I am process %d.\n", getpid());
    cprintf("hello pass.\n");
    // [LAB5 SCC] 用户测试是否从USERTOP开始堆栈
    // test(1,2,3,4);
    return 0;
}

// [LAB5 SCC] test stack
int test(val1,val2,val3,val4) {
    cprintf("val1 ptr : %0x08x\n", &val1) ;
    cprintf("val2 ptr : %0x08x\n", &val2) ;
    cprintf("val3 ptr : %0x08x\n", &val3) ;
    cprintf("val4 ptr : %0x08x\n", &val4) ;
}

