//
//  ChallengeInfoViewController.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "ChallengeInfoViewController.h"
#import "StyleSheet.h"
#import "DIYComicAppDelegate.h"
#import "FlurryAPI.h"

@implementation ChallengeInfoViewController
@synthesize currentLocation=_currentLocation,desiredLocation=_desiredLocation;

- (id)initWithChallenge:(NSString*)challenge {
	[FlurryAPI logEvent:@"CHALLENGE_VIEW" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:challenge,@"challenge",nil]];

	if (self = [self init]) {
		_challenge = [challenge retain];
		
		connector = [[Connector alloc] init];
		connector.delegate = self;
		
		self.title = @"Challenge";
		
		_currentLocation = nil;
		_desiredLocation = nil;
		
		creationAllowed = NO;
		locationAllowed = NO;
		
		delegate = (DIYComicAppDelegate*)[UIApplication sharedApplication].delegate;
	}
	
	return self;
	
}

- (void)loadView {
	[super loadView];
	
	// The backgound image, off the challenge
	imageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	imageView.center = CGPointMake(self.view.center.x, self.view.center.y-50);
	imageView.alpha = 0.8;
	imageView.backgroundColor = self.view.backgroundColor;
	[self.view addSubview:imageView];
	[imageView release];
	
	// The white box where the challenge details will be placed
	TTView *whiteBox = [[TTView alloc] initWithFrame:CGRectMake(10, 10, self.view.width-20, self.view.bottom-140)];
	whiteBox.style = TTSTYLE(whiteBoxStyle);
	whiteBox.backgroundColor = [UIColor clearColor];
	[self.view addSubview:whiteBox];
	[whiteBox release];
	
	// The title
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 17, self.view.width-34, 0)];
	titleLabel.font = TTSTYLEVAR(titleFont);
	titleLabel.textColor = TTSTYLEVAR(titleColor);
	titleLabel.numberOfLines = 0;
	titleLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:titleLabel];
	[titleLabel release];
	
	// Scroll view to contain the challenge details
	scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(17, titleLabel.bottom, titleLabel.width, 0)];
	scrollView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:scrollView];
	[scrollView release];	
	
	// Details of the challenge
	detail = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.width, 0)];
	detail.font = TTSTYLEVAR(detailFont);
	detail.textColor = TTSTYLEVAR(detailColor);
	detail.numberOfLines = 0;
	detail.backgroundColor = [UIColor clearColor];
	[scrollView addSubview:detail];
	
	// Box to encapsulate all status information
	statusBox = [[TTView alloc] initWithFrame:CGRectMake(10, self.view.bottom-120, self.view.width-20, 110)];
	statusBox.style = TTSTYLE(statusBoxStyle);
	statusBox.backgroundColor = [UIColor clearColor];
	[self.view addSubview:statusBox];
	[statusBox release];
	
	// Status title
	UILabel *statusTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, 7, statusBox.width-20, 14)];
	statusTitle.font = [UIFont boldSystemFontOfSize:14];
	statusTitle.textColor = RGBCOLOR(255,255,255);
	statusTitle.text = @"Status";
	statusTitle.backgroundColor = [UIColor clearColor];
	[statusBox addSubview:statusTitle];
	[statusTitle release];
	
	// Opening timeframe title
	UILabel *openingTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, round(7+statusTitle.bottom), 37, 12)];
	openingTitle.font = [UIFont boldSystemFontOfSize:12];
	openingTitle.textColor = RGBCOLOR(255,255,255);
	openingTitle.text = @"Open:";
	openingTitle.backgroundColor = [UIColor clearColor];
	[statusBox addSubview:openingTitle];
	[openingTitle release];
	
	// The starting date/time for the challenge
	startDate = [[UILabel alloc] initWithFrame:CGRectMake(openingTitle.right+5, round(openingTitle.top), statusBox.width-(openingTitle.right+5+7), 12)];
	startDate.font = [UIFont systemFontOfSize:12];
	startDate.textColor = RGBCOLOR(255,255,255);
	startDate.text = @"0/0/0";
	startDate.backgroundColor = [UIColor clearColor];
	[statusBox addSubview:startDate];
	[startDate release];
	
	// Closing timeframe title
	UILabel *closingTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, round(7+openingTitle.bottom), openingTitle.width, 12)];
	closingTitle.font = [UIFont boldSystemFontOfSize:12];
	closingTitle.textColor = RGBCOLOR(255,255,255);
	closingTitle.text = @"Close:";
	closingTitle.backgroundColor = [UIColor clearColor];
	[statusBox addSubview:closingTitle];
	[closingTitle release];
	
	// Closing date/time for the challenge
	endDate = [[UILabel alloc] initWithFrame:CGRectMake(closingTitle.right+5, round(closingTitle.top), statusBox.width-(closingTitle.right+5+7), 12)];
	endDate.font = [UIFont systemFontOfSize:12];
	endDate.textColor = RGBCOLOR(255,255,255);
	endDate.text = @"0/0/0";
	endDate.backgroundColor = [UIColor clearColor];
	[statusBox addSubview:endDate];
	[endDate release];
	
	// Button to view challenge entries
	viewButton = [TTButton buttonWithStyle:@"greyButton:"];
	viewButton.frame = CGRectMake(7, statusBox.height-41, round((statusBox.width-7)/2.0-7), 34);
	[viewButton addTarget:self action:@selector(viewEntriesPressed:) forControlEvents:UIControlEventTouchUpInside];
	[viewButton setTitle:@"View Entries" forState:UIControlStateNormal];
	[statusBox addSubview:viewButton];
	
	// Buttone to go to the comic editor
	createButton = [TTButton buttonWithStyle:@"redButton:"];
	createButton.frame = CGRectMake(viewButton.right+7, statusBox.height-41, round((statusBox.width-7)/2.0-7), 34);
	[createButton addTarget:self action:@selector(createComicPressed:) forControlEvents:UIControlEventTouchUpInside];
	[createButton setTitle:@"Create Comic" forState:UIControlStateNormal];
	[statusBox addSubview:createButton];
	
	// Status label, shown on top of the status box (when challenge submitted)
	statusLabel = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.width-80, -7, 80, 80)];
	CGPoint centre = statusLabel.center;
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/3);
	statusLabel.transform = transform;
	statusLabel.center = centre;
	statusLabel.userInteractionEnabled = NO;
	statusLabel.image = TTIMAGE(@"bundle://Label-Done.png");
	[self.view addSubview:statusLabel];
	[statusLabel release];
	
	// Location Labels
	CGFloat left = round(statusBox.width/2.0+25);
	locationTitle = [[UILabel alloc] initWithFrame:CGRectMake(left, 7, statusBox.width-left-7, 14)];
	locationTitle.font = [UIFont boldSystemFontOfSize:14];
	locationTitle.textColor = RGBCOLOR(255,255,255);
	locationTitle.text = @"Location";
	locationTitle.hidden = YES;
	locationTitle.backgroundColor = [UIColor clearColor];
	[statusBox addSubview:locationTitle];
	[locationTitle release];
	
	locationStatus = [[UILabel alloc] initWithFrame:CGRectMake(locationTitle.left, locationTitle.bottom+7, locationTitle.width, 12)];
	locationStatus.font = [UIFont systemFontOfSize:12];
	locationStatus.backgroundColor = [UIColor clearColor];
	locationStatus.hidden = YES;
	locationStatus.text = @"Determining";
	locationStatus.textColor = [UIColor whiteColor];
	[statusBox addSubview:locationStatus];
	[locationStatus release];
	
	locationIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	locationIndicator.frame = CGRectMake(locationTitle.left, locationStatus.bottom+5, 18, 18);
	locationIndicator.hidden = YES;
	[statusBox addSubview:locationIndicator];
	[locationIndicator release];
	
	locationDistance = [[UILabel alloc] initWithFrame:CGRectMake(locationIndicator.right+5, locationStatus.bottom+7, locationTitle.width-5-locationIndicator.width, 12)];
	locationDistance.font = [UIFont systemFontOfSize:12];
	locationDistance.backgroundColor = [UIColor clearColor];
	locationDistance.hidden = YES;
	[statusBox addSubview:locationDistance];
	[locationDistance release];

	
	////////////////
	// Modal views
	
	// For when the view is loading
	loadingView = [[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleWhiteBox];
	loadingView.frame = self.view.frame;
	loadingView.text = @"Loading...";
	loadingView.hidden = YES;
	loadingView.backgroundColor = self.view.backgroundColor;
	[self.view addSubview:loadingView];
	[loadingView release];
	
	// For when an error occured
	errorView = [[TTErrorView alloc] init];
	errorView.title = @"Error";
	errorView.image = TTIMAGE(@"bundle://Three20.bundle/images/error.png");
	errorView.frame = self.view.frame;
	errorView.backgroundColor = TTSTYLEVAR(backgroundColor);
	errorView.hidden = YES;
	[self.view addSubview:errorView];
	[errorView release];
	
	[self showLoading:YES];
	
	// Grab data
	reloadData = NO;
	[connector grabChallenge:_challenge];
	[connector hasSavedDataForChallenge:_challenge];
}

