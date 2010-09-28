//
//  ActivityView.h
//  DIYComic
//
//  Created by Andreas Wulf on 18/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Three20/Three20.h>


@interface ActivityView : P31LoadingView {
	UIProgressView *_progressView;
	UILabel *_label;
}

@property(retain,nonatomic) UIProgressView *progressView;
@property(retain,nonatomic) UILabel *label;

+ (ActivityView*)loadingViewShowWithMessage:(NSString*)message percentage:(CGFloat)percentage;
- (void)updateText:(NSString*)text percentage:(CGFloat)percentage;

@end
