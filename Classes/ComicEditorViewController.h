//
//  ComicEditorViewController.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
#import "Connector.h"
#import "OverlayView.h"

/* Speech bubble type */
typedef enum {
	SpeechBubbleTypeSpeech,
	SpeechBubbleTypeThought,
	SpeechBubbleTypeNarrative
} SpeechBubbleType;

@class SpeechBubble;

/*!
 ComicEditorViewController comic slide editor
 */
@interface ComicEditorViewController : TTModelViewController 
<ConnectorDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, OverlayViewDelegate> {
	NSString* _challenge; /**< Challenge ID of the challenge viewed */
	NSUInteger _slideID; /**< Current Slide ID for the Challenge ID */
	
	TTActivityLabel *loadingView; /**< View shown while data loads */
	TTErrorView *errorView; /**< View shown if there was an error loading data */
	
	Connector *connector; /**< Connector to grab the data */
	
	UIScrollView *_contentView; /**< Contains all the editable data, which can then be moved around if a keyboar appears */
	UIButton *_backgroundButton; /**< Button used to add boubles and deselect */
	UIImageView *imageView; /**< View that has the background photo and contains all the bubbles */
	UIImage *imageShown; /**< The image that is slected/shown */
	UIButton *imageButton; /**< Used to bring up the image picker */
	UIImagePickerController *imagePicker; /**< Used to pick images */

	TTView *toolBar; /**< The tool bar */
	TTView *highlightedToolBarItem; /**< Highlights which toolbar item is selected */
	TTView *bottomToolBar;	/**< The tool bar at the bottom */

	TTButton *_typeButtonSpeech; /**< Though Select button */
	TTButton *_typeButtonThought; /**< Thought type select button */
	TTButton *_typeButtonNarrative; /**< Narrative type select button */
	
	SpeechBubbleType modeSelection; /**< Current speech bubble mode */
	
	OverlayView *overlayView; /**< Help Screen */	
	
	BOOL savePhotoToLibrary; /**< If the photo grabbed should be saved to the photo libary */
}

@property(nonatomic,retain) UIScrollView *contentView;
@property(nonatomic,retain) UIButton *backgroundButton;
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) UIImage *imageShown;
@property(nonatomic,retain) TTButton *typeButtonSpeech;
@property(nonatomic,retain) TTButton *typeButtonThought;
@property(nonatomic,retain) TTButton *typeButtonNarrative;


/*! Initialise the slide editor view
 @param challenge ID for the view
 @param slideID for the view
 */
- (id)initWithChallenge:(NSString*)challenge slideID:(NSUInteger)slideID;

/*!
 Add a speech bubble for a given touch event
 @param sender of the event
 @param event that contains a touch
 @result speech bubble object that was added
 */
- (SpeechBubble*)addSpeechBubble:(id)sender event:(id)event;

/*!
 Ass a speech bubble wih specified paramaters
 @param rect being the size and location
 @param type being speech bubble type
 @param angle of the tail
 @param text to be displayed
 @result speech bubble object that was added
 */
- (SpeechBubble*)addSpeechBoubleWithFrame:(CGRect)rect type:(SpeechBubbleType)type angle:(NSInteger)angle text:(NSString*)text;

/*!
 Set the speech bubble mode, future newly created bubbles will be set to this
 Will also set selected bubbles as the specified mode
 @param bubbleMode 
 */
- (void)setBubbleMode:(SpeechBubbleType)bubbleMode;

/*!
 Brings up the photo selector
 @param sender
 */
- (void)imageButtonPressed:(id)sender;
/*!
 Activates the speech mode
 @param sender
 */
- (void)speechPressed:(id)sender event:(id)event;
/*!
 Activates the thought mode
 @param sender
 */
- (void)thoughtPressed:(id)sender event:(id)event;
/*!
 Activates the nartive mode
 @param sender
 */
- (void)narrativePressed:(id)sender event:(id)event;

/*!
 Grabs a screen shot of the specified view
 @param view to be captured
 @result the image of the captured view
 */
+ (UIImage *)captureView:(UIView *)view;

/*!
 Renderes the slide to an image file on the disk
 */
- (void)saveImage;

/*!
 Saves all the properties of the slide to the disk
 */
- (void)saveComicState;

/*!
 For positioning the sender's position (speech bubble) to the location of the touch event
 @param sender speech bubble
 @param event with touches
 */
- (void)dragBox:(id)sender event:(id)event;

/*!
 Deselects all speech bubbles
 */
- (void)deselectAll;

/*!
 Gets the first selected speech bubble
 @result speech bubble thats selected
- (SpeechBubble*)selectedBubble;

/*!
 Presents the overlay view
 @param show or not
 */
- (void)showOverlay:(BOOL)show;

@end


#pragma mark -
/* Speech bubble selection states */
typedef enum {
	SpeechBubbleSelectionStateSelected,
	SpeechBubbleSelectionStateInput,
	SpeechBubbleSelectionStateDeselected
} SpeechBubbleSelectionState;


/*!
 SpeechBubble used to represent speech bubbles
 */
@interface SpeechBubble : TTButton <UITextViewDelegate> {	

	TTButton *_cross; /**< Close cross */
	TTButton *_up, *_down, *_left, *_right; /**< Strecth buttons */
	TTButton *_angle; /**< Tail positioning button */
	UITextView *_textView; /**< Used for editing text */
	
	TTButton *_speechBubble; /**< The bubble view */
	UILabel *_speechTextLabel; /**< Text displayed in the bubble */
	SpeechBubbleType _styleMode; /**< Bubble Type */
	NSInteger _anglePos; /**< Angular position of the tail */
	
	SpeechBubbleSelectionState _selectionState; /**< Bubble selection state */
	
	ComicEditorViewController *_viewController; /**< The view controller the bubble belongs to */
}

@property (nonatomic, assign) NSUInteger slideID;
@property (nonatomic, assign) SpeechBubbleType styleMode;
@property (nonatomic, assign) NSInteger anglePos;
@property (nonatomic, readonly) BOOL selected;
@property (nonatomic, readonly) BOOL editing;
@property (nonatomic, assign) SpeechBubbleSelectionState selectionState;

@property (nonatomic, retain) TTButton *cross;
@property (nonatomic, retain) TTButton *up;
@property (nonatomic, retain) TTButton *down;
@property (nonatomic, retain) TTButton *left;
@property (nonatomic, retain) TTButton *right;
@property (nonatomic, retain) TTButton *angle;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) TTButton *speechBubble;
@property (nonatomic, retain) UILabel *speechTextLabel;
@property (nonatomic, assign) ComicEditorViewController *viewController;

/*!
 Initialise a speech bubble with the specified properties
 @param rect location and size
 @param type of speech bubble
 @param angle / tail location
 @param text of the bubble
 @result instance of speech bubble
 */
- (id)initWithFrame:(CGRect)rect type:(SpeechBubbleType)type angle:(NSInteger)angle text:(NSString*)text;

/*!
 Simulates moving the angle button
 @param location where the angle button is to be moved
 */
- (void)angleMoveLocation:(CGPoint)location;

@end

#pragma mark -
/*!
 ZeroEdgeTextView

 UITextView seems to automatically be resetting the contentInset
 bottom margin to 32.0f, causing strange scroll behavior in our small
 textView.  Maybe there is a setting for this, but it seems like odd behavior.
 override contentInset to always be zero.
*/
@interface ZeroEdgeTextView : UITextView
@end