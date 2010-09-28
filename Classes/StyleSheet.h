//
//  StyleSheet.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>

/*!
 StyleSheet, the global style sheet used in this application
 */
@interface StyleSheet : P31StyleSheet {

}

// Text Styles
- (UIFont*)tableSubTextFont;
- (UIColor*)timestampTextColor;
- (UIFont*)tableTimestampFont;
- (UIColor*)tableSubTextColor;
- (UIFont*)titleFont;
- (UIColor*)titleColor;
- (UIFont*)detailFont;

// Colours
- (UIColor*)detailColor;
- (UIColor*)backgroundColor;

// View styles
- (TTStyle*)toolbarStyle;
- (TTStyle*)colourToolbarStyle;
- (TTStyle*)textFieldStyle;
- (TTStyle*)whiteBoxStyle;
- (TTStyle*)statusBoxStyle;
- (TTStyle*)overlayBoxStyle;
- (TTStyle*)sheetStyle;
- (TTStyle*)tableImageStyle;
- (TTStyle*)comicFrame;
- (TTStyle*)selectedItemBackgroundStyle;

// Buttons
- (TTStyle*)pinkButton:(UIControlState)state;
- (TTStyle*)purpleButton:(UIControlState)state;
- (TTStyle*)orangeButton:(UIControlState)state;
- (TTStyle*)whiteButton:(UIControlState)state;
- (TTStyle*)blackButton:(UIControlState)state;
- (TTStyle*)blueButton:(UIControlState)state;
- (TTStyle*)yellowButton:(UIControlState)state;
- (TTStyle*)greenButton:(UIControlState)state;
- (TTStyle*)redButton:(UIControlState)state;
- (TTStyle*)greyButton:(UIControlState)state;
- (TTStyle*)toolBarButton:(UIControlState)state;
- (TTStyle*)toolBarRedButton:(UIControlState)state;
- (TTStyle*)toolBarBlueButton:(UIControlState)state;
- (TTStyle*)comicButton:(UIControlState)state;
- (TTStyle*)crossButton:(UIControlState)state;

- (TTStyle*)speechBubble:(UIControlState)state;
- (TTStyle*)thoughtBubble:(UIControlState)state;
- (TTStyle*)narrativeBubble:(UIControlState)state;

- (TTStyle*)speechToolBarButton:(UIControlState)state;
- (TTStyle*)thoughtToolBarButton:(UIControlState)state;
- (TTStyle*)narrativeToolBarButton:(UIControlState)state;


@end
