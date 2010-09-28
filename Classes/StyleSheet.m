//
//  StyleSheet.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "StyleSheet.h"

#import "DIYComicAppDelegate.h"


@implementation StyleSheet

//////////////////////////
// Global Styles

- (UIColor*)navigationBarTintColor {
	return RGBCOLOR(197,44,45);
}

- (UIColor*)toolbarTintColor {
	return RGBCOLOR(0,0,0);
}


//////////////////////////
// Text Styles

- (UIFont*)tableSubTextFont {
	return [UIFont systemFontOfSize:13];
}

- (UIColor*)timestampTextColor {
	return RGBCOLOR(69,80,106);
}

- (UIFont*)tableTimestampFont {
	return [UIFont systemFontOfSize:13];
}

- (UIColor*)tableSubTextColor {
	return RGBCOLOR(106,94,100);
}

- (UIFont*)titleFont {
	return [UIFont boldSystemFontOfSize:18];
}

- (UIColor*)titleColor {
	return RGBCOLOR(0,0,0);
}

- (UIFont*)detailFont {
	return [UIFont systemFontOfSize:16];
}

- (UIColor*)detailColor {
	return RGBCOLOR(30,30,30);
}

- (UIColor*)backgroundColor {
	return RGBCOLOR(200,200,200);
}


//////////////////////////
// View Styles
- (TTStyle*)selectedItemBackgroundStyle {
	return
	[TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(120,120,120) color2:RGBCOLOR(74,74,74) next:
	 [TTInnerShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:2 offset:CGSizeMake(1, -1) next:nil]];
}


- (TTStyle*)toolbarStyle {
	return
	[TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(54,54,54) color2:RGBCOLOR(20,20,20) next:nil];
}

- (TTStyle*)colourToolbarStyle {
	return
	[TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(100,100,100) color2:RGBCOLOR(40,40,40) next:nil];
}

- (TTStyle*)textFieldStyle {
	return
	[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:7] next:
	 [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
	 
	  [TTInnerShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:4 offset:CGSizeMake(0,1) next:
	    [TTSolidBorderStyle styleWithColor:RGBCOLOR(50,50,50) width:1 next:
	   nil]]]];	
}


- (TTStyle*)whiteBoxStyle {
	return 
	[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
	 [TTSolidFillStyle styleWithColor:RGBACOLOR(255,255,255,0.9) next:
	  nil]];
}

- (TTStyle*)statusBoxStyle {
	return 
	[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
	 [TTSolidFillStyle styleWithColor:RGBCOLOR(50,50,50) next:
	  nil]];
}

- (TTStyle*)overlayBoxStyle {
	return 
	[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
	 [TTSolidFillStyle styleWithColor:RGBACOLOR(50,50,50,0.9) next:
	  nil]];
}


- (TTStyle*)sheetStyle {
	return 
	[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:12 topRight:12 bottomRight:0 bottomLeft:0] next:
	 [TTSolidFillStyle styleWithColor:RGBACOLOR(50,50,50,0.9) next:
	  nil]];
}

- (TTStyle*)tableImageStyle {
	return [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(10, 10, 10, 10) next:
			[TTSolidFillStyle styleWithColor:RGBCOLOR(34,23,43) next:
			[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
			
			[TTImageStyle styleWithImage:nil next:
			 nil]]]];
}

- (TTStyle*)comicFrame {
	return
	[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:0] next:
	 [TTSolidFillStyle styleWithColor:TTSTYLEVAR(backgroundColor) next:
	  [TTSolidBorderStyle styleWithColor:RGBCOLOR(255,255,255) width:4 next:
		[TTSolidBorderStyle styleWithColor:RGBCOLOR(0,0,0) width:1 next:
		 nil]]]];	
}



//////////////////////////
// Buttons

- (TTStyle*)pinkButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(255,105,180) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)purpleButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(128,0,128) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)orangeButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(255,165,0) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)whiteButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(255,255,255) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)blackButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}


- (TTStyle*)blueButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(41,61,182) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)yellowButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(255,255,0) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)greenButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(41,182,61) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}


- (TTStyle*)redButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(197,44,45) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}


- (TTStyle*)greyButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(100,100,100) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(10, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)toolBarButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(120,120,120) color2:RGBCOLOR(50,50,50) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 12, 7, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 12, 7, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 12, 7, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)toolBarRedButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(232,81,83) color2:RGBCOLOR(202,0,2) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 12, 7, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 12, 7, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 12, 7, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}
- (TTStyle*)toolBarBlueButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(100,127,187) color2:RGBCOLOR(79,95,180) next:
		   [TTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,1) blur:1.0 offset:CGSizeMake(0, 0) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 12, 7, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 12, 7, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 12, 7, 12) next:
			 [TTTextStyle styleWithFont:nil color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}


