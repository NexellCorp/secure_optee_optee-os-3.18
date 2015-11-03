/*
 * Copyright (c) 2015, Nexell Limited
 * All rights reserved.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <tee_client_api.h>
#include "ta_helloworld.h"

/*
 * TEE client stuff
 */

static TEEC_Context ctx;
static TEEC_Session sess;
/*
 * in_shm and out_shm are both IN/OUT to support dynamically choosing
 * in_place == 1 or in_place == 0.
 */
static TEEC_SharedMemory in_shm = {
	.flags = TEEC_MEM_INPUT | TEEC_MEM_OUTPUT
};
static TEEC_SharedMemory out_shm = {
	.flags = TEEC_MEM_INPUT | TEEC_MEM_OUTPUT
};

static void errx(const char *msg, TEEC_Result res)
{
	fprintf(stderr, "%s: 0x%08x", msg, res);
	exit (1);
}

static void check_res(TEEC_Result res, const char *errmsg)
{
	if (res != TEEC_SUCCESS)
		errx(errmsg, res);
}

static void open_ta()
{
	TEEC_Result res;
	TEEC_UUID uuid = TA_HELLOWORLD_UUID;
	uint32_t err_origin;

	res = TEEC_InitializeContext(NULL, &ctx);
	check_res(res,"TEEC_InitializeContext");

	res = TEEC_OpenSession(&ctx, &sess, &uuid, TEEC_LOGIN_PUBLIC, NULL,
			       NULL, &err_origin);
	check_res(res,"TEEC_OpenSession");
}

/*
 * Statistics
 *
 * We want to compute min, max, mean and standard deviation of processing time
 */


static void hello_world_msg1(void)
{
	TEEC_Result res;
	uint32_t ret_origin;
	TEEC_Operation op;

	memset(&op, 0, sizeof(op));

	op.paramTypes = TEEC_PARAM_TYPES(TEEC_VALUE_INPUT,
					 TEEC_NONE, TEEC_NONE, TEEC_NONE);

	op.params[0].value.a = 0x12340000;
	op.params[0].value.b = 0x00005678;

	res = TEEC_InvokeCommand(&sess, TA_HELLOWORLD_CMD_MSG1, &op,
				 &ret_origin);
	check_res(res, "TEEC_InvokeCommand");
}

static void hello_world_msg2(void)
{
	TEEC_Result res;
	uint32_t ret_origin;
	TEEC_Operation op;

	memset(&op, 0, sizeof(op));

	op.paramTypes = TEEC_PARAM_TYPES(TEEC_VALUE_INPUT,
					 TEEC_NONE, TEEC_NONE, TEEC_NONE);

	op.params[0].value.a = 0xABCD0000;
	op.params[0].value.b = 0x00001234;


	res = TEEC_InvokeCommand(&sess, TA_HELLOWORLD_CMD_MSG2, &op,
				 &ret_origin);
	check_res(res, "TEEC_InvokeCommand");
}

int main(int argc, char *argv[])
{
	open_ta();
	hello_world_msg1();
	hello_world_msg2();

	return 0;
}
