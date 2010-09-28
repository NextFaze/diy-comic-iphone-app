//
//  ChallengeEntriesCFViewController.m
//  DIYComic
//
//  Created by Andreas Wulf on 16/04/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "ChallengeEntriesCFViewController.h"
#import "ChallengeEntriesListViewController.h"

@implementation ChallengeEntriesCFViewController
@synthesize delegate = _delegate;

- (id)initWithChallenge:(NSString*)challenge {
	if (self = [super init]) {
		self.title = @"Entries";
		connector = [[Connector alloc] init];
		connector.delegate = self;
		
		_challenge = [challenge retain];
		_currentPage = 0;
		
		_data = nil;
	}
	
	return self;
}

- (void)loadView {
	// The cover flow view
	ofView = [[AFOpenFlowView alloc] init];
	ofView.dataSource = self;
	ofView.viewDelegate = self;
	[ofView setSelectedCover:[_delegate getSelectedFrame]];
	CGRect origframe = TTScreenBounds();
	self.view = ofView;
	
	// Title of this view
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, origframe.size.width, 40)];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
	titleLabel.text = @"Hello World";
	[self.view addSubview:titleLabel];
	
	// Name of the selected items
	selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, origframe.size.height-60, origframe.size.width, 40)];
	selectedLabel.textColor = [UIColor whiteColor];
	selectedLabel.backgroundColor = [UIColor clearColor];
	selectedLabel.textAlignment = UITextAlignmentCenter;
	selectedLabel.text = @"";
	[self.view addSubview:selectedLabel];
	
	////////////////
	// Modal views
	loadingView = [[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleBlackBox];
	loadingView.frame = origframe;
	loadingView.text = @"Loading...";
	loadingView.hidden = YES;
	loadingView.backgroundColor = self.view.backgroundColor;
	[self.view addSubview:loadingView];
	[loadingView release];
	
	errorView = [[TTErrorView alloc] init];
	errorView.title = @"Error";
	errorView.image = TTIMAGE(@"bundle://Three20.bundle/images/error.png");
	errorView.frame = origframe;
	errorView.hidden = YES;
	errorView.backgroundColor = TTSTYLEVAR(backgroundColor);
	[self.view addSubview:errorView];
	[errorView release];
		
	[self showLoading:YES];

	[connector grabChallengeEntriesListForChallenge:_challenge page:_currentPage];
}

- (void)showLoading:(BOOL)show {
	loadingView.hidden = !show;
}

- (void)showError:(BOOL)show {
	errorView.hidden = !show;
}

- (void)setTitle:(NSString *)title {
	[super setTitle:title];
	titleLabel.text = title;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// Hide self when exiting portrait view
	if(!UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		[self dismissModalViewControllerAnimated:NO];
	}
}

- (void)dealloc {
	connector.delegate = nil;
	[connector release];
	[ofView release];
	[titleLabel release];
	[selectedLabel release];
	[_challenge release];
	[super dealloc];
}

#pragma mark AFOpenFlowViewDataSource
- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
	// Grab Link from _data and generate it into a picture, and then set the picture
	[ofView setImage:TTIMAGE(@"bundle://DefaultSmall.png") forIndex:index];
}

- (UIImage *)defaultImage {
	// The default picture shown while the real picture loads
	return TTIMAGE(@"bundle://DefaultLarge.png");
}

#pragma mark AFOpenFlowViewDelegate
- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
	// Tell the delegate, what was selected
	[_delegate setSelectedFrame:index];
	
	// Update the selectedlabel to the selected
	selectedLabel.text = [[[_data valueForKey:@"items"] objectAtIndex:index] valueForKey:@"title"];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidTap:(int)index {
	// Tapped on an image? Open the view for the image
	[[TTNavigator navigator].topViewController dismissModalViewControllerAnimated:NO];
	[[TTNavigator navigator] openURLAction:
	 [[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://viewcomic/%d",index]] applyAnimated:YES]];
}

#pragma mark ConnectorDelegate
- (void)connectorRequestDidFinishWithData:(id)data call:(NSString *)call {
	[data retain];	
	
	if ([data isKindOfClass:[NSDictionary class]]) {
		NSDictionary *oldData = _data;
		_data = data;
		[oldData release];
		
		self.title = [_data valueForKey:@"title"];
		NSArray *items = [[_data valueForKey:@"items"] retain];
		ofView.numberOfImages = items.count;
		
		// Restore selected position
		[ofView setSelectedCover:[_delegate getSelectedFrame]];
		selectedLabel.text = [[[_data valueForKey:@"items"] objectAtIndex:[_delegate getSelectedFrame]] valueForKey:@"title"];
		
		[self showLoading:NO];
		[self showError:NO];
	}
}

- (void)connectorRequestDidFailWithError:(NSError *)error call:(NSString *)call {
	// On an error, show the error
	errorView.subtitle = [error localizedDescription];
	errorView.title = [error localizedFailureReason];
	[errorView layoutSubviews];
	[self showLoading:NO];
	[self showError:YES];	
}

@end
