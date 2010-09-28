//
//  P31StyleSheet.m
//  TTCatalog
//
//  Created by Mike DeSaro on 10/12/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import "P31StyleSheet.h"
#import "P31PopupButtonCalloutShape.h"
#import "P31RadialShine.h"


@implementation P31StyleSheet

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark P31AlertView

- (TTStyle*)alertBackground
{
	return [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
			[TTShadowStyle styleWithColor:RGBACOLOR(0, 0, 0, 0.6) blur:4 offset:CGSizeMake( 0, 0 ) next:
			 [TTLinearGradientFillStyle styleWithColor1:RGBACOLOR( 11, 28, 67, 0.7 ) color2:RGBACOLOR( 39, 54, 94, 0.7 ) next:
			  [P31RadialShine radialShineWithNext:
			   [TTSolidBorderStyle styleWithColor:RGBCOLOR( 219, 221, 228 ) width:2 next:nil]]]]];
}


- (TTStyle*)alertOtherButton:(UIControlState)state
{
	if( state == UIControlStateNormal )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTReflectiveFillStyle styleWithColor:RGBACOLOR(150, 157, 176, 0.5) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(255,255,255)
							 shadowColor:RGBACOLOR(0, 0, 0, 0.5)
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else if( state == UIControlStateHighlighted )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTReflectiveFillStyle styleWithColor:RGBACOLOR(35,35,35,0.5) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(255,255,255)
							 shadowColor:RGBACOLOR(0, 0, 0, 0.5)
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else
	{
		return nil;
	}
}


- (TTStyle*)alertDefaultButton:(UIControlState)state
{
	if( state == UIControlStateNormal )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTReflectiveFillStyle styleWithColor:RGBACOLOR(36, 51, 90, 0.5) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(255,255,255)
							 shadowColor:RGBACOLOR(0, 0, 0, 1.0)
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else if( state == UIControlStateHighlighted )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTReflectiveFillStyle styleWithColor:RGBACOLOR(35,35,35,0.5) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(255,255,255)
							 shadowColor:RGBACOLOR(0, 0, 0, 1.0)
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else
	{
		return nil;
	}
}


- (TTStyle*)alertDefaultButtonOld:(UIControlState)state
{
	if( state == UIControlStateNormal )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
											   color2:RGBCOLOR(216, 221, 231) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:16] color:RGBCOLOR(40,40,40)
							 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else if( state == UIControlStateHighlighted )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.9) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(225, 225, 225)
											   color2:RGBCOLOR(196, 201, 221) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:nil color:RGBCOLOR(255,255,255)
							 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else
	{
		return nil;
	}
}


- (TTStyle*)alertOtherButtonOLD:(UIControlState)state
{
	if( state == UIControlStateNormal )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(205,205,205,0) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(205, 205, 205)
											   color2:RGBCOLOR(116, 121, 131) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:nil color:RGBCOLOR(255,255,255)
							 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else if( state == UIControlStateHighlighted )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.9) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(225, 225, 225)
											   color2:RGBCOLOR(196, 201, 221) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else
	{
		return nil;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark P31PopupButton

- (TTStyle*)popupButtonBackground
{
	return [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR( 255, 255, 255 ) color2:RGBCOLOR( 216, 221, 231 ) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR( 130, 130, 130 ) width:1 next:nil]];
}


- (TTStyle*)popupButton:(UIControlState)state
{
	if( state == UIControlStateNormal )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
											   color2:RGBCOLOR(216, 221, 231) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:nil color:TTSTYLEVAR(linkTextColor)
							 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else if( state == UIControlStateHighlighted )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.9) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(225, 225, 225)
											   color2:RGBCOLOR(196, 201, 221) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else
	{
		return nil;
	}
}


- (TTStyle*)popupCloseButton:(UIControlState)state
{
	if( state == UIControlStateNormal )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
											   color2:RGBCOLOR(216, 221, 231) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:nil color:TTSTYLEVAR(linkTextColor)
							 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else if( state == UIControlStateHighlighted )
	{
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.9) blur:1 offset:CGSizeMake(0, 1) next:
		   [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(225, 225, 225)
											   color2:RGBCOLOR(196, 201, 221) next:
			[TTSolidBorderStyle styleWithColor:RGBCOLOR(161, 167, 178) width:1 next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			  [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							 shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
							shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
	}
	else
	{
		return nil;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark P31LauncherViewController

- (UIColor*)launcherBackgroundColor
{
	return [UIColor blackColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark P31LoadingView

- (UIColor*)loadingViewBackgroundColor
{
	return RGBACOLOR( 0, 0, 0, 0.75 );
}


- (UIColor*)loadingViewTextColor
{
	return [UIColor whiteColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIFonts

- (UIFont*)alertTitleFont
{
	return [UIFont boldSystemFontOfSize:18];
}


- (UIFont*)alertBodyFont
{
	return [UIFont systemFontOfSize:14];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIColors

- (UIColor*)alertTextColor
{
	return RGBCOLOR( 255, 255, 255 );
}


- (UIColor*)alertTextTintColor
{
	return RGBCOLOR(119, 140, 168);
}


@end
