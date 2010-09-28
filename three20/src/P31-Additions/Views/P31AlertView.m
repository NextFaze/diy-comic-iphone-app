//
//  P31AlertView.m
//  AlertView
//
//  Created by Mike DeSaro on 10/19/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import "P31AlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "P31.h"
#import <Three20/TTStyleSheet.h>
#import <Three20/TTButton.h>
#import <Three20/TTURLCache.h>


#define kAlertBackgroundImageTag 55

// Constants for laying out the buttons and background
const static CGFloat kButtonHorizontalSpacing = 10.0;
const static CGFloat kButtonSpacing = 4.0;
const static CGFloat kButtonHeight = 40.0;


@interface P31AlertView()
- (void)addButtonWithTitle:(NSString*)title frame:(CGRect)frame isCancelButton:(BOOL)isCancelButton;
@end



@implementation P31AlertView


@synthesize delegate = _delegate, cancelButtonTitle = _cancelButtonTitle, buttonTitles = _buttonTitles, textFields = _textFields,
			dimWindow = _dimWindow, title = _title, body = _body;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<P31AlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    if( self = [self initWithFrame:CGRectZero] )
	{
		self.delegate = delegate;
		
		// Grab all the passed in titles
		NSString *currentObject;
		va_list argList;
		
		if( otherButtonTitles )
		{
			self.buttonTitles = [NSMutableArray array];
			[_buttonTitles addObject:otherButtonTitles];
			
			va_start( argList, otherButtonTitles );
			
			while( currentObject = va_arg( argList, NSString* ) )
				[_buttonTitles addObject:currentObject];
			
			va_end( argList );
		}
		
		// Deal with the rest of the parameters
		self.title = title;
		self.body = message;
		self.cancelButtonTitle = cancelButtonTitle;
	}
	return self;
}


- (id)initWithFrame:(CGRect)frame
{
    if( self = [super initWithFrame:frame] )
	{
		// Setup our defaults
		self.opaque = NO;
		self.style = TTSTYLE(alertBackground);
		self.alpha = 0.6;
    }
    return self;
}


