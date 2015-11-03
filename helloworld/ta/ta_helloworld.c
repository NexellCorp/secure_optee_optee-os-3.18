/*
 * Copyright (c) 2015, Nexell Limited
 * All rights reserved.
 */

#include <tee_internal_api.h>
#include <tee_ta_api.h>
#include <string.h>
#include <stdio.h>
#include <trace.h>

#include "ta_helloworld.h"
#include "ta_helloworld_priv.h"

/*
 * Trusted Application Entry Points
 */

/* Called each time a new instance is created */
TEE_Result TA_CreateEntryPoint(void)
{
	return TEE_SUCCESS;
}

/* Called each time an instance is destroyed */
void TA_DestroyEntryPoint(void)
{
}

/* Called each time a session is opened */
TEE_Result TA_OpenSessionEntryPoint(uint32_t nParamTypes,
				    TEE_Param pParams[4],
				    void **ppSessionContext)
{
	(void)nParamTypes;
	(void)pParams;
	(void)ppSessionContext;
	return TEE_SUCCESS;
}

/* Called each time a session is closed */
void TA_CloseSessionEntryPoint(void *pSessionContext)
{
	(void)pSessionContext;
}

/* Called when a command is invoked */
TEE_Result TA_InvokeCommandEntryPoint(void *pSessionContext,
				      uint32_t nCommandID, uint32_t nParamTypes,
				      TEE_Param pParams[4])
{
	(void)pSessionContext;

	switch (nCommandID) {
	case TA_HELLOWORLD_CMD_MSG1:
		return cmd_msg1(nParamTypes, pParams);

	case TA_HELLOWORLD_CMD_MSG2:
		return cmd_msg2(nParamTypes, pParams);

	default:
		return TEE_ERROR_BAD_PARAMETERS;
	}
}


/* ========================================================================== */

TEE_Result cmd_msg1(uint32_t param_types, TEE_Param params[4])
{
	uint32_t val_a;
	uint32_t val_b;
	uint32_t exp_param_types = TEE_PARAM_TYPES(TEE_PARAM_TYPE_VALUE_INPUT,
						   TEE_PARAM_TYPE_NONE,
						   TEE_PARAM_TYPE_NONE,
						   TEE_PARAM_TYPE_NONE);

	if (param_types != exp_param_types) {
		printf("param_types miss match\r\n");
		return TEE_ERROR_BAD_PARAMETERS;
	}

	val_a   = params[0].value.a;
	val_b   = params[0].value.b;

	printf("Hello World msg 1\r\n");
	printf("val_a = 0x%08X, val_b = 0x%08X\r\n", val_a, val_b);

	return TEE_SUCCESS;
}

TEE_Result cmd_msg2(uint32_t param_types, TEE_Param params[4])
{
	uint32_t val_a;
	uint32_t val_b;
	uint32_t exp_param_types = TEE_PARAM_TYPES(TEE_PARAM_TYPE_VALUE_INPUT,
						   TEE_PARAM_TYPE_NONE,
						   TEE_PARAM_TYPE_NONE,
						   TEE_PARAM_TYPE_NONE);

	if (param_types != exp_param_types) {
		printf("param_types miss match\r\n");
		return TEE_ERROR_BAD_PARAMETERS;
	}

	val_a   = params[0].value.a;
	val_b   = params[0].value.b;

	printf("Hello Wolrd msg 2\r\n");
	printf("val_a = 0x%08X, val_b = 0x%08X\r\n", val_a, val_b);

	return TEE_SUCCESS;
}
