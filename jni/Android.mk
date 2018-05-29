LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := main
LOCAL_SRC_FILES := main.c
# http://stackoverflow.com/questions/12614417/android-ndk-how-to-get-compiler-architecture-in-android-mk-dynamically

ifeq ($(TARGET_ARCH_ABI),armeabi)
	LOCAL_SRC_FILES := $(LOCAL_SRC_FILES) add_asm.S gfpmul.S
    LOCAL_CFLAGS += -D__ARM__
endif

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
	LOCAL_SRC_FILES := $(LOCAL_SRC_FILES) add_asm.S gfpmul.S
    LOCAL_CFLAGS += -D__ARM_7A__
endif

include $(BUILD_SHARED_LIBRARY)