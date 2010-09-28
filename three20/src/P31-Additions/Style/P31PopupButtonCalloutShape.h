//
//  P31PopupButtonCalloutShape.h
//  TTCatalog
//
//  Created by Mike DeSaro on 10/12/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import <Three20/Three20.h>


@interface P31PopupButtonCalloutShape : TTShape
{
	CGFloat _radius;
	CGFloat _pointLocation;
	CGFloat _pointAngle;
	CGSize _pointSize;
}
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat pointLocation;
@property (nonatomic) CGFloat pointAngle;
@property (nonatomic) CGSize pointSize;

+ (P31PopupButtonCalloutShape*)shapeWithRadius:(CGFloat)radius pointLocation:(CGFloat)pointLocation
									pointAngle:(CGFloat)pointAngle pointSize:(CGSize)pointSize;

@end
