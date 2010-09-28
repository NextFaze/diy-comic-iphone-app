//
//  FlickrRequest.m
//  DIYComic
//
//  Created by Andreas Wulf on 19/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FlickrRequest.h"
#import "DIYComicAppDelegate.h"

@implementation FlickrRequest
@synthesize cacheURL;

static NSMutableDictionary *flickrSavedData;

- (NSData*)dataFromDictionary:(NSDictionary*)dict {
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:dict forKey:@"Some Key Value"];
	[archiver finishEncoding];
	[archiver release];
	
	return data;
}

- (NSDictionary*)dictionaryFromData:(NSData*)data {
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	NSDictionary *myDictionary = [unarchiver decodeObjectForKey:@"Some Key Value"];
	[unarchiver finishDecoding];
	[unarchiver release];
	
	return myDictionary;
}

+ (void)clearCache {
	[flickrSavedData removeAllObjects];
}

+ (void)shouldGetNew:(NSString*)url {
	[flickrSavedData removeObjectForKey:url];
}

+ (BOOL)shouldGetNewData:(NSString*)url {
	if (!flickrSavedData) {
		flickrSavedData = [[NSMutableDictionary alloc] init];
	}

	if ([flickrSavedData valueForKey:url]) {
		return NO;
	}
	
	return YES;
}

+ (void)setAsSaved:(NSString*)url {
	[flickrSavedData setObject:@"" forKey:url];
}

- (BOOL)callAPIMethodWithGET:(NSString *)inMethodName arguments:(NSDictionary *)inArguments {
	return [self callAPIMethodWithGET:inMethodName cache:YES arguments:inArguments];
}

- (BOOL)callAPIMethodWithGET:(NSString *)inMethodName cache:(BOOL)cache arguments:(NSDictionary *)inArguments {
	blockCache = !cache;
	
	// Create the URL for the cache
	NSString *arguments = @"";
	for (NSString *key in inArguments) {
		NSString *value = [inArguments objectForKey:key];
		arguments = [NSString stringWithFormat:@"%@?%@=%@",arguments,key,value];
	}
	self.cacheURL = [NSString stringWithFormat:@"cache://%@%@",inMethodName,arguments];

	if ([[TTURLCache cacheWithName:DATA_CACHE] hasDataForURL:cacheURL] && cache && ![FlickrRequest shouldGetNewData:cacheURL]) {
		NSData *data = [[TTURLCache cacheWithName:DATA_CACHE] dataForURL:cacheURL];
		[delegate flickrAPIRequest:self didCompleteWithResponse:[self dictionaryFromData:data]];
		return YES;
	}
	return [super callAPIMethodWithGET:inMethodName arguments:inArguments];
}

- (BOOL)uploadImageStream:(NSInputStream *)inImageStream suggestedFilename:(NSString *)inFilename MIMEType:(NSString *)inType arguments:(NSDictionary *)inArguments {
	self.cacheURL = nil;
	return [super uploadImageStream:inImageStream suggestedFilename:inFilename MIMEType:inType arguments:inArguments];
}

- (void)dealloc {
	[cacheURL release];
	[super dealloc];
}

- (void)httpRequestDidComplete:(LFHTTPRequest *)request {

	NSDictionary *responseDictionary = [OFXMLMapper dictionaryMappedFromXMLData:[request receivedData]];	
	NSDictionary *rsp = [responseDictionary objectForKey:@"rsp"];
	NSString *stat = [rsp objectForKey:@"stat"];
	
	// Cache the result
	if (cacheURL && [stat isEqualToString:@"ok"] && [rsp isKindOfClass:[NSDictionary class]]) {
		[[TTURLCache cacheWithName:DATA_CACHE] storeData:[self dataFromDictionary:rsp] forURL:cacheURL];	
		[FlickrRequest setAsSaved:cacheURL];
	}
	
	[super httpRequestDidComplete:request];
}

- (void)httpRequest:(LFHTTPRequest *)request didFailWithError:(NSString *)error {
	// If there was an error, and we have cached data for this request, we will choose to use it instead
	// Of returning an error
	if (cacheURL && [[TTURLCache cacheWithName:DATA_CACHE] hasDataForURL:cacheURL] && !blockCache) {
		[FlickrRequest shouldGetNew:cacheURL];
		NSData *data = [[TTURLCache cacheWithName:DATA_CACHE] dataForURL:cacheURL];
		[delegate flickrAPIRequest:self didCompleteWithResponse:[self dictionaryFromData:data]];
		return;
	} else {
		[super httpRequest:request didFailWithError:error];
	}

}

@end
