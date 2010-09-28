//
//  ActivityView.m
//  DIYComic
//
//  Created by Andreas Wulf on 18/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ActivityView.h"
#import "StyleSheet.h"
#import <QuartzCore/QuartzCore.h>

#define kActivityIndicatorTag 2
#define kLabelTag 1

@implementation ActivityView
@synthesize progressView=_progressView, label=_label;


+ (ActivityView*)loadingViewShowWithMessage:(NSString*)message percentage:(CGFloat)percentage {
	ActivityView *loadingView = [[[ActivityView alloc] initWithFrame:CGRectMake(160 - 110, 240 - 75, 220, 140) message:message] autorelease];
	
	if( !loadingView )
		return nil;
	
	loadingView.opaque = NO;
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[loadingView.backgroundWindow addSubview:loadingView];
	
	[loadingView show];
	
	return loadingView;
}


- (id)initWithFrame:(CGRect)frame message:(NSString*)message {
	if (self = [super initWithFrame:frame]) {
		// Setup our layer
		self.layer.backgroundColor = TTSTYLEVAR(loadingViewBackgroundColor).CGColor;
		self.layer.cornerRadius = 12.0;
		
		// Setup our label
		self.label = [[[UILabel alloc] initWithFrame:CGRectMake( 15, 12, 200.0-10, 40.0 )] autorelease];
		_label.tag = kLabelTag;
		_label.hidden = YES;
		_label.text = message;
		_label.textColor = TTSTYLEVAR(loadingViewTextColor);
		_label.backgroundColor = [UIColor clearColor];
		_label.textAlignment = UITextAlignmentCenter;
		_label.lineBreakMode = UILineBreakModeWordWrap;
		_label.numberOfLines = 2;
		_label.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
		_label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:_label];
		
		// Setup the activityView
		UIActivityIndicatorView *_activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		_activityView.tag = kActivityIndicatorTag;
		_activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |	UIViewAutoresizingFlexibleRightMargin |	UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:_activityView];
		
		
		CGRect activityIndicatorRect = _activityView.frame;
		activityIndicatorRect.origin.x = 0.5 * ( self.frame.size.width - activityIndicatorRect.size.width );
		activityIndicatorRect.origin.y = _label.frame.origin.y + _label.frame.size.height+13;
		_activityView.frame = activityIndicatorRect;
		
		self.progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(10, _activityView.bottom+15, self.width-20, 20)] autorelease];
		_progressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:_progressView];
		
		// Create our window
		_backgroundWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_backgroundWindow.windowLevel = 2;
		_backgroundWindow.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
		_backgroundWindow.alpha = 0.0;
	}
	return self;
}

- (void)updateText:(NSString*)text percentage:(CGFloat)percentage {
	_label.text = text;
	_progressView.progress = percentage;
}

- (void)dealloc {
	[_progressView release];
	[_label release];
	[super dealloc];
}

@end
