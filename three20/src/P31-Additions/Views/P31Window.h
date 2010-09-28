//
//  P31Window.h
//  TTCatalog
//
//  Created by Mike DeSaro on 10/14/09.
//  Copyright 2009 FreedomVOICE. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol P31WindowDelegate
- (void)windowWasTouched:(UIWindow*)window;
@end


@interface P31Window : UIWindow
{
	id<P31WindowDelegate> _touchDelegate;
}
@property (nonatomic, assign) id<P31WindowDelegate> touchDelegate;


- (id)initWithFrame:(CGRect)frame andTouchDelegate:(id<P31WindowDelegate>)touchDelegate;

@end