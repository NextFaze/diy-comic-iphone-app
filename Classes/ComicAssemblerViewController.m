//
//  ComicAssemblerViewController.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "ComicAssemblerViewController.h"
#import "P31LoadingView.h"
#import "StyleSheet.h"
#import "ActivityView.h"

#import "DIYComicAppDelegate.h"
#import "FlurryAPI.h"

#define UNTITLED_LABEL @"Click to add a title"

#define FIRST_SHOW @"FIRST_SHOW_ASSEMBLE"
#define OVERLAY_FILE @"OverlayAssembler.png"

@implementation ComicAssemblerViewController

- (id)initWithChallenge:(NSString*)challenge {
	[FlurryAPI logEvent:@"COMIC_MAKE" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:challenge,@"challenge",nil]];

	if (self = [self init]) {
		_challenge = [challenge retain];
		
		connector = [[Connector alloc] init];
		connector.delegate = self;
		
		loading = nil;
		detailView = nil;
		overlayView = nil;

		self.title = @"Create";
		
		UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style: UIBarButtonItemStyleBordered target:self action:@selector(submitPressed:)];
		self.navigationItem.rightBarButtonItem=submitButton;
		[submitButton release];
		
		comicButtonFocused = nil;
		self.autoresizesForKeyboard = YES;
		
		_data = nil;
	}
	
	return self;
}

- (void)dealloc {
	[toolBar release];
	[gridView release];
	[infoButton release];
	[titleButton release];
	[previewButton release];
	TT_RELEASE_SAFELY(overlayView);
	[detailView release];
	connector.delegate = nil;
	[connector release];
	[disabledView release];
	[_data release];
	[_challenge release];
	[super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
		
 	[connector grabComicDetailsForChallenge:_challenge];
}

- (void)loadView {
	[super loadView];
	
	////////////////
	// Tiled Buttons
	gridView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-44)];
	gridView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:gridView];
	
	addButton = [TTButton buttonWithStyle:@"comicButton:"];
	[addButton setTitle:[NSString stringWithFormat:@"+"] forState:UIControlStateNormal];
	CGPoint location = [self locationForGridButtonInPosition:0];
	addButton.frame = CGRectMake(location.x, location.y, gridView.width/2.0, gridView.width/2.0);
	[addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[gridView addSubview:addButton];
		
	///////////////
	// Details View
	detailView = [[TTView alloc] initWithFrame:CGRectMake(0, 44, self.view.width, 160)];
	detailView.style = TTSTYLE(sheetStyle);
	detailView.backgroundColor = [UIColor clearColor];
	detailView.top = self.view.height-44;
	[self.view addSubview:detailView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, detailView.width-20, 12)];
	titleLabel.font = [UIFont boldSystemFontOfSize:12];
	titleLabel.textColor = RGBCOLOR(255,255,255);
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = @"Title";
	[detailView addSubview:titleLabel];
	[titleLabel release];
	
	titleField = [[UITextField alloc] initWithFrame:CGRectMake(10, titleLabel.bottom+5, titleLabel.width, 31)];
	titleField.borderStyle = UITextBorderStyleRoundedRect;
	titleField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
	[detailView addSubview:titleField];	
	
	UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleField.bottom+10, titleLabel.width, 12)];
	detailLabel.font = [UIFont boldSystemFontOfSize:12];
	detailLabel.textColor = RGBCOLOR(255,255,255);
	detailLabel.backgroundColor = [UIColor clearColor];
	detailLabel.text = @"Description";
	[detailView addSubview:detailLabel];
	[detailLabel release];
	
	detailField = [[TTTextEditor alloc] initWithFrame:CGRectMake(10, detailLabel.bottom+5, titleLabel.width, detailView.height-10-detailLabel.bottom-5)];
	detailField.style = TTSTYLE(textFieldStyle);
	detailField.backgroundColor = [UIColor clearColor];
	detailField.autoresizesToText = NO;
	detailField.showsExtraLine = NO;
	[detailView addSubview:detailField];
				   
	
	//////////////
	// Tool Bar
	toolBar = [[TTView alloc] initWithFrame:CGRectMake(0, self.view.height-44, self.view.width, 44)];
	toolBar.style = TTSTYLE(toolbarStyle);
	
	infoButton = [[UIButton buttonWithType:UIButtonTypeInfoLight] retain];
	[infoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	infoButton.frame = CGRectMake(7, 7, 25, 30);
	[toolBar addSubview:infoButton];

	titleButton = [[TTButton buttonWithStyle:@"toolBarButton:"] retain];
	[titleButton setTitle:UNTITLED_LABEL forState:UIControlStateNormal];
	titleButton.frame = CGRectMake(infoButton.right+7, 7, 40, 30);
	[titleButton addTarget:self action:@selector(titlePressed:) forControlEvents:UIControlEventTouchUpInside];
	[toolBar addSubview:titleButton];
	[titleButton sizeToFit];
	
	previewButton = [[TTButton buttonWithStyle:@"toolBarRedButton:"] retain];
	[previewButton setTitle:@"Preview" forState:UIControlStateNormal];
	previewButton.frame = CGRectMake(7, 7, 40, 30);
	[toolBar addSubview:previewButton];
	[previewButton sizeToFit];
	[previewButton addTarget:self action:@selector(previewPressed:) forControlEvents:UIControlEventTouchUpInside];
	previewButton.right = toolBar.right-7;
	
	[self.view addSubview:toolBar];
	
	////////////////
	// Modal views
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
		
	////////////////
	// Disabled views
	disabledView = [[DisabledView alloc] initWithFrame:CGRectMake(0, toolBar.bottom, self.view.width, self.view.height-toolBar.height)];
	disabledView.backgroundColor = RGBACOLOR(100,100,100,0.8);
	disabledView.hidden = YES;
	disabledView.title = @"Disabled";
	disabledView.subtitle = @"This comic can no longer be edited";
	
	[self.view addSubview:disabledView];
}

