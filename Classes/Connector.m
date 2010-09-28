//
//  Connector.m
//  DIYComic
//
//  Created by Andreas Wulf on 6/04/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "Connector.h"
#import "NSDate.h"
#import "ObjectiveFlickerAdditions.h"
#import <CoreLocation/CoreLocation.h>

#import "Konstants.h"


//#import "FlickrAPIKey.h" // API Key in Delegate Header
#import "DIYComicAppDelegate.h"

#import "FlurryAPI.h"

#define ITEMS_PER_PAGE @"20"

NSString * md5( NSString *str ) {
	
	const char *cStr = str.UTF8String;
	
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5( cStr, strlen(cStr), result );
	
	return [NSString 
			
			stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
			];
	
}

@implementation Connector
@synthesize delegate=_delegate, serverTime=_serverTime;

- (id)init {
	if (self = [super init]) {
		_flickerRequest = nil;
		_flickerContext = nil;
		_returningSelector = nil;
		_challengeQueried = nil;
		_passingInfo = nil;
		_serverTime = nil;
	}
	
	return self;
}

- (FlickrRequest*)flickerRequest {
	if (!_flickerRequest) {
		_flickerRequest = [[FlickrRequest alloc] initWithAPIContext:self.flickerContext];
		[_flickerRequest setRequestTimeoutInterval:60];
		_flickerRequest.delegate = self;
	}
	
	return _flickerRequest;
}

- (OFFlickrAPIContext*)flickerContext {
	if (!_flickerContext) {
		_flickerContext = [[OFFlickrAPIContext alloc] initWithAPIKey:kOBJECTIVE_FLICKR_API_KEY sharedSecret:kOBJECTIVE_FLICKR_API_SHARED_SECRET];
		[_flickerContext setAuthToken:kOBJECTIVE_FLICKR_API_AUTH_TOKEN];
	}
	
	return _flickerContext;
}


- (void)dealloc {
	_delegate = nil;
	_flickerRequest.delegate = nil;
	[_flickerRequest cancel];
	[_flickerRequest release];
	[_flickerContext release];
	[_serverTime release];
	[super dealloc];
}


#pragma mark -
#pragma mark Tools

- (NSDate*)serverTime {
	if (!_serverTime) {
		return [NSDate date];
	}
	return _serverTime;
}

+ (NSString*)getUserName {
	NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
	return (userName ? userName : @"");
}

+ (void)setUserName:(NSString*)userName {
	[[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"userName"];
}

- (NSError*)makeErrorWithTitle:(NSString*)title description:(NSString*)description {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  description,NSLocalizedDescriptionKey,
							  title,NSLocalizedFailureReasonErrorKey, 
							  nil]; 
	
	return [NSError errorWithDomain:DIYComicErrorDomain code:0 userInfo:userInfo];
}


- (NSString*)stringForTag:(NSString*)tag contents:(NSString*)contents{
	NSRange startRange = [contents rangeOfString:tag];
	NSInteger start = startRange.location+startRange.length;
	
	if (startRange.length) {
		
		NSRange endRange = [contents rangeOfString:@";" options:0 range:NSMakeRange(start,contents.length-start)];
		NSInteger end =  endRange.location-start;

		if (endRange.length || start+end<contents.length) {
			return [contents substringWithRange:NSMakeRange(start, end)];
		}
	}
	
	return @"";
}

- (NSDictionary*)extractEntryItemDetailsFromString:(NSString*)statusItems {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
								 [self stringForTag:@"UID:" contents:statusItems],@"UID",
								 [self stringForTag:@"THUMB:" contents:statusItems],@"thumb",
								 [self stringForTag:@"IMAGE:" contents:statusItems],@"image",
								 nil];
}

- (NSDictionary*)extractItemsFromString:(NSString*)statusItems {	
	NSString *dateFormat = @"yyyy-MM-dd HH:mm zzz";
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:dateFormat];
	
	NSDate *startDate = [dateFormatter dateFromString:[self stringForTag:@"START:" contents:statusItems]];
	NSDate *endDate = [dateFormatter dateFromString:[self stringForTag:@"END:" contents:statusItems]];	
	if (!startDate) startDate = [NSDate distantPast];
	if (!endDate) endDate = [NSDate distantFuture];
	
	NSString* versionStr = [self stringForTag:@"VERSION:" contents:statusItems];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
						  startDate,@"startDate",
						  endDate,@"endDate",
						  versionStr,@"version",
						  nil];
	//[NSNumber numberWithFloat:[[self stringForTag:@"VERSION:" contents:statusItems] doubleValue]],@"version",
	
	NSString *locationString = [self stringForTag:@"LOCATION:" contents:statusItems];
	if (locationString.length>2) {
		NSString *commaSeperated = [locationString substringWithRange:NSMakeRange(1, locationString.length-2)];
		NSArray *array = [commaSeperated componentsSeparatedByString:@","];
		if (array.count == 3) {
			CLLocationCoordinate2D coord = {[[array objectAtIndex:0] doubleValue],[[array objectAtIndex:1] doubleValue]};
			CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord altitude:0 horizontalAccuracy:[[array objectAtIndex:2] doubleValue] verticalAccuracy:0 timestamp:[NSDate date]];
			[dict setObject:location forKey:@"location"];
		}
	}
	
	[dateFormatter release];
	
	return dict;
}



- (NSDictionary*)extractDetailSplit:(NSString*)details {
	NSArray *descComponents = [details componentsSeparatedByString:@"---"];
	NSString *description = [descComponents objectAtIndex:0];
	NSString *statusItems = [descComponents lastObject];
	
	if (!description) description = @"";
	if (!statusItems) statusItems = @"";
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  description,@"description",
						  statusItems,@"statusItems",
						  nil];
	
	return dict;
}

/*
 - NewBadge : current_time < start_time
 - OpenBadge : current_time > start_time && current_time < finish_time
 - TimeBadge: current_time >  finish_time - 0.2 * (finish_time - start_time) (ie. within 20% of finish_time)
 - ClosedBadge: current_time > finish_time 
 */
- (NSString*)badgeFromStatusItems:(NSDictionary*)statusItems {
	NSDate *start = [statusItems objectForKey:@"startDate"];
	NSDate *end = [statusItems objectForKey:@"endDate"];
	NSDate *current = self.serverTime;
	
	if ([current compare:start] < 0) {
		return @"bundle://Badge-New.png";
	
	} else if ([current compare:end] >=0 ) {
		return @"bundle://Badge-Close.png";
	
	} else {
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSInteger length = [[calendar components:NSMinuteCalendarUnit fromDate:start toDate:end options:0] minute];
		NSInteger timeLeft = [[calendar components:NSMinuteCalendarUnit fromDate:current toDate:end options:0] minute];
		
		if (timeLeft < length*0.2) {
			return @"bundle://Badge-Time.png";
		} else {
			return @"bundle://Badge-Open.png";
		}

	}
	
	return @"";
}

- (NSString*)timerFromStatusItems:(NSDictionary*)statusItems {
	NSDate *start = [statusItems objectForKey:@"startDate"];
	NSDate *end = [statusItems objectForKey:@"endDate"];
	NSDate *current = self.serverTime;
	
	if ([current compare:start] < 0) {
		return [NSString stringWithFormat:@"Starts in %@",[start formatRelativeTimeRevised]];;
		
	} else if ([current compare:end] >=0 ) {
		return [NSString stringWithFormat:@"Has ended %@",[end formatRelativeTimeRevised]];
		
	} else if (end) {
		return [NSString stringWithFormat:@"Ends in %@",[end formatRelativeTimeRevised]];
		
	}
	
	return @"No Time";
}

