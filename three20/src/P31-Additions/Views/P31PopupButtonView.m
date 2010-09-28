//
//  TWPopupButtonView.m
//  TestPopUp
//
//  Created by Mike DeSaro on 10/12/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import "P31PopupButtonView.h"
#import <Three20/TTStyleSheet.h>
#import "P31.h"


@interface P31PopupButtonView()
- (TTStyle*)popupBackgroundWithPointLocation:(CGFloat)pointLocation;
- (CGRect)calculateFrameFromOrigin:(CGPoint)originPoint;
@end



// Constants for laying out the buttons and background
const static CGFloat kVertialSpacing = 10.0;
const static CGFloat kButtonHorizontalSpacing = 10.0; // Space on left/right inside buttons

const static CGFloat kButtonSpacing = 3.0;
const static CGFloat kButtonHeight = 35.0;
const static CGFloat kCalloutTailHeight = 40.0;

@implementation P31PopupButtonView

@synthesize delegate = _delegate, shouldAutoHide = _shouldAutoHide, buttonTitles = _buttonTitles, buttonWindow = _buttonWindow;

///////
#pragma mark NSObject

- (id)initWithDelegate:(id<P31PopupButtonViewDelegate>)delegate originPoint:(CGPoint)originPoint yOffset:(CGFloat)yOffset buttonTitles:(NSString*)title, ...
{
    if( self = [super initWithFrame:CGRectZero] )
	{
		self.delegate = delegate;
		
		// Grab all the passed in titles
		NSString *currentObject;
		va_list argList;
		
		if( title )
		{
			self.buttonTitles = [NSMutableArray array];
			[_buttonTitles addObject:title];
			
			va_start( argList, title );
			
			while( currentObject = va_arg( argList, NSString* ) )
				[_buttonTitles addObject:currentObject];
			
			va_end( argList );
		}
		
		// Set our pointSize
		_pointSize = CGSizeMake( 40, 40 );
		
		// Calculate our frame and other information for the background
		CGRect frame = [self calculateFrameFromOrigin:originPoint];
		
		if( _displayingBelowOrigin )
			frame.origin.y -= yOffset;
		else
			frame.origin.y += yOffset;
		
		// Set our frame and properties
		self.frame = frame;
		self.alpha = 0.0;
		self.opaque = NO;
		
    }
    return self;
}


- (void)dealloc
{
	TT_RELEASE_SAFELY( _buttonTitles );
	TT_RELEASE_SAFELY( _buttonWindow );
	
    [super dealloc];							
}


/////
#pragma mark Private

