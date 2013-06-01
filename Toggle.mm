#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//------------------------------------------------------------------------------------------------------------------------
//All the code to create the UI of the toggle itself was fetched and modified from BigBoss' Brightness Toggle source code.
//------------------------------------------------------------------------------------------------------------------------

@interface PasscodeView : UIView
{
	UITextField *passcodeField;
	UIButton *okBtn;
	BOOL enabled;
}
@property (nonatomic, assign) BOOL enabled;

- (PasscodeView *) initWindow;
- (void) transitionOut;
- (void) transitionIn;
- (void) CloseButtonPressed; 
- (void) endTimer:(NSTimer *)timer;
- (UIWindow*) getAppWindow;
-(void)passcodeInput;
@end

@implementation PasscodeView
@synthesize enabled;
- (PasscodeView *) initWindow
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
	
	// Setup the label
	/*UILabel* Label = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 15.0f, 100.0f, 20.0f)]; 
	[Label setText:@"Cecrecy"];
	[Label setTextColor:[UIColor whiteColor]];
	[Label setBackgroundColor: [UIColor clearColor]];
	[self addSubview: Label];
	[Label release];*/
	
	// Setup the passcode field.
	passcodeField = [[UITextField alloc] initWithFrame:CGRectMake(15, 30, 180, 31)];
	passcodeField.borderStyle = UITextBorderStyleRoundedRect;
	passcodeField.placeholder = @"Your Passcode";
	[self addSubview:passcodeField];
	
	okBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	okBtn.frame = CGRectMake(198, 30, 60, 31);
	[okBtn setTitle:@"OK" forState:UIControlStateNormal];
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
	[self removeFromSuperview];
}

//************************************************************************************************************
// CloseButtonPressed: When the close button pressed. Closes up the window.
//************************************************************************************************************
- (void) CloseButtonPressed 
{
	/*NSLog(@"Value changed = %D\n", ValueChanged);
	if(ValueChanged == YES)
	{
		NSMutableDictionary* Prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist"];

		if(Prefs != nil)
		{
			NSLog(@"Prefs != nil\n");
			float CurrentBacklight1 = [[Prefs objectForKey:@"SBBacklightLevel"] floatValue];
			float CurrentBacklight2 = [[Prefs objectForKey:@"SBBacklightLevel2"] floatValue];
			NSNumber* Number = [NSNumber numberWithFloat:CurrentBacklight];
			
			if(CurrentBacklight2 > 0)
			{
				NSLog(@"CurrentBacklight2 = %f\n", CurrentBacklight2);
				[Prefs setObject:Number forKey:@"SBBacklightLevel2"];
			}
			if(CurrentBacklight1 > 0)
			{
				NSLog(@"CurrentBacklight1 = %f\n", CurrentBacklight1);
				[Prefs setObject:Number forKey:@"SBBacklightLevel"];
			}
			[Prefs writeToFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist" atomically:YES];
		}
	}*/
	[self transitionOut];
}

-(void)passcodeInput
{
}
@end

// Required
extern "C" BOOL isCapable() {
	return YES;
}

// Required
extern "C" BOOL isEnabled() {
	return YES;
}

// Optional
// Faster isEnabled. Remove this if it's not necessary. Keep it if isEnabled() is expensive and you can make it faster here.
extern "C" BOOL getStateFast() {
	return YES;
}

// Required
extern "C" void setState(BOOL enabled) {
	// Set State!
	PasscodeView *pv = [[PasscodeView alloc] initWindow];
	pv.enabled = enabled;
	[pv transitionIn];
	[pv release];
}

// Required
// How long the toggle takes to toggle, in seconds.
extern "C" float getDelayTime() {
	return 0.0f;
}

// vim:ft=objc
