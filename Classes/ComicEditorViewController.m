//
//  ComicEditorViewController.m
//  DIYComic
//
//  Created by Simon Vogler & Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "ComicEditorViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "StyleSheet.h"

#define FIRST_SHOW @"FIRST_SHOW_EDITOR"
#define OVERLAY_FILE @"OverlayEditor.png"

@implementation ComicEditorViewController

@synthesize imageView, imageShown, contentView=_contentView,backgroundButton=_backgroundButton;
@synthesize typeButtonThought=_typeButtonThought,typeButtonSpeech=_typeButtonSpeech,typeButtonNarrative=_typeButtonNarrative;

- (id)initWithChallenge:(NSString*)challenge slideID:(NSUInteger)slideID {
	if (self = [super init]) {
		_challenge = [challenge retain];
		_slideID = slideID;
		
		overlayView = nil;
		
		imageShown = nil;
		
		connector = [[Connector alloc] init];
		connector.delegate = self;
		
		UIBarButtonItem *picsButton = [[UIBarButtonItem alloc] initWithTitle:@"Set Photo" style: UIBarButtonItemStyleBordered target:self action:@selector(imageButtonPressed:)];
		self.navigationItem.rightBarButtonItem = picsButton;
		[picsButton release];
		
		modeSelection = 0;
		savePhotoToLibrary = NO;
		
		highlightedToolBarItem = nil;
					
		self.title = @"Edit";
	}
	
	return self;
}

// Toolbar attributes
static int const kToolBarButtonWidth = 70;
static int const kToolBarButtonHeight = 54;	//30;
static int const kToolBarHeight = 70;	//44;

// Toolbar titles
static NSString* const kSpeech = @"Speech";
static NSString* const kThought = @"Thought";
static NSString* const kNarrative = @"Narrative";
static NSString* const kSaveImage = @"Save Image";

// Font name
static NSString* const kFontName = @"Marker Felt";

// Colour selection bar attributes
static int const kColourToolBarHeight = 26;
static int const kColourBlock = 18;

// Image Size
static int const kImageSize = 320;

// Colour selection bar attributes
static int const kColourToolBarOriginY = 390;	// kImageY+kImageSize;


