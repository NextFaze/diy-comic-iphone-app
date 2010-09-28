//
//  FlickrRequest.h
//  DIYComic
//
//  Created by Andreas Wulf on 19/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ObjectiveFlickr.h"
#define DATA_CACHE @"datacache"


@interface FlickrRequest : OFFlickrAPIRequest {
	NSString *cacheURL; /**< URL that is currently being processed */
	BOOL blockCache; /**< If the current call doesn't allow cache */
	
}

@property(nonatomic,retain) NSString *cacheURL;

/*!
 Tells all new requests to fetch data from the server (if possible)
 */
+ (void)clearCache;

/*!
 Asks if the request should get data from ther server
 @param url for cache
 @result if the a new instance of the requested URL should be downloaded
 */
+ (BOOL)shouldGetNewData:(NSString*)url;

/*!
 Tells to refresh the specified URL on next call
 @param url for cache
 */
+ (void)shouldGetNew:(NSString*)url;

/*!
 Set the URL as saved/cached data
 */
+ (void)setAsSaved:(NSString*)url;

/*!
 Flickr API call that can be specified to use cached data or not
 @param inMethodName / API name
 @param cache if it should use cached if possible
 @param inArguments for the API call
 @result if sucessful
 */
- (BOOL)callAPIMethodWithGET:(NSString *)inMethodName cache:(BOOL)cache arguments:(NSDictionary *)inArguments;

@end
