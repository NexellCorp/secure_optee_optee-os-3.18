	.text

/*
 * The head of l-loader is defined in below.
 * struct l_loader_head {
 *	unsigned int	first_instr;
 *	unsigned char	magic[16];	@ BOOTMAGICNUMBER!
 *	unsigned int	l_loader_start;
 *	unsigned int	l_loader_end;
 * };
 */

#define CPU_WARMRSTREQ_OFFSET		0x2AC
#define CPU_WARMRSTREQ_CORE0		(1 << 0)
#define CPU_WARMRSTREQ_CORE07		(0xFF << 0)
#define CPU_WARMRSTREQ_CORE17		(0xFE << 0)

#define CPU_CLUSTER0_CTRL_OFFSET	0x13C	/* TIEOFF79  register */
#define CPU_CLUSTER1_CTRL_OFFSET	0x180	/* TIEOFF96  register */

#define CPU0_RVBARADDR_OFFSET		0x140	/* TIEOFF80  register */
#define CPU1_RVBARADDR_OFFSET		0x148	/* TIEOFF82  register */
#define CPU2_RVBARADDR_OFFSET		0x150	/* TIEOFF84  register */
#define CPU3_RVBARADDR_OFFSET		0x158	/* TIEOFF86  register */
#define CPU4_RVBARADDR_OFFSET		0x184	/* TIEOFF97  register */
#define CPU5_RVBARADDR_OFFSET		0x18C	/* TIEOFF99  register */
#define CPU6_RVBARADDR_OFFSET		0x194	/* TIEOFF101 register */
#define CPU7_RVBARADDR_OFFSET		0x19C	/* TIEOFF103 register */
#define CPUx_RVBARADDR_RANGE		0x8

#define CPU_0_AARCH64_MODE		(0x1 << 12)	/* cpu 0     */
#define CPU_0_3_AARCH64_MODE		(0xF << 12)	/* cpu 0 ~ 3 */
#define CPU_4_7_AARCH64_MODE		(0xF << 4)	/* cpu 4 ~ 7 */

	.global	_start
_start:
	b	reset
@ Android magic number: "BOOTMAGICNUMBER!"
android_magic:
	.word	0x544f4f42
	.word	0x4947414d
	.word	0x4d554e43
	.word	0x21524542
	.word	LLOADER_START		@ LLOADER_START in RAM
	.word	0			@ LLOADER_END in RAM

entries:
	@ 5 entries with 7 words
	.space	140

	.align	7

reset:
	ldr	r8, =(0x7fe00000 + 0x700)
	str	r0, [r8]		@ download mode (1:usb,2:uart,0:boot)

	@ copy fip image
	ldr	r0, =(0x7fc00000)	@ src
	ldr	r1, =(0x40000000)	@ dst
	ldr	r2, =(0x7fe00000)	@ end of src
copy_loop_text:
	ldmia	r0!, {r3-r10}
	stmia	r1!, {r3-r10}
	cmp	r0, r2
	ble	copy_loop_text

	ldr	r4, =0xC0011000		@ TIEOFF register base
	@ set RVBAR for cpu0
	ldr	r5, =CPU0_RVBARADDR_OFFSET
	ldr	r6, =LLOADER_BL1_BIN
	mov	r6, r6, lsr #2
	str	r6, [r4, r5]
1:
	ldr	r0, [r4, r5]
	cmp	r0, r6
	bne	1b

	@ set AARCH64 mode
	mov	r5, #CPU_CLUSTER0_CTRL_OFFSET
	ldr	r0, [r4, r5]		@ Load TIEOFF79_REG
	orr	r0, r0, #CPU_0_AARCH64_MODE
	str	r0, [r4, r5]		@ Save to TIEOFF79_REG

	@ dump log message
	adr	r0, str_aarch64
	bl	printascii
	ldr	r0, =LLOADER_BL1_BIN
	bl	printhex8
	mov	r0, #'!'
	bl	printch
	mov	r0, #'\n'
	bl	printch

	@ switch to aarch64
//	mov	r2, #3
	mov	r2, #1
	mcr	p15, 0, r2, c12, c0, 2

	@ execute warm reset to switch aarch64
	ldr	r4, =0xC0010000		@ Clock & Power register base
	mov	r5, #CPU_WARMRSTREQ_OFFSET
	ldr	r0, [r4, r5]		@ Load CPU_WARMRSTREQ register
	orr	r0, r0, #CPU_WARMRSTREQ_CORE0
	str	r0, [r4, r5]		@ Save to CPU_WARMRSTREQ register

	wfi
panic:
	b	panic

str_aarch64:
	.asciz	"\nSwitch to aarch64 mode. CPU0 executes at 0x"
