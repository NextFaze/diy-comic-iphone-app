//
//  OverlayView.h
//  DIYComic
//
//  Created by Andreas Wulf on 21/07/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>

@protocol OverlayViewDelegate

/*!
 Called when the dismiss button was pressed
 */
- (void)overlayViewdismissPressed;

@end


/*!
 OverlayView is used to present instructions/information ontop of a current view
 */
@interface OverlayView : TTView {
	UIImageView *_instructionView; /**< Shows the content image */
	UIScrollView *_contentView; /**< If the content is too big, allows scrolling */
	TTButton *_dismissButton; /**< Dismisses the overlay view, via delegate */
	UIImage *_content; /**< Image content */
	
	id<OverlayViewDelegate> _delegate; /**< The delegate */
}

@property(nonatomic,retain) UIImage *content;
@property(nonatomic,assign) id<OverlayViewDelegate> delegate;

/*!
 Initialise with a specified content image
 @param image to display as content
 @result instance of the created object
 */
- (id)initWithContent:(UIImage*)image;

@end
