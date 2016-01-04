LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := host/helloworld.c

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../optee_client/out/export/include \
	$(LOCAL_PATH)/ta \
	$(LOCAL_PATH)/host

MY_VERSION = $(shell git describe --always --dirty=-dev 2>/dev/null || echo Unknown)

LOCAL_CFLAGS := -Os
LOCAL_CFLAGS += -D_ISOC99_SOURCE=1
LOCAL_CLFAGS += -DVERSION="$(MY_VERSION)"

LOCAL_SHARED_LIBRARIES := libteec
LOCAL_MODULE := helloworld-optee
LOCAL_MODULE_TAGS := optional
include $(BUILD_EXECUTABLE)