- (void)dealloc
{
	TT_RELEASE_SAFELY( _cancelButtonTitle );
    TT_RELEASE_SAFELY( _dimWindow );
	TT_RELEASE_SAFELY( _buttonTitles );
	TT_RELEASE_SAFELY( _textFields );
	TT_RELEASE_SAFELY( _title );
	TT_RELEASE_SAFELY( _body );
	
	[super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private

- (void)setupInitialFrame
{
	// Top and bottom padding
	CGFloat frameHeight = 35.0;
	
	// Add our UITextFields in if we have any
	if( _textFields != nil )
	{
		int totalTextFields = [_textFields count];
		frameHeight += ( totalTextFields * 31.0 ) + ( ( totalTextFields + 1 ) * kButtonSpacing );
	}
	
	// Add title height if we have one
	if( !STRING_IS_EMPTY_OR_NIL( _title ) )
	{
		_titleSize = [_title sizeWithFont:TTSTYLEVAR(alertTitleFont) constrainedToSize:CGSizeMake( 270.0, 500.0 ) lineBreakMode:UILineBreakModeWordWrap];
		frameHeight += _titleSize.height;
	}
	
	// Add body height if we have one
	if( !STRING_IS_EMPTY_OR_NIL( _body ) )
	{
		_bodySize = [_body sizeWithFont:TTSTYLEVAR(alertBodyFont) constrainedToSize:CGSizeMake( 260.0, 500.0 ) lineBreakMode:UILineBreakModeWordWrap];

		// TODO: make this work
		// Limit bodyHeight and use a UITextView if the body is too big
		if( _bodySize.height > 150 )
		{
			//bodyHeight = 150;
		}
		
		frameHeight += _bodySize.height;
	}
	
	// Buttons
	int buttonCount = [_buttonTitles count];
	BOOL hasCancelButton = !STRING_IS_EMPTY_OR_NIL( _cancelButtonTitle );
	
	if( hasCancelButton && ( buttonCount == 1 || buttonCount == 0 ) )
	{
		// Button height and spacing on top/bottom of button
		frameHeight += kButtonHeight + ( 2 * kButtonSpacing );
	}
	else if( buttonCount > 1 )
	{
		// Add one for our cancelButton
		if( hasCancelButton )
			buttonCount++;
		
		frameHeight += ( buttonCount * kButtonSpacing ) + ( buttonCount * kButtonHeight );
	}

	// Default to 20.0 which is the height of the status bar
	CGFloat startYPos = 20.0;
	CGFloat startXPos = ( _dimWindow.bounds.size.width - 280.0 ) / 2.0;
	
	// Adjust our yPos only if we are not in landscape
	if( !UIInterfaceOrientationIsLandscape( TTInterfaceOrientation() ) )
		startYPos = ( _textFields == nil ) ? ( 480.0 - frameHeight ) / 2 : ( 480.0 - frameHeight ) / 2 - 100.0;
	
	self.frame = CGRectMake( startXPos, startYPos, 280.0, frameHeight );
}


- (void)popupAlertView
{
	CGAffineTransform afterAnimationTransform = CGAffineTransformIdentity;
	
	self.transform = CGAffineTransformMakeScale( 0.5, 0.5 );
	
	// Adjust our transforms if we have textFields
	if( _textFields != nil )
	{
		//self.transform = CGAffineTransformTranslate( self.transform, 0, -100 );
		//afterAnimationTransform = CGAffineTransformMakeTranslation( 0, -100 );
		[[_textFields objectAtIndex:0] becomeFirstResponder];
	}
	
	// Create a keyframe animation to follow a path back to the center
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	bounceAnimation.removedOnCompletion = NO;
	
	NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.2], [NSNumber numberWithFloat:0.8], [NSNumber numberWithFloat:1.0], nil];
	//NSArray *timings = [NSArray arrayWithObjects:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil];
	
	bounceAnimation.values = values;
	//bounceAnimation.timingFunctions = timings;
	bounceAnimation.duration = 0.4;

	[self.layer addAnimation:bounceAnimation forKey:@"transformScale"];
	
	self.transform = afterAnimationTransform;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSNotifications

- (void)orientationDidChangeNotification:(NSNotification*)note
{
	// Rotate ourself if we are going to portrait
	self.transform = TTRotateTransformForOrientation( TTInterfaceOrientation() );

	// Adjust our xPos
	CGFloat startXPos = ( TTScreenBounds().size.width - 280.0 ) / 2.0;
	
	self.frame = CGRectMake( startXPos, self.frame.origin.y, 280.0, self.frame.size.height );
}


// The workhorse.  This function adds all our views.
- (void)addButtonsAndTextToAlertView
{
	// Add our title buttons
	CGFloat yPos = 15.0;
	
	if( ![_title isEmptyOrWhitespace] )
	{
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( 10.0, yPos, 260.0, _titleSize.height )];
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.textAlignment = UITextAlignmentCenter;
		label.numberOfLines = 10;
		label.shadowColor = RGBCOLOR( 15, 15, 15 );
		label.shadowOffset = CGSizeMake( 0, -1 );
		label.text = _title;
		label.font = TTSTYLEVAR(alertTitleFont);
		label.textColor = TTSTYLEVAR(alertTextColor);
		label.backgroundColor = [UIColor clearColor];
		
		[self addSubview:label];
		[label release];
		
		yPos += _titleSize.height + 10.0;
	}
	
	// Body text
	if( ![_body isEmptyOrWhitespace] )
	{		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( 10.0, yPos, 260.0, _bodySize.height )];
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.textAlignment = UITextAlignmentCenter;
		label.numberOfLines = 20;
		label.text = _body;
		label.font = TTSTYLEVAR(alertBodyFont);
		label.textColor = TTSTYLEVAR(alertTextColor);
		label.backgroundColor = [UIColor clearColor];
		
		[self addSubview:label];
		[label release];
		
		yPos += _bodySize.height + 10.0;
	}
	
	// UITextFields
	if( _textFields != nil )
	{
		yPos += kButtonSpacing;
		
		for( UITextField *tf in _textFields )
		{
			tf.frame = CGRectMake( 10.0, yPos, self.frame.size.width - ( 2 * kButtonHorizontalSpacing ), 31.0 );
			[self addSubview:tf];
			
			yPos += tf.frame.size.height + kButtonSpacing;
		}
		
		yPos += kButtonSpacing;
	}

	// Buttons
	CGFloat buttonWidth = self.frame.size.width - ( 2 * kButtonHorizontalSpacing );
	int otherButtonCount = [_buttonTitles count];
	BOOL hasCancelButton = !STRING_IS_EMPTY_OR_NIL( _cancelButtonTitle );
	
	if( hasCancelButton && otherButtonCount == 0 )
	{
		// Add our cancelButton full width
		CGRect frame = CGRectMake( kButtonHorizontalSpacing, yPos, buttonWidth, kButtonHeight );
		[self addButtonWithTitle:_cancelButtonTitle frame:frame isCancelButton:YES];
		
		yPos += frame.size.height + kButtonSpacing;
	}
	else if( hasCancelButton && otherButtonCount == 1 )
	{
		// Add our cancelButton half width
		CGRect frame = CGRectMake( kButtonHorizontalSpacing, yPos, ( buttonWidth / 2 ) - 2.0, kButtonHeight );
		[self addButtonWithTitle:_cancelButtonTitle frame:frame isCancelButton:YES];
				
		// Add our only other button
		frame.origin.x = kButtonHorizontalSpacing + frame.size.width + ( kButtonHorizontalSpacing / 2 );
		[self addButtonWithTitle:[_buttonTitles objectAtIndex:0] frame:frame isCancelButton:NO];
		
		yPos += kButtonHeight + kButtonSpacing;
	}
	else if( hasCancelButton && otherButtonCount > 1 )
	{
		// Add our cancelButton full width
		CGRect frame = CGRectMake( kButtonHorizontalSpacing, yPos, buttonWidth, kButtonHeight );
		
		// Add all other buttons
		for( NSString *title in _buttonTitles )
		{
			[self addButtonWithTitle:title frame:frame isCancelButton:NO];
			
			yPos += kButtonHeight + kButtonSpacing;
			frame.origin.y = yPos;
		}
		
		[self addButtonWithTitle:_cancelButtonTitle frame:frame isCancelButton:YES];
		
		yPos += kButtonHeight + kButtonSpacing;
		
	}
	else if( otherButtonCount > 0 )
	{
		// Add our cancelButton full width
		CGRect frame = CGRectMake( kButtonHorizontalSpacing, yPos, buttonWidth, kButtonHeight );

		// Add all other buttons
		for( NSString *title in _buttonTitles )
		{
			[self addButtonWithTitle:title frame:frame isCancelButton:NO];
			
			yPos += frame.size.height + kButtonSpacing;
			frame.origin.y = yPos;
		}
	}
	
	
	for( NSString *title in _buttonTitles )
	{
		
		
		// Increment our yPos
		yPos += kButtonHeight + kButtonSpacing;
	}
}


