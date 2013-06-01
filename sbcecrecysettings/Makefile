include theos/makefiles/common.mk

BUNDLE_NAME = SBCecrecySettings
SBCecrecySettings_FILES = SBCecrecySettings.mm
SBCecrecySettings_INSTALL_PATH = /Library/PreferenceBundles
SBCecrecySettings_FRAMEWORKS = UIKit
SBCecrecySettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SBCecrecySettings.plist$(ECHO_END)
SUBPROJECTS += sbcecrecypasswordscreen
include $(THEOS_MAKE_PATH)/aggregate.mk
