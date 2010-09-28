//
//  LoadingView.h
//  LoadingView

#import "TTGlobalUI.h"


@interface P31LoadingView : UIView
{
	UIWindow *_backgroundWindow;
}
@property (nonatomic, retain) UIWindow *backgroundWindow;

+ (P31LoadingView*)loadingViewShowWithLoadingMessage;
+ (P31LoadingView*)loadingViewShowWithMessage:(NSString*)message;

- (id)initWithFrame:(CGRect)frame message:(NSString*)message;

- (void)show;
- (void)hide;
- (void)hideAfterDelay:(NSTimeInterval)delay;
- (void)hideWithDoneImageAfterDelay:(NSTimeInterval)delay;
- (void)hideWithDoneImage;
- (void)hideWithDoneImageAndMessage:(NSString*)message;
- (void)hideWithDoneImageAndMessage:(NSString*)message afterDelay:(NSTimeInterval)delay;

- (void)setMessage:(NSString*)message;

@end