- (void)addButtonWithTitle:(NSString*)title frame:(CGRect)frame isCancelButton:(BOOL)isCancelButton
{
	TTButton *button;
	
	if( isCancelButton )
		button = [TTButton buttonWithStyle:@"alertDefaultButton:" title:title];
	else
		button = [TTButton buttonWithStyle:@"alertOtherButton:" title:title];

	button.frame = frame;
	[button addTarget:self action:@selector(onTouchPopupButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
}


- (void)hide
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	 
	// Hide the keyboard if it's up
	if( _keyboardIsShowing )
	{
		for( UITextField *tf in _textFields )
			[tf resignFirstResponder];
	}
	
	// Fade ourself out and on animationEnd remove ourself from the window
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	[_dimWindow viewWithTag:kAlertBackgroundImageTag].alpha = 0.0;
	self.alpha = 0.0;
	
	[UIView commitAnimations];
}


- (void)onTouchPopupButton:(UIButton*)sender
{
	// Grab button info
	NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
	
	uint buttonIndex;
	// First, check for the cancel button
	if( [buttonTitle isEqualToString:_cancelButtonTitle] )
		buttonIndex = 0;
	else
		buttonIndex = [_buttonTitles indexOfObject:buttonTitle] + 1;
	
	// Let our delegate know about the touch and dismiss ourself
	// Delegate method
	if( [_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:withTitle:)] )
		[_delegate alertView:self clickedButtonAtIndex:buttonIndex withTitle:buttonTitle];
	
	[self hide];
}


