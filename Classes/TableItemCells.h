//
//  TableItemCells.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import <Three20/Three20.h>

/* TableChallengeItemCell
 A cell for TTTableItemViews with
 */
@interface TableChallengeItemCell : TTTableTextItemCell {
	TTImageView *_pictureView; /**< Picture view for the cell */
	UIImageView *_badgeImageView; /**< Bage image overlayed on the picture */
	UIImageView *_statusImageView; /**< Status image overlayed on the picture */
	UILabel *_titleLabel; /**< Title of the cell (heading) */
	UILabel *_subtitleLabel; /**< Sub title (under the title) */
	UILabel *_descriptionLabel; /**< Futher details to be displayed on the cell */
}

@property(nonatomic,readonly) TTImageView *pictureView;
@property(nonatomic,readonly) UIImageView *badgeImageView;
@property(nonatomic,readonly) UIImageView *statusImageView;
@property(nonatomic,readonly) UILabel *titleLabel;
@property(nonatomic,readonly) UILabel *subtitleLabel;
@property(nonatomic,readonly) UILabel *descriptionLabel;

@end
