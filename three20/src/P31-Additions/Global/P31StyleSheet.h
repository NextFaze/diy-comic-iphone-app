//
//  P31StyleSheet.h
//  TTCatalog
//
//  Created by Mike DeSaro on 10/12/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import <Three20/Three20.h>


@interface P31StyleSheet : TTDefaultStyleSheet
{

}

// P31 Popup Button

- (TTStyle*)popupButtonBackground;


// Launcher View Controller
@property (nonatomic, readonly) UIColor *launcherBackgroundColor;


// Fonts
@property (nonatomic, readonly) UIFont *alertTitleFont;
@property (nonatomic, readonly) UIFont *alertBodyFont;


// Colors
@property (nonatomic, readonly) UIColor *alertTextColor;
@property (nonatomic, readonly) UIColor *alertTextTintColor;

@property (nonatomic, readonly) UIColor *loadingViewBackgroundColor;
@property (nonatomic, readonly) UIColor *loadingViewTextColor;


@end