- (void)showLoading:(BOOL)show {
	loadingView.hidden = !show;
}

- (void)showError:(BOOL)show {
	errorView.hidden = !show;
}

- (void)addCommicButton:(NSInteger)position image:(NSString*)imageURL slideID:(NSInteger)slideID {
	// Create a comic button
	ComicFrameButton *comicButton = [[[ComicFrameButton alloc] init] autorelease];
	[comicButton setStylesWithSelector:@"comicButton:"];
	[comicButton setTitle:[NSString stringWithFormat:@"%d",position+1] forState:UIControlStateNormal];
	[comicButton setImage:imageURL forState:UIControlStateNormal];
	comicButton.slideID = slideID;
	CGPoint location = [self locationForGridButtonInPosition:position];
	comicButton.frame = CGRectMake(location.x, location.y, gridView.width/2.0, gridView.width/2.0);
	[comicButton addTarget:self action:@selector(comicButtonDragged:event:) forControlEvents:UIControlEventTouchDragInside];
	[comicButton addTarget:self action:@selector(comicButtonReleased:event:) forControlEvents:UIControlEventTouchUpInside];
	[gridView addSubview:comicButton];
	
	TTButton *cross = [TTButton buttonWithStyle:@"crossButton:"];
	[cross setTitle:@"x" forState:UIControlStateNormal];
	cross.frame = CGRectMake(1, 1, 28, 28);
	cross.backgroundColor = [UIColor clearColor];
	[cross addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[comicButton addSubview:cross];
}

- (void)deleteButtonPressed:(id)sender {
	
	// Confirm to delete the comic
	TTButton *deleteButton = sender;
	if (!((TTButton*)deleteButton.superview).tracking) {
		UIAlertView *alert = [[UIAlertView alloc]	 initWithTitle:@"Delete this frame?" 
																message:@"Once deleted, it is permanently gone." 
															delegate:self 
													cancelButtonTitle:@"Cancel" 
													otherButtonTitles:@"Delete",nil];
		[alert show];
		[alert release];
		
		comicButtonFocused = (TTButton*)deleteButton.superview;
	}
}

- (void)comicButtonDragged:(id)sender event:(id)event {
	if ([sender isKindOfClass:[TTButton class]]) {
		if (sender == addButton) {
			return;
		}
		
		TTButton *button = sender;
		UIEvent *touchEvent = event;
		UITouch *touch = [[touchEvent allTouches] anyObject];
		
		lastPhase = touch.phase;
		
		// If the tracking the button, move the comic to the location of the press
		if (button.tracking) {
			[[button superview] bringSubviewToFront:button];
			CGPoint location = [touch locationInView:gridView];
			button.center = location;			
			
			// Scroll up or down, if user hits the edges
			NSInteger screenPos = gridView.screenViewY+location.y;
			if (screenPos>(gridView.bottom)) {
				[gridView scrollRectToVisible:CGRectMake(0, location.y, 10, 80) animated:NO];
			} else if ((screenPos-gridView.top-70)<70) {
				[gridView scrollRectToVisible:CGRectMake(0, location.y-80, 10, 80) animated:NO];
			}
		}
	}
}

- (void)comicButtonReleased:(id)sender event:(id)event {
	if (sender == addButton) {
		return;
	}
	
	ComicFrameButton *button = sender;
	UIEvent *touchEvent = event;
	UITouch *touch = [[touchEvent allTouches] anyObject];

	//orig: CGPoint prevlocation = [touch previousLocationInView:gridView];
	CGPoint location = [touch locationInView:gridView];	
	
	NSInteger newPosition = [self positionInGridForLocation:location];
	CGPoint newLocation = [self locationForGridButtonInPosition:newPosition];
	
	// Snap the button in the closest valid position
	[UIView beginAnimations:@"Button Release" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
	
	button.frame = CGRectMake(newLocation.x, newLocation.y, button.width, button.height);
	[button setTitle:[NSString stringWithFormat:@"%d",newPosition+1] forState:UIControlStateNormal];
	
	[UIView commitAnimations];
	
	// Re-arrange all the other comic buttons to their new locations
	[self shuffleGridAround:button];
	
	// Re-attange the slides order in data, so it can be saved
	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:gridView.subviews.count];
	for (int i=0; i<=gridView.subviews.count; i++) {
		for (ComicFrameButton *button in gridView.subviews) {
			if ([button isKindOfClass:[ComicFrameButton class]]) {
				NSInteger position = [self positionInGridForLocation:button.origin];
				if (position==i) {
					[frames addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									   [button imageForState:UIControlStateNormal],@"imageURL",
									   [NSNumber numberWithInt:button.slideID],@"slideID",
									   nil]];
					break;
				}
			}
		}
	}
	[_data setObject:frames forKey:@"frames"];
		
	if(lastPhase != UITouchPhaseMoved) {
		TTOpenURL([NSString stringWithFormat:@"tt://editcomic/%@/%d",_challenge,button.slideID]);
	} else {
		
		// Save the moved changes
		[connector saveComicDetailsForChallenge:_challenge data:_data];
	}


	lastPhase = touch.phase;
}