- (void)loadView {
	[super loadView];
	
	// Register for keyboard notifications
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
	[nc addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
	[nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
	
	////////////////////////
	// Set up image views
	////////////////////////
	self.imageView = [[UIImageView alloc] init];
	[imageView release];
	imageView.frame = CGRectMake(0, 0, kImageSize, kImageSize);
	imageView.backgroundColor = [UIColor blackColor];
	imageView.userInteractionEnabled = YES;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.image = imageShown;
	
	imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.allowsImageEditing = YES;
	
	
	//////////////////
	// Set up Tool Bar
	//////////////////
	toolBar = [[TTView alloc] initWithFrame:CGRectMake(0, 0, self.view.width+40, kToolBarHeight)];
	toolBar.style = TTSTYLE(colourToolbarStyle);	//orig: toolbarStyle);
	
	[highlightedToolBarItem release];
	highlightedToolBarItem = [[TTView alloc] initWithFrame:CGRectMake(0, 0, toolBar.height+20, toolBar.height)];
	highlightedToolBarItem.style = TTSTYLE(selectedItemBackgroundStyle);
	[toolBar addSubview:highlightedToolBarItem];	
	
	self.typeButtonSpeech = [TTButton buttonWithStyle:@"speechToolBarButton:"];
	[_typeButtonSpeech setTitle:kSpeech forState:UIControlStateNormal];
	_typeButtonSpeech.frame = CGRectMake(22, 7, kToolBarButtonWidth, kToolBarButtonHeight+4);
	[_typeButtonSpeech addTarget:self action:@selector(speechPressed:event:) forControlEvents:UIControlEventTouchUpInside];
	[toolBar addSubview:_typeButtonSpeech];
	[self setBubbleMode:SpeechBubbleTypeSpeech];
	
	self.typeButtonThought = [TTButton buttonWithStyle:@"thoughtToolBarButton:"];
	[_typeButtonThought setTitle:kThought forState:UIControlStateNormal];
	_typeButtonThought.frame = CGRectMake(160-(kToolBarButtonWidth/2), 7, kToolBarButtonWidth, kToolBarButtonHeight);
	[_typeButtonThought addTarget:self action:@selector(thoughtPressed:event:) forControlEvents:UIControlEventTouchUpInside];
	[toolBar addSubview:_typeButtonThought];
	
	self.typeButtonNarrative = [TTButton buttonWithStyle:@"narrativeToolBarButton:"];
	[_typeButtonNarrative setTitle:kNarrative forState:UIControlStateNormal];
	_typeButtonNarrative.frame = CGRectMake(320-kToolBarButtonWidth-22, 7, kToolBarButtonWidth, kToolBarButtonHeight);
	[_typeButtonNarrative addTarget:self action:@selector(narrativePressed:event:) forControlEvents:UIControlEventTouchUpInside];
	[toolBar addSubview:_typeButtonNarrative];
	
	[self.view addSubview:toolBar];
	
	//////////////////
	// Colour palette
	//////////////////
	bottomToolBar = [[TTView alloc] initWithFrame:CGRectMake(0, kColourToolBarOriginY, self.view.width, kColourToolBarHeight)];
	bottomToolBar.style = TTSTYLE(colourToolbarStyle);
	
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	infoButton.frame = CGRectMake(7, 0, 25, kColourToolBarHeight);
	[bottomToolBar addSubview:infoButton];
	
	/*orig: TTButton *redButton= [TTButton buttonWithStyle:@"redButton:"];
	redButton.frame = CGRectMake(4, 4, kColourBlock, kColourBlock);
	[redButton setTitle:@"Red" forState:UIControlStateNormal];
	[redButton addTarget:self action:@selector(updateColour:event:) forControlEvents:UIControlEventTouchUpInside];
	[colourBar addSubview:redButton];
	
	TTButton *greenButton= [TTButton buttonWithStyle:@"greenButton:"];
	greenButton.frame = CGRectMake(4+26, 4, kColourBlock, kColourBlock);
	[greenButton setTitle:@"Green" forState:UIControlStateNormal];
	[greenButton addTarget:self action:@selector(updateColour:event:) forControlEvents:UIControlEventTouchUpInside];
	[colourBar addSubview:greenButton];
	
	TTButton *blueButton= [TTButton buttonWithStyle:@"blueButton:"];
	blueButton.frame = CGRectMake(4+(2*26), 4, kColourBlock, kColourBlock);
	[blueButton setTitle:@"Blue" forState:UIControlStateNormal];
	[blueButton addTarget:self action:@selector(updateColour:event:) forControlEvents:UIControlEventTouchUpInside];
	[colourBar addSubview:blueButton];
	
	TTButton *yellowButton= [TTButton buttonWithStyle:@"yellowButton:"];
	yellowButton.frame = CGRectMake(4+(3*26), 4, kColourBlock, kColourBlock);
	[yellowButton setTitle:@"Yellow" forState:UIControlStateNormal];
	[yellowButton addTarget:self action:@selector(updateColour:event:) forControlEvents:UIControlEventTouchUpInside];
	[colourBar addSubview:yellowButton];
	
	TTButton *whiteButton= [TTButton buttonWithStyle:@"whiteButton:"];
	whiteButton.frame = CGRectMake(4+(4*26), 4, kColourBlock, kColourBlock);
	[whiteButton setTitle:@"White" forState:UIControlStateNormal];
	[whiteButton addTarget:self action:@selector(updateColour:event:) forControlEvents:UIControlEventTouchUpInside];
	[colourBar addSubview:whiteButton];
	
	TTButton *greyButton= [TTButton buttonWithStyle:@"greyButton:"];
	greyButton.frame = CGRectMake(4+(5*26), 4, kColourBlock, kColourBlock);
	[greyButton setTitle:@"Grey" forState:UIControlStateNormal];
	[greyButton addTarget:self action:@selector(updateColour:event:) forControlEvents:UIControlEventTouchUpInside];
	[colourBar addSubview:greyButton];
	
	TTButton *blackButton= [TTButton buttonWithStyle:@"blackButton:"];
	blackButton.frame = CGRectMake(4+(6*26), 4, kColourBlock, kColourBlock);
	[blackButton setTitle:@"Black" forState:UIControlStateNormal];
	[blackButton addTarget:self action:@selector(updateColour:event:) forControlEvents:UIControlEventTouchUpInside];
	[colourBar addSubview:blackButton];
	
	TTButton *orangeButton= [TTButton buttonWithStyle:@"orangeButton:"];
	orangeButton.frame = CGRectMake(4+(7*26), 4, kColourBlock, kColourBlock);
	[orangeButton setTitle:@"Orange" forState:UIControlStateNormal];
	[orangeButton addTarget:self action:@selector(updateColour:event:) forControlEvents:UIControlEventTouchUpInside];
	[colourBar addSubview:orangeButton];
	
	TTButton *pinkButton= [TTButton buttonWithStyle:@"pinkButton:"];
	pinkButton.frame = CGRectMake(4+(8*26), 4, kColourBlock, kColourBlock);
	[pinkButton setTitle:@"Pink" forState:UIControlStateNormal];
	[pinkButton addTarget:self action:@selector(updateColour:event:) forControlEvents:UIControlEventTouchUpInside];
	[colourBar addSubview:pinkButton];
	
	TTButton *purpleButton= [TTButton buttonWithStyle:@"purpleButton:"];
	purpleButton.frame = CGRectMake(4+(9*26), 4, kColourBlock, kColourBlock);
	[purpleButton setTitle:@"Purple" forState:UIControlStateNormal];
	[purpleButton addTarget:self action:@selector(updateColour:event:) forControlEvents:UIControlEventTouchUpInside];
	[colourBar addSubview:purpleButton];
	
	UILabel *colourLabel = [[UILabel alloc] initWithFrame:CGRectMake(8+(10*26), 4, 60, kColourBlock)];
	colourLabel.backgroundColor = [UIColor clearColor];
	colourLabel.textColor = [UIColor whiteColor];
	colourLabel.font = [UIFont boldSystemFontOfSize:14.0];
	colourLabel.text = @"Colour";
	[colourBar addSubview:colourLabel];
	[colourLabel release];*/
	
	[self.view addSubview:bottomToolBar];
	
	///////////////////////////
	// Set up the content view
	///////////////////////////
	self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, toolBar.bottom, self.view.width, self.view.height-toolBar.height-bottomToolBar.height)];
	[_contentView release];
	[_contentView addSubview:imageView];
	_contentView.backgroundColor = self.view.backgroundColor;
	_contentView.contentSize = imageView.bounds.size;
	[self.view addSubview:_contentView];
	
	self.backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_backgroundButton.frame = imageView.bounds;
	_backgroundButton.backgroundColor = [UIColor clearColor];
	[_backgroundButton addTarget:self action:@selector(backgroundButtonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
	[imageView addSubview:_backgroundButton];
	
	
	////////////////
	// Modal views
	////////////////
	loadingView = [[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleWhiteBox];
	loadingView.frame = self.view.frame;
	loadingView.text = @"Loading...";
	loadingView.hidden = YES;
	loadingView.backgroundColor = self.view.backgroundColor;
	[self.view addSubview:loadingView];
	[loadingView release];
	
	errorView = [[TTErrorView alloc] init];
	errorView.title = @"Error";
	errorView.image = TTIMAGE(@"bundle://Three20.bundle/images/error.png");
	errorView.frame = self.view.frame;
	errorView.hidden = YES;
	errorView.backgroundColor = TTSTYLEVAR(backgroundColor);
	[self.view addSubview:errorView];
	[errorView release];
	
	[self showLoading:YES];
	
	////////////////////////////////
	// Get the data for this slide
	////////////////////////////////
	[connector grabComicSlideDetailsForChallenge:_challenge slide:_slideID];
}

- (void)viewDidUnload {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	[super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self saveImage];
	[self saveComicState];
}

- (void)deselectAll {
	for(SpeechBubble *speechBubble in imageView.subviews) {
		if (![speechBubble isKindOfClass:[SpeechBubble class]]) continue;
		speechBubble.selectionState = SpeechBubbleSelectionStateDeselected;
	}
}

- (SpeechBubble*)selectedBubble {
	for(SpeechBubble *speechBubble in imageView.subviews) {
		if ([speechBubble isKindOfClass:[SpeechBubble class]] && speechBubble.selected) {
			return speechBubble;
		}
	}
	
	return nil;
}


#pragma mark -
#pragma mark Scroll up UIView when keyboard visible
- (void)keyboardDidShow:(NSNotification *)nc {
	NSValue* value = [nc.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	CGRect keyboardBounds;
	[value getValue:&keyboardBounds];
	
	_contentView.height = self.view.height-(keyboardBounds.size.height-bottomToolBar.height);
	
	UIView *sb = [self selectedBubble];
	CGFloat height = sb.height;
	[_contentView scrollRectToVisible:CGRectMake(sb.left, sb.top, sb.width, (height>_contentView.height ? _contentView.height : height))
							 animated:YES];
	
}

- (void)keyboardWillHide:(NSNotification *)nc {
	_contentView.top = toolBar.bottom;
	_contentView.height = self.view.height-toolBar.height-bottomToolBar.height;
}

- (void)keyboardWillShow:(NSNotification *)nc {
	[UIView beginAnimations:@"keyboardup" context:nil];
	[UIView setAnimationDuration:0.32];
	_contentView.top = 0;
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Save Image / Comic States

- (void)saveImage {
	// Deselect all selected boxes for final image
	for(SpeechBubble *speechBubble in imageView.subviews) {
		if (![speechBubble isKindOfClass:[SpeechBubble class]]) continue;
		speechBubble.selectionState=SpeechBubbleSelectionStateDeselected;
	}
	
	// Save final image
	UIImage *caputered = [ComicEditorViewController captureView:imageView];
	
	// Store to iPhone documents directory
	NSData *imageData = UIImagePNGRepresentation(caputered);
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	documentsDirectory = [documentsDirectory stringByAppendingPathComponent:slidePictureFile(_challenge,_slideID)];
	NSError *error = nil;
	[imageData writeToFile:documentsDirectory options:NSDataWritingAtomic error:&error];
	if (error) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedFailureReason] 
														message:[NSString stringWithFormat:@"Could not render slide to an image because %@",[error localizedDescription]] 
													   delegate:nil 
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)saveComicState {
	// Save the configurable data
	NSMutableArray *boubleItems = [NSMutableArray arrayWithCapacity:imageView.subviews.count];	
	for (SpeechBubble *frame in imageView.subviews) {
		if (![frame isKindOfClass:[SpeechBubble class]]) continue;
		
		NSMutableDictionary *boubleItem = [NSMutableDictionary dictionaryWithCapacity:6];
		[boubleItem setObject:[NSNumber numberWithFloat:frame.origin.x] forKey:@"x"];
		[boubleItem setObject:[NSNumber numberWithFloat:frame.origin.y] forKey:@"y"];
		[boubleItem setObject:[NSNumber numberWithFloat:frame.width] forKey:@"width"];
		[boubleItem setObject:[NSNumber numberWithFloat:frame.height] forKey:@"height"];
		[boubleItem setObject:[NSNumber numberWithInt:frame.styleMode] forKey:@"type"];
		[boubleItem setObject:[NSNumber numberWithInt:frame.anglePos] forKey:@"angle"];
		[boubleItem setObject:frame.textView.text forKey:@"text"];
		
		[boubleItems addObject:boubleItem];
	}
	
	[connector saveComicSlideDetailsForChallenge:_challenge slide:_slideID boubleItems:boubleItems image:imageView.image];
}

#pragma mark -
#pragma mark Speech Bubble Mode
- (void)setBubbleMode:(SpeechBubbleType)bubbleMode {
	CGPoint centre;
	switch (bubbleMode) {
		case SpeechBubbleTypeSpeech:
			centre = _typeButtonSpeech.center;
			break;
		case SpeechBubbleTypeThought:
			centre = _typeButtonThought.center;
			break;
		case SpeechBubbleTypeNarrative:
			centre = _typeButtonNarrative.center;
			break;
		default:
			centre = CGPointZero;
			break;
	}

	modeSelection = bubbleMode;
	[UIView beginAnimations:@"movehighlighted" context:nil];
	[UIView setAnimationDuration:0.32];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	highlightedToolBarItem.left = round(centre.x-highlightedToolBarItem.width/2.0);
	[UIView commitAnimations];
}

- (void)speechPressed:(id)sender event:(id)event {
	[self setBubbleMode:SpeechBubbleTypeSpeech];
	[self selectedBubble].styleMode = SpeechBubbleTypeSpeech;
}

- (void)thoughtPressed:(id)sender event:(id)event {
	[self setBubbleMode:SpeechBubbleTypeThought];
	[self selectedBubble].styleMode = SpeechBubbleTypeThought;
}

- (void)narrativePressed:(id)sender event:(id)event {
	[self setBubbleMode:SpeechBubbleTypeNarrative];
	[self selectedBubble].styleMode = SpeechBubbleTypeNarrative;
}

#pragma mark -
#pragma mark Screen Capture

+ (UIImage *)captureView:(UIView *)view {
	// Screen capture of edited comic
	UIGraphicsBeginImageContext(view.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
	CGContextFillRect(ctx, view.frame);
    [view.layer renderInContext:ctx];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
	return newImage;
}


#pragma mark -
#pragma mark Update Image

static NSString* const kPhoto = @"Take Photo";
static NSString* const kLibrary = @"Choose From Library";
static NSString* const kCancel = @"Cancel";

- (void)imageButtonPressed:(id)selector {
	[self deselectAll];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[actionSheet addButtonWithTitle:kPhoto];
	}
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		[actionSheet addButtonWithTitle:kLibrary];
	}
	
	[actionSheet addButtonWithTitle:kCancel];
	actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
	[actionSheet showInView:[[TTNavigator navigator] window]];
	[actionSheet release];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo :(NSDictionary *)info {
	[self dismissModalViewControllerAnimated:YES];
	

	UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
	if (savePhotoToLibrary) {
		UIImageWriteToSavedPhotosAlbum([info objectForKey:@"UIImagePickerControllerOriginalImage"],nil,nil,nil);
	}
	
	imageView.image = image;
	self.imageShown = image;
	[self deselectAll];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
	if([title isEqualToString:kPhoto]) {
		savePhotoToLibrary = YES;
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentModalViewController:imagePicker animated:YES];
	}
	else if([title isEqualToString:kLibrary]) {
		savePhotoToLibrary = NO;
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:imagePicker animated:YES];
	}
}


#pragma mark -
#pragma mark Adding Speech Bubble

// Speech bubble attributes
static int const kStretch = 30;
static int const kCrossSize = 30;
static int const kWidth = 200;
static int const kHeight = 140;

// Text spacing within speech bubble
static int const kTextOffset = 6;	//4;
static int const kTextHeightOffset = 10;

- (SpeechBubble*)addSpeechBubble:(id)sender event:(id)event {
	UIEvent *touchEvent = event;
	UITouch *touch = [[touchEvent allTouches] anyObject];
	CGPoint location = [touch locationInView:imageView];
	CGRect frame = CGRectMake(round(location.x - kWidth/2), round(location.y - kHeight/2), kWidth, kHeight);
	SpeechBubble *sBubble = [self addSpeechBoubleWithFrame:frame type:modeSelection angle:240 text:@""];
	return sBubble;
}


- (SpeechBubble*)addSpeechBoubleWithFrame:(CGRect)rect type:(SpeechBubbleType)type angle:(NSInteger)angle text:(NSString*)text {
	[self deselectAll];

	// Restore speech bubble
	SpeechBubble *sBubble = [[SpeechBubble alloc] initWithFrame:rect type:type angle:angle text:text];
	sBubble.selectionState = SpeechBubbleSelectionStateDeselected;
	sBubble.viewController = self;
	[imageView addSubview:sBubble];
	[sBubble release];
	return sBubble;
}



#pragma mark -
#pragma mark button methods

- (void)backgroundButtonPressed:(id)sender event:(id)event {
	BOOL createNew = YES;
	// Check if we are actually dismissing a button
	for(SpeechBubble *speechBubble in imageView.subviews) {
		if (![speechBubble isKindOfClass:[SpeechBubble class]]) continue;
		
		if(speechBubble.selectionState == SpeechBubbleSelectionStateSelected) {
			speechBubble.selectionState = SpeechBubbleSelectionStateDeselected;
			createNew = NO;
		} else if (speechBubble.selectionState == SpeechBubbleSelectionStateInput) {
			speechBubble.selectionState = SpeechBubbleSelectionStateSelected;
			createNew = NO;
		}
	}
	
	// Create new speech bubble, if nothing was dismissed
	if(createNew) {
		[self addSpeechBubble:nil event:event].selectionState = SpeechBubbleSelectionStateInput;
	}
}

- (void)dragBox:(id)sender event:(id)event {
	[self deselectAll];
	
	TTButton *button = (TTButton*)sender;
	UIEvent *touchEvent = event;
	UITouch *touch = [[touchEvent allTouches] anyObject];
		
	SpeechBubble *spb = (SpeechBubble*)button.superview;
	CGPoint location = [touch locationInView:imageView];
	// Don't allow speech bubbles to go off the screen
	if (location.x>0 && location.x<imageView.width && location.y>0 && location.y<imageView.height) {
		spb.center = location;
		spb.frame = spb.frame;
	}
	[imageView bringSubviewToFront:spb];
}


- (void)deleteButtonPressed:(id)sender {
	// Confirm to delete the speech bubble
	TTButton *deleteButton = sender;
	if (!((TTButton*)deleteButton.superview).tracking) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete this speech bubble?" 
													message:@"Once deleted, it is permanently gone." 
													delegate:self 
													cancelButtonTitle:@"Cancel" 
													otherButtonTitles:@"Delete",nil];
		[alert show];
		[alert release];
	}
}


