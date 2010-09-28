//
//  SettingsViewController.h
//  DIYComic
//
//  Created by Andreas Wulf on 16/04/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
#import "Connector.h"


/*!
 SettingsViewController used to alter profile/accoutn settings from the current user
 */
@interface SettingsViewController : TTModelViewController <ConnectorDelegate, UIAlertViewDelegate> {
	Connector *connector; /**< Connector to grab the data */
	
	TTActivityLabel *loadingView; /**< View shown while data loads */
	TTErrorView *errorView; /**< View shown if there was an error loading data */
	
	UITextField *userNameField;
	TTButton *activateButton;
	
	P31LoadingView *loadingPopUpView; /**< Activity indicator view */
}

@property(retain,nonatomic) UITextField *userNameField;
@property(retain,nonatomic) TTButton *activateButton;

@end
