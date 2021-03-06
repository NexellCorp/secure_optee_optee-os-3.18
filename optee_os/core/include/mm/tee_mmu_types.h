/*
 * Copyright (c) 2014, STMicroelectronics International N.V.
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
#ifndef TEE_MMU_TYPES_H
#define TEE_MMU_TYPES_H

#include <stdint.h>

#define TEE_MATTR_VALID_BLOCK	(1 << 0)
#define TEE_MATTR_HIDDEN_BLOCK	(1 << 1)
#define TEE_MATTR_PHYS_BLOCK	(1 << 2)
#define	TEE_MATTR_TABLE		(1 << 3)
#define	TEE_MATTR_PR		(1 << 4)
#define	TEE_MATTR_PW		(1 << 5)
#define	TEE_MATTR_PX		(1 << 6)
#define	TEE_MATTR_PRW		(TEE_MATTR_PR | TEE_MATTR_PW)
#define	TEE_MATTR_PRX		(TEE_MATTR_PR | TEE_MATTR_PX)
#define	TEE_MATTR_PRWX		(TEE_MATTR_PRW | TEE_MATTR_PX)
#define	TEE_MATTR_UR		(1 << 7)
#define	TEE_MATTR_UW		(1 << 8)
#define	TEE_MATTR_UX		(1 << 9)
#define	TEE_MATTR_URW		(TEE_MATTR_UR | TEE_MATTR_UW)
#define	TEE_MATTR_URX		(TEE_MATTR_UR | TEE_MATTR_UX)
#define	TEE_MATTR_URWX		(TEE_MATTR_URW | TEE_MATTR_UX)

#define TEE_MATTR_GLOBAL	(1 << 10)
#define TEE_MATTR_I_NONCACHE	 0
#define TEE_MATTR_I_WRITE_THR	(1 << 11)
#define TEE_MATTR_I_WRITE_BACK	(1 << 12)
#define TEE_MATTR_O_NONCACHE	 0
#define TEE_MATTR_O_WRITE_THR	(1 << 13)
#define TEE_MATTR_O_WRITE_BACK	(1 << 14)

#define TEE_MATTR_NONCACHE	 0
#define TEE_MATTR_CACHE_DEFAULT	(TEE_MATTR_I_WRITE_BACK | \
				 TEE_MATTR_O_WRITE_BACK)

#define TEE_MATTR_CACHE_UNKNOWN	(1 << 15)

#define	TEE_MATTR_SECURE	(1 << 16)

struct tee_mmap_region {
	paddr_t pa;
	vaddr_t va;
	size_t size;
	uint32_t attr; /* TEE_MATTR_* above */
};

struct tee_mmu_info {
	struct tee_mmap_region *table;
	size_t size;
	vaddr_t ta_private_vmem_start;
	vaddr_t ta_private_vmem_end;
};

#endif