#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// For the delete button
	NSString *button = [alertView buttonTitleAtIndex:buttonIndex];
	if ([button isEqualToString:@"Delete"]) {
		SpeechBubble *bubble = [self selectedBubble];
		bubble.selectionState = SpeechBubbleSelectionStateDeselected;
		[bubble removeFromSuperview];
	}	
}

#pragma mark -
- (void)showLoading:(BOOL)show {
	loadingView.hidden = !show;
}

- (void)showError:(BOOL)show {
	errorView.hidden = !show;
}

- (void)dealloc {
	[imageView release];
	[imageShown release];
	[imagePicker release];
	connector.delegate = nil;
	[connector release];
	[_challenge release];
	TT_RELEASE_SAFELY(highlightedToolBarItem);
	TT_RELEASE_SAFELY(_typeButtonSpeech);
	TT_RELEASE_SAFELY(_typeButtonThought);
	TT_RELEASE_SAFELY(_typeButtonNarrative); 
	TT_RELEASE_SAFELY(_contentView);
	TT_RELEASE_SAFELY(_backgroundButton);
	TT_RELEASE_SAFELY(overlayView);
	[super dealloc];
}

- (void)showOverlay:(BOOL)show {
	if (show && !overlayView) {	
		overlayView = [[OverlayView alloc] init];
		overlayView.frame = CGRectMake(10, 10, self.view.width-20, self.view.height-20);
		overlayView.content = [UIImage imageNamed:OVERLAY_FILE];
		overlayView.delegate = self;
		overlayView.alpha = 0;
		[self.view addSubview:overlayView];
		
		[UIView beginAnimations:@"Overlay Appear" context:nil];
		[UIView setAnimationDuration:0.5];
		overlayView.alpha = 1;
		[UIView commitAnimations];
		
	} else {
		[UIView beginAnimations:@"Overlay Disappear" context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		overlayView.alpha = 0;
		[UIView commitAnimations];
	}
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	[overlayView removeFromSuperview];
	UIView *oldView = overlayView;
	overlayView = nil;
	[oldView release];
}

- (void)infoButtonPressed:(id)sender {
	[self showOverlay:YES];
}

#pragma mark OverlayViewDelegate
- (void)overlayViewdismissPressed {
	[self showOverlay:NO];
}

#pragma mark ConnectorDelegate
- (void)connectorRequestDidFinishWithData:(id)data call:(NSString*)call {
	if ([data isKindOfClass:[NSDictionary class]]) {
		
		// Update/add the information to the view components
		if ([call isEqualToString:@"grabComicSlideDetailsForChallenge"]) {
		
			// Restore the configurable data
			
			// Restore boubles
			NSDictionary *slideDetails = data;
			NSArray *boubleItems = [slideDetails objectForKey:@"boubles"];	
			for (NSDictionary *bouble in boubleItems) {
				CGFloat x = [[bouble objectForKey:@"x"] floatValue];
				CGFloat y = [[bouble objectForKey:@"y"] floatValue];
				CGFloat width = [[bouble objectForKey:@"width"] floatValue];
				CGFloat height = [[bouble objectForKey:@"height"] floatValue];
				NSInteger type = [[bouble objectForKey:@"type"] intValue];
				NSInteger angle = [[bouble objectForKey:@"angle"] intValue];
				NSString *text = [bouble objectForKey:@"text"];
				
				[self addSpeechBoubleWithFrame:CGRectMake(x,y,width,height) type:type angle:angle text:text];
			}

			// Restore photo
			if(!imageView.image) {
				self.imageShown = [UIImage imageWithData:[slideDetails objectForKey:@"photo"]]; 
				imageView.image = imageShown;
			}
			[self showLoading:NO];
			[self showError:NO];
			
			BOOL shown = [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_SHOW];
			if (!shown) {
				[self showOverlay:YES];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_SHOW];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}		
		}
	}
}

