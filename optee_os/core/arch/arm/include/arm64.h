/*
 * Copyright (c) 2015, Linaro Limited
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
#ifndef ARM64_H
#define ARM64_H

#ifndef ASM
#include <stdint.h>
#endif

#define SCTLR_M		(1 << 0)
#define SCTLR_A		(1 << 1)
#define SCTLR_C		(1 << 2)
#define SCTLR_SA	(1 << 3)
#define SCTLR_I		(1 << 12)

#define TTBR_ASID_MASK		0xff
#define TTBR_ASID_SHIFT		48

#define CLIDR_LOUIS_SHIFT	21
#define CLIDR_LOC_SHIFT		24
#define CLIDR_FIELD_WIDTH	3

#define CSSELR_LEVEL_SHIFT	1

#define DAIFBIT_FIQ			(1 << 0)
#define DAIFBIT_IRQ			(1 << 1)
#define DAIFBIT_ABT			(1 << 2)
#define DAIFBIT_DBG			(1 << 3)
#define DAIFBIT_ALL			(DAIFBIT_FIQ | DAIFBIT_IRQ | \
					 DAIFBIT_ABT | DAIFBIT_DBG)

#define DAIF_F_SHIFT		6
#define DAIF_F			(1 << 6)
#define DAIF_I			(1 << 7)
#define DAIF_A			(1 << 8)
#define DAIF_D			(1 << 9)
#define DAIF_AIF		(DAIF_A | DAIF_I | DAIF_F)

#define SPSR_MODE_RW_SHIFT	4
#define SPSR_MODE_RW_MASK	0x1
#define SPSR_MODE_RW_64		0x0
#define SPSR_MODE_RW_32		0x1

#define SPSR_64_MODE_SP_SHIFT	0
#define SPSR_64_MODE_SP_MASK	0x1
#define SPSR_64_MODE_SP_EL0	0x0
#define SPSR_64_MODE_SP_ELX	0x1

#define SPSR_64_MODE_EL_SHIFT	2
#define SPSR_64_MODE_EL_MASK	0x3
#define SPSR_64_MODE_EL1	0x1
#define SPSR_64_MODE_EL0	0x0

#define SPSR_64_DAIF_SHIFT	6
#define SPSR_64_DAIF_MASK	0xf

#define SPSR_32_AIF_SHIFT	6
#define SPSR_32_AIF_MASK	0x7

#define SPSR_32_E_SHIFT		9
#define SPSR_32_E_MASK		0x1
#define SPSR_32_E_LITTLE	0x0
#define SPSR_32_E_BIG		0x1

#define SPSR_32_T_SHIFT		5
#define SPSR_32_T_MASK		0x1
#define SPSR_32_T_ARM		0x0
#define SPSR_32_T_THUMB		0x1

#define SPSR_32_MODE_SHIFT	0
#define SPSR_32_MODE_MASK	0xf
#define SPSR_32_MODE_USR	0x0


#define SPSR_64(el, sp, daif)						\
	(SPSR_MODE_RW_64 << SPSR_MODE_RW_SHIFT |			\
	((el) & SPSR_64_MODE_EL_MASK) << SPSR_64_MODE_EL_SHIFT |	\
	((sp) & SPSR_64_MODE_SP_MASK) << SPSR_64_MODE_SP_SHIFT |	\
	((daif) & SPSR_64_DAIF_MASK) << SPSR_64_DAIF_SHIFT)

#define SPSR_32(mode, isa, aif)						\
	(SPSR_MODE_RW_32 << SPSR_MODE_RW_SHIFT |			\
	SPSR_32_E_LITTLE << SPSR_32_E_SHIFT |				\
	((mode) & SPSR_32_MODE_MASK) << SPSR_32_MODE_SHIFT |		\
	((isa) & SPSR_32_T_MASK) << SPSR_32_T_SHIFT |			\
	((aif) & SPSR_32_AIF_MASK) << SPSR_32_AIF_SHIFT)


#define TCR_T0SZ_SHIFT		0
#define TCR_EPD0		(1 << 7)
#define TCR_IRGN0_SHIFT		8
#define TCR_ORGN0_SHIFT		10
#define TCR_SH0_SHIFT		12
#define TCR_T1SZ_SHIFT		16
#define TCR_A1			(1 << 22)
#define TCR_EPD1		(1 << 23)
#define TCR_IRGN1_SHIFT		24
#define TCR_ORGN1_SHIFT		26
#define TCR_SH1_SHIFT		28
#define TCR_EL1_IPS_SHIFT	32
#define TCR_TG1_4KB		(2ull << 30)

/* Normal memory, Inner/Outer Non-cacheable */
#define TCR_XRGNX_NC		0x0
/* Normal memory, Inner/Outer Write-Back Write-Allocate Cacheable */
#define TCR_XRGNX_WB		0x1
/* Normal memory, Inner/Outer Write-Through Cacheable */
#define TCR_XRGNX_WT		0x2
/* Normal memory, Inner/Outer Write-Back no Write-Allocate Cacheable */
#define TCR_XRGNX_WBWA	0x3

/* Non-shareable */
#define TCR_SHX_NSH		0x0
/* Outer Shareable */
#define TCR_SHX_OSH		0x2
/* Inner Shareable */
#define TCR_SHX_ISH		0x3

#define ESR_EC_SHIFT		26
#define ESR_EC_MASK		0x3f

