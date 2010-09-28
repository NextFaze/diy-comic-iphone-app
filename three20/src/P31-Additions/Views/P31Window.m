//
//  P31Window.m
//  TTCatalog
//
//  Created by Mike DeSaro on 10/14/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import "P31Window.h"


@implementation P31Window

@synthesize touchDelegate = _touchDelegate;


- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame andTouchDelegate:nil];
}


- (id)initWithFrame:(CGRect)frame andTouchDelegate:(id<P31WindowDelegate>)touchDelegate
{
    if( self = [super initWithFrame:frame] )
	{
        self.touchDelegate = touchDelegate;
		// Uncomment the next line to debug
		//self.backgroundColor = [UIColor colorWithRed:0.1 green:0.3 blue:0.5 alpha:0.2];
    }
    return self;
}


- (void)dealloc
{
	NSLog( @"DEALLOC P31Window" );
	
    [super dealloc];
}


- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
	UIView *v = [super hitTest:point withEvent:event];
	
	// If the hitTest returns us, return nil to pass it on and let our delegate know
	if( v == self && _touchDelegate != nil )
	{
		[_touchDelegate windowWasTouched:self];
		return nil;
	}
	
	return v;
}


@end