- (void)connectorRequestDidFailWithError:(NSError*)error call:(NSString*)call {
	// On an error, show the error
	errorView.subtitle = [error localizedDescription];
	errorView.title = [error localizedFailureReason];
	[errorView layoutSubviews];
	[self showLoading:NO];
	[self showError:YES];
}

@end


#pragma mark -
#pragma mark SpeechBubble

@implementation SpeechBubble
@synthesize slideID=_slideID, cross=_cross, up=_up, down=_down, left=_left, right=_right, angle=_angle;
@synthesize textView=_textView, viewController=_viewController;
@synthesize speechBubble=_speechBubble,speechTextLabel=_speechTextLabel;
@synthesize styleMode=_styleMode, anglePos=_anglePos;
@synthesize selectionState=_selectionState;

- (id)init {
	CGRect frame = CGRectMake(0, 0, kWidth, kHeight);
	return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame type:SpeechBubbleTypeSpeech angle:240 text:@""];
}

- (id)initWithFrame:(CGRect)rect type:(SpeechBubbleType)type angle:(NSInteger)angle text:(NSString*)text {
	if (self = [super initWithFrame:rect]) {
		
		_viewController = nil;
		// Restore speech bubble
		self.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.5];
		
		[self.layer setBorderColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.8].CGColor];
		[self.layer setBorderWidth:1.6];
		[self.layer setCornerRadius:5.0];
		
		_speechBubble = [[TTButton alloc] init];
		[_speechBubble setStylesWithSelector:@"speechBubble:"];
		_speechBubble.frame = CGRectMake(kStretch, kStretch, kWidth-(2*kStretch), kHeight-(2*kStretch));
		[_speechBubble addTarget:self action:@selector(dragBox:event:) forControlEvents:UIControlEventTouchDragInside];
		[_speechBubble addTarget:self action:@selector(selectBox:event:) forControlEvents:UIControlEventTouchUpInside];
		[_speechBubble setTitle:text forState:UIControlStateNormal];
		[self addSubview:self.speechBubble];
		
		_speechTextLabel = [[UILabel alloc] init];
		_speechTextLabel.text = text;
		_speechTextLabel.font = [UIFont fontWithName:@"Marker Felt" size:14];
		_speechTextLabel.textAlignment = UITextAlignmentCenter;
		_speechTextLabel.numberOfLines = 0;
		[_speechBubble addSubview:_speechTextLabel];
				
		self.cross = [TTButton buttonWithStyle:@"speechBubbleCrossButton:"];
		[_cross setTitle:@"x" forState:UIControlStateNormal];
		_cross.frame = CGRectMake(0, 0, kCrossSize, kCrossSize);
		_cross.backgroundColor = [UIColor clearColor];
		[_cross addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.cross];
		
		self.up = [TTButton buttonWithStyle:@"stretchSpeechBubble:"];
		_up.frame = CGRectMake(round(self.width/2-(kStretch/2)), 0, kStretch, kStretch);
		_up.backgroundColor = [UIColor clearColor];
		[_up addTarget:self action:@selector(adjustButtonDragged:event:) forControlEvents:UIControlEventTouchDragInside];
		[self addSubview:self.up];
		
		self.down = [TTButton buttonWithStyle:@"stretchSpeechBubble:"];
		_down.frame = CGRectMake(round(self.width/2-(kStretch/2)), self.height-kStretch, kStretch, kStretch);
		_down.backgroundColor = [UIColor clearColor];
		[_down addTarget:self action:@selector(adjustButtonDragged:event:) forControlEvents:UIControlEventTouchDragInside];
		[self addSubview:self.down];
		
		self.left = [TTButton buttonWithStyle:@"stretchSpeechBubble:"];
		_left.frame = CGRectMake(0, round(self.height/2-(kStretch/2)), kStretch, kStretch);
		_left.backgroundColor = [UIColor clearColor];
		[_left addTarget:self action:@selector(adjustButtonDragged:event:) forControlEvents:UIControlEventTouchDragInside];
		[self addSubview:self.left];
		
		self.right = [TTButton buttonWithStyle:@"stretchSpeechBubble:"];
		_right.frame = CGRectMake(self.width-kStretch, round(self.height/2-(kStretch/2)), kStretch, kStretch);
		_right.backgroundColor = [UIColor clearColor];
		[_right addTarget:self action:@selector(adjustButtonDragged:event:) forControlEvents:UIControlEventTouchDragInside];
		[self addSubview:self.right];
		
		self.angle = [TTButton buttonWithStyle:@"speechBubbleTailAdjust:"];
		[_angle setTitle:@"a" forState:UIControlStateNormal];
		_angle.frame = CGRectMake(self.width/4, self.height-kCrossSize, kCrossSize, kCrossSize);
		_angle.backgroundColor = [UIColor clearColor];
		[_angle addTarget:self action:@selector(angleDragged:event:) forControlEvents:UIControlEventTouchDragInside];
		[self addSubview:self.angle];
		
		_textView = [[ZeroEdgeTextView alloc] init];
		_textView.font = [UIFont fontWithName:kFontName size:14.0];
		_textView.delegate = self;
		_textView.returnKeyType = UIReturnKeyDefault;
		[_textView setContentOffset:CGPointMake(0, 0)];
		[_textView setContentInset:UIEdgeInsetsZero];
		_textView.scrollEnabled = YES;
		_textView.textAlignment = UITextAlignmentCenter;
		_textView.text = text;
		[_speechBubble addSubview:self.textView];
		
		self.frame = rect;
		self.anglePos = angle;
		self.styleMode = type;
		
	}
	return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	BOOL inside = [super pointInside:point withEvent:event];
	if (!self.selected) {
		inside = (point.y >= _speechBubble.top && point.y <= _speechBubble.bottom) && (point.x >= _speechBubble.left && point.x <= _speechBubble.right);
	}
	return inside;
}


