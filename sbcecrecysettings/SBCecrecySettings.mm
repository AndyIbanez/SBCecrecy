#import <Preferences/Preferences.h>

@interface SBCecrecySettingsListController: PSListController {
}
@end

@implementation SBCecrecySettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SBCecrecySettings" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
