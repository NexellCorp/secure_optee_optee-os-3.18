#ifndef __NXP5430_UART_H__
#define __NXP5430_UART_H__

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

#define NX_UARTTRSTAT_TX_EMPTY_BIT  (1 << 2)    /* Transmit empty bit in UARTTRSTAT register */
#define NX_UARTTRSTAT_TXBE_BIT      (1 << 1)    /* Transmit BUFFER empty bit in UARTTRSTAT register */

#endif  /* __NXP5430_UART_H__ */ 