- (BOOL)appUpToDate:(NSString*)requiredVersion {

	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	T2Log(@"App Version is [%@], Required Version [%@]",appVersion, requiredVersion);
	
	NSComparisonResult cmp = [requiredVersion compare:appVersion];
//	switch (cmp)
//	{
//		case NSOrderedAscending: NSLog(@"NSOrderedAscending req[%@] app[%@]",requiredVersion,appVersion); break;
//		case NSOrderedDescending:  NSLog(@"NSOrderedDescending req[%@] app[%@]",requiredVersion,appVersion); break;
//		case NSOrderedSame:  NSLog(@"NSOrderedSame req[%@] app[%@]",requiredVersion,appVersion); break;
//		default: NSLog(@"OTHER"); break;
//	}
	// Required Version not greater then the App Version.
	return (cmp != NSOrderedDescending );
}

- (NSString*)openFromStatusItems:(NSDictionary*)statusItems {
	NSDate *start = [statusItems objectForKey:@"startDate"];
	NSDate *end = [statusItems objectForKey:@"endDate"];
	NSDate *current = self.serverTime;
	if ([current compare:start] > 0 && [current compare:end] < 0 && [self appUpToDate:[statusItems objectForKey:@"version"]]) {
		return @"YES";
		
	}
	
	return @"NO";
}


- (NSString*)challengeIDFromFlikrID:(NSString*)flickrID {
	return flickrID;//[[flikrID componentsSeparatedByString:@"-"] lastObject];
}

- 
(NSString*)flickrIDFromChallengeID:(NSString*)challengeID {
	return challengeID;//[NSString stringWithFormat:@"%@-%@",kOBJECTIVE_FLICKR_API_USER,challengeID];
}


- (BOOL)submittedChallenge:(NSString*)challengeID {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"SUBMITTED-%@",challengeID]] ? YES : NO);
}

- (NSString*)getIDForSubmittedChallenge:(NSString*)challengeID {
	return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"SUBMITTED-%@",challengeID]];
}

- (void)setSubmittedChallenge:(NSString*)challengeID setID:(NSString*)setID {
	[[NSUserDefaults standardUserDefaults] setObject:setID forKey:[NSString stringWithFormat:@"SUBMITTED-%@",challengeID]];
}

- (NSString*)uniqueIdentifier {
	NSString *udid = [UIDevice currentDevice].uniqueIdentifier;
	return md5(udid);
}

- (NSString*)makeEntryTitle:(NSString*)title {
	NSString *removedHazards = [title stringByReplacingOccurrencesOfString:@"::" withString:@";;"];
	return [NSString stringWithFormat:@"%@::%@",removedHazards,[Connector getUserName]];
}

- (NSString*)extractTitle:(NSString*)entryTitle {
	NSArray *components = [entryTitle componentsSeparatedByString:@"::"];
	if (components.count>=2) {
		return [components objectAtIndex:0];
	} else {
		return @"";
	}
}

- (NSString*)extractUser:(NSString*)entryTitle {
	NSArray *components = [entryTitle componentsSeparatedByString:@"::"];
	if (components.count>=2) {
		return [components objectAtIndex:1];
	} else {
		return @"";
	}
}

- (BOOL)inLocation:(CLLocation*)desiredLocation current:(CLLocation*)currentLocation  {
	if (!desiredLocation) return YES;
	if (!currentLocation) return NO;
	
	double distance = [currentLocation getDistanceFrom:desiredLocation];
	return (distance < desiredLocation.horizontalAccuracy);
}

// From: http://www.cocoadev.com/index.pl?BaseSixtyFour
+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}


