//
//  TTSpeechBubbleShape.m
//  DIYComic
//
//  Created by Andreas Wulf on 16/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TTSpeechBubbleShape.h"
#define RD(_RADIUS) (_RADIUS == TT_ROUNDED ? round(fh/2) : _RADIUS)

@implementation TTSpeechBubbleShape (DIYComic)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)subtractPointFromRect:(CGRect)rect {
	CGFloat x = 0;
	CGFloat y = 0;
	CGFloat w = rect.size.width;
	CGFloat h = rect.size.height;
	
	if ((_pointLocation >= 0 && _pointLocation < 45)
		|| (_pointLocation >= 315 && _pointLocation < 360)) {
		if ((_pointAngle >= 270 && _pointAngle < 360) || (_pointAngle >= 0 && _pointAngle < 90)) {
			x += _pointSize.height; //MODDED
			w -= _pointSize.height; //MODDED
		}
		
	} else if (_pointLocation >= 45 && _pointLocation < 135) {
		if (_pointAngle >= 0 && _pointAngle < 180) {
			y += _pointSize.height;
			h -= _pointSize.height;
		}
		
	} else if (_pointLocation >= 135 && _pointLocation < 225) {
		if (_pointAngle >= 90 && _pointAngle < 270) {
			w -= _pointSize.height; //MODDED
		}
		
	} else if (_pointLocation >= 225 && _pointLocation <= 315) {
		if (_pointAngle >= 180 && _pointAngle < 360) {
			h -= _pointSize.height;
		}
	}
	
	return CGRectMake(x, y, w, h);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRightEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
               reset:(BOOL)reset {
	CGFloat fw = size.width;
	CGFloat fh = size.height;
	CGFloat pointY = 0;
	
	if (reset) {
		CGPathMoveToPoint(path, nil, fw, RD(_radius));
	}
	
	// MODDED
	if (_pointLocation > 135 && _pointLocation < 225) {
		CGFloat ph;
		
		if (_pointAngle >= 90 && _pointAngle < 270) {
			ph = -_pointSize.height;
			
		} else {
			ph = _pointSize.height;
		}
		
		pointY = fh - (((_pointLocation-135)/90) * fh);
		CGPathAddLineToPoint(path, nil, fw, pointY-floor(_pointSize.width/2));
		CGPathAddLineToPoint(path, nil, fw-ph, pointY);
		CGPathAddLineToPoint(path, nil, fw, pointY+floor(_pointSize.width/2));
		//CGPathAddLineToPoint(path, nil, fw, RD(_radius));
	}
	//END MODDED
	
	CGPathAddArcToPoint(path, nil, fw, fh, fw-RD(_radius), fh, RD(_radius));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addLeftEdge:(CGSize)size lightSource:(NSInteger)lightSource toPath:(CGMutablePathRef)path
              reset:(BOOL)reset {
	// MODDED
	CGFloat fh = size.height;
	CGFloat pointY = 0;
	
	if (reset) {
		CGPathMoveToPoint(path, nil, 0, fh-RD(_radius));
	}
	
	
	
	if (_pointLocation >= 315 || _pointLocation <= 45) {
		CGFloat ph = _pointAngle >= 270 || _pointAngle < 90 ? _pointSize.height : -_pointSize.height;
		if (_pointLocation >= 315 ) {
			pointY = ((_pointLocation-315)/90) * fh;
		} else {
			pointY = ((_pointLocation+45)/90) * fh;
		}
		
		
		CGPathAddLineToPoint(path, nil, 0, pointY+floor(_pointSize.width/2));
		CGPathAddLineToPoint(path, nil, -ph, pointY);
		CGPathAddLineToPoint(path, nil, 0, pointY-floor(_pointSize.width/2));
	}
	
	if (lightSource >= 0 && lightSource <= 90) {
		CGPathAddArcToPoint(path, nil, 0, 0, RD(_radius), 0, RD(_radius));
		
	} else {
		CGPathAddLineToPoint(path, nil, 0, RD(_radius));
	}
	
	//END MODDED
}


@end
