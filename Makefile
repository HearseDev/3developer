# Manually specifying to use theos sdks, since we are using private frameworks.
SDK_PATH = $(THEOS)/sdks/iPhoneOS17.2.sdk/
SYSROOT = $(SDK_PATH)

TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 3developer
$(TWEAK_NAME)_FILES = $(wildcard src/*.m) $(wildcard src/*.mm) $(wildcard src/*.x) $(wildcard src/*.xm)
$(TWEAK_NAME)_CFLAGS += -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS += Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
#SUBPROJECTS += 3developercc
include $(THEOS_MAKE_PATH)/aggregate.mk
