//
//  ChallengeEntriesListViewController.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
#import "Connector.h"
#import "GenericTableSource.h"
#import "ChallengeEntriesCFViewController.h"

@interface ChallengeEntriesListViewController : TTTableViewController <ConnectorDelegate,TableSourceDelegate,ChallengeEntriesCFViewControllerDelegate> {
	NSString* _challenge; /**< Challenge ID of the challenge viewed */
	NSUInteger _currentPage; /**< Page currently at */
	
	Connector *connector; /**< Page currently at */
	NSMutableArray *tableItems; /**< List of table items */

	UIView *blackView; /**< View shown above all over views, used for blacking out */
	
	/*! Keeps track of the cover flow position on the cover flow view (when in landscape) */
	NSInteger coverFlowPosition;
}

@property(nonatomic,assign) NSInteger coverFlowPosition;

/*!
 Initialise the challenge view
 @param challenge ID for the view
 */
- (id)initWithChallenge:(NSString*)challenge;

@end
