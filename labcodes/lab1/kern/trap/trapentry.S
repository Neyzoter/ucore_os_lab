#include <memlayout.h>

# vectors.S sends all traps here.
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    # [scc] trapframe的结构就是这样的pushregs(low)、gs、es、fs、gs(high)
    # [scc] 补充：trapframe后面的成员，已经被push了（因为stack是从高地址到低地址，而结构体是相反的）
    pushl %ds
    pushl %es
    pushl %fs
    pushl %gs
    # [scc] pushal将trapframe的pushregs内容入栈
    pushal

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
    movw %ax, %ds
    movw %ax, %es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    # [scc] esp入栈，调用trap即可知道参数是刚入栈的数值，就是前面的gs、es、fs等组成的trapframe
    pushl %esp

    # call trap(tf), where tf=%esp
    # [scc] 为什么tf=%esp，因为这是机制，此时esp指向栈顶，也就是pushal后的trapframe的第一个数值
    call trap

    # pop the pushed stack pointer
    popl %esp

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal

    # restore %ds, %es, %fs and %gs
    popl %gs
    popl %fs
    popl %es
    popl %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
    iret

