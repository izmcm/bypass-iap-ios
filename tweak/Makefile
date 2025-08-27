export THEOS_DEVICE_IP=127.0.0.1
export THEOS_DEVICE_PORT=2222

TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard

DEBUG = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = bypassIAPiOS

bypassIAPiOS_FILES = Tweak.x
bypassIAPiOS_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
