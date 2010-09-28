//
//  GenericTableSource.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>
/*!
 TableSourceDelegate to be used with the table sources */
@protocol TableSourceDelegate
/*! 
 loadNextPage load the next page
 */
- (void)loadNextPage;
@end


/*!
 Data source for TTTableViews that recognise the table Items/Cells 
 in this project/application
 */
@interface ListDataSource : TTListDataSource {
	id<TableSourceDelegate> _delegate; /**< Delegate */
}

@property(nonatomic,assign) id<TableSourceDelegate> delegate;

@end


/*!
 Sectioned Data source for TTTableViews that recognise the table Items/Cells 
 in this project/application
 */
@interface SectionedDataSource : TTSectionedDataSource {
	id<TableSourceDelegate> _delegate; /**< Delegate */
}

@property(nonatomic,assign) id<TableSourceDelegate> delegate;

@end

