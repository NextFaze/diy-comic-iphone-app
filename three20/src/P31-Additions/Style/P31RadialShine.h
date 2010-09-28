//
//  P31RadialShine.h
//  TTCatalog
//
//  Created by Mike DeSaro on 10/19/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import <Three20/TTStyle.h>


@interface P31RadialShine : TTStyle
{
	UIColor *_color;
	CGFloat _ovalScaleX;
	CGFloat _ovalScaleY;
}
@property (nonatomic,retain) UIColor *color;
@property (nonatomic, readwrite) CGFloat ovalScaleX;
@property (nonatomic, readwrite) CGFloat ovalScaleY;


+ (P31RadialShine*)radialShineWithNext:(TTStyle*)next;
+ (P31RadialShine*)radialShineWithColor:(UIColor*)color next:(TTStyle*)next;
+ (P31RadialShine*)radialShineWithColor:(UIColor*)color ovalScaleX:(CGFloat)ovalScaleX ovalScaleY:(CGFloat)ovalScaleY next:(TTStyle*)next;

@end