#pragma mark -
#pragma mark RemoteServices
/////////////////////////////////////////
#pragma mark grabChallengeListPage
////////////////////////////////////////
- (void)RESPONDgrabChallengeListPage:(id)obj {
	if ([obj isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = obj;
		[dict retain];
		
		
		NSArray *collections = [[dict objectForKey:@"collections"] objectForKey:@"collection"];
		
		for (NSDictionary *subcollections in collections) {
			if ([[subcollections valueForKey:@"title"] isEqualToString:@"CHALLENGES"]) {
				collections = [subcollections valueForKey:@"collection"];
			}
		}
		
		
		NSMutableArray *challengeItems = [NSMutableArray arrayWithCapacity:5];
		for (NSDictionary *collection in collections) {
			
			NSDictionary *description = [self extractDetailSplit:[collection objectForKey:@"description"]];
			NSDictionary *statusItems = [self extractItemsFromString:[description objectForKey:@"statusItems"]];
			
			NSString *challengeID = [self challengeIDFromFlikrID:[collection objectForKey:@"id"]];
			
			NSString *title = [collection objectForKey:@"title"];
			if (!title) title = @"";
			NSString *iconSmall = [collection objectForKey:@"iconsmall"];
			if (!iconSmall) iconSmall = @"";
			NSString *details = [description objectForKey:@"description"];
			if (!details) details = @"";
			
			NSDictionary *item = [NSDictionary dictionaryWithObjects:
								 [NSArray arrayWithObjects:
								  title, 
								  iconSmall, 
								  [self badgeFromStatusItems:statusItems],
								  ([self submittedChallenge:challengeID] ? @"bundle://Label-Done.png" : @""),
								  [self timerFromStatusItems:statusItems],
								  details,
								  challengeID,
								  nil] 
										forKeys:
								  [NSArray arrayWithObjects:@"title",@"image",@"badge",@"status",@"time",@"summary",@"id",nil]]; 
		  [challengeItems addObject:item];
		}
		
		NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:5];
		[data setObject:challengeItems forKey:@"items"];
		[data setValue:@"NO" forKey:@"MorePages"];
		
		[_delegate connectorRequestDidFinishWithData:data call:@"grabChallengeListPage"];
		
		[dict release];
		
	
	} else if ([obj isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		///NSError *error = [self makeErrorWithTitle:@"Unknown Error" description:@"Could not load challenges list"];
		[_delegate connectorRequestDidFailWithError:error call:@"grabChallengeListPage"];
		
		
	} else {
		NSError *error = [self makeErrorWithTitle:@"Unknown Error" description:@"Could not load challenges list"];
		[_delegate connectorRequestDidFailWithError:error call:@"grabChallengeListPage"];
	}
}

- (void)grabChallengeListPage:(NSUInteger)page {
	_returningSelector = @"RESPONDgrabChallengeListPage:";
	[self.flickerRequest callAPIMethodWithGET:@"flickr.collections.getTree" arguments:nil];	
	
	//NSLog(@"Connector grabChallengeListPage");
}



/////////////////////////////////////////
#pragma mark grabChallenge
////////////////////////////////////////
- (void)RESPONDgrabChallenge:(id)obj {
	if ([obj isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = obj;
		[dict retain];
		
		NSArray *collections = [[dict objectForKey:@"collections"] objectForKey:@"collection"];
		
		for (NSDictionary *subcollections in collections) {
			if ([[subcollections valueForKey:@"title"] isEqualToString:@"CHALLENGES"]) {
				collections = [subcollections valueForKey:@"collection"];
			}
		}
		

		NSDictionary *collection = nil;
		for (collection in collections) {
			
					
			NSString *challengeID = [self challengeIDFromFlikrID:[collection objectForKey:@"id"]];
			if ([challengeID isEqualToString:_challengeQueried]) {
				break;
			} else {
				collection = nil;
			}
		}
		
		
		if (!collection) {
			NSError *error = [self makeErrorWithTitle:@"Unknown Challenge" description:@"Could not load challenge"];
			[_delegate connectorRequestDidFailWithError:error call:@"grabChallenge"];
			
		} else {
			NSDictionary *description = [self extractDetailSplit:[collection objectForKey:@"description"]];
			NSDictionary *statusItems = [self extractItemsFromString:[description objectForKey:@"statusItems"]];
			
			NSString *title = [collection objectForKey:@"title"];
			if (!title) title = @"";
			NSString *chalDescription = [description objectForKey:@"description"];
			if (!chalDescription) chalDescription = @"";
			NSString *icon = [collection objectForKey:@"iconlarge"];
			if (!icon) icon = @"";
			NSString *allowCreation = [self openFromStatusItems:statusItems];
			NSString *done = ([self submittedChallenge:_challengeQueried] ? @"YES" : @"NO");
			
			NSString *allowVersion = ([self appUpToDate:[statusItems objectForKey:@"version"]] ? @"YES" : @"NO");
			NSDate *start = [statusItems objectForKey:@"startDate"];
			NSDate *end = [statusItems objectForKey:@"endDate"];
			
			NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:7];
			[data setObject:title forKey:@"title"];
			[data setObject:chalDescription forKey:@"detail"];
			[data setObject:start forKey:@"startDate"];
			[data setObject:end forKey:@"endDate"];
			[data setObject:done forKey:@"status"];
			[data setObject:icon forKey:@"image"];
			[data setObject:allowVersion forKey:@"allowVersion"];
			[data setObject:allowCreation forKey:@"allowCreation"];
			
			CLLocation *location = [statusItems objectForKey:@"location"];
			if (location) {
				[data setObject:location forKey:@"location"];
			}
			 
			[_delegate connectorRequestDidFinishWithData:data call:@"grabChallenge"];
		}
			
		[_challengeQueried release];
		_challengeQueried=nil;
		[dict release];
		
		
	} else if ([obj isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		[_delegate connectorRequestDidFailWithError:error call:@"grabChallenge"];
		
		
	} else {
		NSError *error = [self makeErrorWithTitle:@"Unknown Error" description:@"Could not load challenge"];
		[_delegate connectorRequestDidFailWithError:error call:@"grabChallenge"];
	}
}




- (void)grabChallenge:(NSString*)challengeID {
	_returningSelector = @"RESPONDgrabChallenge:";
	_challengeQueried = [challengeID retain];
	[self.flickerRequest callAPIMethodWithGET:@"flickr.collections.getTree" arguments:nil];
}


/////////////////////////////////////////
#pragma mark grabChallengeEntriesListPage
////////////////////////////////////////
- (void)RESPONDgrabChallengeEntriesListPage:(id)obj {
	if ([obj isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = obj;
		[dict retain];

		NSDictionary *collection = nil;
		NSArray *collections = [[dict objectForKey:@"collections"] objectForKey:@"collection"];
				
		for (NSDictionary *subcollections in collections) {
			if ([[subcollections valueForKey:@"title"] isEqualToString:@"CHALLENGES"]) {
				collections = [subcollections valueForKey:@"collection"];
			}
		}
		
		for (collection in collections) {
			
			
			NSString *challengeID = [self challengeIDFromFlikrID:[collection objectForKey:@"id"]];
			if ([challengeID isEqualToString:_challengeQueried]) {
				break;
			} else {
				collection = nil;
			}
		}
		
		NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:5];
		[data setValue:@"NO" forKey:@"MorePages"];
		
		NSString *title = [collection objectForKey:@"title"];
		if (!title) title = @"";
		[data setObject:title forKey:@"title"];
		
		NSArray *sets = [collection objectForKey:@"set"];
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:sets.count];
		
		
		if ([sets isKindOfClass:[NSDictionary class]]) {
			sets = [NSArray arrayWithObject:sets];			
		}
		
		
		for (NSDictionary *set in sets) {
			NSDictionary *description = [self extractDetailSplit:[set objectForKey:@"description"]];
			NSDictionary *statusItems = [self extractEntryItemDetailsFromString:[description objectForKey:@"statusItems"]];
			
			NSString *title = [collection objectForKey:@"title"];
			if (!title) title = @"";
			NSString *iconSmall = [collection objectForKey:@"iconsmall"];
			if (!iconSmall) iconSmall = @"";
			NSString *details = [collection objectForKey:@"description"];
			if (!details) details = @"";
			
			NSString *itemTitle = [self extractTitle:[set objectForKey:@"title"]];
			if (!itemTitle) itemTitle = @"";
			NSString *itemDesc = [description objectForKey:@"description"];
			if (!itemDesc) itemDesc = @"";
			NSString *itemId = [set objectForKey:@"id"];
			if (!itemId) itemId = @"";
			NSString *user = [self extractUser:[set objectForKey:@"title"]];
			if (!user) user = @"(Unknown User)";
			NSString *image = [statusItems objectForKey:@"thumb"];
			if (!image) image = @"";
			
			NSDictionary *item = [NSDictionary dictionaryWithObjects:
			 [NSArray arrayWithObjects:
			  itemTitle, 
			  image,
			  @"",
			  @"",
			  user,
			  itemDesc,
			  itemId,
			  nil] 
										forKeys:
			 [NSArray arrayWithObjects:@"title",@"image",@"badge",@"label",@"user",@"detail",@"id",nil] 
			 ];
			[items addObject:item];
		}
		
		[data setObject:items forKey:@"items"];
		
		
		[_delegate connectorRequestDidFinishWithData:data call:@"grabChallengeEntriesListPage"];
		
		
		[_challengeQueried release];
		_challengeQueried=nil;
		[dict release];
		
		
	} else if ([obj isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		[_delegate connectorRequestDidFailWithError:error call:@"grabChallenge"];
		
		
	} else {
		NSError *error = [self makeErrorWithTitle:@"Unknown Error" description:@"Could not load challenge"];
		[_delegate connectorRequestDidFailWithError:error call:@"grabChallenge"];
	}
	
}

- (void)grabChallengeEntriesListForChallenge:(NSString*)challengeID page:(NSUInteger)pageNo {\
	_returningSelector = @"RESPONDgrabChallengeEntriesListPage:";
	_challengeQueried = [challengeID retain];
	[self.flickerRequest callAPIMethodWithGET:@"flickr.collections.getTree" arguments:nil];
}


/////////////////////////////////////////
#pragma mark grabChallengeEntry
////////////////////////////////////////
- (void)RESPOND2grabChallengeEntry:(id)obj {
	if ([obj isKindOfClass:[NSDictionary class]] && [_passingInfo isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = obj;
		[dict retain];
		
		NSDictionary *passDict = _passingInfo;
		
		NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:5];
		
		
		NSString *title = nil;
		NSString *detail = nil;
		NSString *user = nil;
		
		NSArray *collections = [[passDict objectForKey:@"collections"] objectForKey:@"collection"];
		for (NSDictionary *subcollections in collections) {
			if ([[subcollections valueForKey:@"title"] isEqualToString:@"CHALLENGES"]) {
				collections = [subcollections valueForKey:@"collection"];
			}
		}
		
		BOOL doBreak = NO;
		for (NSDictionary *collection in collections) {
			NSArray *sets = [collection objectForKey:@"set"];
			if ([sets isKindOfClass:[NSDictionary class]]) {
				sets = [NSArray arrayWithObject:sets];			
			}
			
			for (NSDictionary *set in sets) {
				if ([[set objectForKey:@"id"] isEqualToString:_challengeQueried]) {
					title = [self extractTitle:[set objectForKey:@"title"]];
					detail = [[self extractDetailSplit:[set objectForKey:@"description"]] objectForKey:@"description"];
					user = [self extractUser:[set objectForKey:@"title"]];
					doBreak = YES;
					break;
				}
			}
			if (doBreak) break;
		}
		
		NSArray *photos = [[dict objectForKey:@"photoset"] objectForKey:@"photo"];
		if ([photos isKindOfClass:[NSDictionary class]]) {
			photos = [NSArray arrayWithObject:photos];
		}
		
		NSMutableArray *photoItems = [NSMutableArray arrayWithCapacity:photos.count];
		for (NSDictionary *photo in photos) {
			NSString *photoURL = [photo objectForKey:@"url_o"];
			if (!photoURL) photoURL = @"";
			
			[photoItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:photoURL,@"imageURL",[NSNumber numberWithInt:0],@"slideID",nil]];
		}
		
		if (!title) title = @"(No Title)";
		if (!detail) detail = @"(No Details)";
		if (!user) user = @"(Unknown User)";
		[data setObject:title forKey:@"title"];
		[data setObject:detail forKey:@"detail"];
		[data setObject:user forKey:@"user"];
		
		[data setObject:photoItems forKey:@"frames"];
		
		[_delegate connectorRequestDidFinishWithData:data call:@"grabChallengeEntry"];	
		
		
		[_challengeQueried release];
		_challengeQueried=nil;
		[dict release];
		
		
	} else if ([obj isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		[_delegate connectorRequestDidFailWithError:error call:@"grabChallenge"];
		
		
	}  else if ([_passingInfo isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		[_delegate connectorRequestDidFailWithError:error call:@"grabChallenge"];
		
		
	} else {
		NSError *error = [self makeErrorWithTitle:@"Unknown Error" description:@"Could not load challenge"];
		[_delegate connectorRequestDidFailWithError:error call:@"grabChallenge"];
	}
	
	[_passingInfo release];
	_passingInfo = nil;
}

- (void)RESPONDgrabChallengeEntry:(id)obj {
	_passingInfo = [obj retain];
	_returningSelector = @"RESPOND2grabChallengeEntry:";
	
	[self.flickerRequest callAPIMethodWithGET:@"flickr.photosets.getPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:_challengeQueried,@"photoset_id",@"url_t,url_o,tags",@"extras",nil]];
}

- (void)grabChallengeEntry:(NSString*)entryID {
	_returningSelector = @"RESPONDgrabChallengeEntry:";
	_challengeQueried = [entryID retain];
	
	[self.flickerRequest callAPIMethodWithGET:@"flickr.collections.getTree" arguments:nil];
}


/////////////////////////////////////////
#pragma mark submitCommicForChallenge
////////////////////////////////////////
- (void)submitCommicForChallenge:(NSString*)challengeID {
	[_delegate connectorRequestDidFinishWithData:nil call:@"submitCommicForChallenge"];
}


/////////////////////////////////////////
#pragma mark submitCommicForChallengewithData
////////////////////////////////////////
- (void)ADD_TO_COLLECTION_submitCommicForChallenge:(id)obj {
	[FlickrRequest clearCache];
	
	if ([obj isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
		
		[_passingInfo release];
		_passingInfo = nil;
	}
	
	[self setSubmittedChallenge:_challengeQueried setID:[_passingInfo objectForKey:@"setID"]];
	[_delegate connectorRequestDidFinishWithData:[NSNumber numberWithInt:1] call:@"submitCommicForChallenge"];
	
	[_passingInfo release];
	_passingInfo = nil;
	[_challengeQueried release];
	_challengeQueried = nil;
	
	
}

- (void)ADD_PHOTOS_TO_SET_submitCommicForChallenge:(id)obj {
	[FlickrRequest clearCache];
	
	if ([obj isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
		
		[_passingInfo release];
		_passingInfo = nil;
	}
	
	NSMutableArray *uploaded = [_passingInfo valueForKey:@"uploaded"];
	if (uploaded.count) [uploaded removeObjectAtIndex:0];
	
	if (uploaded.count) {	
		_returningSelector = @"ADD_PHOTOS_TO_SET_submitCommicForChallenge:";
		[self.flickerRequest callAPIMethodWithGET:@"flickr.photosets.addPhoto" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[uploaded objectAtIndex:0],@"photo_id",[_passingInfo valueForKey:@"setID"],@"photoset_id",nil]];
		
		
	} else {	
		NSString *setIDs = [_passingInfo valueForKey:@"setID"];
		NSString *oldSet = [_passingInfo valueForKey:@"oldSet"];
		
		NSArray *sets = [_passingInfo valueForKey:@"sets"];
		if ([sets isKindOfClass:[NSDictionary class]]) {
			sets = [NSArray arrayWithObject:sets];
		}
		for (NSDictionary *set in sets) {
			NSString *currentID = [set objectForKey:@"id"];
			if (![oldSet isEqualToString:currentID]) {
				setIDs = [NSString stringWithFormat:@"%@,%@",setIDs,currentID];
			}
		}
		
		_returningSelector = @"ADD_TO_COLLECTION_submitCommicForChallenge:";
		[self.flickerRequest callAPIMethodWithGET:@"flickr.collections.editSets" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[self flickrIDFromChallengeID:_challengeQueried],@"collection_id",@"0",@"do_remove",setIDs,@"photoset_ids",nil]];
		
	}
}

- (void)CREATE_SET_submitCommicForChallenge:(id)obj {
	[FlickrRequest clearCache];
	
	if ([obj isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
		
		[_passingInfo release];
		_passingInfo = nil;
		
	} else if ([obj isKindOfClass:[NSDictionary class]]) {
		[_passingInfo setValue:[[obj valueForKey:@"photoset"] valueForKey:@"id"] forKey:@"setID"];
		[self ADD_PHOTOS_TO_SET_submitCommicForChallenge:nil];
		
	} else {
		NSError *error = [self makeErrorWithTitle:@"Unknown Error" description:@"Could not load challenge"];
		[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
	}	

}

- (void)CREATE_SET1_submitCommicForChallenge:(id)obj  {
	[FlickrRequest clearCache];

	if ([obj isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
		
		[_passingInfo release];
		_passingInfo = nil;
		
	} else if ([obj isKindOfClass:[NSDictionary class]]) {
		NSString *thumb;
		NSString *orig;
		NSArray *sizes = [[obj valueForKey:@"sizes"] valueForKey:@"size"];
		for (NSDictionary *size in sizes) {
			if ([[size objectForKey:@"label"] isEqualToString:@"Thumbnail"]) {
				thumb = [size objectForKey:@"source"];
			} else if ([[size objectForKey:@"label"] isEqualToString:@"Original"]) {
				orig = [size objectForKey:@"source"];
			}
		}
		if (!orig) orig = @"";
		if (!thumb) thumb = @"";
		
		NSString *title = [self makeEntryTitle:[_passingInfo valueForKey:@"title"]];
		NSString *details = [NSString stringWithFormat:@"%@---\nUID:%@;\nIMAGE:%@;\nTHUMB:%@;",[_passingInfo valueForKey:@"detail"],[self uniqueIdentifier],orig,thumb];
		NSMutableArray *uploaded = [_passingInfo valueForKey:@"uploaded"];
		
		_returningSelector = @"CREATE_SET_submitCommicForChallenge:";
		[self.flickerRequest callAPIMethodWithGET:@"flickr.photosets.create" arguments:[NSDictionary dictionaryWithObjectsAndKeys:title,@"title",details,@"description",[uploaded objectAtIndex:0],@"primary_photo_id",nil]];
		
	} else {
		NSError *error = [self makeErrorWithTitle:@"Unknown Error" description:@"Could not load challenge"];
		[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
	}	
}

- (void)UPLOAD_PHOTOS_submitCommicForChallenge:(id)obj {	
	[FlickrRequest clearCache];
	if ([obj isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
		
		[_passingInfo release];
		_passingInfo = nil;
		return;
	}
	
	
	NSMutableArray *toUpload = [_passingInfo valueForKey:@"toUpload"];
	NSMutableArray *uploaded = [_passingInfo valueForKey:@"uploaded"];
	NSInteger slideID = [[[toUpload objectAtIndex:0] valueForKey:@"slideID"] intValue];	
	
	if ([obj isKindOfClass:[NSDictionary class]]) {
		[toUpload removeObjectAtIndex:0];
		NSString *photoID = [[obj valueForKey:@"photoid"] valueForKey:@"_text"];
		[uploaded addObject:photoID];
	}
	
	
	if ([obj isKindOfClass:[NSNumber class]]) {
		NSString *text = [NSString stringWithFormat:@"Uploading Photo %d of %d",slidesToUpload-toUpload.count+1,slidesToUpload];
		CGFloat percent = (uploaded.count+[obj floatValue])/(slidesToUpload+2.0);
		
		[_delegate connectorRequestDidFinishWithData:[NSDictionary dictionaryWithObjectsAndKeys:text,@"text",[NSNumber numberWithFloat:percent],@"percentage",nil] call:@"submitCommicForChallenge"];
		return;
	}
	
	
	if (!toUpload.count) {
		// Create Set
		[_delegate connectorRequestDidFinishWithData:[NSDictionary dictionaryWithObjectsAndKeys:@"Finishing",@"text",[NSNumber numberWithFloat:100],@"percentage",nil] call:@"submitCommicForChallenge"];
		
		_returningSelector = @"CREATE_SET1_submitCommicForChallenge:";
		[self.flickerRequest callAPIMethodWithGET:@"flickr.photos.getSizes" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[uploaded objectAtIndex:0],@"photo_id",nil]];
		
	} else {
		slideID = [[[toUpload objectAtIndex:0] valueForKey:@"slideID"] intValue];
		NSString *tags = [NSString stringWithFormat:@"uid:%@ user:%@",[self uniqueIdentifier],[Connector getUserName]];
		
		NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		dirPath = [dirPath stringByAppendingPathComponent:slidePictureFile(_challengeQueried,slideID)];
		NSInputStream *imageStream = [NSInputStream inputStreamWithFileAtPath:dirPath];
		_returningSelector = @"UPLOAD_PHOTOS_submitCommicForChallenge:";
		[self.flickerRequest uploadImageStream:imageStream suggestedFilename:[NSString stringWithFormat:@"%.3d.png",slideID] MIMEType:@"image/png" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"is_public",tags,@"tags",nil]];
	}	
}

- (void)DELETE_PHOTOS_submitCommicForChallenge:(id)obj {
	[FlickrRequest clearCache];
	NSMutableArray *toDelete = [_passingInfo objectForKey:@"toDelete"];
	
	if ([obj isKindOfClass:[NSDictionary class]]) {
		if (toDelete.count) [toDelete removeObjectAtIndex:0];
	} 
	
	if (!toDelete.count) {
		[self setSubmittedChallenge:_challengeQueried setID:nil];
		[self UPLOAD_PHOTOS_submitCommicForChallenge:nil];	
		
	} else {
		_returningSelector = @"DELETE_PHOTOS_submitCommicForChallenge:";
		[self.flickerRequest callAPIMethodWithGET:@"flickr.photos.delete" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[toDelete objectAtIndex:0],@"photo_id",nil]];	
		
	}

}

- (void)DELETE_PHOTOSET_submitCommicForChallenge:(id)obj {
	[FlickrRequest clearCache];
	[self DELETE_PHOTOS_submitCommicForChallenge:nil];	
}

- (void)DELETE_OLD_submitCommicForChallenge:(id)obj {
	[FlickrRequest clearCache];
	
	if ([obj isKindOfClass:[NSDictionary class]]) {
		[_delegate connectorRequestDidFinishWithData:[NSDictionary dictionaryWithObjectsAndKeys:@"Removing Previous Submission",@"text",[NSNumber numberWithFloat:0],@"percentage",nil] call:@"submitCommicForChallenge"];
		
		NSDictionary *photoSet = [obj valueForKey:@"photoset"];
		NSArray *photos = [photoSet objectForKey:@"photo"];
		
		if ([photos isKindOfClass:[NSDictionary class]]) {
			photos = [NSArray arrayWithObject:photos];
		}
		
		NSMutableArray *toDelete = [NSMutableArray arrayWithCapacity:photos.count];
		for (NSDictionary *photo in photos) {
			[toDelete addObject:[photo valueForKey:@"id"]];
		}
		
		[_passingInfo setValue:toDelete forKey:@"toDelete"];
		
		_returningSelector = @"DELETE_PHOTOSET_submitCommicForChallenge:";
		[self.flickerRequest callAPIMethodWithGET:@"flickr.photosets.delete" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[self getIDForSubmittedChallenge:_challengeQueried],@"photoset_id",nil]];
		
	} else {
		[self UPLOAD_PHOTOS_submitCommicForChallenge:nil];	
	}

}

- (void)CHECKVALID_submitCommicForChallenge:(id)obj {
	[FlickrRequest clearCache];
	
	if ([obj isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = obj;
		[dict retain];
		
		NSDictionary *collection = nil;
		NSArray *collections = [[dict objectForKey:@"collections"] objectForKey:@"collection"];
		
		for (NSDictionary *subcollections in collections) {
			if ([[subcollections valueForKey:@"title"] isEqualToString:@"CHALLENGES"]) {
				collections = [subcollections valueForKey:@"collection"];
			}
		}
		
		for (collection in collections) {
			NSString *challengeID = [self challengeIDFromFlikrID:[collection objectForKey:@"id"]];
			if ([challengeID isEqualToString:_challengeQueried]) {
				break;
			} else {
				collection = nil;
			}
		}
		
		
		if (!collection) {
			NSError *error = [self makeErrorWithTitle:@"Unknown Challenge" description:@"Could not load challenge"];
			[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
			
			[_challengeQueried release];
			_challengeQueried=nil;
			
		} else {
			NSDictionary *description = [self extractDetailSplit:[collection objectForKey:@"description"]];
			NSDictionary *statusItems = [self extractItemsFromString:[description objectForKey:@"statusItems"]];
			NSString *allowCreation = [self openFromStatusItems:statusItems];

			if ([allowCreation boolValue]) {
				NSMutableDictionary *newData = [NSMutableDictionary dictionaryWithCapacity:4];
				[newData setObject:[_passingInfo valueForKey:@"title"] forKey:@"title"];
				[newData setObject:[_passingInfo valueForKey:@"detail"] forKey:@"detail"];
				[newData setObject:[NSMutableArray arrayWithCapacity:((NSArray*)[_passingInfo valueForKey:@"frames"]).count] forKey:@"uploaded"];
				
				// Only upload photos that actually exist
				NSArray *frames = [_passingInfo valueForKey:@"frames"];
				NSMutableArray *toUpload = [NSMutableArray arrayWithCapacity:frames.count];
				NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
				for (NSDictionary *frame in frames) {
					int slideID = [[frame valueForKey:@"slideID"] intValue];
					
					NSString *dir = [dirPath stringByAppendingPathComponent:slidePictureFile(_challengeQueried,slideID)];;
					if ([[NSFileManager defaultManager] fileExistsAtPath:dir]) {
						[toUpload addObject:frame];
					}
				}
				[newData setObject:toUpload forKey:@"toUpload"];
				
				// If there are no photos, return with an error
				if (!toUpload.count) {
					NSError *error = [self makeErrorWithTitle:@"No Slides" description:@"You must create and add content to the slides before submitting them"];
					[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
					
					[_passingInfo release];
					_passingInfo = nil;
					[dict release];
					return;
				}
				
				NSString *set = [collection objectForKey:@"set"];
				if (!set) set = [NSDictionary dictionaryWithObject:@"" forKey:@"id"];
				[newData setObject:set forKey:@"sets"];
				
				[_passingInfo release];
				_passingInfo = [newData retain];
				
				slidesToUpload = ((NSArray*)[_passingInfo objectForKey:@"toUpload"]).count;
				
				NSString *existingChallenge = [self getIDForSubmittedChallenge:_challengeQueried];
				if (!existingChallenge) existingChallenge = @"";
				[newData setObject:existingChallenge forKey:@"oldSet"];
				
				if (existingChallenge.length) {
					_returningSelector = @"DELETE_OLD_submitCommicForChallenge:";
					[self.flickerRequest callAPIMethodWithGET:@"flickr.photosets.getPhotos" arguments:[NSDictionary dictionaryWithObjectsAndKeys:existingChallenge,@"photoset_id",nil]];
					
				} else {
					[self UPLOAD_PHOTOS_submitCommicForChallenge:nil];	
				}

				
			} else {
				NSError *error;
				if (![self appUpToDate:[statusItems valueForKey:@"version"]]) {
					error = [self makeErrorWithTitle:@"Newer App Required"  description:@"To submit challenges, please update this app using the app store."];				
				} else {
					error = [self makeErrorWithTitle:@"Could no submit" description:@"The challenge has closed"];
				}
				
				[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
				
				[_passingInfo release];
				_passingInfo = nil;
			}
		}
		[dict release];
		
		
	} else if ([obj isKindOfClass:[NSError class]]) {
		NSError *error = obj;
		[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
		
		[_passingInfo release];
		_passingInfo = nil;
		
		
	} else {
		NSError *error = [self makeErrorWithTitle:@"Unknown Error" description:@"Could not load challenge"];
		[_delegate connectorRequestDidFailWithError:error call:@"submitCommicForChallenge"];
		
		[_passingInfo release];
		_passingInfo = nil;
	}
	
}

- (void)submitCommicForChallenge:(NSString*)challengeID withData:(NSDictionary*)data {
	[FlurryAPI logEvent:@"COMIC_SUBMIT" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:challengeID,@"challengeID",nil]];

	[FlickrRequest clearCache];
	
	_returningSelector = @"CHECKVALID_submitCommicForChallenge:";
	_challengeQueried = [challengeID retain];
	_passingInfo = [data retain];
	[self.flickerRequest callAPIMethodWithGET:@"flickr.collections.getTree" arguments:nil];
}

/////////////////////////////////////////
#pragma mark activateUserName
////////////////////////////////////////
- (void)ADD_TO_PROFILES_DONE_activateUserName:(id)obj {

}


- (void)ADD_TO_PROFILES_activateUserName:(id)obj {
	
	if ([obj isKindOfClass:[NSDictionary class]]) {
		
		NSString *collectionID = @"";
		NSArray *collections = [[obj objectForKey:@"collections"] objectForKey:@"collection"];
		for (NSDictionary *subcollections in collections) {
			if ([[subcollections valueForKey:@"title"] isEqualToString:@"PROFILES"]) {
				collections = [subcollections valueForKey:@"set"];
				collectionID = [subcollections valueForKey:@"id"];
			}
		}

		NSString *setIDs = _passingInfo;
		
		NSArray *sets = collections;
		if ([sets isKindOfClass:[NSDictionary class]]) {
			sets = [NSArray arrayWithObject:sets];
		}
		for (NSDictionary *set in sets) {
			NSString *currentID = [set objectForKey:@"id"];
			setIDs = [NSString stringWithFormat:@"%@,%@",setIDs,currentID];
		}

		_returningSelector = @"ADD_TO_PROFILES_DONE_activateUserName:";
		[self.flickerRequest callAPIMethodWithGET:@"flickr.collections.editSets" arguments:[NSDictionary dictionaryWithObjectsAndKeys:collectionID,@"collection_id",@"0",@"do_remove",setIDs,@"photoset_ids",nil]];
	}
	
	[_passingInfo release];
}

- (void)REGISTER_NAME_activateUserName:(id)obj {
	if ([obj isKindOfClass:[NSError class]]) {
		[_delegate connectorRequestDidFailWithError:obj call:@"activateUserName"];
		
		[_passingInfo release];
		_passingInfo = nil;
		
	} else {
		[Connector setUserName:_passingInfo];
		[_delegate connectorRequestDidFinishWithData:nil call:@"activateUserName"];
		
		[_passingInfo release];
		_passingInfo = nil;
		
		if ([obj isKindOfClass:[NSDictionary class]]) {
			NSString *setID = [[obj valueForKey:@"photoset"] valueForKey:@"id"];
			
			
			_passingInfo = [setID retain];
			
			_returningSelector = @"ADD_TO_PROFILES_activateUserName:";
			[self.flickerRequest callAPIMethodWithGET:@"flickr.collections.getTree" arguments:nil];
			
			
		}
		
		
		
	}
	
}

- (void)GRAB_DEFAULT_PIC_activateUserName:(id)obj {
	
	if ([obj isKindOfClass:[NSDictionary class]]) {
		NSDictionary *defaultPhotos = obj;
		
		NSArray *photos = [[defaultPhotos valueForKey:@"photos"] valueForKey:@"photo"];
		
		if ([photos isKindOfClass:[NSDictionary class]]) {
			photos = [NSArray arrayWithObject:photos];		
		}
		
		if (photos.count) {
			NSString *photoID = [[photos objectAtIndex:0] valueForKey:@"id"];
			NSString *details = [NSString stringWithFormat:@"%@---\nUID:%@;",@"No Profile Details",[self uniqueIdentifier]];
			
			
			_returningSelector = @"REGISTER_NAME_activateUserName:";
			[self.flickerRequest callAPIMethodWithGET:@"flickr.photosets.create" arguments:
			 [NSDictionary dictionaryWithObjectsAndKeys:
			  [NSString stringWithFormat:@"PROFILE::%@",_passingInfo],@"title",
			  details,@"description",
			  photoID,@"primary_photo_id",
			  nil]];
			
			
		} else {
			NSError *error = [self makeErrorWithTitle:@"Error: No default pictures available" description:@"Please try again later"];
			[_delegate connectorRequestDidFailWithError:error call:@"activateUserName"];
		}

		
	} else if ([obj isKindOfClass:[NSError class]]) {
		[_delegate connectorRequestDidFailWithError:obj call:@"activateUserName"];
	} else {
		
		NSError *error = [self makeErrorWithTitle:@"Unknown error occured while getting default picture" description:@"Please try again later"];
		[_delegate connectorRequestDidFailWithError:error call:@"activateUserName"];
	}

}

- (void)CHECK_IF_IN_USE_activateUserName:(id)obj {
	NSString *requestedName = _passingInfo;
	BOOL dupe = NO;
	
	if ([obj isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dict = [obj valueForKey:@"photosets"];
		NSArray *photosets = [dict valueForKey:@"photoset"];
		
		if ([photosets isKindOfClass:[NSDictionary class]]) {
			photosets = [NSArray arrayWithObject:photosets];
		}
		
		for (NSDictionary *set in photosets) {
			NSString *title = [[set valueForKey:@"title"] valueForKey:@"_text"];
			NSString *user = [self extractUser:title];
			if ([user caseInsensitiveCompare:requestedName]==0) {
				NSString *details = [[set valueForKey:@"description"] valueForKey:@"_text"];
				NSString *split = [[self extractDetailSplit:details] valueForKey:@"statusItems"];
				if (split) {
					NSString *outcome = [split uppercaseString];					
					NSString *uid = [[self extractEntryItemDetailsFromString:outcome] valueForKey:@"UID"];
					
					if ([uid isEqualToString:[self uniqueIdentifier]]) {
						
						[Connector setUserName:_passingInfo];
						[_delegate connectorRequestDidFinishWithData:nil call:@"activateUserName"];
						
						[_passingInfo release];
						return;
					}
					

				}

				dupe = YES;
				break;
			}
		}
	}
	
	if(dupe) {
		NSError *error = [self makeErrorWithTitle:@"Display Name is in Use" description:@"Please try another name"];
		[_delegate connectorRequestDidFailWithError:error call:@"activateUserName"];
		
	} else {
		_returningSelector = @"GRAB_DEFAULT_PIC_activateUserName:";
		[self.flickerRequest callAPIMethodWithGET:@"flickr.photos.search" arguments:
		 [NSDictionary dictionaryWithObjectsAndKeys:
		  kOBJECTIVE_FLICKR_API_USER,@"user_id",
		  @"DefaultProfilePicture",@"tags",
		  nil]];
		[FlurryAPI setUserID:requestedName];
	}
}

- (void)activateUserName:(NSString*)userName {
	_returningSelector = @"CHECK_IF_IN_USE_activateUserName:";
	_passingInfo = [userName retain];
	[self.flickerRequest callAPIMethodWithGET:@"flickr.photosets.getList" cache:NO arguments:nil];
}

- (void)deactivateUserName {
	[Connector setUserName:@""];
	[_delegate connectorRequestDidFinishWithData:nil call:@"deactivateUserName"];
} 

#pragma mark -
#pragma mark LocalServices
/////////////////////////////////////////
#pragma mark grabComicDetailsForChallenge
////////////////////////////////////////
- (void)RESPONDgrabComicDetailsForChallenge:(NSDictionary*)dict {
	[_delegate connectorRequestDidFinishWithData:dict call:@"grabComicDetailsForChallenge"];	
}

- (void)THREADgrabComicDetailsForChallenge:(NSString*)challengeID {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *_challengeID = [challengeID retain];
	
	
	// Path for challenge info
	NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	dirPath = [dirPath stringByAppendingPathComponent:challengeComicFile(_challengeID)];
	
	// Grab current details
	NSMutableDictionary *challengeData = [NSMutableDictionary dictionaryWithContentsOfFile:dirPath];
	
	NSString *title = [challengeData objectForKey:@"title"];
	if (!title) title = @"";
	NSString *details = [challengeData objectForKey:@"detail"];
	if (!details) details = @"";
	NSString *username = [Connector getUserName];
	if (!username) username = @"(Not set)";
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
	[dict setObject:title forKey:@"title"];
	[dict setObject:details forKey:@"detail"];
	[dict setObject:username forKey:@"user"];
	[dict setObject:[NSNumber numberWithInt:0] forKey:@"disabled"];
	[dict setObject:[NSNumber numberWithInt:[self submittedChallenge:_challengeID]] forKey:@"submitted"];
	
	NSString *nextFreeSlide = [challengeData objectForKey:@"nextFreeSlide"];
	if (nextFreeSlide) {
		[dict setObject:nextFreeSlide forKey:@"nextFreeSlide"];
	}
	
	NSArray *slides = [challengeData objectForKey:@"slides"];
	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:slides.count];
	for (NSNumber *slideID in slides) {
		NSString *slidePic = [NSString stringWithFormat:@"documents://%@",slidePictureFile(_challengeID,[slideID intValue])];
		[frames addObject:[NSDictionary dictionaryWithObjectsAndKeys:slidePic,@"imageURL",slideID,@"slideID",nil]];
	}
	[dict setObject:frames forKey:@"frames"];
	
	[self
	 performSelectorOnMainThread:@selector(RESPONDgrabComicDetailsForChallenge:)
	 withObject:dict
	 waitUntilDone:NO];
	
	[_challengeID release];
	[pool release];
}

- (void)grabComicDetailsForChallenge:(NSString*)challengeID {
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(THREADgrabComicDetailsForChallenge:) object:challengeID];
	[thread start];
	[thread release];
	
	
}

////////////////////////////////////////
#pragma mark hasLocalDataForChallenge
////////////////////////////////////////
- (void)RESPONDhasSavedDataForChallenge:(NSDictionary*)dict {
	[_delegate connectorRequestDidFinishWithData:dict call:@"hasSavedDataForChallenge"];	
}

- (void)THREADhasSavedDataForChallenge:(NSString*)challengeID {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *_challengeID = [challengeID retain];
	
	
	// Path for challenge info
	NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	dirPath = [dirPath stringByAppendingPathComponent:challengeComicFile(_challengeID)];
	
	// Grab current details
	NSMutableDictionary *challengeData = [NSMutableDictionary dictionaryWithContentsOfFile:dirPath];
	NSArray *slides = [challengeData objectForKey:@"slides"];

	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",slides.count>0],@"hasData",nil];
	
	[self
	 performSelectorOnMainThread:@selector(RESPONDhasSavedDataForChallenge:)
	 withObject:dict
	 waitUntilDone:NO];
	
	[_challengeID release];
	[pool release];
}

- (void)hasSavedDataForChallenge:(NSString*)challengeID {
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(THREADhasSavedDataForChallenge:) object:challengeID];
	[thread start];
	[thread release];
	
	
}

/////////////////////////////////////////
#pragma mark grabComicSlideDetailsForChallenge
////////////////////////////////////////
- (void)RESPONDgrabComicSlideDetailsForChallenge:(NSDictionary*)dict {
	if (!dict) {
		dict = [NSMutableDictionary dictionary];
	}
	
	[_delegate connectorRequestDidFinishWithData:dict call:@"grabComicSlideDetailsForChallenge"];	
}

- (void)THREADgrabComicSlideDetailsForChallenge:(NSDictionary*)data {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *challengeID = [[data objectForKey:@"challengeID"] retain];
	NSInteger slideID = [[data objectForKey:@"slideID"] intValue];
	
	NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	dirPath = [dirPath stringByAppendingPathComponent:slideDataFile(challengeID,slideID)];
	NSMutableDictionary *slideData = [NSMutableDictionary dictionaryWithContentsOfFile:dirPath];
	
	[self
	 performSelectorOnMainThread:@selector(RESPONDgrabComicSlideDetailsForChallenge:)
	 withObject:slideData
	 waitUntilDone:NO];
	
	[challengeID release];
	[pool release];
}

- (void)grabComicSlideDetailsForChallenge:(NSString*)challengeID slide:(NSUInteger)slideID {
	NSDictionary *sending = [NSDictionary dictionaryWithObjectsAndKeys:
							 challengeID,@"challengeID",
							 [NSNumber numberWithInt:slideID],@"slideID",
							 nil];
	
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(THREADgrabComicSlideDetailsForChallenge:) object:sending];
	[thread start];
	[thread release];
}

/////////////////////////////////////////
#pragma mark saveComicDetailsForChallenge
////////////////////////////////////////
- (void)saveComicDetailsForChallenge:(NSString*)challengeID data:(NSDictionary*)data {
	[data retain];
	
	// Path for challenge info
	NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	dirPath = [dirPath stringByAppendingPathComponent:challengeComicFile(challengeID)];
	
	// Grab current details
	NSMutableDictionary *challengeData = [NSMutableDictionary dictionaryWithContentsOfFile:dirPath];
	if (!challengeData) {
		// Make a file if there is none
		challengeData = [NSMutableDictionary dictionaryWithCapacity:3];
	}
	
	// Save the slide positions
	NSArray *frames = [data objectForKey:@"frames"];
	NSMutableArray *slides = [NSMutableArray arrayWithCapacity:frames.count];
	NSInteger nextFreeSlide = 0;
	for (NSDictionary *frame in frames) {
		NSNumber *slideID = [frame objectForKey:@"slideID"];
		[slides addObject:slideID];
		
		nextFreeSlide = (nextFreeSlide<([slideID intValue]+1) ? [slideID intValue]+1 : nextFreeSlide);
	}
	
	if ([data objectForKey:@"nextFreeSlide"]) {
		[challengeData setObject:[data objectForKey:@"nextFreeSlide"] forKey:@"nextFreeSlide"];
	} else {
		[challengeData setObject:[NSNumber numberWithInt:nextFreeSlide] forKey:@"nextFreeSlide"];
	}

	[challengeData setObject:slides forKey:@"slides"];
	
	// Save comic details
	NSString *title = [data objectForKey:@"title"];
	if (!title) title = @"";
	NSString *details = [data objectForKey:@"detail"];
	if (!details) details = @"";
	
	[challengeData setObject:title forKey:@"title"];
	[challengeData setObject:details forKey:@"detail"];
	
	if ([challengeData writeToFile:dirPath atomically:YES]) {
		[_delegate connectorRequestDidFinishWithData:[NSNumber numberWithInt:1] call:@"saveComicDetailsForChallenge"];
	} else {
		NSError *error = [self makeErrorWithTitle:@"Failed to Save Comic" description:@"Could not write to file, try relaunching this application"];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedFailureReason] 
														message:[NSString stringWithFormat:@"Could not render slide to an image because %@",[error localizedDescription]] 
													   delegate:nil 
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];

		[_delegate connectorRequestDidFailWithError:error call:@"saveComicDetailsForChallenge"];
	}	
	
	[data release];
}


/////////////////////////////////////////
#pragma mark saveComicSlideDetailsForChallenge
////////////////////////////////////////
- (void)RESPONDsaveComicSlideDetailsForChallenge:(NSDictionary*)dict {
	[_delegate connectorRequestDidFinishWithData:dict call:@"saveComicsSlideDetailsForChallenge"];
}

- (void)RESPONDsaveComicSlideDetailsForChallengeFailed:(NSError*)error {
	[_delegate connectorRequestDidFailWithError:error call:@"saveComicsSlideDetailsForChallenge"];	
}

- (void)THREADsaveComicSlideDetailsForChallenge:(NSDictionary*)sending {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *challengeID = [[sending objectForKey:@"challengeID"] retain];
	NSInteger slideID = [[sending objectForKey:@"slideID"] intValue];
	NSArray *items = [[sending objectForKey:@"items"] retain];
	NSData *photo = UIImagePNGRepresentation([sending objectForKey:@"photo"]);
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:items,@"boubles",photo,@"photo",nil];
	[items release];
	
	// Store to iPhone documents directory
	NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	dirPath = [dirPath stringByAppendingPathComponent:slideDataFile(challengeID,slideID)];
	
	if ([data writeToFile:dirPath atomically:YES]) {
		[self
		 performSelectorOnMainThread:@selector(RESPONDgrabComicDetailsForChallenge:)
		 withObject:nil
		 waitUntilDone:NO];
		
	} else {
		NSError *error = [self makeErrorWithTitle:@"Failed to Save Slide" description:@"Could not write slide to file, try relaunching this application"];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedFailureReason] 
														message:[error localizedDescription] 
													   delegate:nil 
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self
		 performSelectorOnMainThread:@selector(RESPONDsaveComicSlideDetailsForChallengeFailed:)
		 withObject:error
		 waitUntilDone:NO];
	}	
	
	[challengeID release];
	[pool release];
}

- (void)saveComicSlideDetailsForChallenge:(NSString*)challengeID slide:(NSUInteger)slideID boubleItems:(NSArray*)items image:(UIImage*)image {
	NSDictionary *sending = [NSDictionary dictionaryWithObjectsAndKeys:
							 challengeID,@"challengeID",
							 [NSNumber numberWithInt:slideID],@"slideID",
							 items,@"items",
							 image,@"photo",
							 nil];
	
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(THREADsaveComicSlideDetailsForChallenge:) object:sending];
	[thread start];
	[thread release];
}


