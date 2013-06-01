include theos/makefiles/common.mk

BUNDLE_NAME = SBCecrecyPasswordScreen
SBCecrecyPasswordScreen_FILES = SBCecrecyPasswordScreen.mm
SBCecrecyPasswordScreen_INSTALL_PATH = /Library/PreferenceBundles
SBCecrecyPasswordScreen_FRAMEWORKS = UIKit
SBCecrecyPasswordScreen_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