- (void)setSelectionState:(SpeechBubbleSelectionState)selectionState {
	_selectionState = selectionState;

	// Properties of Selected and Input states
	if (_selectionState==SpeechBubbleSelectionStateSelected || _selectionState==SpeechBubbleSelectionStateInput) {
		_cross.hidden = NO;
		_angle.hidden = _styleMode != SpeechBubbleTypeSpeech;
		_up.hidden = NO;
		_down.hidden = NO;
		_left.hidden = NO;
		_right.hidden = NO;

		self.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.5];
		[self.layer setBorderColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.8].CGColor];		
	}
	
	
	// Properties of Input State
	if (_selectionState==SpeechBubbleSelectionStateInput) {
		_textView.hidden = NO;
		[_textView becomeFirstResponder];
		
	// Properties of Selected State
	} else if (_selectionState==SpeechBubbleSelectionStateSelected) {
		_textView.hidden = YES;
		[_textView resignFirstResponder];
	
	// Properties of deselected state
	} else if (_selectionState==SpeechBubbleSelectionStateDeselected) {
		_cross.hidden = YES;
		_angle.hidden = YES;
		_up.hidden = YES;
		_down.hidden = YES;
		_left.hidden = YES;
		_right.hidden = YES;
		_textView.hidden = YES;
		[_textView resignFirstResponder];
		self.backgroundColor = [UIColor clearColor];
		[self.layer setBorderColor:[UIColor clearColor].CGColor];
	}
}

