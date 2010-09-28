//
//  Connector.h
//  DIYComic
//
//  Created by Andreas Wulf on 6/04/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
#import "ObjectiveFlickr.h"
#import "FlickrRequest.h"
#import <CoreLocation/CoreLocation.h>

#define slidePictureFile(challengeID,slideID) [NSString stringWithFormat:@"Comic%@Slide%d.png",challengeID,slideID]
#define slideDataFile(challengeID,slideID) [NSString stringWithFormat:@"Comic%@Slide%d.plist",challengeID,slideID]
#define challengeComicFile(challengeID) [NSString stringWithFormat:@"ComicChallenge%@.plist",challengeID]
#define DIYComicErrorDomain @"com.DIYComic"

/*!
 ConnectorDelegate protocole to return data back to the caller
 */
@protocol ConnectorDelegate



/*!
 Called when data has finished loading
 @param data recieved
 @param call which was called to retrieve this data
 */
- (void)connectorRequestDidFinishWithData:(id)data call:(NSString*)call;

/*!
 Called when data had dificulties loading
 @param error recieved
 @param call which was called to retrieve this error
 */
- (void)connectorRequestDidFailWithError:(NSError*)error call:(NSString*)call;

@end

/* Connector
 Contains all the logic and data handeling for this application
 */
@interface Connector : NSObject <OFFlickrAPIRequestDelegate> {
	id<ConnectorDelegate> _delegate; /**< Delegate */
	
	FlickrRequest *_flickerRequest;
	OFFlickrAPIContext *_flickerContext;
	
	NSString *_returningSelector;
	NSString *_challengeQueried;
	id _passingInfo;
	NSInteger slidesToUpload;
	
	NSDate *_serverTime;
}

@property(nonatomic,readonly) FlickrRequest *flickerRequest;
@property(nonatomic,readonly) OFFlickrAPIContext *flickerContext;
@property(nonatomic,retain) NSDate *serverTime;
@property(assign,nonatomic) id<ConnectorDelegate> delegate;

/////////////////////////////
// Convienence 
- (NSDictionary*)extractItemsFromString:(NSString*)statusItems;
- (NSDictionary*)extractDetailSplit:(NSString*)details;
- (NSString*)badgeFromStatusItems:(NSDictionary*)statusItems;
- (NSString*)openFromStatusItems:(NSDictionary*)statusItems;
- (NSString*)timerFromStatusItems:(NSDictionary*)statusItems;
- (NSString*)challengeIDFromFlikrID:(NSString*)flikrID;
- (NSString*)flickrIDFromChallengeID:(NSString*)challengeID;
- (BOOL)submittedChallenge:(NSString*)challengeID;
- (void)setSubmittedChallenge:(NSString*)challengeID setID:(NSString*)setID;
+ (NSString*)getUserName;
+ (void)setUserName:(NSString*)userName;
- (BOOL)inLocation:(CLLocation*)desiredLocation current:(CLLocation*)currentLocation;

/*!
 Encoded Data in base64 for transmisison
 @result base64 Encoding of theData
 */
+ (NSString*)base64forData:(NSData*)theData;

/////////////////////////////
// Remote Services
// These return their data using delegate calls, as downloading information take time

- (void)grabChallengeListPage:(NSUInteger)pageNo;
- (void)grabChallenge:(NSString*)challengeID;
- (void)grabChallengeEntriesListForChallenge:(NSString*)challengeID page:(NSUInteger)pageNo;
- (void)grabChallengeEntry:(NSString*)entryID;

- (void)submitCommicForChallenge:(NSString*)challengeID;
- (void)submitCommicForChallenge:(NSString*)challengeID withData:(NSDictionary*)data;

/////////////////////////////
// Local Services
// These return their details using the delegate calls, as generating some of the info will be slow

- (void)grabComicDetailsForChallenge:(NSString*)challengeID;
- (void)grabComicSlideDetailsForChallenge:(NSString*)challengeID slide:(NSUInteger)slideID;

- (void)hasSavedDataForChallenge:(NSString*)challengeID;

- (void)saveComicDetailsForChallenge:(NSString*)challengeID data:(NSDictionary*)data;
- (void)saveComicSlideDetailsForChallenge:(NSString*)challengeID slide:(NSUInteger)slideID boubleItems:(NSArray*)items image:(UIImage*)image;
- (void)createNewSlideForChallenge:(NSString*)challengeID;

- (void)activateUserName:(NSString*)userName;
- (void)deactivateUserName; 
- (void)grabUserName;

@end
