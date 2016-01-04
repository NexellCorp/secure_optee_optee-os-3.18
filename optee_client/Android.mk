################################################################################
# Android optee-client and optee-supplicant makefile                                                #
################################################################################
LOCAL_PATH := $(call my-dir)

################################################################################
# Include optee-client common config and flags                                 #
################################################################################
include $(LOCAL_PATH)/config.mk
include $(LOCAL_PATH)/flags.mk

################################################################################
# Build libteec.so - TEE (Trusted Execution Environment) shared library        #
################################################################################
# include $(CLEAR_VARS)
# LOCAL_CFLAGS += -DANDROID_BUILD
# # psw0523 fix : android compile error
# #LOCAL_CFLAGS += $(CFLAGS)
#
# ifeq ($(CFG_TEE_CLIENT_LOG_FILE), true)
# LOCAL_CFLAGS += -DTEEC_LOG_FILE=$(CFG_TEE_CLIENT_LOG_FILE)
# endif
#
# LOCAL_CFLAGS += -DDEBUGLEVEL_$(CFG_TEE_CLIENT_LOG_LEVEL)
# LOCAL_CFLAGS += -DBINARY_PREFIX=\"TEEC\"
#
# LOCAL_SRC_FILES += libteec/src/tee_client_api.c
# LOCAL_SRC_FILES += libteec/src/teec_trace.c
#
# LOCAL_C_INCLUDES := $(LOCAL_PATH)/public \
# 		$(LOCAL_PATH)/libteec/include \
#
# LOCAL_PRELINK_MODULE := false
# LOCAL_MODULE := libteec
# LOCAL_MODULE_TAGS := optional
# include $(BUILD_SHARED_LIBRARY)

################################################################################
# Build tee supplicant                                                         #
################################################################################
include $(CLEAR_VARS)

LOCAL_SRC_FILES := tee-supplicant/src/handle.c \
	tee-supplicant/src/tee_supp_fs.c \
	tee-supplicant/src/tee_supplicant.c \
	tee-supplicant/src/teec_ta_load.c

LOCAL_SHARED_LIBRARIES := libteec

LOCAL_C_INCLUDES := $(LOCAL_PATH)/public \
		$(LOCAL_PATH)/libteec/include \
#		$(LOCAL_PATH)/tee-supplicant/src

LOCAL_CFLAGS := -DANDROID_BUILD
# psw0523 fix : android compile error
#LOCAL_CFLAGS += $(CFLAGS)
LOCAL_CFLAGS += -DDEBUGLEVEL_$(CFG_TEE_SUPP_LOG_LEVEL)
LOCAL_CFLAGS += -DBINARY_PREFIX=\"TEES\"
LOCAL_CFLAGS += -DTEEC_LOAD_PATH=\"$(CFG_TEE_CLIENT_LOAD_PATH)\"

LOCAL_MODULE := tee-android-supplicant
LOCAL_MODULE_TAGS := optional

include $(BUILD_EXECUTABLE)
