//
//  ChallengesHomeViewController.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "ChallengesHomeViewController.h"
#import "TableItems.h"

#define FIRST_SHOW @"FIRST_SHOW_HOME"
#define OVERLAY_FILE @"OverlayHome.png"

@implementation ChallengesHomeViewController

- (id)init {
	if (self = [super init]) {
		self.title = @"Challenges";
		connector = [[Connector alloc] init];
		connector.delegate = self;
		_currentPage = 0;		
		tableItems = [[NSMutableArray alloc] initWithCapacity:20];
		
		newTableLoaded = 0;
	}
	
	self.variableHeightRows = YES;
	
	UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithTitle:@"Profile" 
																 style:UIBarButtonItemStylePlain 
																target:@"tt://settings" 
																action:@selector(openURLFromButton:)];
	self.navigationItem.rightBarButtonItem = settings;
	[settings release];
	
	// The info button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	button.width = 30;
	[button addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	self.navigationItem.leftBarButtonItem = infoButton;
	[infoButton release];
	
	return self;
}

- (void)dealloc {
	connector.delegate = nil;
	[connector release];
	[tableItems release];
	TT_RELEASE_SAFELY(overlayView);
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	newTableLoaded++;
	[connector grabChallengeListPage:_currentPage];
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


#pragma mark TableSourceDelegate
- (void)loadNextPage {
	_currentPage++;
	[connector grabChallengeListPage:_currentPage];
}

#pragma mark ConnectorDelegate
- (void)connectorRequestDidFinishWithData:(id)data call:(NSString *)call {
	[data retain];
	
	if ([data isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = data;
		
		NSArray *items = [dict valueForKey:@"items"];
		
		// Data being refreshed
		if (newTableLoaded) {
			[tableItems removeAllObjects];
			
		// Remove the the MoreTable Cell if there is one
		} else if ([[tableItems lastObject] isKindOfClass:[TTTableMoreButton class]]) {
			[tableItems removeLastObject];
		}
		
		// Add all the table Items
		for (NSDictionary *item in items) {
			TableChallengeItem *tableItem = [TableChallengeItem itemWithTitle:[item valueForKey:@"title"]
																	 subtitle:[item valueForKey:@"time"]
																  description:[item valueForKey:@"summary"]
																	 imageURL:[item valueForKey:@"image"]
																 defaultImage:TTIMAGE(@"bundle://DefaultSmall.png")  
																   badgeImage:TTIMAGE([item valueForKey:@"badge"])  
																  statusImage:TTIMAGE([item valueForKey:@"status"])  
																		  URL:[NSString stringWithFormat:@"tt://challenge/%@",[item valueForKey:@"id"]]];
			[tableItems addObject:tableItem];
		}
		
		// If there are more pages
		BOOL morePages = [[dict valueForKey:@"MorePages"] boolValue];
		if (morePages) {
			[tableItems addObject:[TTTableMoreButton itemWithText:@"Show More" subtitle:nil]]; 
		}
		
		self.dataSource = (ListDataSource*)[ListDataSource dataSourceWithItems:tableItems];
		((ListDataSource*)self.dataSource).delegate = self;
		newTableLoaded--;
		
		BOOL shown = [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_SHOW];
		if (!shown) {
			[self showOverlay:YES];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_SHOW];
			[[NSUserDefaults standardUserDefaults] synchronize];
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
