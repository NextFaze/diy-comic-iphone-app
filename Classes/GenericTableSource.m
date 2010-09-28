//
//  GenericTableSource.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "GenericTableSource.h"
#import "TableItems.h"
#import "TableItemCells.h"

@implementation ListDataSource
@synthesize delegate = _delegate;

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {			
	if ([object isKindOfClass:[TableChallengeItem class]]) {
		return [TableChallengeItemCell class];  
	} 
	
	return [super tableView:tableView cellClassForObject:object];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	[_delegate loadNextPage];
}

- (NSString*)titleForEmpty {
	return @"No Data";
}

@end


@implementation SectionedDataSource : TTSectionedDataSource
@synthesize delegate = _delegate;

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {				
	if ([object isKindOfClass:[TableChallengeItem class]]) {
		return [TableChallengeItemCell class];  
	}
	
	return [super tableView:tableView cellClassForObject:object];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	[_delegate loadNextPage];
}

- (NSString*)titleForEmpty {
	return @"No Data";
}

@end



