//
//  P31PopupButtonCalloutShape.m
//  TTCatalog
//
//  Created by Mike DeSaro on 10/12/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import "P31PopupButtonCalloutShape.h"


static CGFloat kInsetWidth = 5;
#define RD(_RADIUS) (_RADIUS == TT_ROUNDED ? round(fh/2) : _RADIUS)


@implementation P31PopupButtonCalloutShape

@synthesize radius = _radius, pointLocation = _pointLocation, pointAngle = _pointAngle, pointSize = _pointSize;

///////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (P31PopupButtonCalloutShape*)shapeWithRadius:(CGFloat)radius pointLocation:(CGFloat)pointLocation
							 pointAngle:(CGFloat)pointAngle pointSize:(CGSize)pointSize
{
	P31PopupButtonCalloutShape* shape = [[[P31PopupButtonCalloutShape alloc] init] autorelease];
	shape.radius = radius;
	shape.pointLocation = pointLocation;
	shape.pointAngle = pointAngle;
	shape.pointSize = pointSize;
	
	return shape;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (CGRect)subtractPointFromRect:(CGRect)rect
{
	CGFloat x = 0;
	CGFloat y = 0;
	CGFloat w = rect.size.width;
	CGFloat h = rect.size.height;
	
	if ((_pointLocation >= 0 && _pointLocation < 45)
		|| (_pointLocation >= 315 && _pointLocation < 360))
	{
		if ((_pointAngle >= 270 && _pointAngle < 360) || (_pointAngle >= 0 && _pointAngle < 90))
		{
			x += _pointSize.width;
			w -= _pointSize.width;
		}
	}
	else if (_pointLocation >= 45 && _pointLocation < 135)
	{
		if (_pointAngle >= 0 && _pointAngle < 180)
		{
			y += _pointSize.height;
			h -= _pointSize.height;
		}
	}
	else if (_pointLocation >= 135 && _pointLocation < 225)
	{
		if (_pointAngle >= 90 && _pointAngle < 270)
		{
			w -= _pointSize.width;
		}
	} else if (_pointLocation >= 225 && _pointLocation <= 315)
	{
		if (_pointAngle >= 180 && _pointAngle < 360)
		{
			h -= _pointSize.height;
		}
	}
	
	return CGRectMake(x, y, w, h);
}


- (void)addTopEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path reset:(BOOL)reset
{
	CGFloat fw = size.width;
	CGFloat fh = size.height;
	CGFloat pointX = 0;
	CGFloat rdRadius = RD( _radius );
	
	if( lightSource >= 0 && lightSource <= 90 )
	{
		if( reset )
		{
			CGPathMoveToPoint( path, nil, rdRadius, 0 );
		}
	}
	else
	{
		if( reset )
		{
			CGPathMoveToPoint( path, nil, 0, rdRadius );
		}
		CGPathAddArcToPoint( path, nil, 0, 0, rdRadius, 0, rdRadius );
	}
	
	if( _pointLocation >= 45 && _pointLocation <= 135 )
	{
		CGFloat ph = ( _pointAngle >= 0 && _pointAngle < 180 ) ? _pointSize.height : -_pointSize.height;
		pointX = ( ( _pointLocation - 45 ) / 90 ) * fw;
		
		//CGPathAddLineToPoint( path, nil, pointX - floor( _pointSize.width / 2 ), 0 );
		//CGPathAddLineToPoint( path, nil, pointX, -ph );
		//CGPathAddLineToPoint( path, nil, pointX + floor( _pointSize.width / 2 ), 0 );

		
		// Mine
		CGPathAddLineToPoint( path, nil, pointX - floor( _pointSize.width / 2 ), 0 );
		CGPathAddArcToPoint( path, nil, pointX - floor( _pointSize.width / 2 ), -ph, pointX - floor( _pointSize.width / 4 ), -ph, rdRadius );
		CGPathAddArcToPoint( path, nil, pointX + floor( _pointSize.width / 2 ), -ph, pointX + floor( _pointSize.width / 2 ), 0, rdRadius );
		CGPathAddLineToPoint( path, nil, pointX + floor( _pointSize.width / 2 ), 0 );
	}
	
	CGPathAddArcToPoint( path, nil, fw, 0, fw, rdRadius, rdRadius );
}


- (void)addRightEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
			   reset:(BOOL)reset
{
	CGFloat fw = size.width;
	CGFloat fh = size.height;
	
	if (reset)
	{
		CGPathMoveToPoint(path, nil, fw, RD(_radius));
	}
	
	CGPathAddArcToPoint(path, nil, fw, fh, fw-RD(_radius), fh, RD(_radius));
}


- (void)addBottomEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path reset:(BOOL)reset
{
	CGFloat fw = size.width;
	CGFloat fh = size.height;
	CGFloat pointX = 0;
	CGFloat rdRadius = RD( _radius );
	
	if( reset )
	{
		CGPathMoveToPoint( path, nil, fw - rdRadius, fh );
	}
	
	if( _pointLocation >= 225 && _pointLocation <= 315 )
	{
		CGFloat ph = ( _pointAngle >= 0 && _pointAngle < 180 ) ? _pointSize.height : -_pointSize.height;		
		pointX = fw - ( ( ( _pointLocation - 225 ) / 90 ) * fw );
		
		CGPathAddArcToPoint( path, nil, fw - rdRadius, fh, floor( fw / 2 ), fh, rdRadius );

		CGPathAddLineToPoint( path, nil, pointX + floor( _pointSize.width / 2 ), fh );
		CGPathAddArcToPoint( path, nil, pointX + floor( _pointSize.width / 2 ), fh - ph, pointX - floor( _pointSize.width / 4 ), fh - ph, rdRadius );
		CGPathAddArcToPoint( path, nil, pointX - floor( _pointSize.width / 2 ), fh - ph, pointX - floor( _pointSize.width / 2 ), fh, rdRadius );
		CGPathAddLineToPoint( path, nil, pointX - floor( _pointSize.width / 2 ), fh );
		
		CGPathAddLineToPoint( path, nil, rdRadius, fh );
	}
	
	CGPathAddArcToPoint( path, nil, 0, fh, 0, fh - rdRadius, rdRadius );
}


- (void)addLeftEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
			  reset:(BOOL)reset
{
	CGFloat fh = size.height;
	
	if (reset)
	{
		CGPathMoveToPoint(path, nil, 0, fh-RD(_radius));
	}
	
	if (lightSource >= 0 && lightSource <= 90)
	{
		CGPathAddArcToPoint(path, nil, 0, 0, RD(_radius), 0, RD(_radius));
	}
	else
	{
		CGPathAddLineToPoint(path, nil, 0, RD(_radius));
	}
}


- (void)addToPath:(CGSize)size path:(CGMutablePathRef)path
{
	[self addTopEdge:size lightSource:0 toPath:path reset:YES];
	[self addRightEdge:size lightSource:0 toPath:path reset:NO];
	[self addBottomEdge:size lightSource:0 toPath:path reset:NO];
	[self addLeftEdge:size lightSource:0 toPath:path reset:NO];
}


- (void)drawPath:(CGMutablePathRef)path inRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
	CGContextAddPath(context, path);
	CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)addToPath:(CGRect)rect
{
	[self openPath:rect];
	
	CGMutablePathRef path = CGPathCreateMutable();
	rect = [self subtractPointFromRect:rect];
	[self addToPath:rect.size path:path];
	CGPathCloseSubpath(path);
	[self drawPath:path inRect:rect];
	CGPathRelease(path);
	
	[self closePath:rect];
}