- (BOOL)selected {
	return _selectionState==SpeechBubbleSelectionStateSelected || _selectionState==SpeechBubbleSelectionStateInput;
}

- (BOOL)editing {
	return _selectionState==SpeechBubbleSelectionStateInput;
}

- (void)setFrame:(CGRect)frame {
	super.frame = CGRectMake(round(frame.origin.x), 
							 round(frame.origin.y), 
							 round(frame.size.width), 
							 round(frame.size.height));

	[_cross setFrame:CGRectMake(1, 1, kCrossSize, kCrossSize)];
	[_left setFrame:CGRectMake(0, round(self.height/2-(kStretch/2)), kStretch, kStretch)];
	[_right setFrame:CGRectMake(self.width-kStretch, round(self.height/2-(kStretch/2)), kStretch, kStretch)];
	[_up setFrame:CGRectMake(round(self.width/2-(kStretch/2)),0,  kStretch, kStretch)];
	[_down setFrame:CGRectMake(round(self.width/2-(kStretch/2)), round(self.height-kStretch), kStretch, kStretch)];
	
	[_speechBubble setFrame:CGRectMake(kCrossSize, kCrossSize, round(self.width-(2*kCrossSize)), round(self.height-(2*kCrossSize)))];
	self.anglePos=_anglePos;
}