- (TTStyle*)comicButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:0] next:
		 [TTSolidFillStyle styleWithColor:TTSTYLEVAR(backgroundColor) next:
		 [TTImageStyle styleWithImage:nil next:
		 [TTSolidBorderStyle styleWithColor:RGBCOLOR(255,255,255) width:5 next:
		  [TTSolidBorderStyle styleWithColor:RGBCOLOR(0,0,0) width:1 next:
		  
		   [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:50] 
								color:RGBCOLOR(130,130,130)
						  shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
			 
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:0] next:
		 [TTImageStyle styleWithImage:nil next:
		 [TTSolidBorderStyle styleWithColor:RGBACOLOR(120,120,120,0.8) width:5 next:
		  [TTSolidFillStyle styleWithColor:RGBACOLOR(160,160,160,0.5) next:
		   [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:50] 
								color:RGBCOLOR(120,120,120)
						  shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						 shadowOffset:CGSizeMake(0, -1) next:nil]]]]];

	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:0] next:
		 [TTImageStyle styleWithImage:nil next:
		 [TTSolidBorderStyle styleWithColor:RGBACOLOR(130,130,130,0.8) width:5 next:
		  [TTSolidFillStyle styleWithColor:RGBACOLOR(160,160,160,0.5) next:
		   [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:50] 
								color:RGBCOLOR(130,130,130)
						  shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						 shadowOffset:CGSizeMake(0, -1) next:nil]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)crossButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTSolidBorderStyle styleWithColor:RGBCOLOR(255,255,255) width:1.5 next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(219,42,44) next:
			[TTImageStyle styleWithImage:TTIMAGE(@"bundle://CloseCross.png") defaultImage:nil contentMode:UIViewContentModeCenter size:CGSizeZero next:nil]]]];
		
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTSolidBorderStyle styleWithColor:RGBCOLOR(255,255,255) width:1.5 next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTImageStyle styleWithImage:TTIMAGE(@"bundle://CloseCross.png") defaultImage:nil contentMode:UIViewContentModeCenter size:CGSizeZero next:nil]]]];
		
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:5] next:
		 [TTSolidBorderStyle styleWithColor:RGBCOLOR(255,255,255) width:1.5 next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTImageStyle styleWithImage:TTIMAGE(@"bundle://CloseCross.png") defaultImage:nil contentMode:UIViewContentModeCenter size:CGSizeZero next:nil]]]];
		
	} else {
		return nil;
	}
}

- (TTStyle*)speechBubble:(UIControlState)state {
	if(state == UIControlStateNormal) {
		return
		[TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:10 pointLocation:290 pointAngle:270 pointSize:CGSizeMake(20,10)] next:
		 [TTSolidFillStyle styleWithColor:RGBCOLOR(255,255,255) next:
		  [TTSolidBorderStyle styleWithColor:RGBCOLOR(0,0,0) width:1 next:nil]]];
		
	}
	else return nil;
}

- (TTStyle*)thoughtBubble:(UIControlState)state {
	if(state == UIControlStateNormal) {
		return
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:30] next:
		 [TTSolidFillStyle styleWithColor:RGBCOLOR(255,255,255) next:
		  [TTSolidBorderStyle styleWithColor:RGBCOLOR(0,0,0) width:1 next:nil]]];
	}
	else return nil;
}

- (TTStyle*)narrativeBubble:(UIControlState)state {
	if(state == UIControlStateNormal) {
		return
		[TTSolidFillStyle styleWithColor:RGBCOLOR(255,255,255) next:
		 [TTSolidBorderStyle styleWithColor:RGBCOLOR(0,0,0) width:1 next:nil]];
	}
	else return nil;
}

