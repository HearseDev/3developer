SDK_PATH = $(THEOS)/sdks/iPhoneOS18.1.sdk/
SYSROOT = $(SDK_PATH)
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = developermodule
$(BUNDLE_NAME)_BUNDLE_EXTENSION = bundle
$(BUNDLE_NAME)_FILES = module.m alert.xm
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = ControlCenterUIKit
$(BUNDLE_NAME)_INSTALL_PATH = /Library/ControlCenter/Bundles

include $(THEOS_MAKE_PATH)/bundle.mk
