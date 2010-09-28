//
//  ObjectiveFlickerAdditions.m
//  DIYComic
//
//  Created by Andreas Wulf on 13/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ObjectiveFlickerAdditions.h"


@implementation OFFlickrAPIRequest (DIYComic)

- (LFHTTPRequest*)getHTTPRequest {
	return HTTPRequest;
}

- (void)httpRequest:(LFHTTPRequest *)request didReceiveStatusCode:(NSUInteger)statusCode URL:(NSURL *)url responseHeader:(CFHTTPMessageRef)header {
	if ([delegate respondsToSelector:@selector(setServerTime:)]) {
		NSString *dateString = (NSString*) CFHTTPMessageCopyHeaderFieldValue(header, CFSTR("Date"));
		
		if (dateString.length) {
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
			[delegate performSelector:@selector(setServerTime:) withObject:[df dateFromString:dateString]];
			
			[df release];
		}
    }
}

@end
