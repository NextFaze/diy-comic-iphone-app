//
//  TWPopupButtonView.h
//  TestPopUp
//
//  Created by Mike DeSaro on 10/12/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import <Three20/Three20.h>
#import "P31Window.h"


@protocol P31PopupButtonViewDelegate;

@interface P31PopupButtonView : TTView <P31WindowDelegate>
{
	id<P31PopupButtonViewDelegate> _delegate;
	CGSize _pointSize;
	BOOL _shouldAutoHide;
@private
	NSMutableArray *_buttonTitles;
	BOOL _displayingBelowOrigin;
	P31Window *_buttonWindow;
}
@property (nonatomic, assign) id<P31PopupButtonViewDelegate> delegate;
@property (nonatomic, assign) BOOL shouldAutoHide;
@property (nonatomic, retain) NSMutableArray *buttonTitles;
@property (nonatomic, retain) UIWindow *buttonWindow;


- (id)initWithDelegate:(id<P31PopupButtonViewDelegate>)delegate originPoint:(CGPoint)originPoint yOffset:(CGFloat)yOffset buttonTitles:(NSString*)title, ...;
- (void)show;
- (void)hide;


@end



@protocol P31PopupButtonViewDelegate
- (void)popupView:(P31PopupButtonView*)popupView didTouchObjectAtIndex:(int)index withTitle:(NSString*)title;
@end
