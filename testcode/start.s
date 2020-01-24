.extern main
.globl _start
.text

_start:
    ldr r13, topofmem
    sub r13, r13, #16
    mov r11, r13                 // set frame pointer to stack pointer
    bl main
    b _start
topofmem:
    .word   0x2000
