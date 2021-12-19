TARGET := iphone:clang:latest:13.0

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = 3developerprefs

3developerprefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
3developerprefs_FILES = TDPRootListController.m
3developerprefs_FRAMEWORKS = UIKit
3developerprefs_PRIVATE_FRAMEWORKS = Preferences
3developerprefs_INSTALL_PATH = /Library/PreferenceBundles
3developerprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
