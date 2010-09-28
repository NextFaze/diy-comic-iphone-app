//
//  ComicViewerViewController.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
#import "Connector.h"
#import "ComicScrollView.h"
#import <MessageUI/MessageUI.h>

#import "FBConnect.h"

/*!
 ComicViewerViewController displays the comic, either:
 Previews the comic in its current state for a challenge a user is partaking
 Presents a comic entry from other users
 */
@interface ComicViewerViewController : TTModelViewController <MFMailComposeViewControllerDelegate,ConnectorDelegate,ComicScrollViewDataSource,FBSessionDelegate,FBDialogDelegate,UIActionSheetDelegate> {
	NSString* _challenge; /**< Challenge ID of the challenge viewed (for preview mode) */
	NSString* _comic; /**< Comic IDviewed (for comic view mode)*/
	
	Connector *connector; /**< Connector to grab the data */
	
	TTActivityLabel *loadingView; /**< View shown while data loads */
	TTErrorView *errorView; /**< View shown if there was an error loading data */
	
	ComicScrollView* _scrollView; /**< Scroll view for the details */
		
	NSDictionary* _data; /**< Data to be shown */
	
	NSString* _viewTitle; /**< Displays Title of the comic */
	
	UIScrollView *_descView; /**< Container to the description of the comic */
	TTStyledTextLabel *_descLabel; /**< Description of the comic */
	
	Facebook *_facebook; /**< Keeps track of the current facebook session */
	P31LoadingView *_p31LoadingView; /**< Loading view for activity */
}

/*!
 Updates the title to the whats in the current data
 */
- (void)updatePageTitle;

/*!
 Initialises the view to show a comic entry
 @param comicID of the entry
 @param challengeID of the entry
 */
- (id)initWithComic:(NSString*)comicID challenge:(NSString*)challengeID;
// Legacy to not crash saved state apps
- (id)initWithComic:(NSString*)comicID;


/*!
 Initialises the view to preview the comic for the challenge
 @param challengeID to preview
 */
- (id)initWithChallenge:(NSString*)challengeID;

@end
