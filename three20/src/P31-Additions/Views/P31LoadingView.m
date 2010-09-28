//
//  LoadingView.m
//  LoadingView


#import "P31LoadingView.h"
#import "TTURLCache.h"
#import <QuartzCore/QuartzCore.h>
#import "P31StyleSheet.h"


#define kActivityIndicatorTag 2
#define kLabelTag 1

// Image used for the hideWithDoneImage method
static UIImage *doneImage;

@implementation P31LoadingView

@synthesize backgroundWindow = _backgroundWindow;


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject

+ (void)initialize
{
	doneImage = [TTIMAGE( @"bundle://Prime31.bundle/images/check.png" ) retain];
}


+ (void)setDoneImage:(UIImage*)image
{
	[doneImage release];
	doneImage = [image retain];
}


+ (P31LoadingView*)loadingViewShowWithLoadingMessage
{
	return [P31LoadingView loadingViewShowWithMessage:@"Loading..."];
}


+ (P31LoadingView*)loadingViewShowWithMessage:(NSString*)message
{
	P31LoadingView *loadingView = [[[P31LoadingView alloc] initWithFrame:CGRectMake( 160 - 75, 240 - 75, 150, 115 ) message:message] autorelease];
	
	if( !loadingView )
		return nil;
	
	loadingView.opaque = NO;
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[loadingView.backgroundWindow addSubview:loadingView];
	
	[loadingView show];
	
	return loadingView;
}


- (id)init
{
	return [self initWithFrame:CGRectMake( 160 - 75, 240 - 75, 150, 115 ) message:@""];
}


- (id)initWithFrame:(CGRect)frame message:(NSString*)message
{
	if( self = [super initWithFrame:frame] )
	{
		// Setup our layer
		self.layer.backgroundColor = TTSTYLEVAR(loadingViewBackgroundColor).CGColor;
		self.layer.cornerRadius = 12.0;
		
		// Setup our label
		UILabel *_label = [[[UILabel alloc] initWithFrame:CGRectMake( 0, 12, 150.0, 40.0 )] autorelease];
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
		activityIndicatorRect.origin.y = _label.frame.origin.y + _label.frame.size.height;
		_activityView.frame = activityIndicatorRect;
		
		// Create our window
		_backgroundWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_backgroundWindow.windowLevel = 2;
		_backgroundWindow.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
		_backgroundWindow.alpha = 0.0;
	}
	return self;
}


- (void)dealloc
{
	[_backgroundWindow release];
	
	[super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if( [animationID isEqualToString:@"show"] )
	{
		// Show our label and activityView
		[self viewWithTag:kLabelTag].hidden = NO;
		[(UIActivityIndicatorView*)[self viewWithTag:kActivityIndicatorTag] startAnimating];		
	}
	else
	{
		[self removeFromSuperview];
		
		// restore main key window
		[[TTNavigator navigator].window makeKeyAndVisible];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"P31LoadingViewFinished" object:nil];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public

- (void)show
{
	// Grab the old frame so we can animate it in
	CGRect realFrame = self.frame;
	self.frame = CGRectMake( 160, 0, 0, 0 );
	
	// Make the window visible
	[self.backgroundWindow makeKeyAndVisible];
	
	// Animate in our loadingView and then display the label and activity indicator
	[UIView beginAnimations:@"show" context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	self.frame = realFrame;
	_backgroundWindow.alpha = 1.0;
	
	[UIView commitAnimations];
}


- (void)hide
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	self.frame = CGRectMake( 160, 0, 0, 0 );
	self.alpha = 0.0;
	_backgroundWindow.alpha = 0.0;
	
	[UIView commitAnimations];
}


- (void)hideAfterDelay:(NSTimeInterval)delay
{
	[self performSelector:@selector(hide) withObject:nil afterDelay:delay];
}


- (void)hideWithDoneImageAfterDelay:(NSTimeInterval)delay
{
	[self performSelector:@selector(hideWithDoneImage) withObject:nil afterDelay:delay];
}


- (void)hideWithDoneImage
{
	[self hideWithDoneImageAndMessage:@"Done"];
}


- (void)hideWithDoneImageAndMessage:(NSString*)message
{
	[self hideWithDoneImageAndMessage:message afterDelay:0.3];
}


- (void)hideWithDoneImageAndMessage:(NSString*)message afterDelay:(NSTimeInterval)delay
{
	// Grab the frame of the activityIndicator and shift it up a bit
	CGRect frame = [self viewWithTag:kActivityIndicatorTag].frame;
	frame.origin.y -= 5;
	
	// Remove it and the label
	[[self viewWithTag:kActivityIndicatorTag] removeFromSuperview];
	[self setMessage:message];
	
	// Create a UIImageView and add it
	UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
	iv.image = doneImage;
	iv.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	[self addSubview:iv];
	
	[self performSelector:@selector(hide) withObject:nil afterDelay:delay];
}


- (void)setMessage:(NSString*)message
{
	((UILabel*)[self viewWithTag:1]).text = message;
}



@end
