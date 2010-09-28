//
//  ChallengeEntriesListViewController.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "ChallengeEntriesListViewController.h"
#import "TableItems.h"
#import "FlurryAPI.h"

@implementation ChallengeEntriesListViewController
@synthesize coverFlowPosition;

- (id)initWithChallenge:(NSString*)challenge {
	[FlurryAPI logEvent:@"CHALLENGE_ENTRIES" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:challenge,@"challenge",nil]];

	if (self = [super init]) {
		self.title = @"Entries";
		connector = [[Connector alloc] init];
		connector.delegate = self;
		
		_challenge = [challenge retain];
		_currentPage = 0;
		
		tableItems = [[NSMutableArray alloc] initWithCapacity:20];
		
		coverFlowPosition = 0;
		
		self.variableHeightRows = YES;
	}
	
	return self;
}

- (void)dealloc {
	connector.delegate = nil;
	[connector release];
	[_challenge release];
	[tableItems release];
	[blackView release];
	[blackView removeFromSuperview];
	[super dealloc];
}

- (void)loadView {
	[super loadView];
	[connector grabChallengeEntriesListForChallenge:_challenge page:_currentPage];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Create the blackout view
	// Size it to the maximum size of width/height, so that it'll black out 
	// at any rotation
	CGRect frame = [TTNavigator navigator].window.frame;
	CGFloat maxSize = frame.size.width;
	CGFloat height = frame.size.height;
	if (height>maxSize) {
		maxSize = height;
	}
	
	blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxSize, maxSize)];
	blackView.backgroundColor = [UIColor blackColor];
	blackView.alpha = 0;
	[self.navigationController.view addSubview:blackView];
	
}

// COVER FLOW DISABLED
/*
- (void)viewWillDisappear:(BOOL)animated {
	// If the view is dissapearing black the view out, if the
	// cover flow view is present
	if (!self.modalViewController) {
		if (animated) {
			[UIView beginAnimations:@"fade" context:nil];
			[UIView setAnimationDuration:0.6];
		}
		
		blackView.alpha = 0;
		
		if (animated) {
			[UIView commitAnimations];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// If the view is in landacape, present the cover flow view
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)&&animated) {
		ChallengeEntriesCFViewController *challengeViewController = [[ChallengeEntriesCFViewController alloc] initWithChallenge:_challenge];
		challengeViewController.delegate = self;
		[self presentModalViewController:challengeViewController animated:NO];
		[challengeViewController release];
	}
	
	// Fade to the cover flow view if in landscape
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:0.2];
	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		blackView.alpha = 1;
	} else {
		blackView.alpha = 0;
	}
	
	[UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Fade to the cover flow view if in landscape/
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:0.2];
	
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		blackView.alpha = 1;
	} else {
		blackView.alpha = 0;
	}

	[UIView commitAnimations];
	
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// If the view is in landacape, present the cover flow view
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		ChallengeEntriesCFViewController *challengeViewController = [[ChallengeEntriesCFViewController alloc] initWithChallenge:_challenge];
		challengeViewController.delegate = self;
		[self presentModalViewController:challengeViewController animated:NO];
		[challengeViewController release];
	}
}*/

#pragma mark TableSourceDelegate
- (void)loadNextPage {
	_currentPage++;
	[connector grabChallengeEntriesListForChallenge:_challenge page:_currentPage];
}

#pragma mark ChallengeEntriesCFViewControllerDelegate
- (void)setSelectedFrame:(NSInteger)frame {
	coverFlowPosition = frame;
}

- (NSInteger)getSelectedFrame {
	return coverFlowPosition;
}

#pragma mark ConnectorDelegate
- (void)connectorRequestDidFinishWithData:(id)data call:(NSString *)call {
	[data retain];
	
	if ([data isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = data;
				
		self.title = [dict valueForKey:@"title"];
		NSArray *items = [[dict valueForKey:@"items"] retain];

		// Remove the the MoreTable Cell if there is one
		if ([[tableItems lastObject] isKindOfClass:[TTTableMoreButton class]]) {
			[tableItems removeLastObject];
		}
		
		// Set the table items
		for (NSDictionary *item in items) {
			TableChallengeItem *tableItem = [TableChallengeItem itemWithTitle:[item valueForKey:@"title"]
																	 subtitle:[item valueForKey:@"user"]
																  description:[item valueForKey:@"detail"]
																	 imageURL:[item valueForKey:@"image"]
																 defaultImage:TTIMAGE(@"bundle://DefaultSmall.png")  
																   badgeImage:TTIMAGE([item valueForKey:@"badge"])  
																  statusImage:TTIMAGE([item valueForKey:@"status"])  
																		  URL:[NSString stringWithFormat:@"tt://viewcomic/%@/%@",[item valueForKey:@"id"],_challenge]];
			[tableItems addObject:tableItem];
			
		}

		
		// If there are more pages
		BOOL morePages = [[dict valueForKey:@"MorePages"] boolValue];
		if (morePages) {
			[tableItems addObject:[TTTableMoreButton itemWithText:@"Show More" subtitle:nil]]; 
		}
		
		self.dataSource = (ListDataSource*)[ListDataSource dataSourceWithItems:tableItems];
		((ListDataSource*)self.dataSource).delegate = self;
		
		if (!items.count) {
			[self showEmpty:YES];
			((TTErrorView*)self.emptyView).subtitle = @"Be the first to submit a comic for this challenge!";
			((TTErrorView*)self.emptyView).title = @"No Comics Have Been Submitted";
			((TTErrorView*)self.emptyView).image = TTIMAGE(@"bundle://DefaultSmall.png");
			[self.emptyView layoutSubviews];
			
		} else {
			[self showEmpty:NO];
		}
	}
	[data release];
}

- (void)connectorRequestDidFailWithError:(NSError *)error call:(NSString *)call {
	// On an error, show the error
	[self showLoading:NO];
	[self showError:YES];	
	((TTErrorView*)self.errorView).subtitle = [error localizedDescription];
	((TTErrorView*)self.errorView).title = [error localizedFailureReason];
	((TTErrorView*)self.errorView).image = TTIMAGE(@"bundle://Three20.bundle/images/error.png");
	[self.errorView layoutSubviews];	
}

@end
