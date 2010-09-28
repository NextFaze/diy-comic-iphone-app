//
//  TableItems.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>

/*! 
 TableChallengeItem, a table item for TTTableViews that shows:
 to store properties for TableChallengeItemCell 
 */
@interface TableChallengeItem : TTTableTextItem {
	NSString* _title; /**< Title */
	NSString* _subtitle; /**< Subtitle */
	NSString* _description; /**< Description/details */
	NSString* _imageURL; /**< URL for the image to be shown */
	UIImage* _defaultImage; /**< Default image (while URL Image loads */
	UIImage* _badgeImage; /**< Badge to be shown on the cell */
	UIImage* _statusImage; /**< Status image to be shown on the cell */
}

@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* subtitle;
@property(nonatomic,copy) NSString* description;
@property(nonatomic,copy) NSString* imageURL;
@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic,retain) UIImage* badgeImage;
@property(nonatomic,retain) UIImage* statusImage;

/*!
 Creates a table item with the specified details
 @result TableChallengeItem filled with the details
 */
+ (id)itemWithTitle:(NSString*)title
		   subtitle:(NSString*)subtitle
		description:(NSString*)description
		   imageURL:(NSString*)imageURL
	   defaultImage:(UIImage*)defaultImage
		 badgeImage:(UIImage*)badgeImage
		statusImage:(UIImage*)statusImage
				URL:(NSString*)URL;

@end