- (void)addInverseToPath:(CGRect)rect
{
	[self openPath:rect];
	
	CGMutablePathRef path = CGPathCreateMutable();
	rect = [self subtractPointFromRect:rect];
	CGRect shadowRect = CGRectMake(-kInsetWidth, -kInsetWidth,
								   rect.size.width+kInsetWidth*2, rect.size.height+kInsetWidth*2);
	CGPathAddRect(path, nil, shadowRect);
	[self addToPath:rect.size path:path];
	CGPathCloseSubpath(path);
	[self drawPath:path inRect:rect];
	CGPathRelease(path);
	
	[self closePath:rect];
}


- (void)addTopEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource
{
	rect = [self subtractPointFromRect:rect];
	
	CGMutablePathRef path = CGPathCreateMutable();
	[self addTopEdge:rect.size lightSource:lightSource toPath:path reset:YES];
	[self drawPath:path inRect:rect];
	CGPathRelease(path);
}


- (void)addRightEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource
{
	rect = [self subtractPointFromRect:rect];
	
	CGMutablePathRef path = CGPathCreateMutable();
	[self addRightEdge:rect.size lightSource:lightSource toPath:path reset:YES];
	[self drawPath:path inRect:rect];
	CGPathRelease(path);
}


- (void)addBottomEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource
{
	rect = [self subtractPointFromRect:rect];
	
	CGMutablePathRef path = CGPathCreateMutable();
	[self addBottomEdge:rect.size lightSource:lightSource toPath:path reset:YES];
	[self drawPath:path inRect:rect];
	CGPathRelease(path);
}


- (void)addLeftEdgeToPath:(CGRect)rect lightSource:(NSInteger)lightSource
{
	rect = [self subtractPointFromRect:rect];
	
	CGMutablePathRef path = CGPathCreateMutable();
	[self addLeftEdge:rect.size lightSource:lightSource toPath:path reset:YES];
	[self drawPath:path inRect:rect];
	CGPathRelease(path);
}

@end