// Called when the fade out animation stops.  Removes the alert window
- (void)animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
	[self removeFromSuperview];
	
	// Hide the window.  This will get it out of the UIWindow hierarchy
	_dimWindow.hidden = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	int totalTextFields = [_textFields count];
	
	if( ( totalTextFields - 1 ) > textField.tag )
	{
		[[_textFields objectAtIndex:textField.tag + 1] becomeFirstResponder];
	}
	
	return NO;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if( !_keyboardIsShowing )
	{
		_keyboardIsShowing = YES;
	
		[UIView beginAnimations:nil context:NULL];
		// Adjust the transform the fit the keyboard if necessary
		self.transform = CGAffineTransformTranslate( self.transform, 0.0, -100 );
		[UIView commitAnimations];
	}
	
	return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public

- (UITextField*)textFieldAtIndex:(int)index
{
	if( [_textFields count] > index )
		return [_textFields objectAtIndex:index];
	
	return nil;
}


- (NSString*)textForTextFieldAtIndex:(int)index
{
	return [self textFieldAtIndex:index].text;
}


- (void)addTextFieldWithValue:(NSString*)value placeHolder:(NSString*)placeHolder
{
	// Create our array if we haven't already
	if( _textFields == nil )
		self.textFields = [NSMutableArray array];
	
	// Create out textField without a frame for now
	UITextField *tf = [[UITextField alloc] init];
	tf.delegate = self;
	tf.font = [UIFont systemFontOfSize:20.0];
	tf.keyboardAppearance = UIKeyboardAppearanceAlert;
	tf.borderStyle = UITextBorderStyleRoundedRect;
	//tf.backgroundColor = [UIColor whiteColor];
	tf.tag = [_textFields count];
	tf.placeholder = placeHolder;
	tf.text = value;
	
	[_textFields addObject:tf];
	[tf release];
}


- (void)show
{
	// Listen for rotation events
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChangeNotification:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
	
	_dimWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_dimWindow.bounds = TTScreenBounds();
	_dimWindow.transform = TTRotateTransformForOrientation( TTInterfaceOrientation() );
	_dimWindow.windowLevel = UIWindowLevelAlert;
	
	// Show the window
	[_dimWindow makeKeyAndVisible];
	
	// Add the background
	UIView *bgImage = [[[UIView alloc] initWithFrame:_dimWindow.bounds] autorelease];
	bgImage.backgroundColor = RGBACOLOR( 0, 0, 0, 0.5 );
	
	bgImage.alpha = 0.0;
	bgImage.tag = kAlertBackgroundImageTag;
	[_dimWindow addSubview:bgImage];
	
	
	// Setup  our frame and add our buttons
	[self setupInitialFrame];
	[self addButtonsAndTextToAlertView];
	
	// Delegate method
	if( [_delegate respondsToSelector:@selector(willPresentAlertView:)] )
		[_delegate willPresentAlertView:self];
	
	// Add ourself to the window
	[_dimWindow addSubview:self];
	
	
	// Fade in the background view
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	
	bgImage.alpha = 0.8;
	self.alpha = 1.0;
	
	[UIView commitAnimations];
	
	// Animate our entrance
	[self popupAlertView];
}


@end
