//
//  P31RadialShine.m
//  TTCatalog
//
//  Created by Mike DeSaro on 10/19/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import "P31RadialShine.h"
#import <Three20/TTShape.h>
#import "TTCorePreprocessorMacros.h"


@implementation P31RadialShine

@synthesize color = _color, ovalScaleX = _ovalScaleX, ovalScaleY = _ovalScaleY;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (P31RadialShine*)radialShineWithNext:(TTStyle*)next
{
	return [P31RadialShine radialShineWithColor:[[UIColor whiteColor] colorWithAlphaComponent:40.0/255.0] next:next];
}


+ (P31RadialShine*)radialShineWithColor:(UIColor*)color next:(TTStyle*)next
{
	return [P31RadialShine radialShineWithColor:color ovalScaleX:1.0 ovalScaleY:70.0/425.0 next:next];
}


+ (P31RadialShine*)radialShineWithColor:(UIColor*)color ovalScaleX:(CGFloat)ovalScaleX ovalScaleY:(CGFloat)ovalScaleY next:(TTStyle*)next
{
	P31RadialShine* style = [[[self alloc] initWithNext:next] autorelease];
	style.color = color;
	style.ovalScaleX = ovalScaleX;
	style.ovalScaleY = ovalScaleY;
	
	return style;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNext:(TTStyle*)next
{  
	if( self = [super initWithNext:next] )
	{
		_color = nil;
	}
	return self;
}


- (void)dealloc
{
	TT_RELEASE_SAFELY( _color );
	
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyle

- (void)draw:(TTStyleContext*)context
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState( ctx );
	[context.shape addToPath:context.frame];
	
	CGContextClip( ctx );
	
	//Draw elipse
	CGContextSetFillColorWithColor( ctx, _color.CGColor );
		
	CGContextScaleCTM( ctx, _ovalScaleX, _ovalScaleY );
	CGContextAddArc( ctx, 
					( context.frame.origin.x + context.frame.size.width / 2.0 ) / _ovalScaleX,
					( context.frame.origin.y + 0.0) / _ovalScaleY,
					context.frame.size.width / 2.0 * 425.0 / 270.0, 
					0.0, 2*M_PI, 1 );
	CGContextFillPath( ctx );
	
	CGContextRestoreGState( ctx );
	
	return [self.next draw:context];
}

@end
