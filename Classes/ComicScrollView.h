//
//  ComicScrollView.h
//  DIYComic
//
//  Created by Andreas Wulf on 15/04/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
@class ComicScrollView;

/*!
 ComicScrollViewDataSource data source protocol
 */
@protocol ComicScrollViewDataSource
/*!
 Returns the number of pages ComicScrollView will show
 @param scrollView requesting the data
 @result number of pages
 */
- (NSInteger)numberOfPagesInScrollView:(ComicScrollView*)scrollView;

/*!
 Image URL for the requested page
 @param scrollView requesting the data
 @param pageIndex of the requesting page
 @result the URL for the image at the requested page
 */
- (NSString*)scrollView:(ComicScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex;
@end

/*! 
 ComicScrollView
 A scroll view that dynamically load pictures as they reach a range close to the viewable range
 
 It is designed to decrease loading times and use minimum memory
 */
@interface ComicScrollView : UIScrollView <UIScrollViewDelegate> {
	id<ComicScrollViewDataSource> _dataSource; /**< Data source */
	
	NSInteger pages; /**< How many Images/Pages there are */
	CGSize pageSize; /**< The size of each image/page */
	
	NSArray* pageItems; /**< List of all the pages/images */
	
	CGPoint lastPosition; /**< Last scroll position */
	
	CGFloat visibleRange; /**< Range to load within the visible range */
}

@property(nonatomic,assign) id<ComicScrollViewDataSource> dataSource;

/*!
 Reloads the data
 */
- (void)reloadData;

/*! 
 Reloads the pages
 */
- (void)processPages;

@end
