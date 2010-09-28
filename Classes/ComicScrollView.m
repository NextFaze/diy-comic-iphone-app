//
//  ComicScrollView.m
//  DIYComic
//
//  Created by Andreas Wulf on 15/04/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "ComicScrollView.h"
#import "StyleSheet.h"

@implementation ComicScrollView
@synthesize dataSource = _dataSource;

- (id)init {
	if (self = [super init]) {
		pageSize = CGSizeMake(0, 0);
		pages = 0;
		pageItems = nil;
		
		self.delegate = self;
		
		[self reloadData];
	}
	
	return self;
}


- (void)setFrame:(CGRect)frame {
	lastPosition = self.contentOffset;
	visibleRange = frame.size.width;
	
	[super setFrame:frame];
	
	// Set the page/image size the minimum size out of width and height
	CGFloat size = frame.size.width;
	if (frame.size.height<frame.size.width) {
		size = frame.size.height;
	}
	pageSize = CGSizeMake(size, size);
	
	// Reload pages/images
	[self removeAllSubviews];
	[self processPages];
}


- (void)reloadData {
	pages = [_dataSource numberOfPagesInScrollView:self];
	[self removeAllSubviews];
	
	[self processPages];

}

- (void)processPages {
	
	// Keep track of regious with views
	CGFloat leftest = CGFLOAT_MAX;
	CGFloat rightest = -CGFLOAT_MAX;

	CGFloat leftRange = self.contentOffset.x-visibleRange;
	CGFloat rightRange = self.contentOffset.x+self.width+visibleRange;
	
	// First remove any out of range views
	NSMutableArray *viewsToRemove = [[NSMutableArray alloc] initWithCapacity:self.subviews.count];
	for (UIView *view in self.subviews) {
		if (view.right<leftRange) {
			[viewsToRemove addObject:view];
			
		} else if (view.left>rightRange) {
			[viewsToRemove addObject:view];
		
		} else {
			if (view.left<leftest) {
				leftest = view.left;
			}
			
			if (view.right>rightest) {
				rightest = view.right;
			}
		}
	}
	
	for (UIView *view in viewsToRemove) {
		[view removeFromSuperview];
	}
	[viewsToRemove release];

	
	// Now Add any required pages, by scanning the region where views should be
	for (int i=0; i<pages; i++) {
		CGFloat left = i*pageSize.width;
		CGFloat right = (i+1)*pageSize.width;
		
		if (rightRange>left && right>leftRange) {
			// This frame should be visible
			
			if (right>rightest || left<leftest) {
				// Add this frame
				TTView *comicFrame = [[TTView alloc] initWithFrame:CGRectMake(left, 0, pageSize.width, pageSize.height)];
				comicFrame.style = TTSTYLE(comicFrame);
				TTImageView *imageView = [[TTImageView alloc] initWithFrame:CGRectMake(5, 5, comicFrame.width-10, comicFrame.height-10)];
				imageView.defaultImage = TTIMAGE(@"bundle://DefaultLargeLoading.png");
				imageView.urlPath = [_dataSource scrollView:self pageAtIndex:i];
				imageView.contentMode = UIViewContentModeScaleAspectFit;
				[self addSubview:comicFrame];
				[comicFrame addSubview:imageView];
				
				
				if (comicFrame.left<leftest) {
					leftest = comicFrame.left;
				}
				
				if (comicFrame.right>rightest) {
					rightest = comicFrame.right;
				}
				
				[imageView release];
				[comicFrame release];
				
			}
		}
	}
	
	// Adjust the scroll view's content size to match the sum of the page widths
	self.contentSize = CGSizeMake(pageSize.width*pages, pageSize.height);
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self processPages];
	
}
		

@end
