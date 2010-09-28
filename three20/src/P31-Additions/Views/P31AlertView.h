//
//  P31AlertView.h
//  AlertView
//
//  Created by Mike DeSaro on 10/19/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import <Three20/TTGlobalCore.h>
#import <Three20/TTView.h>


@protocol P31AlertViewDelegate;

@interface P31AlertView : TTView <UITextFieldDelegate>
{
@private
	id<P31AlertViewDelegate> _delegate;
	NSString *_cancelButtonTitle;
	NSMutableArray *_buttonTitles;
	NSMutableArray *_textFields;
	
	UIWindow *_dimWindow;
	NSString *_title;
	NSString *_body;
	BOOL _keyboardIsShowing;
	
	CGSize _titleSize;
	CGSize _bodySize;
}
@property (nonatomic, assign) id<P31AlertViewDelegate> delegate;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, retain) NSMutableArray *buttonTitles;
@property (nonatomic, retain) NSMutableArray *textFields;

@property (nonatomic, retain) UIWindow *dimWindow;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;


- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<P31AlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
- (void)addTextFieldWithValue:(NSString*)value placeHolder:(NSString*)placeHolder;
- (void)show;

- (UITextField*)textFieldAtIndex:(int)index;
- (NSString*)textForTextFieldAtIndex:(int)index;

@end




@protocol P31AlertViewDelegate <NSObject>
@optional
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(P31AlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex withTitle:(NSString*)title;
// before animation and showing view
- (void)willPresentAlertView:(P31AlertView*)alertView;

//- (void)alertView:(P31AlertView*)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
//- (void)alertView:(P31AlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
@end