- (void)showLoading:(BOOL)show {
	loadingView.hidden = !show;
}

- (void)showError:(BOOL)show {
	errorView.hidden = !show;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (_desiredLocation) {
		[delegate registerForLocationDelegate:self];
		[delegate.locationManager startUpdatingLocation]; 
		
	}
	
	// Grab data
	if (reloadData) {
		[connector grabChallenge:_challenge];
		[connector hasSavedDataForChallenge:_challenge];
		reloadData = YES;
	}
	
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (_desiredLocation) {
		[delegate removeFromLocationDelegate:self];
		[delegate.locationManager stopUpdatingLocation]; 
	}
}

- (void)viewEntriesPressed:(id)sender {
	[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://entries/%@",_challenge]] applyAnimated:YES]];
}

- (void)createComicPressed:(id)sender {
	[[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:[NSString stringWithFormat:@"tt://makecomic/%@",_challenge]] applyAnimated:YES]];
	reloadData = YES;
}

- (void)updateLocation {
	// If there is no desired location, ignore
	if (!_desiredLocation) {
		locationAllowed = YES;
		
	} else if ([connector inLocation:_desiredLocation current:_currentLocation]) {		
		[delegate.locationManager stopUpdatingLocation]; 
		locationAllowed = YES;
		
		locationStatus.text = @"In Location";
		locationDistance.text = @"✔";
		locationDistance.textColor = [UIColor greenColor];
		locationDistance.left = locationIndicator.left;
		locationDistance.top = locationStatus.top;
		locationStatus.left = locationIndicator.right;
		[locationIndicator stopAnimating];
		
	} else {
		locationStatus.text = @"Out of Location";
		locationDistance.textColor = [UIColor whiteColor];
		locationDistance.left = locationIndicator.right+5;
		locationDistance.top = locationIndicator.top+2;
		locationStatus.left = locationIndicator.left;
		
		double distance = [_desiredLocation getDistanceFrom:_currentLocation]-_desiredLocation.horizontalAccuracy;
		if (distance>=1000) {
			locationDistance.text = [NSString stringWithFormat:@"%.0fkm away",distance/1000.0];
		} else {
			locationDistance.text = [NSString stringWithFormat:@"%.1fm away",distance];
		}
		locationAllowed = NO;
	}

	[self updateCreation];
}