- (void)changeTitle:(NSString*)title {
	NSString *newTitle = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if (!newTitle.length) {
		newTitle = UNTITLED_LABEL;
	}
	
	[titleButton setTitle:newTitle forState:UIControlStateNormal];
	[titleButton sizeToFit];
	CGFloat maxWidth = previewButton.left-titleButton.left-7;
	if (titleButton.width > maxWidth) {
		titleButton.width = maxWidth;
	}
}

- (void)disableEditing:(BOOL)disable {
	// if disabled, prevent submitting and editing of the comics
	if (disable) {
		titleField.enabled = NO;
		detailField.userInteractionEnabled = NO;
		self.navigationItem.rightBarButtonItem.enabled = NO;
		disabledView.hidden = NO;
	} else {
		titleField.enabled = YES;
		detailField.userInteractionEnabled = YES;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		disabledView.hidden = YES;
	}
}


- (void)titlePressed:(id)sender {
	// Present/Hide the details view
	// When the view is shown, the title button changes to "Done"
	
	if (detailView.bottom == toolBar.top) {
		NSString *title = [titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[self changeTitle:title];
		if (!title) title = @"";
		
		NSString *detail = [detailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if (!detail) detail = @"";
		
		[_data setObject:title forKey:@"title"];
		[_data setObject:detail forKey:@"detail"];
		
		[titleButton setStylesWithSelector:@"toolBarButton:"];
	} else {
		[self changeTitle:@"Done"];
		[titleButton setStylesWithSelector:@"toolBarBlueButton:"];
	}
	
	[UIView beginAnimations:@"detailDraw" context:nil];
	[UIView setAnimationDuration:0.32];
	
	if (detailView.bottom == toolBar.top) {		
		detailView.top = toolBar.top;	
	} else {
		detailView.bottom = toolBar.top;
	}
	
	[UIView commitAnimations];
	
	[detailField resignFirstResponder];
	[titleField resignFirstResponder];
	
	// Save the title details
	[connector saveComicDetailsForChallenge:_challenge data:_data];
}

- (void)previewPressed:(id)sender {
	if (detailView.bottom == toolBar.top) {
		[self titlePressed:nil];
	}
	[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://previewcomic/%@",_challenge]] applyAnimated:YES]];
}

- (void)keyboardWillAppear:(BOOL)animated withBounds:(CGRect)bounds {
	
	if (animated) {
		[UIView beginAnimations:@"KeyboardAppearing" context:nil];
		[UIView setAnimationDuration:0.32];
	}
	
	self.view.bottom = TTScreenBounds().size.height-bounds.size.height-self.navigationController.navigationBar.bottom;
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds {	
	if ([titleField isEditing] || [detailField editing]) {
		return;
	}
}

- (void)keyboardWillDisappear:(BOOL)animated withBounds:(CGRect)bounds {
	if (animated) {
		[UIView beginAnimations:@"KeyboardAppearing" context:nil];
		[UIView setAnimationDuration:0.32];
	}
	
	self.view.top = 0;
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)submitPressed:(id)sender {
	if (detailView.bottom == toolBar.top) {
		[self titlePressed:nil];
	}
	
	if (![Connector getUserName].length) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No display name set" 
														message:@"Would you like to set your display name now?" 
													   delegate:self
											  cancelButtonTitle:@"No" 
											  otherButtonTitles:@"Yes",nil];
		[alert show];
		[alert release];
		
	} else if (!titleField.text.length) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Title" 
														message:@"Please enter a Title" 
													   delegate:nil
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submit this Comic?" 
														message:@"Submitting this comic will upload it to the server for all to view" 
													   delegate:self
											  cancelButtonTitle:@"Cancel" 
											  otherButtonTitles:@"Submit",nil];
		[alert show];
		[alert release];
	}
}

