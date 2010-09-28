//
//  ComicAssemblerViewController.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
#import "Connector.h"
#import "OverlayView.h"
@class DisabledView;
@class ActivityView;

/*!
 ComicAssemblerViewController view that allows a user to:
 Enter a Title and Description of their comic
 Add, remove and re-arrange comics
 Submit their comic
 */
@interface ComicAssemblerViewController : TTModelViewController <UIAlertViewDelegate, ConnectorDelegate, UIAlertViewDelegate, OverlayViewDelegate> {
	NSString* _challenge; /**< Challenge ID of the challenge viewed */
	
	Connector *connector; /**< Connector to grab the data */
	
	TTView *toolBar; /**< The tool bar */
	TTButton *titleButton; /**< Title button on the tool bar (hide/show details view) */
	TTButton *previewButton; /**< The preview button on the tool bar */
	UIButton *infoButton; /**< Button that presents the overlay view */
	
	UIScrollView *gridView; /**< The grid view/layout showing the slides/frames */
	TTButton *addButton; /**< Add new slide/frame button */
	
	TTView *detailView; /**< Details view */
	UITextField *titleField; /**< Name of the comic */
	TTTextEditor *detailField; /**< Description of the comic */
	
	ActivityView *loading; /**< Loading screen shown while submitting */
	
	DisabledView *disabledView; /**< View shown ontop to prevent editing, when disabled */
	
	TTActivityLabel *loadingView; /**< View shown while data loads */
	TTErrorView *errorView; /**< View shown if there was an error loading data */
	
	TTButton *comicButtonFocused; /**< Currently focused/selected comic slide/frame */
	
	NSMutableDictionary *_data; /**< Data to be shown */

	UITouchPhase lastPhase; /**< Records what the last touch phase was */
	
	OverlayView *overlayView; /**< Help Screen */
}

/*!
 Initialise the challenge view
 @param challenge ID for the view
 */
- (id)initWithChallenge:(NSString*)challenge;

/*!
 Adds a new comic slide/frame (button)
 @param position to be inserted at
 @param imageURL of the picture to be shown
 @param slideID of the added slide
 */
- (void)addCommicButton:(NSInteger)position image:(NSString*)imageURL slideID:(NSInteger)slideID;

/*!
 Find the location (co-ordinates) for a slide/frame (button) for the given position
 @param position of the button
 @result CGPoint (top,left) of the grid position
 */
- (CGPoint)locationForGridButtonInPosition:(NSInteger)position;

/*!
 Find the closest valid position in the grid for the given location
 @param location , co-rdinate (top,left)
 @result The valid position
 */
- (NSInteger)positionInGridForLocation:(CGPoint)location;

/*! 
 Shuffle the the grid in order (around the selected grid button
 @param gridButton to shuffle the other grid items around (can be null for no exclusions)
 */
- (void)shuffleGridAround:(TTButton*)gridButton;

/*! 
 Shuffle the the grid in order (around the selected grid button
 @param gridButton to shuffle the other grid items around (can be null for no exclusions)
 @param is the shuffle should be animated
 */
- (void)shuffleGridAround:(TTButton*)gridButton animated:(BOOL)animated; 

/*!
 Disable the view for editing/submitting
 @param disable YES for Disable , NO to enable
 */
- (void)disableEditing:(BOOL)disable;

/*!
 Presents the overlay view
 @param show or not
 */
- (void)showOverlay:(BOOL)show;

@end


#pragma mark -
/*!
 ComicFrameButton used in ComicAssemblerViewController to represent comic slides/frames
 */
@interface ComicFrameButton : TTButton {
	NSUInteger slideID; /**< Server side slide ID */
}
@property(nonatomic,assign) NSUInteger slideID;
@end


#pragma mark -
/*!
 DisabledView shown when the view is disabled
 */
@interface DisabledView : TTErrorView {
}
@end




