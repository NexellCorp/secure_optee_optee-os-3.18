/*
 * Copyright (c) 2015, Nexell Limited
 * All rights reserved.
 */

#ifndef TA_HELLOWORLD_H
#define TA_HELLOWORLD_H

#define TA_HELLOWORLD_UUID { 0x968c7511, 0x9ace, 0x43fe, \
	{ 0x8a, 0x78, 0xfa, 0xf9, 0x88, 0x09, 0x6d, 0xe5 } }

/*
 * Commands implemented by the TA
 */

#define TA_HELLOWORLD_CMD_MSG1	0
#define TA_HELLOWORLD_CMD_MSG2	1

/*
 * Supported HELLO WORLD modes of operation
 */

#define TA_AES_ECB	0
#define TA_AES_CBC	1
#define TA_AES_CTR	2
#define TA_AES_XTS	3

#endif /* TA_HELLOWORLD_H */
