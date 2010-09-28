//
//  ChallengeEntriesCFViewController.h
//  DIYComic
//
//  Created by Andreas Wulf on 16/04/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
#import "AFOpenFlowView.h"
#import "Connector.h"

/*!
 ChallengeEntriesCFViewControllerDelegate for the ChallengeEntriesCFViewController
 */
@protocol ChallengeEntriesCFViewControllerDelegate

/*! 
 Sets the selected frame
 @param frame index selected
 */
- (void)setSelectedFrame:(NSInteger)frame;

/*!
 Get the selcted frame
 @result selected frame index
 */
- (NSInteger)getSelectedFrame;

@end



#pragma mark -
/*!
 ChallengeEntriesCFViewController is a cover flow representation of ChallengeEntriesListViewController 
 used when in the device is in landscape mode
 */
@interface ChallengeEntriesCFViewController : TTModelViewController <ConnectorDelegate, AFOpenFlowViewDataSource, AFOpenFlowViewDelegate> {
	AFOpenFlowView *ofView; /**< The cover flow view */
	id<ChallengeEntriesCFViewControllerDelegate> _delegate; /**< Delegate for this view */
	
	Connector *connector; /**< Page currently at */
	
	NSString* _challenge; /**< Challenge ID of the challenge viewed */
	NSUInteger _currentPage; /**< Current page shown */
	
	TTActivityLabel *loadingView; /**< View shown while data loads */
	TTErrorView *errorView; /**< View shown if there was an error loading data */
	
	NSDictionary *_data; /**< Data to be shown */
	
	UILabel *titleLabel; /**< Title of this view */
	UILabel *selectedLabel; /**< Selected comic title */
}

@property(nonatomic,assign) id<ChallengeEntriesCFViewControllerDelegate> delegate;

/*!
 Initialise the challenge view
 @param challenge ID for the view
 */
- (id)initWithChallenge:(NSString*)challenge;

@end
