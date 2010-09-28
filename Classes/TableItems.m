//
//  TableItems.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "TableItems.h"


@implementation TableChallengeItem
@synthesize title=_title, subtitle=_subtitle, description=_description, imageURL=_imageURL;
@synthesize defaultImage=_defaultImage, badgeImage=_badgeImage, statusImage=_statusImage;

+ (id)itemWithTitle:(NSString*)title
		   subtitle:(NSString*)subtitle
		description:(NSString*)description
		   imageURL:(NSString*)imageURL
	   defaultImage:(UIImage*)defaultImage
		 badgeImage:(UIImage*)badgeImage
		statusImage:(UIImage*)statusImage
				URL:(NSString*)URL {
	
	TableChallengeItem* item = [[[self alloc] init] autorelease];
	item.title = title;
	item.subtitle = subtitle;
	item.description = description;
	item.imageURL = imageURL;
	item.defaultImage = defaultImage;
	item.badgeImage = badgeImage;
	item.statusImage = statusImage;
	item.URL = URL;
	
	return item;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
	if (self = [super init]) {
		_title = nil;
		_subtitle = nil;
		_description = nil;
		_imageURL = nil;
		_defaultImage = nil;
		_badgeImage = nil;
		_statusImage = nil;
	}
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_title);
	TT_RELEASE_SAFELY(_subtitle);
	TT_RELEASE_SAFELY(_description);
	TT_RELEASE_SAFELY(_imageURL);
	TT_RELEASE_SAFELY(_defaultImage);
	TT_RELEASE_SAFELY(_badgeImage);
	TT_RELEASE_SAFELY(_statusImage);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
	if (self = [super initWithCoder:decoder]) {
		self.title = [decoder decodeObjectForKey:@"title"];
		self.subtitle = [decoder decodeObjectForKey:@"subtitle"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
		self.defaultImage = [decoder decodeObjectForKey:@"defaultImage"];
		self.badgeImage = [decoder decodeObjectForKey:@"badgeImage"];
		self.statusImage = [decoder decodeObjectForKey:@"statusImage"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
	[super encodeWithCoder:encoder];
	if (self.text) {
		[encoder encodeObject:self.title forKey:@"title"];
		[encoder encodeObject:self.subtitle forKey:@"subtitle"];
		[encoder encodeObject:self.description forKey:@"description"];
		[encoder encodeObject:self.imageURL forKey:@"imageURL"];
		[encoder encodeObject:self.defaultImage forKey:@"defaultImage"];
		[encoder encodeObject:self.badgeImage forKey:@"badgeImage"];
		[encoder encodeObject:self.statusImage forKey:@"statusImage"];
	}
}

@end