- (CGRect)calculateFrameFromOrigin:(CGPoint)originPoint
{
	// Grab the longestString 
	NSString *longestString = nil;
	int longestStringLength = 0;
	for( NSString *string in _buttonTitles )
	{
		int stringLength = [string length];
		if( longestString == nil || longestStringLength < stringLength )
		{
			longestString = string;
			longestStringLength = stringLength;
			continue;
		}
	}
	
	CGSize textSize = [longestString sizeWithFont:TTSTYLEVAR(buttonFont)];
	
	// Setup our frame and properties now that we know how many buttons we will have
	CGRect frame;
	frame.size.width = textSize.width + 50;
	frame.size.height = ( kVertialSpacing * 2 ) + ( ( [_buttonTitles count] - 1 ) * kButtonSpacing ) + ( [_buttonTitles count] * kButtonHeight ) + kCalloutTailHeight;
	frame.origin.x = originPoint.x - frame.size.width / 2;
	frame.origin.y = originPoint.y - frame.size.height;
	
	CGFloat pointLocation = 270.0f;
	CGFloat frameShift = 0;
	_displayingBelowOrigin = NO;
	
	// Are we going to overlap on the right or left?
	if( frame.origin.x < 0 )
	{
		frameShift = 10 - frame.origin.x;
	}
	else if( frame.origin.x + frame.size.width > 320 )
	{
		frameShift = ( 320.0 - 10.0 ) - frame.origin.x - frame.size.width;
	}
	
	// If we had a frameShift adjust our pointLocation so the dongle lines up correctly
	if( frameShift != 0 )
	{
		CGFloat pointX = frame.size.width / 2 - frameShift;
		pointLocation = 315 - ( 90 * pointX ) / frame.size.width;
		
		frame.origin.x += frameShift;
	}
	
	// Are we displaying above or below our target?
	if( frame.origin.y < 0 )
	{
		// See how far off from center pointLocation is
		CGFloat offset = 270 - pointLocation;
		pointLocation = 90 + offset;
		frame.origin.y += frame.size.height;
		
		// Set our flag so we lay things out correctly
		_displayingBelowOrigin = YES;
	}
	
	
	// Add the cancel button with appropriate style
	TTButton *button = [TTButton buttonWithStyle:@"popupCloseButton:" title:@"X"];
	
	CGFloat buttonY = ( _displayingBelowOrigin ) ? 5 : frame.size.height - kButtonHeight;
	button.frame = CGRectMake( floorf( frame.size.width / 2 ) - floorf( kButtonHeight / 2 ) - frameShift, buttonY, kButtonHeight, kButtonHeight );
	[button addTarget:self action:@selector(onTouchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
	
	// Add the backgorund style
	self.style = [self popupBackgroundWithPointLocation:pointLocation];
	
	return frame;
}


- (TTStyle*)popupBackgroundWithPointLocation:(CGFloat)pointLocation
{
	CGFloat pointAngle = ( pointLocation > 225 ) ? 270 : 90;

	return [TTShapeStyle styleWithShape:[P31PopupButtonCalloutShape shapeWithRadius:10 pointLocation:pointLocation // 300 is bottom left.  245 - 300 is allowed
																		 pointAngle:pointAngle pointSize:_pointSize] next:
			TTSTYLEVAR(popupButtonBackground)];
}


// Called when the fade out animation stops
- (void)animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
	[self removeFromSuperview];
	
	// Hide the window.  This will get it out of the UIWindow hierarchy
	_buttonWindow.hidden = YES;
}


- (void)onTouchPopupButton:(UIButton*)sender
{
	// Grab button info
	NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
	uint buttonIndex = [_buttonTitles indexOfObject:buttonTitle];
	
	// Let our delegate know about the touch and dismiss ourself
	[_delegate popupView:self didTouchObjectAtIndex:buttonIndex withTitle:buttonTitle];
	
	[self hide];
}


- (void)onTouchCancelButton:(UIButton*)sender
{
	[self hide];
}


/////////
#pragma mark UIView

// If we get a touch that wasnt eaten by a UIResponder (button), hide ourself
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *v = [super hitTest:point withEvent:event];
	
	// If the hitTest returns us, return nil to pass it on and let our delegate know
	if( v == self )
		[self hide];
	
	return v;
}


//////
#pragma mark P31WindowDelegate

- (void)windowWasTouched:(UIWindow*)window
{
	// Hide will remove the view from the hierarchy and dimiss ourself
	[self hide];
}


///////
#pragma mark Public

- (void)show
{
	BOOL shouldAddButtons = NO;
	
	// If we dont have a _buttonWindow create one
	if( _buttonWindow == nil )
	{
		_buttonWindow = [[P31Window alloc] initWithFrame:TTScreenBounds() andTouchDelegate:self];
		_buttonWindow.windowLevel = 2; // Keyboard window will be 1
		
		shouldAddButtons = YES;
	}
	
	// Show ourself and start eating events
	[_buttonWindow makeKeyAndVisible];
	
	// Add ourself to the window
	[_buttonWindow addSubview:self];
	
	if( shouldAddButtons )
	{
		// Add our title buttons
		CGFloat yPos = ( _displayingBelowOrigin ) ? kVertialSpacing + _pointSize.height : kVertialSpacing;
		CGFloat buttonWidth = self.size.width - ( 2 * kButtonHorizontalSpacing );
		for( NSString *title in _buttonTitles )
		{
			TTButton *button = [TTButton buttonWithStyle:@"popupButton:" title:title];
			button.frame = CGRectMake( kButtonHorizontalSpacing, yPos, buttonWidth, kButtonHeight );
			[button addTarget:self action:@selector(onTouchPopupButton:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
			
			// Increment our yPos
			yPos += kButtonHeight + kButtonSpacing;
		}
	}
	
	// Fade in the view
	[UIView beginAnimations:nil context:NULL];
	self.alpha = 1.0;
	[UIView commitAnimations];
	
	// Hide ourself in 2 seconds if it is deemed we should
	if( _shouldAutoHide )
		[self performSelector:@selector(hide) withObject:nil afterDelay:2.0];
}


- (void)hide
{
	// If we are set to autohide, cancel the invocation just in case it hasnt fired yet
	if( _shouldAutoHide )
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	// Fade ourself out and on animationEnd remove ourself from the window
	// Fade in the view
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	self.alpha = 0.0;
	
	[UIView commitAnimations];
}


@end