- (void)dealloc {
	[_cross release];
	[_up release];
	[_down release];
	[_left release];
	[_right release];
	[_angle release];
	[_textView release];
	[_speechBubble release];
	[_speechTextLabel release];
	[super dealloc];
}

- (void)selectBox:(id)sender event:(id)event {
	SpeechBubbleSelectionState selectionState = _selectionState;
	[_viewController setBubbleMode:_styleMode];
	[_viewController deselectAll];

	[self.superview bringSubviewToFront:self];
	switch(selectionState) {
		case SpeechBubbleSelectionStateSelected:
			self.selectionState = SpeechBubbleSelectionStateInput;
			break;
		case SpeechBubbleSelectionStateInput:
			break;
		case SpeechBubbleSelectionStateDeselected:
			self.selectionState = SpeechBubbleSelectionStateSelected;
			break;
		default: break;
	}
}

- (void)dragBox:(id)sender event:(id)event {
	[_viewController dragBox:sender event:event];
}

- (void)angleDragged:(id)sender event:(id)event {
	if([sender isKindOfClass:[TTButton class]]) {
		TTButton *button = sender;
		UIEvent *touchEvent = event;
		UITouch *touch = [[touchEvent allTouches] anyObject];
		
		[[button superview] bringSubviewToFront:button];
		CGPoint location = [touch locationInView:self];
		[self angleMoveLocation:location];
	}
}

- (void)angleMoveLocation:(CGPoint)location {
	// Now we need to see which section the angle is located in
	// We do this by drawing two diagonal lines A->D and C->B across the speech bubble
	// if the Point P is above A->D & C->B top quadrant, beloew both, bottom quadrant
	// Below A->D but above C->B then left, else right quadrant
	
	// Set up the points in question
	CGFloat A[] = {_speechBubble.left,_speechBubble.top};
	CGFloat B[] = {_speechBubble.right,_speechBubble.top};
	CGFloat C[] = {_speechBubble.left,_speechBubble.bottom};
	CGFloat D[] = {_speechBubble.right,_speechBubble.bottom};
	CGFloat P[] = {location.x,location.y};
	
	CGFloat result1 = (D[0]-A[0])*(D[1]-P[1]) - (D[1]-A[1])*(D[0]-P[0]);
	CGFloat result2 = (B[0]-C[0])*(B[1]-P[1]) - (B[1]-C[1])*(B[0]-P[0]);
	
	// Move P into speech bubble boundries
	if (P[0]<_speechBubble.left) P[0] = _speechBubble.left;
	if (P[0]>_speechBubble.right) P[0] = _speechBubble.right;
	if (P[1]<_speechBubble.top) P[1] = _speechBubble.top;
	if (P[1]>_speechBubble.bottom) P[1] = _speechBubble.bottom;
	
	// TOP
	if (result1>=0 && result2>=0) {
		self.anglePos = 45+(P[0]/self.width)*90;
	
	// BOTTOM
	} else if (result1<=0 && result2<=0) {
		self.anglePos = 315-(P[0]/self.width)*90;
		
	// RIGHT
	} else if (result1>0 && result2<0) {
		self.anglePos = 225-(P[1]/self.height)*90;
		
	// LEFT
	} else {
		if (P[1]>self.height/2.0) {
			self.anglePos = (P[1]/self.height)*90-45;
		} else {
			self.anglePos = (P[1]/self.height)*90+315;
		}

	}
}



- (void)setAnglePos:(NSInteger)anglePos {
	_anglePos = anglePos;
	
	// TOP
	if (_anglePos >= 45 && _anglePos <= 135) {
		_angle.frame = CGRectMake(((_anglePos-45.0)/90.0)*_speechBubble.width+_speechBubble.top-_angle.width/2.0, 0, _angle.width, _angle.height);		
		
	// RIGHT
	} else if (_anglePos > 135 && _anglePos < 225) {
		_angle.frame = CGRectMake(self.width-_angle.width, ((225.0-_anglePos)/90.0)*_speechBubble.height+_speechBubble.left-_angle.width/2.0, _angle.width, _angle.height);	
		
	// BOTTOM
	} else if (_anglePos >= 225 && _anglePos <= 315) {		
		_angle.frame = CGRectMake(((315.0-_anglePos)/90.0)*_speechBubble.width+_speechBubble.top-_angle.width/2.0, self.height-_angle.height, _angle.width, _angle.height);
		
	// LEFT
	} else {
		CGFloat point;		
		if (_anglePos > 315) point = (_anglePos-315.0)/90.0*_speechBubble.height;
		if (_anglePos < 45) point = (_anglePos)/90.0*_speechBubble.height+_speechBubble.height/2.0;
				
		_angle.frame = CGRectMake(0, point+_speechBubble.left-_angle.width/2.0, _angle.width, _angle.height);	
	}	
	
	self.styleMode = _styleMode;
}