#define ESR_EC_UNKNOWN		0x00
#define ESR_EC_WFI		0x01
#define ESR_EC_AARCH32_CP15_32	0x03
#define ESR_EC_AARCH32_CP15_64	0x04
#define ESR_EC_AARCH32_CP14_MR	0x05
#define ESR_EC_AARCH32_CP14_LS	0x06
#define ESR_EC_FP_ASIMD		0x07
#define ESR_EC_AARCH32_CP10_ID	0x08
#define ESR_EC_AARCH32_CP14_64	0x0c
#define ESR_EC_ILLEGAL		0x0e
#define ESR_EC_AARCH32_SVC	0x11
#define ESR_EC_AARCH64_SVC	0x15
#define ESR_EC_AARCH64_SYS	0x18
#define ESR_EC_IABT_EL0		0x20
#define ESR_EC_IABT_EL1		0x21
#define ESR_EC_PC_ALIGN		0x22
#define ESR_EC_DABT_EL0		0x24
#define ESR_EC_DABT_EL1		0x25
#define ESR_EC_SP_ALIGN		0x26
#define ESR_EC_AARCH32_FP	0x28
#define ESR_EC_AARCH64_FP	0x2c
#define ESR_EC_SERROR		0x2f
#define ESR_EC_BREAKPT_EL0	0x30
#define ESR_EC_BREAKPT_EL1	0x31
#define ESR_EC_SOFTSTP_EL0	0x32
#define ESR_EC_SOFTSTP_EL1	0x33
#define ESR_EC_WATCHPT_EL0	0x34
#define ESR_EC_WATCHPT_EL1	0x35
#define ESR_EC_AARCH32_BKPT	0x38
#define ESR_EC_AARCH64_BRK	0x3c

/* Combined defines for DFSC and IFSC */
#define ESR_FSC_MASK		0x3f
#define ESR_FSC_TRANS_L0	0x04
#define ESR_FSC_TRANS_L1	0x05
#define ESR_FSC_TRANS_L2	0x06
#define ESR_FSC_TRANS_L3	0x07
#define ESR_FSC_ACCF_L1		0x09
#define ESR_FSC_ACCF_L2		0x0a
#define ESR_FSC_ACCF_L3		0x0b
#define ESR_FSC_PERMF_L1	0x0d
#define ESR_FSC_PERMF_L2	0x0e
#define ESR_FSC_PERMF_L3	0x0f
#define ESR_FSC_ALIGN		0x21

#define CPACR_EL1_FPEN_SHIFT	20
#define CPACR_EL1_FPEN_MASK	0x3
#define CPACR_EL1_FPEN_NONE	0x0
#define CPACR_EL1_FPEN_EL1	0x1
#define CPACR_EL1_FPEN_EL0EL1	0x3
#define CPACR_EL1_FPEN(x)	((x) >> CPACR_EL1_FPEN_SHIFT \
				      & CPACR_EL1_FPEN_MASK)

#ifndef ASM
static inline void isb(void)
{
	asm volatile ("isb");
}

static inline void dsb(void)
{
	asm volatile ("dsb sy");
}

/*
 * Templates for register read/write functions based on mrs/msr
 */

#define DEFINE_REG_READ_FUNC_(reg, type, asmreg)	\
static inline type read_##reg(void)			\
{							\
	type val;					\
							\
	asm volatile("mrs %0, " #asmreg : "=r" (val));	\
	return val;					\
}

#define DEFINE_REG_WRITE_FUNC_(reg, type, asmreg)		\
static inline void write_##reg(type val)			\
{								\
	asm volatile("msr " #asmreg ", %0" : : "r" (val));	\
}

#define DEFINE_U32_REG_READ_FUNC(reg) \
		DEFINE_REG_READ_FUNC_(reg, uint32_t, reg)

#define DEFINE_U32_REG_WRITE_FUNC(reg) \
		DEFINE_REG_WRITE_FUNC_(reg, uint32_t, reg)

#define DEFINE_U32_REG_READWRITE_FUNCS(reg)	\
		DEFINE_U32_REG_READ_FUNC(reg)	\
		DEFINE_U32_REG_WRITE_FUNC(reg)

#define DEFINE_U64_REG_READ_FUNC(reg) \
		DEFINE_REG_READ_FUNC_(reg, uint64_t, reg)

#define DEFINE_U64_REG_WRITE_FUNC(reg) \
		DEFINE_REG_WRITE_FUNC_(reg, uint64_t, reg)

#define DEFINE_U64_REG_READWRITE_FUNCS(reg)	\
		DEFINE_U64_REG_READ_FUNC(reg)	\
		DEFINE_U64_REG_WRITE_FUNC(reg)

/*
 * Define register access functions
 */

DEFINE_U32_REG_READWRITE_FUNCS(cpacr_el1)
DEFINE_U32_REG_READWRITE_FUNCS(daif)
DEFINE_U32_REG_READWRITE_FUNCS(fpcr)
DEFINE_U32_REG_READWRITE_FUNCS(fpsr)

DEFINE_U32_REG_READ_FUNC(contextidr_el1)

DEFINE_REG_READ_FUNC_(cntfrq, uint32_t, cntfrq_el0)

DEFINE_U64_REG_READWRITE_FUNCS(ttbr0_el1)
DEFINE_U64_REG_READWRITE_FUNCS(ttbr1_el1)
DEFINE_U64_REG_READWRITE_FUNCS(tcr_el1)

DEFINE_U64_REG_READ_FUNC(esr_el1)
DEFINE_U64_REG_READ_FUNC(far_el1)
DEFINE_U64_REG_READ_FUNC(mpidr_el1)

DEFINE_U64_REG_WRITE_FUNC(mair_el1)

DEFINE_REG_READ_FUNC_(cntpct, uint64_t, cntpct_el0)

#endif /*ASM*/

#endif /*ARM64_H*/

