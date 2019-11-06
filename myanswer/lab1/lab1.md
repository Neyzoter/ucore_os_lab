# lab1

## exam1

**1.操作系统镜像文件ucore.img是如何一步一步生成的?(需要比较详细地解释Makefile中每一条相关命令和命令参数的含义，以及说明命令导致的结果)**

**2.一个被系统认为是符合规范的硬盘主引导扇区的特征是什么?**

512个字节，最后两个字节是0x55和0xAA，见`tools/sign.c`

## exam2

**1.从CPU加电后执行的第一条指令开始，单步跟踪BIOS的执行。**

* 设置architecture 为i8086

  `/tools/gdbinit`文件加入，设置架构为i8086，gdb和qemu直接通过网络端口1234通信：

  ```
  set architecture i8086
  target remote :1234
  ```

* 开始debug

  `make debug`，程序一开始就进入等待状态。可以看到进入到了`kern/init/init.c`文件的`kern_init`函数。地址是`0x100000`。

* debug单步指令

  ```
  si      单步执行
  next	单步到程序源代码的下一行,不进入函数。
  nexti	单步一条机器指令,不进入函数。
  step	单步到下一个不同的源代码行(包括进入函数)。
  stepi	单步一条机器指令。
  ```

  **解答：**逐步输入`next`，QEMU界面会一步一步打印BIOS加载Bootloader的过程。

  <img src="./img/lab1_exam2_stepbystep.png" width="600" alt="Bootloader过程">	

  

**2.在初始化位置0x7c00设置实地址断点，测试断点正常。**

BIOS将Bootloader搬运到了`0x7c00`，程序再从此地址开始运行。

* 设置断点

  gdb中输入`b *[地址]`来设置特定断点当qemu中的cpu执行到指定地址时，便会将控制权交给gdb：

  `b *0x7c00`

  `continue`

  还可以输入`x /10i 0x7c00`来查看汇编指令。

**3.从0x7c00开始跟踪代码运行，将单步跟踪反汇编得到的代码与bootasm.S和bootblock.asm进行比较。**

* 在gdbinit中加入反汇编参数

  ```
  define	hook-stop
  x/i	$pc
  end
  ```

* 开始debug

  `make debug`

* 设置断点

  ```
  b *0x7c00
  continue
  ```

  可以看到大部分和`bootasm.S`内容相同，但是普遍没有`bootasm.S`的`w`，如`bootasm.S`中的`xorw %ax, %ax`，反汇编后是`xor %ax, %ax`。movl的l用于32位的字值，movw的w用于16位的字值，movb的b用于8位的字值。

  

**4.自己找一个bootloader或内核中的代码位置，设置断点并进行测试。**

## exam3

**BIOS将通过读取硬盘主引导扇区到内存,并转跳到对应内存中的位置执行bootloader。请分析bootloader是如何完成从实模式进入保护模式的。**

* 为何开启A20,以及如何开启A20

  寻址寄存器`segent:offset<(0xffff左移4位+0xffff)=1088KB`，最多可访问1088KB空间，比1MB大了一些。为了保持向下兼容，需要设置第20位（A20）地址一直为0，这样才能实现不超过1MB。在进入保护模式后，需要使用这一位（A20），又要打开使能这一位。

  http://hengch.blog.163.com/blog/static/107800672009013104623747/

* 如何初始化GDT表

  初始化GDT表：一个简单的GDT表和其描述符已经静态储存在引导区（asm.h）中，载入即可

  ```assembly
  lgdt gdtdesc
  ```

  

* 如何使能和进入保护模式

  控制寄存器cr0的第0位PE置1，可以开启保护模式。

  ```assembly
  movl %cr0, %eax             # cr0 ： 控制寄存器0
  orl $CR0_PE_ON, %eax        # CR0_PE_ON = 0x01，和cr0的数值或操作，即第0位（PE：CR0的位0是启用保护（Protection Enable）标志）置1
  movl %eax, %cr0             # 给cr0赋值，启动保护模式
  ```

  