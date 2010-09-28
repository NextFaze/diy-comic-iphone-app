//
//  ChallengeInfoViewController.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
#import "Connector.h"

#import <CoreLocation/CoreLocation.h>
@class DIYComicAppDelegate;

/*!
 ChallengeInfoViewController displays all the information for the selected challenge
 */
@interface ChallengeInfoViewController : TTModelViewController <ConnectorDelegate,CLLocationManagerDelegate> {
	Connector *connector; /**< Connector to grab the data */
	NSString *_challenge; /**< Challenge ID of the challenge viewed */
	
	UIScrollView *scrollView; /**< Scroll view for the details */
	TTView *statusBox; /**< Status box */
	
	UILabel *titleLabel; /**< Name of the challenge */
	TTImageView *imageView; /**< Challenge picture */
	UILabel *detail; /**< Details about the challenge */
	
	UILabel *startDate; /**< Starting date label */
	UILabel *endDate; /**< Ending date label */
	
	UIImageView *statusLabel; /**< Status picture */
	
	UILabel *locationTitle; /**< Location title label */
	UILabel *locationStatus; /**< Location status */
	UILabel *locationDistance; /**< Location distance */
	UIActivityIndicatorView *locationIndicator; /**< Indicates when location updating*/
	
	TTButton *viewButton; /**< Button to view entries */
	TTButton *createButton; /**< Button to create a comic/entry */
	
	TTActivityLabel *loadingView; /**< View shown while data loads */
	TTErrorView *errorView; /**< View shown if there was an error loading data */
	
	DIYComicAppDelegate *delegate; /**< App delegate */
	
	CLLocation *_currentLocation; /**< Current iPhone location */
	CLLocation *_desiredLocation; /**< Location required for the challenge */
	
	BOOL creationAllowed; /**< If creating a comic is allowed */
	BOOL locationAllowed; /**< If the current location is valid */
	BOOL hasData; /**< If there is a comic saved for the challenge */
	
	BOOL reloadData; /**< Checks if new data should be loaded on view did appear */
}

@property(nonatomic,retain) CLLocation *desiredLocation;
@property(nonatomic,retain) CLLocation *currentLocation;

/*!
 Initialise the challenge view
 @param challenge ID for the view
 */
- (id)initWithChallenge:(NSString*)challenge;

/*!
 Updates the view with the current location information
 */
- (void)updateLocation;

/*!
 Update creation button status
 */
- (void)updateCreation;

@end
