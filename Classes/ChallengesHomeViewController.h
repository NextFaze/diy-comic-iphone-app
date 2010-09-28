//
//  ChallengesHomeViewController.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
#import "Connector.h"
#import "GenericTableSource.h"
#import "OverlayView.h"

/*! 
 ChallengesHomeViewController lists all the challenges
 */
@interface ChallengesHomeViewController : TTTableViewController <ConnectorDelegate,TableSourceDelegate,OverlayViewDelegate> {
	NSUInteger _currentPage; /**< Page currently at */
	
	Connector *connector; /**< Connector to grab the data */
	NSMutableArray *tableItems; /**< List of table items */
	
	int newTableLoaded; /**< If the table needs to be cleared */
	
	OverlayView *overlayView; /**< Help Screen */
}

/*!
 Presents the overlay view
 @param show or not
 */
- (void)showOverlay:(BOOL)show;

@end
