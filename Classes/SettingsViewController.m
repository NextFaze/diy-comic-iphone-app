//
//  SettingsViewController.m
//  DIYComic
//
//  Created by Andreas Wulf on 16/04/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "SettingsViewController.h"
#import "StyleSheet.h"

@implementation SettingsViewController
@synthesize userNameField, activateButton;

- (id)init {
	if (self = [super init]) {
		connector = [[Connector alloc] init];
		connector.delegate = self;

		self.title = @"Profile";
		
		loadingView = nil;
	}
	
	return self;
}

- (void)dismissPressed:(id)sender {
	[userNameField resignFirstResponder];
}

- (void)activatePressed:(id)sender {
	if (userNameField.enabled) {
		NSString *userName = [userNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if (!userName.length) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No User Name Specified" 
															message:@"Please enter a user name" 
														   delegate:nil 
												  cancelButtonTitle:@"Ok" 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		} else {
			loadingPopUpView = [P31LoadingView loadingViewShowWithMessage:@"Activating"];		
			[connector activateUserName:userName];
		}
		
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Deactivate User name?" 
														message:@"Do you whish to deactivate your user name?" 
													   delegate:self
											  cancelButtonTitle:@"No" 
											  otherButtonTitles:@"Yes",nil];
		[alert show];
		[alert release];
	}

}

- (void)loadView {
	[super loadView];	

	UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
	dismissButton.frame = self.view.frame;
	[dismissButton addTarget:self action:@selector(dismissPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:dismissButton];
	
	//////
	// User name setting
	UILabel *usernameHeading = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.width-20, 30)];
	usernameHeading.text = @"Display Name";
	usernameHeading.font = TTSTYLEVAR(titleFont);
	usernameHeading.textColor = TTSTYLEVAR(titleColor);
	usernameHeading.backgroundColor = self.view.backgroundColor;
	[usernameHeading sizeToFit];
	[self.view addSubview:usernameHeading];
	
	UILabel *usernameInfo = [[UILabel alloc] initWithFrame:CGRectMake(10, usernameHeading.bottom+2, self.view.width-20, 30)];
	usernameInfo.text = @"This is the name that will be shown on the comics uploaded, this name can't be changed once activated";
	usernameInfo.font = TTSTYLEVAR(detailFont);
	usernameInfo.textColor = TTSTYLEVAR(detailColor);
	usernameInfo.numberOfLines = 0;
	usernameInfo.backgroundColor = self.view.backgroundColor;
	[usernameInfo sizeToFit];
	[self.view addSubview:usernameInfo];
	
	self.userNameField = [[[UITextField alloc] initWithFrame:CGRectMake(10, usernameInfo.bottom+5, self.view.width-20, 41)] autorelease];
	userNameField.borderStyle = UITextBorderStyleRoundedRect;
	userNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	userNameField.autocorrectionType = UITextAutocorrectionTypeNo;
	userNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[self.view addSubview:userNameField];
	
	self.activateButton = [TTButton buttonWithStyle:@"redButton:"];
	activateButton.frame = CGRectMake(10, userNameField.bottom+5, self.view.width-20, 41);
	[activateButton addTarget:self action:@selector(activatePressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:activateButton];
	
	////////////////
	// Model views
	loadingView = [[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleWhiteBox];
	loadingView.frame = self.view.frame;
	loadingView.text = @"Loading...";
	loadingView.hidden = YES;
	loadingView.backgroundColor = self.view.backgroundColor;
	[self.view addSubview:loadingView];
	[loadingView release];
	
	errorView = [[TTErrorView alloc] init];
	errorView.title = @"Error";
	errorView.image = TTIMAGE(@"bundle://Three20.bundle/images/error.png");
	errorView.frame = self.view.frame;
	errorView.hidden = YES;
	errorView.backgroundColor = TTSTYLEVAR(backgroundColor);
	[self.view addSubview:errorView];
	[errorView release];
	
	[self showLoading:YES];
	
	[connector grabUserName];
}

- (void)showLoading:(BOOL)show {
	loadingView.hidden = !show;
}

- (void)showError:(BOOL)show {
	errorView.hidden = !show;
}

- (void)dealloc {
	connector.delegate = nil;
	[connector release];
	[userNameField release];
	[activateButton release];
	[super dealloc];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex==1) {
		loadingPopUpView = [P31LoadingView loadingViewShowWithMessage:@"De-activating"];
		[connector deactivateUserName];
	}
}

#pragma mark ConnectorDelegate
- (void)connectorRequestDidFinishWithData:(id)data call:(NSString*)call {
	if ([call isEqualToString:@"grabUserName"]) {
		if ([data isKindOfClass:[NSString class]] && ((NSString*)data).length) {
			userNameField.text = data;
			[activateButton setTitle:@"De-activate" forState:UIControlStateNormal];
			activateButton.enabled = NO;
			activateButton.alpha = 0.5;
			userNameField.enabled = NO;
			userNameField.alpha = 0.5;
			
		} else {
			[activateButton setTitle:@"Activate" forState:UIControlStateNormal];
			userNameField.enabled = YES;
			userNameField.alpha = 1;
		}		
		
		[self showLoading:NO];
		[self showError:NO];
		
	} else if ([call isEqualToString:@"activateUserName"] || [call isEqualToString:@"deactivateUserName"]) {
		[loadingPopUpView hideWithDoneImageAndMessage:@"Activated" afterDelay:0.5];
		loadingPopUpView = nil;
		
		[connector grabUserName];
	}

}

- (void)connectorRequestDidFailWithError:(NSError*)error call:(NSString*)call {	
	if ([call isEqualToString:@"grabUserName"]) {
		errorView.subtitle = [error localizedDescription];
		errorView.title = [error localizedFailureReason];
		[errorView layoutSubviews];
		[self showLoading:NO];
		[self showError:YES];
		
		
	} else if ([call isEqualToString:@"activateUserName"]||[call isEqualToString:@"deactivateUserName"]) {
		[loadingPopUpView hide];
		loadingPopUpView = nil;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] 
																message:[error localizedFailureReason] 
																delegate:nil 
													  cancelButtonTitle:@"Ok" 
													  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
}

@end
