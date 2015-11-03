/*
 * Copyright (c) 2015, Nexell Limited
 * All rights reserved.
 */

#ifndef TA_HELLOWORLD_PRIV_H
#define TA_HELLOWORLD_PRIV_H

#include <tee_api.h>

TEE_Result cmd_msg1(uint32_t param_types, TEE_Param params[4]);
TEE_Result cmd_msg2(uint32_t param_types, TEE_Param params[4]);

#endif /* TA_HELLOWORLD_PRIV_H */
