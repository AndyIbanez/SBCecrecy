//-----------------------------------------------------------------------------------------------------------------------------------------------------
//All the code to create the UI of the toggle itself was taken and modified from BigBoss' Brightness Toggle source code. Anything else is "original".
//-----------------------------------------------------------------------------------------------------------------------------------------------------

#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSBundle *cecret = nil;

// Required
extern "C" BOOL isCapable() {
	return YES;
}

// Required
extern "C" BOOL isEnabled() {
	NSMutableDictionary *enabledDir = [[NSMutableDictionary dictionaryWithContentsOfFile: 
								[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.SBCecrecyEnabled.plist"]] retain];
	BOOL valToReturn;
	if(enabledDir == nil)
	{
		enabledDir = [[NSMutableDictionary alloc] init];
		[enabledDir setObject:[NSNumber numberWithBool:NO] forKey:@"toggleEnabled"];
		[enabledDir writeToFile:[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.SBCecrecyEnabled.plist"] atomically:YES];
		valToReturn = NO;
	}else	
	{
		valToReturn = [[enabledDir objectForKey:@"toggleEnabled"] boolValue];
	}
	return valToReturn;
}

// Optional
// Faster isEnabled. Remove this if it's not necessary. Keep it if isEnabled() is expensive and you can make it faster here.
extern "C" BOOL getStateFast() {
	return isEnabled();
}

extern "C" NSString *getPasscode()
{
	NSDictionary *passcodeString = [NSMutableDictionary dictionaryWithContentsOfFile: 
								[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.PasscodeString.plist"]];
	return [passcodeString objectForKey:@"passcodeString"];
}

extern "C" void hideIcons()
{
	if(cecret == NULL)
	{
		cecret = [[NSBundle alloc] initWithPath:@"/Library/Cecrecy/Cecrecy.bundle"];
	}
	
	Class cecretClass;
	id cecretBin;
	if((cecretClass = [cecret principalClass]))
	{
		cecretBin = [[cecretClass alloc] init];
	}
	
	[cecretBin performSelector:@selector(hideIcons)];
	[cecretBin release];
	[cecret release];
	system("killall -9 SpringBoard");
}

extern "C" void showIcons()
{
	if(cecret == NULL)
	{
		cecret = [[NSBundle alloc] initWithPath:@"/Library/Cecrecy/Cecrecy.bundle"];
	}
	
	Class cecretClass;
	id cecretBin;
	if((cecretClass = [cecret principalClass]))
	{
		cecretBin = [[cecretClass alloc] init];
	}
	
	[cecretBin performSelector:@selector(showIcons)];
	[cecretBin release];
	[cecret release];
	system("killall -9 SpringBoard");
}

extern "C" BOOL passcodeEnabled()
{
	NSDictionary *passcodeEnabled = [NSMutableDictionary dictionaryWithContentsOfFile: 
								[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.sbcecrecysettings.plist"]];
	NSDictionary *passcodeString = [NSMutableDictionary dictionaryWithContentsOfFile: 
								[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.PasscodeString.plist"]];
	if(passcodeEnabled == nil || passcodeString == nil)
	{
		return NO;
	}else
	{
		return [[passcodeEnabled objectForKey:@"usePasscode"] boolValue];
	}
}

@interface PasscodeView : UIView <UIAlertViewDelegate>
{
	UITextField *passcodeField;
	UIButton *okBtn;
	BOOL enabled;
	NSMutableDictionary *enabledDir;
}
@property (nonatomic, assign) BOOL enabled;

- (PasscodeView *) initWindowAndEnabled:(BOOL)enable;
- (void) transitionOut;
- (void) transitionIn;
- (void) CloseButtonPressed; 
- (void) endTimer:(NSTimer *)timer;
- (UIWindow*) getAppWindow;
-(void)passcodeInput;
@end

@implementation PasscodeView
@synthesize enabled;
- (PasscodeView *) initWindowAndEnabled:(BOOL)enable
{
	//ValueChanged = NO;
	self = [super initWithFrame:CGRectMake(-274.0f, 40.0f, 274.0f, 71.0f)];
	NSString* CurrentTheme;
	UIWindow* Window = [self getAppWindow];
	if([Window respondsToSelector:@selector(getCurrentTheme)])
	{
		CurrentTheme = [NSString stringWithString:[Window performSelector:@selector(getCurrentTheme)]];
	}
	else
	{
		CurrentTheme = [NSString stringWithString:@"Default"];
	}
	
	// Setup the background image.
	UIImageView* Image = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 274.0f, 71.0f)];
	
	//IMPORTANT CHANGE ON THE LINE BELOW. According to the iphonedevwiki.net, refering to the /var/mobile directory is a bad idea. Use NSHomeDirectory() instead.
	Image.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/SBSettings/Themes/%@/SliderFrame.png", NSHomeDirectory(), CurrentTheme]];
	[self addSubview: Image];
	[Image release];
	
	// Setup the passcode field.
	passcodeField = [[UITextField alloc] initWithFrame:CGRectMake(15, 30, 180, 31)];
	passcodeField.borderStyle = UITextBorderStyleRoundedRect;
	passcodeField.placeholder = @"Your Passcode";
	passcodeField.secureTextEntry = YES;
	[self addSubview:passcodeField];
	
	okBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	okBtn.frame = CGRectMake(198, 30, 60, 31);
	[okBtn setTitle:@"OK" forState:UIControlStateNormal];
	[okBtn addTarget:self action:@selector(passcodeInput) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:okBtn];
	
	// Setup the close button
	UIButton* CloseButtonBigger = [[UIButton alloc] initWithFrame:CGRectMake(234.0f, 0.0f, 40.0f, 40.0f)];
	[CloseButtonBigger addTarget:self action:@selector(CloseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview: CloseButtonBigger];
	[CloseButtonBigger release];

	UIButton* CloseButton = [[UIButton alloc] initWithFrame:CGRectMake(244.0f, 5.0f, 25.0f, 25.0f)];
	[CloseButton setShowsTouchWhenHighlighted: YES];
	[CloseButton setBackgroundImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/SBSettings/Themes/%@/Close.png", NSHomeDirectory(), CurrentTheme]] forState:UIControlStateNormal];
	[CloseButton addTarget:self action:@selector(CloseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview: CloseButton];
	[CloseButton release];
	
	//Save the state of the toggle. In my tutorial, I wrote that your SBSettings toggle shouldn't have to keep track of itself. Now you know rules sometimes are to be broken!
	//Remember: If the toggle is currently ON, enabled will be NO, telling us it wants to turn it off.
	enabledDir = [[NSMutableDictionary dictionaryWithContentsOfFile: 
								[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.SBCecrecyEnabled.plist"]] retain];
	if(enabledDir == nil)
	{
		enabledDir = [[NSMutableDictionary dictionary] retain];
	}
	
	enabled = enable;
	
	
	return self;
}

//************************************************************************************************************
// getAppWindow - attempts to retrieve the app window.
//************************************************************************************************************
- (UIWindow*) getAppWindow
{
	UIWindow* TheWindow = nil;
	UIApplication* App = [UIApplication sharedApplication];
	NSArray* windows = [App windows];
	unsigned int i;
	for(i = 0; i < [windows count]; i++)
	{
		TheWindow = [windows objectAtIndex:i];
		if([TheWindow respondsToSelector:@selector(getCurrentTheme)])
		{
			break;
		}
	}
	
	if(i == [windows count])
	{
		NSLog(@"Couldn't find the app window, defaulting to keyWindow\n");
		TheWindow = [App keyWindow];
	}
	
	return TheWindow;
}

//************************************************************************************************************
// transitionIn - animates the view in place.
//************************************************************************************************************
- (void) transitionIn
{
	UIWindow* TheWindow = [self getAppWindow];
	
	[TheWindow addSubview: self];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	CGAffineTransform transformView	= CGAffineTransformMakeTranslation(297.0f, 0.0f);
	[self setTransform: transformView];
	[UIView commitAnimations];
	[passcodeField becomeFirstResponder];
}


//************************************************************************************************************
// transitionOut - transitions the window view out.
//************************************************************************************************************
- (void) transitionOut
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[[[UIApplication sharedApplication] keyWindow] addSubview: self];
	CGAffineTransform transformView	= CGAffineTransformMakeTranslation(-297.0f, 0.0f);
	[self setTransform: transformView];
	[UIView commitAnimations];

	[NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(endTimer:) userInfo:nil repeats:NO];
}

//************************************************************************************************************
// endTimer: Timer callback to remove the rest of the controls after animation completes.
//************************************************************************************************************
- (void) endTimer:(NSTimer *)timer 
{
	[passcodeField release];
	[okBtn release];
	[enabledDir release];
	[self removeFromSuperview];
}

//************************************************************************************************************
// CloseButtonPressed: When the close button pressed. Closes up the window.
//************************************************************************************************************
- (void) CloseButtonPressed 
{
	[self transitionOut];
}

-(void)passcodeInput
{
	if([getPasscode() isEqualToString:passcodeField.text])
	{
		[enabledDir setObject:[NSNumber numberWithBool:enabled] forKey:@"toggleEnabled"];
		[enabledDir writeToFile:[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.SBCecrecyEnabled.plist"] atomically:YES];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Respring Required." message:@"Your phone will now respring to toggle your icons." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong Passcode" message:@"Incorrect password. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		passcodeField.text = @"";
		[self transitionOut];
	}
}

//UIAlertView delegate methods.
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if([alertView.title isEqualToString:@"Respring Required."])
	{
		if(enabled == NO)
		{
			showIcons();
		}else
		{
			hideIcons();
		}
	}
}
@end

// Required
extern "C" void setState(BOOL enabled) {
	// Set State!
	if(passcodeEnabled())
	{
		PasscodeView *pv = [[PasscodeView alloc] initWindowAndEnabled:enabled];
		[pv transitionIn];
		[pv release];
	}else
	{
		NSMutableDictionary *enabledDir = [NSMutableDictionary dictionaryWithContentsOfFile: 
								[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.SBCecrecyEnabled.plist"]];
		if(enabledDir == nil)
		{
			enabledDir = [NSMutableDictionary dictionary];
		}
		[enabledDir setObject:[NSNumber numberWithBool:enabled] forKey:@"toggleEnabled"];
		[enabledDir writeToFile:[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.SBCecrecyEnabled.plist"] atomically:YES];
		if(enabled == NO)
		{
			showIcons();
		}else
		{
			hideIcons();
		}
	}
}

// Required
// How long the toggle takes to toggle, in seconds.
extern "C" float getDelayTime() {
	return 0.0f;
}

// vim:ft=objc
