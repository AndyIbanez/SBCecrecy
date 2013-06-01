#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>

@interface SBCecrecyPasswordScreenListController: PSListController
{
	UIButton *setPasscode;
	UITextField *oldPasscode;
	UITextField *newPasscode;
	UITextField *repeatPasscode;
	NSMutableDictionary *passcodeDic;
}
-(void)newPasscodeAction;
-(void)changePasscodeAction;
-(void)enableRepeatPasscode;
-(void)newPasscodeSet; //First time setting up a passcode.
-(void)passcodeChanged; //Not new password. Changing old one.
-(void)enableNewPasscode;
@end

@implementation SBCecrecyPasswordScreenListController
-(void)viewDidLoad
{
	passcodeDic = [[NSMutableDictionary dictionaryWithContentsOfFile: 
								[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.PasscodeString.plist"]] retain];
	if(passcodeDic == nil)
	{
		//There's no passcode.
		setPasscode = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		setPasscode.frame = CGRectMake(5, 15, 310, 44);
		[setPasscode setTitle:@"Set Passcode" forState:UIControlStateNormal];
		[setPasscode addTarget:self action:@selector(newPasscodeAction) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:setPasscode];
	}else
	{
		setPasscode = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		setPasscode.frame = CGRectMake(5, 15, 310, 44);
		[setPasscode setTitle:@"Change Passcode" forState:UIControlStateNormal];
		[setPasscode addTarget:self action:@selector(changePasscodeAction) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:setPasscode];
	}
}

-(void)newPasscodeAction
{
	newPasscode = [[UITextField alloc] initWithFrame:CGRectMake(5, 70, 310, 31)];
	newPasscode.borderStyle = UITextBorderStyleRoundedRect;
	newPasscode.placeholder = @"New Passcode";
	newPasscode.secureTextEntry = YES;
	[newPasscode addTarget:self action:@selector(enableRepeatPasscode) forControlEvents:UIControlEventEditingDidEndOnExit]; 
	[self.view addSubview:newPasscode];
	repeatPasscode = [[UITextField alloc] initWithFrame:CGRectMake(5, 106, 310, 31)];
	repeatPasscode.borderStyle = UITextBorderStyleRoundedRect;
	repeatPasscode.placeholder = @"Repeat New Passcode";
	repeatPasscode.secureTextEntry = YES;
	repeatPasscode.enabled = NO;
	[repeatPasscode addTarget:self action:@selector(newPasscodeSet) forControlEvents:UIControlEventEditingDidEndOnExit]; 
	[self.view addSubview:repeatPasscode];
	[setPasscode setTitle:@"OK" forState:UIControlStateNormal];
	[setPasscode addTarget:self action:@selector(newPasscodeSet) forControlEvents:UIControlEventTouchUpInside];
}

-(void)enableRepeatPasscode
{
	if([newPasscode.text length] < 1)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty Passcode." message:@"If you want a passcode, it can't be empty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[newPasscode becomeFirstResponder];
	}else	
	{
		repeatPasscode.enabled = YES;
		[repeatPasscode becomeFirstResponder];	
	}
}

-(void)newPasscodeSet
{
	if([newPasscode.text isEqualToString:repeatPasscode.text])
	{
		//Everything went fine! Save the passcode.
		//We know we got here because the dictionary was nil to begin with...
		passcodeDic = [NSMutableDictionary dictionary];
		[passcodeDic setObject:repeatPasscode.text forKey:@"passcodeString"];
		[passcodeDic writeToFile:[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.PasscodeString.plist"] atomically:YES];
		[setPasscode setTitle:@"Change Passcode" forState:UIControlStateNormal];
		[setPasscode addTarget:self action:@selector(changePasscodeAction) forControlEvents:UIControlEventTouchUpInside];
		[newPasscode removeFromSuperview];
		[repeatPasscode removeFromSuperview];
	}else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passcode Mismatch" message:@"The passcodes do not match! Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		repeatPasscode.enabled = NO;
		repeatPasscode.text = @"";
		newPasscode.text = @"";
		[newPasscode becomeFirstResponder];
	}
}

-(void)passcodeChanged
{
	if([newPasscode.text isEqualToString:repeatPasscode.text])
	{
		//Everything went fine! Save the passcode.
		//We know we got here because the dictionary was nil to begin with...
		passcodeDic = [[NSMutableDictionary alloc] init];
		[passcodeDic setObject:repeatPasscode.text forKey:@"passcodeString"];
		[passcodeDic writeToFile:[NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.andyibanez.Cecrecy.PasscodeString.plist"] atomically:YES];
		[setPasscode setTitle:@"Change Passcode" forState:UIControlStateNormal];
		[setPasscode addTarget:self action:@selector(changePasscodeAction) forControlEvents:UIControlEventTouchUpInside];
		[newPasscode removeFromSuperview];
		[repeatPasscode removeFromSuperview];
		[oldPasscode removeFromSuperview];
	}else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passcode Mismatch" message:@"The passcodes do not match! Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		repeatPasscode.enabled = NO;
		repeatPasscode.text = @"";
		newPasscode.text = @"";
		[newPasscode becomeFirstResponder];
	}
}

-(void)changePasscodeAction
{
	oldPasscode = [[UITextField alloc] initWithFrame:CGRectMake(5, 70, 310, 31)];
	oldPasscode.borderStyle = UITextBorderStyleRoundedRect;
	oldPasscode.placeholder = @"Old Passcode";
	oldPasscode.secureTextEntry = YES;
	[oldPasscode addTarget:self action:@selector(enableNewPasscode) forControlEvents:UIControlEventEditingDidEndOnExit];
	[self.view addSubview:oldPasscode];
	newPasscode = [[UITextField alloc] initWithFrame:CGRectMake(5, 106, 310, 31)];
	newPasscode.borderStyle = UITextBorderStyleRoundedRect;
	newPasscode.placeholder = @"New Passcode";
	newPasscode.secureTextEntry = YES;
	newPasscode.enabled = NO;
	[newPasscode addTarget:self action:@selector(enableRepeatPasscode) forControlEvents:UIControlEventEditingDidEndOnExit]; 
	[self.view addSubview:newPasscode];
	repeatPasscode = [[UITextField alloc] initWithFrame:CGRectMake(5, 142, 310, 31)];
	repeatPasscode.borderStyle = UITextBorderStyleRoundedRect;
	repeatPasscode.placeholder = @"Repeat New Passcode";
	repeatPasscode.secureTextEntry = YES;
	repeatPasscode.enabled = NO;
	[repeatPasscode addTarget:self action:@selector(passcodeChanged) forControlEvents:UIControlEventEditingDidEndOnExit]; 
	[self.view addSubview:repeatPasscode];
	[setPasscode setTitle:@"OK" forState:UIControlStateNormal];
	[setPasscode addTarget:self action:@selector(passcodeChanged) forControlEvents:UIControlEventTouchUpInside];
}

-(void)enableNewPasscode
{
	NSString *inFile = (NSString *)[passcodeDic objectForKey:@"passcodeString"];
	if([inFile isEqualToString:oldPasscode.text])
	{
		newPasscode.enabled = YES;
		[newPasscode becomeFirstResponder];
	}else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passcode Mismatch" message:@"Your old passcode does not match the one on file. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		oldPasscode.text = @"";
		[oldPasscode becomeFirstResponder];
	}
}

-(void)dealloc
{
	[super dealloc];
	[newPasscode release];
	[repeatPasscode release];
	[oldPasscode release];
	[setPasscode release];
	[passcodeDic release];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[newPasscode resignFirstResponder];
	[repeatPasscode resignFirstResponder];
	[oldPasscode resignFirstResponder];
	[setPasscode resignFirstResponder];
}
@end

// vim:ft=objc
