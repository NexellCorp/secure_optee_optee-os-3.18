/*
 * Copyright (c) 2014, Linaro Limited
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
#include <drivers/nxp5430_uart.h>
#include <io.h>

/* NX_UART Registers */
#define UARTDLCON               0x00    // Line Control
#define UARTRUCON               0x04    // Control
#define UARTEFCON               0x08    // FIFO Control
#define UARTFMCON               0x0C    // Modem Control
#define UARTTRSTAT              0x10    // Tx/Rx Status
#define UARTERSTAT              0x14    // Rx Error Status
#define UARTFSTAT               0x18    // FIFO Status
#define UARTMSTAT               0x1C    // Modem Status
#define UARTTXH                 0x20    // Transmit Buffer
#define UARTRXH                 0x24    // Recieve Buffer
#define UARTBRDR                0x28    // Baud Rate Driver
#define UARTFRACVAL             0x2C    // Driver Fractional Value
#define UARTINTP                0x30    // Instrrupt Pending
#define UARTINTSP               0x34    // Instrrupt Source
#define UARTINTM                0x38    // Instrrupt Mask

#define NX_UARTFSTAT_TXFF_BIT       (1 << 24)   /* Transmit FIFO full bit in UARTFSTAT register */
#define NX_UARTFSTAT_RXFE_BIT       (1 << 2)    /* Receive FIFO empty bit in UARTFR register */

#define NX_UARTTRSTAT_TX_EMPTY_BIT  (1 << 2)    /* Transmit empty bit in UARTTRSTAT register */
#define NX_UARTTRSTAT_TXBE_BIT      (1 << 1)    /* Transmit BUFFER empty bit in UARTTRSTAT register */


void nxp5430_uart_flush(vaddr_t base)
{
	while (!(read32(base + UARTTRSTAT) & NX_UARTTRSTAT_TX_EMPTY_BIT))
		;
}

void nxp5430_uart_init(vaddr_t base, uint32_t uart_clk, uint32_t baud_rate)
{
#if 0
	if (baud_rate) {
		uint32_t divisor = (uart_clk * 4) / baud_rate;

		write32(divisor >> 6, base + UART_IBRD);
		write32(divisor & 0x3f, base + UART_FBRD);
	}

	write32(0, base + UART_RSR_ECR);

	/* Configure TX to 8 bits, 1 stop bit, no parity, fifo disabled. */
	write32(UART_LCRH_WLEN_8, base + UART_LCR_H);

	write32(UART_IMSC_RXIM, base + UART_IMSC);

	/* Enable UART and TX */
	write32(UART_CR_UARTEN | UART_CR_TXE | UART_CR_RXE, base + UART_CR);
#else

	if (baud_rate) {
		uint32_t divisor = (uart_clk * 4) / baud_rate;
		divisor = divisor;
	}
#endif

	nxp5430_uart_flush(base);
}

void nxp5430_uart_putc(int ch, vaddr_t base)
{
	/*
	 * Wait until there is space in the FIFO
	 */
	while (read32(base + UARTFSTAT) & NX_UARTFSTAT_TXFF_BIT)
		;

	/* Send the character */
	write32(ch, base + UARTTXH);
}

bool nxp5430_uart_have_rx_data(vaddr_t base)
{
	return !(read32(base + UARTFSTAT) & NX_UARTFSTAT_RXFE_BIT);
}

int nxp5430_uart_getchar(vaddr_t base)
{
	while (!nxp5430_uart_have_rx_data(base))
		;
	return read32(base + UARTRXH) & 0xff;
}