- (void)setStyleMode:(SpeechBubbleType)styleMode {
	_styleMode = styleMode;
	
	TTStyle *sbStyle;
	int pointAng = 270;
	
	CGFloat leftPadd = 10;
	CGFloat rightPadd = 10;
	CGFloat topPadd = 10;
	CGFloat bottomPadd = 10;
	CGFloat pointHeight = 10;
	
	// TOP
	if (_anglePos >= 45 && _anglePos <= 135) {
		topPadd += pointHeight;
		pointAng = 90;
			
	// RIGHT
	} else if (_anglePos > 135 && _anglePos < 225) {
		rightPadd += pointHeight;
		pointAng = 180;
	
	// BOTTOM
	} else if (_anglePos >= 225 && _anglePos <= 315) {
		bottomPadd += pointHeight;
		pointAng = 270;
		
	// LEFT
	} else {
		leftPadd += pointHeight;
		pointAng = 0;
	}	
	
	switch (_styleMode) {
		case SpeechBubbleTypeSpeech:		
			sbStyle = [TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:5 pointLocation:_anglePos pointAngle:pointAng pointSize:CGSizeMake(20,pointHeight)] next:
					   [TTSolidFillStyle styleWithColor:RGBCOLOR(255,255,255) next:
						[TTSolidBorderStyle styleWithColor:RGBCOLOR(0,0,0) width:1 next:
						 nil]]];
			self.angle.hidden = !self.selected;
			break;
			
		case SpeechBubbleTypeThought:
			topPadd = leftPadd = rightPadd = bottomPadd = 10;
			sbStyle = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:30] next:
					   [TTSolidFillStyle styleWithColor:RGBCOLOR(255,255,255) next:
						[TTSolidBorderStyle styleWithColor:RGBCOLOR(0,0,0) width:1 next:
						 nil]]];
			self.angle.hidden = YES;
			break;
			
		case SpeechBubbleTypeNarrative:
			topPadd = leftPadd = rightPadd = bottomPadd = 10;
			sbStyle = [TTSolidFillStyle styleWithColor:RGBCOLOR(255,255,255) next:
						[TTSolidBorderStyle styleWithColor:RGBCOLOR(0,0,0) width:1 next:
						 nil]];
			self.angle.hidden = YES;
			break;
			
		default:
			break;
	}

	_textView.frame = CGRectMake(leftPadd, topPadd, _speechBubble.width-leftPadd-rightPadd, _speechBubble.height-topPadd-bottomPadd);
	_speechTextLabel.frame = _textView.frame;
	[_speechBubble setStyle:sbStyle forState:UIControlStateNormal];
}

- (void)adjustButtonDragged:(id)sender event:(id)event {
	UIView *button = [sender superview];
	UIEvent *touchEvent = event;
	UITouch *touch = [[touchEvent allTouches] anyObject];
	
	[button.superview bringSubviewToFront:button];
	CGPoint location = [touch locationInView:button.superview];

	if (sender==_up) {
		// UP
		// Minimum size check
		if(self.height + (self.origin.y - location.y) < 110) return;
		
		// Maximum size check
		if(self.height + (self.origin.y - location.y) > 300) return;
		
		self.frame = CGRectMake(self.origin.x,
											   location.y,
											   self.width,
											   self.height + (self.origin.y - location.y));
		
	} else if (sender==_down) {
		// DOWN
		// Minimum size check
		if(self.height + (location.y - (self.origin.y + self.height)) < 110) return;
		
		// Maximum size check
		if(self.height + (location.y - (self.origin.y + self.height)) > 300) return;
		
		self.frame = CGRectMake(self.origin.x,
								self.origin.y,
								self.width,
								self.height + (location.y - (self.origin.y + self.height)));
	
	} else if (sender==_right) {
		// RIGHT
		// Minimum size check
		if(self.width + (location.x - (self.origin.x + self.width)) < 150) return;
		
		// Maximum size check
		if(self.width + (location.x - (self.origin.x + self.width)) > 300) return;
		
		self.frame = CGRectMake(self.origin.x,
								self.origin.y,
								self.width + (location.x - (self.origin.x + self.width)),
								self.height);
		
	} else if (sender==_left) {
		// LEFT
		// Minimum size check
		if(self.width + (self.origin.x - location.x) < 150) return;
		
		// Maximum size check
		if(self.width + (self.origin.x - location.x) > 300) return;
		
		self.frame = CGRectMake(location.x,
								self.origin.y,
								self.width + (self.origin.x - location.x),
								self.height);
	}

	//[self angleMoveLocation:_angle.origin];
}

- (void)deleteButtonPressed:(id)sender {
	[_viewController deleteButtonPressed:sender];
}


#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    return TRUE;	
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	self.selectionState = SpeechBubbleSelectionStateInput;
}

- (void)textViewDidChange:(UITextView *)textView {
	_speechTextLabel.text = _textView.text;
}

@end
	 
	 

#pragma mark - 
@implementation ZeroEdgeTextView
 
- (UIEdgeInsets)contentInset { 
	return UIEdgeInsetsZero; 
}
 
@end