/////////////////////////////////////////
#pragma mark createNewSlideForChallenge
////////////////////////////////////////
- (void)createNewSlideForChallenge:(NSString*)challengeID {
	// Path for challenge info
	NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	dirPath = [dirPath stringByAppendingPathComponent:challengeComicFile(challengeID)];
	
	// Grap current details
	NSMutableDictionary *challengeData = [NSMutableDictionary dictionaryWithContentsOfFile:dirPath];
	if (!challengeData) {
		challengeData = [NSMutableDictionary dictionaryWithCapacity:3];
	}
	NSMutableArray *slides = [NSMutableArray arrayWithArray:[challengeData objectForKey:@"slides"]];
	NSInteger nextFreeSlide = [[challengeData objectForKey:@"nextFreeSlide"] intValue];
	
	// Update current details
	[slides addObject:[NSNumber numberWithInt:nextFreeSlide]];
	[challengeData setObject:slides forKey:@"slides"];
	[challengeData setObject:[NSNumber numberWithInt:nextFreeSlide+1] forKey:@"nextFreeSlide"];
	
	// Info for this slide
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
	[dict setObject:[NSNumber numberWithInt:nextFreeSlide] forKey:@"slideID"];
	[dict setObject:[NSNumber numberWithInt:nextFreeSlide+1] forKey:@"nextFreeSlide"];
	[dict setObject:@"" forKey:@"imageURL"];

	//if ([challengeData writeToFile:dirPath atomically:YES]) {
		[_delegate connectorRequestDidFinishWithData:dict call:@"createNewSlideForChallenge"];
	/*} else {
		[self makeErrorWithTitle:@"Failed to Add Slide" description:@"Could not write to file, try relaunching this application"];
		[_delegate connectorRequestDidFailWithError:nil call:@"createNewSlideForChallenge"];
	}*/	
}


/////////////////////////////////////////
#pragma mark grabUserName
////////////////////////////////////////
- (void)grabUserName {
	[_delegate connectorRequestDidFinishWithData:[Connector getUserName] call:@"grabUserName"];
}



#pragma mark OFFlickrAPIRequestDelegate
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary {
	//NSLog(@"GOT RESPONSE: %@ \n%@",inResponseDictionary,inRequest);
	
	[self
	 performSelectorOnMainThread:NSSelectorFromString(_returningSelector)
	 withObject:inResponseDictionary
	 waitUntilDone:NO];
	
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError {
	//NSLog(@"GOT ERROR: %@ \n%@",inError,inRequest);

	[self
	 performSelectorOnMainThread:NSSelectorFromString(_returningSelector)
	 withObject:inError
	 waitUntilDone:NO];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes {
	//NSLog(@"GOT PHOTO sent %d %d\n",inSentBytes,inTotalBytes,inRequest);
	
	[self
	 performSelectorOnMainThread:NSSelectorFromString(_returningSelector)
	 withObject:[NSNumber numberWithFloat:((float)inSentBytes)/((float)inTotalBytes)]
	 waitUntilDone:NO];
}

@end

