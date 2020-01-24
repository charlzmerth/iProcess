	.cpu arm7tdmi
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"test.c"
	.text
	.comm	array,400,4
	.align	2
	.global	foo
	.arch armv4t
	.syntax unified
	.arm
	.fpu softvfp
	.type	foo, %function
foo:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	push	{r4, fp}
	add	fp, sp, #4
.L4:
	mov	r4, #0
	b	.L2
.L3:
	ldr	r3, .L5
	str	r4, [r3, r4, lsl #2]
	add	r4, r4, #1
.L2:
	cmp	r4, #99
	ble	.L3
	b	.L4
.L6:
	.align	2
.L5:
	.word	array
	.size	foo, .-foo
	.ident	"GCC: (GNU Tools for Arm Embedded Processors 8-2018-q4-major) 8.2.1 20181213 (release) [gcc-8-branch revision 267074]"