- (TTStyle*)stretchSpeechBubble:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 7, 7, 2) next:
		 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		 [TTShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:2.5 offset:CGSizeMake(2, -2) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(99,150,255) next:
		   [TTInsetStyle styleWithInset:UIEdgeInsetsMake(10, 0, 0, 0) next:
			nil]]]]];
		
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 7, 7, 2) next:
		 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		  [TTShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:2.5 offset:CGSizeMake(2, -2) next:
		   [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
			[TTInsetStyle styleWithInset:UIEdgeInsetsMake(10, 0, 0, 0) next:
			 nil]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 7, 7, 2) next:
		 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		  [TTShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:2.5 offset:CGSizeMake(2, -2) next:
		   [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
			[TTInsetStyle styleWithInset:UIEdgeInsetsMake(10, 0, 0, 0) next:
			 nil]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)speechBubbleTailAdjust:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 7, 7, 2) next:
		 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		  [TTShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:2.5 offset:CGSizeMake(2, -2) next:
		   [TTReflectiveFillStyle styleWithColor:RGBCOLOR(255,224,38) next:
			[TTInsetStyle styleWithInset:UIEdgeInsetsMake(10, 0, 0, 0) next:
			 nil]]]]];
		
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 7, 7, 2) next:
		 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		  [TTShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:2.5 offset:CGSizeMake(2, -2) next:
		   [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
			[TTInsetStyle styleWithInset:UIEdgeInsetsMake(10, 0, 0, 0) next:
			 nil]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 7, 7, 2) next:
		 [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:8] next:
		  [TTShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:2.5 offset:CGSizeMake(2, -2) next:
		   [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
			[TTInsetStyle styleWithInset:UIEdgeInsetsMake(10, 0, 0, 0) next:
			 nil]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)speechBubbleCrossButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:2] next:
		 [TTShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:2.0 offset:CGSizeMake(1, 1) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(219,42,44) next:
		   [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 0, 0, 2) next:
		   [TTImageStyle styleWithImage:TTIMAGE(@"bundle://CloseCross.png") defaultImage:nil contentMode:UIViewContentModeCenter size:CGSizeZero next:nil]]]]];
		
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:2] next:
		 [TTShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:2.0 offset:CGSizeMake(1, 1) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 0, 0, 2) next:
			[TTImageStyle styleWithImage:TTIMAGE(@"bundle://CloseCross.png") defaultImage:nil contentMode:UIViewContentModeCenter size:CGSizeZero next:nil]]]]];
		
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:2] next:
		 [TTShadowStyle styleWithColor:RGBCOLOR(0,0,0) blur:2.0 offset:CGSizeMake(1, 1) next:
		  [TTReflectiveFillStyle styleWithColor:RGBCOLOR(0,0,0) next:
		   [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 0, 0, 2) next:
			[TTImageStyle styleWithImage:TTIMAGE(@"bundle://CloseCross.png") defaultImage:nil contentMode:UIViewContentModeCenter size:CGSizeZero next:nil]]]]];
		
	} else {
		return nil;
	}
}


- (TTStyle*)speechToolBarButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:5 pointLocation:290 pointAngle:270 pointSize:CGSizeMake(15,10)] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(232,81,83) color2:RGBCOLOR(202,0,2) next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:[UIFont fontWithName:@"Marker Felt" size:14.0] color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:5 pointLocation:290 pointAngle:270 pointSize:CGSizeMake(15,10)] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:[UIFont fontWithName:@"Marker Felt" size:14.0] color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:5 pointLocation:290 pointAngle:270 pointSize:CGSizeMake(15,10)] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			[TTBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 12, 9, 12) next:
			 [TTTextStyle styleWithFont:[UIFont fontWithName:@"Marker Felt" size:14.0] color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)thoughtToolBarButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:20] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(232,81,83) color2:RGBCOLOR(202,0,2) next:
		   [TTTextStyle styleWithFont:[UIFont fontWithName:@"Marker Felt" size:14.0] color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:20] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			 [TTTextStyle styleWithFont:[UIFont fontWithName:@"Marker Felt" size:14.0] color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:20] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			 [TTTextStyle styleWithFont:[UIFont fontWithName:@"Marker Felt" size:14.0] color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]];
	} else {
		return nil;
	}
}

- (TTStyle*)narrativeToolBarButton:(UIControlState)state {
	if (state == UIControlStateNormal) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:0] next:
		 [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.2) shadow:RGBACOLOR(255,255,255,0.2) width:1.0 lightSource:90 next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(232,81,83) color2:RGBCOLOR(202,0,2) next:
			 [TTTextStyle styleWithFont:[UIFont fontWithName:@"Marker Felt" size:14.0] color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]];
	} else if (state == UIControlStateHighlighted) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:0] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			 [TTTextStyle styleWithFont:[UIFont fontWithName:@"Marker Felt" size:14.0] color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]];
	} else if (state == UIControlStateSelected) {
		return 
		[TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:0] next:
		 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 1, 0) next:
		  [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(50,50,50) color2:RGBCOLOR(0,0,0) next:
		   [TTSolidBorderStyle styleWithColor:RGBCOLOR(0, 0, 0) width:1 next:
			 [TTTextStyle styleWithFont:[UIFont fontWithName:@"Marker Felt" size:14.0] color:[UIColor whiteColor]
							shadowColor:[UIColor colorWithWhite:255 alpha:0.4]
						   shadowOffset:CGSizeMake(0, -1) next:nil]]]]];
	} else {
		return nil;
	}
}

@end
