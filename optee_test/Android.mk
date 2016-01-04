LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := host/xtest/xtest_1000.c \
	host/xtest/xtest_4000.c \
	host/xtest/xtest_5000.c \
	host/xtest/xtest_6000.c \
	host/xtest/xtest_7000.c \
	host/xtest/xtest_10000.c \
	host/xtest/xtest_20000.c \
	host/xtest/xtest_helpers.c \
	host/xtest/xtest_main.c \
	host/xtest/xtest_test.c \
	host/xtest/adbg/src/adbg_case.c \
	host/xtest/adbg/src/adbg_enum.c \
	host/xtest/adbg/src/adbg_expect.c \
	host/xtest/adbg/src/adbg_log.c \
	host/xtest/adbg/src/adbg_mts.c \
	host/xtest/adbg/src/adbg_run.c \
	host/xtest/adbg/src/adbg_util.c \
	host/xtest/adbg/src/r_list_genutil.c \
	host/xtest/adbg/src/security_utils_hex.c \
	host/xtest/adbg/src/security_utils_mem.c

LOCAL_C_INCLUDES := $(LOCAL_PATH)/host/xtest \
	$(LOCAL_PATH)/host/xtest/adbg/include \
	$(LOCAL_PATH)/host/xtest/xml/include \
	$(LOCAL_PATH)/../optee_client/out/export/include \
	$(LOCAL_PATH)/../optee_os/out/arm-plat-nxp5430/export-user_ta/host_include \
	$(LOCAL_PATH)/ta/create_fail_test/include \
	$(LOCAL_PATH)/ta/crypt/include \
	$(LOCAL_PATH)/ta/enc_fs/include \
	$(LOCAL_PATH)/ta/os_test/include \
	$(LOCAL_PATH)/ta/rpc_test/include \
	$(LOCAL_PATH)/ta/sims/include \
	$(LOCAL_PATH)/ta/storage/include

LOCAL_CFLAGS := -DUSER_SPACE
LOCAL_CFLAGS += -DCFG_ENC_FS
#LOCAL_CFLAGS += -Wall -Wcast-align \
				-Werror-implicit-function-declaration -Wextra -Wfloat-equal \
				-Wformat-nonliteral -Wformat-security -Wformat=2 -Winit-self \
				-Wmissing-declarations -Wmissing-format-attribute \
				-Wmissing-include-dirs -Wmissing-noreturn \
				-Wmissing-prototypes -Wnested-externs -Wpointer-arith \
				-Wshadow -Wstrict-prototypes -Wswitch-default \
				-Wwrite-strings \
				-Wno-missing-field-initializers -Wno-format-zero-length

LOCAL_SHARED_LIBRARIES := libteec
LOCAL_MODULE := xtest
LOCAL_MODULE_TAGS := optional
include $(BUILD_EXECUTABLE)
