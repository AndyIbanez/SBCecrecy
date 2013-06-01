include theos/makefiles/common.mk

LIBRARY_NAME = Toggle
Toggle_FILES = Toggle.mm
Toggle_FRAMEWORKS=UIKit Foundation CoreFoundation CoreGraphics
Toggle_INSTALL_PATH = /var/mobile/Library/SBSettings/Toggles/SBCecrecy

include $(THEOS_MAKE_PATH)/library.mk
SUBPROJECTS += sbcecrecysettings
include $(THEOS_MAKE_PATH)/aggregate.mk