- (void)addButtonPressed:(id)sender {
	NSInteger nextFreeSlide = [[_data objectForKey:@"nextFreeSlide"] intValue];

	// Update current details
	[_data setObject:[NSNumber numberWithInt:nextFreeSlide+1] forKey:@"nextFreeSlide"];

	NSUInteger i = gridView.subviews.count-1;
		
	[self addCommicButton:i image:@"" slideID:nextFreeSlide];
	[self shuffleGridAround:nil];

	[connector saveComicDetailsForChallenge:_challenge data:_data];
}

- (void)showOverlay:(BOOL)show {
	if (show && !overlayView) {
		[detailField resignFirstResponder];
		[titleField resignFirstResponder];
		
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

- (void)animationDidStop:(id *)anim finished:(BOOL)flag {
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

#pragma mark gridView methods
// Calculates the location (top,left) for a grid item
- (CGPoint)locationForGridButtonInPosition:(NSInteger)position {
	CGFloat gridSize = gridView.width/2.0;
	
	CGFloat x = (position%2)*gridSize;
	CGFloat y = floor(position/2)*gridSize;

	return CGPointMake(x, y);
	
}

// Calculates the closest position for the given location
- (NSInteger)positionInGridForLocation:(CGPoint)location {
	CGFloat gridSize = gridView.width/2.0;
	
	NSInteger x = floor(location.x/gridSize);
	NSInteger y = floor(location.y/gridSize);
	if (y<0) y = 0;
	if (x<0) x = 0;
	NSInteger pos = x+y*2;
	if (pos > gridView.subviews.count-4) {
		pos = gridView.subviews.count-4;
	}
	
	return pos;
}

// Re-arrange the comic slides
- (void)shuffleGridAround:(TTButton*)gridButton {
	[self shuffleGridAround:gridButton animated:YES];
}
	
- (void)shuffleGridAround:(TTButton*)gridButton animated:(BOOL)animated {
	NSInteger newPosition = [[gridButton titleForState:UIControlStateNormal] intValue]-1;
	
	// Arrange the buttons to their appropriate locations
	NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:gridView.subviews.count];	
	for (TTButton *button in gridView.subviews) {
		// Ignore the currently selected button and the add Button, they are sorted out later
		if ([button isKindOfClass:[TTButton class]] && button!=addButton && gridButton!=button) {
			
			// Current position for the current button in question
			NSInteger currentPosition = [[button titleForState:UIControlStateNormal] intValue]-1;

			// Find the spot in the array for the current button (an O(N) sorting method)
			NSUInteger spot = 0;
			for (;spot<buttons.count;spot++) {
				NSInteger currentSpot = [[((TTButton*)[buttons objectAtIndex:spot]) titleForState:UIControlStateNormal] intValue]-1;
				if (currentPosition<currentSpot ) {
					break;
				}
			}
			[buttons insertObject:button atIndex:spot];
		}
	}
	
	// Add the selected button to its spot in the positions array
	NSInteger spot = 0;
	for (;spot<buttons.count;spot++) {
		if (newPosition<=spot ) {
			break;
		}
	}
	if (gridButton) [buttons insertObject:gridButton atIndex:spot];
	
	// Add the add button to the end
	[buttons insertObject:addButton atIndex:buttons.count];	
	
	
	// Re-arrange the view now
	if (animated) {
		[UIView beginAnimations:@"Buttons Shuffle" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.2];
	}
	
	spot = 0;
	for (;spot<buttons.count;spot++) {
		TTButton* button = [buttons objectAtIndex:spot];
		// Currently selected button, knows its position, so ignore it
		if (button!=gridButton) {
			// The All buttons (except add) will require renaming to their position number
			if (button != addButton) {
				[button setTitle:[NSString stringWithFormat:@"%d",spot+1] forState:UIControlStateNormal];
			}
			// Place the button to their appropriate location
			CGPoint newLocation = [self locationForGridButtonInPosition:spot];
			button.frame = CGRectMake(newLocation.x, newLocation.y, button.width, button.height);
		}
	}
	
	if (animated) {
		[UIView commitAnimations];
	}
	
	// Update the scroll view to accomidate the size of the button layout (if changed)
	gridView.contentSize = CGSizeMake(gridView.width, (gridView.width/2.0)*(ceil(buttons.count/2.0)));
	
	// The slides/frames
	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:buttons.count];		
	for (ComicFrameButton *button in buttons) {
		if ([button isKindOfClass:[ComicFrameButton class]]) {
			NSString *slidePic = [NSString stringWithFormat:@"documents://%@",slidePictureFile(_challenge,button.slideID)];
			[frames addObject:[NSDictionary dictionaryWithObjectsAndKeys:slidePic,@"imageURL",[NSNumber numberWithInt:button.slideID],@"slideID",nil]];
		}
	}
	[_data setObject:frames forKey:@"frames"];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// For the submit button
	NSString *button = [alertView buttonTitleAtIndex:buttonIndex];
	if ([button isEqualToString:@"Submit"]) {
		loading = [ActivityView loadingViewShowWithMessage:@"Preparing to Submit" percentage:0.0];
		[loading show];
		[connector submitCommicForChallenge:_challenge withData:_data];		
	
	// For the delete a slide button
	} else if ([button isEqualToString:@"Delete"]) {
		[comicButtonFocused removeFromSuperview];
		comicButtonFocused = nil;

		[self shuffleGridAround:nil];
		// Save the moved changes
		[connector saveComicDetailsForChallenge:_challenge data:_data];

	} else if ([button isEqualToString:@"Yes"]) {
		[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://settings"] applyAnimated:YES]];
		
	}	
}

#pragma mark ConnectorDelegate
- (void)connectorRequestDidFinishWithData:(id)data call:(NSString*)call {
	if ([data isKindOfClass:[NSDictionary class]]) {
		
		// Update/add the information to the view components
		if ([call isEqualToString:@"grabComicDetailsForChallenge"]) {
			NSDictionary *dict = data;
			[_data release];
			_data = [[NSMutableDictionary dictionaryWithDictionary:dict] retain];
			
			NSArray *subviews = [NSArray arrayWithArray:gridView.subviews];
			for (UIView *subview in subviews) {
				if ([subview isKindOfClass:[ComicFrameButton class]] && subview!=addButton) {
					[subview removeFromSuperview];
				}
			}
			
			// Title of this comic
			NSString *title = [_data valueForKey:@"title"];
			if (title.length) {
				[self changeTitle:title];
				titleField.text = title;
			}
			
			// Details about this comic
			NSString *detail = [_data valueForKey:@"detail"];
			if (detail.length) {
				detailField.text = detail;
			}	
			
			// The slides/frames
			NSArray *frames = [_data valueForKey:@"frames"];		
			NSInteger i = 0;
			for (NSDictionary *dict in frames) {
				NSInteger slideID = [[dict valueForKey:@"slideID"] intValue];
				NSString *imageURL = [dict objectForKey:@"imageURL"];
				
				[[TTURLCache sharedCache] removeURL:imageURL fromDisk:NO];
				[self addCommicButton:i image:imageURL slideID:slideID];
			}
			
			// Is this desabled?
			BOOL disabled = [[_data valueForKey:@"disabled"] boolValue];		
			if (disabled) {
				[self disableEditing:YES];
			} else {
				[self disableEditing:NO];
			}
			
			// Has already been submitted?
			BOOL submitted = [[_data valueForKey:@"submitted"] boolValue];		
			if (submitted) {
				self.navigationItem.rightBarButtonItem.title = @"Re-submit";
			} else {
				self.navigationItem.rightBarButtonItem.title = @"Submit";
			}
			
			BOOL shown = [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_SHOW];
			if (!shown) {
				[self showOverlay:YES];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_SHOW];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
		}
	}
	
	if ([call isEqualToString:@"submitCommicForChallenge"]) {
		
		if ([data isKindOfClass:[NSNumber class]]) {
			[connector grabComicDetailsForChallenge:_challenge];
			
			[loading hideWithDoneImage];
			loading = nil;
			
		} else if ([data isKindOfClass:[NSDictionary class]]) {
			[loading updateText:[data objectForKey:@"text"] percentage:[[data objectForKey:@"percentage"] floatValue]];
		}
	} 

	
	// Re-arrange all the buttons/slides (no selected slide/frame)
	[self shuffleGridAround:nil animated:NO];		
							   
	[self showLoading:NO];
	[self showError:NO];
}

- (void)connectorRequestDidFailWithError:(NSError*)error call:(NSString*)call {
	if ([call isEqualToString:@"submitCommicForChallenge"]) {		
		[connector grabComicDetailsForChallenge:_challenge];
		
		[loading hide];
		loading = nil;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedFailureReason]
														message:[error localizedDescription]
													   delegate:self
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	} else {
		// On an error, show the error
		errorView.subtitle = [error localizedDescription];
		errorView.title = [error localizedFailureReason];
		[errorView layoutSubviews];
		[self showLoading:NO];
		[self showError:YES];
	}
}

@end

#pragma mark -
@implementation ComicFrameButton
@synthesize slideID;

@end

#pragma mark -
@implementation DisabledView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_titleView.textColor = [UIColor whiteColor];
		_subtitleView.textColor = [UIColor whiteColor];
	}
	
	return self;
}

@end