- (void)updateCreation {
	if (creationAllowed && locationAllowed || hasData) {
		createButton.enabled = YES;
		createButton.alpha = 1.0;
	} else {
		createButton.enabled = NO;
		createButton.alpha = 0.5;			
	}	
}

- (void)dealloc {
	connector.delegate = nil;
	[connector release];
	[_challenge release];
	delegate = nil;
	[_currentLocation release];
	[_desiredLocation release];
	[super dealloc];
}

#pragma mark ConnectorDelegate

- (void)connectorRequestDidFailWithError:(NSError *)error call:(NSString *)call {
	// On an error, show the error
	errorView.subtitle = [error localizedDescription];
	errorView.title = [error localizedFailureReason];
	[errorView layoutSubviews];
	[self showLoading:NO];
	[self showError:YES];
}

- (void)connectorRequestDidFinishWithData:(id)data call:(NSString *)call {
	if ([call isEqualToString:@"grabChallenge"]) {		
		NSDictionary *dict = data;
		
		// The Name of the challenge
		titleLabel.text = [dict valueForKey:@"title"];
		[titleLabel sizeToFit];
		
		// Adjust the scroll view to fit between the title and status
		scrollView.top = titleLabel.bottom+4;
		scrollView.height = statusBox.top-17-scrollView.top;
		
		// Set the background image (if there is one)
		imageView.urlPath = [dict valueForKey:@"image"];
		
		// Detail Box
		detail.text = [dict valueForKey:@"detail"];
		[detail sizeToFit];
		detail.width = scrollView.width;		
		scrollView.contentSize = CGSizeMake(scrollView.width, detail.bottom);	
		
		// Grab the start and ending dates
		NSDate *startingDate = [dict valueForKey:@"startDate"];
		NSDate *endingDate = [dict valueForKey:@"endDate"];
		
		// Work out how much time to go	
		NSDateFormatter *dF = [[NSDateFormatter alloc] init];
		[dF setDateFormat:@"HH:mma dd/MM/YYYY"];
		endDate.text = [dF stringFromDate:endingDate];
		startDate.text = [dF stringFromDate:startingDate];
		
		statusLabel.hidden = ![[dict valueForKey:@"status"] boolValue];
		
		// Enable the create button?
		creationAllowed = [[dict valueForKey:@"allowCreation"] boolValue];
		
		// Show error if wrong version
		NSString *version = [dict valueForKey:@"allowVersion"];
		if (![version boolValue]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Newer App Required" 
															message:@"To submit challenges, please update this app using the App Store." 
														   delegate:nil
												  cancelButtonTitle:@"Ok" 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		
		// Grab location details
		self.desiredLocation = [dict valueForKey:@"location"];

		if (_desiredLocation) {
			locationStatus.hidden = NO;
			locationTitle.hidden = NO;
			locationDistance.hidden = NO;
			locationIndicator.hidden = NO;
			[locationIndicator startAnimating];
			
			// Register for location
			[delegate registerForLocationDelegate:self];
			[delegate.locationManager startUpdatingLocation];
		}
		locationAllowed = _desiredLocation==nil;
		
		[self showLoading:NO];
		[self showError:NO];
		
	} else if ([call isEqualToString:@"hasSavedDataForChallenge"]) {
		hasData = [[data valueForKey:@"hasData"] boolValue];
		if (hasData) {
			[createButton setTitle:@"Edit Comic" forState:UIControlStateNormal];
		} else {
			[createButton setTitle:@"Create Comic" forState:UIControlStateNormal];
		}

	}
	
	[self updateCreation];
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	self.currentLocation = newLocation;
	[self updateLocation];
}

@end
