//
//  TableItemCells.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "TableItemCells.h"
#import "TableItems.h"
#import "StyleSheet.h"

#define kCellPadding 10
#define kCellMargin 5

@implementation TableChallengeItemCell

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell class public

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	//TableChallengeItem* item = object;
	
	/*CGFloat width = tableView.width - (kHPadding*2 + [tableView tableCellMargin]*2);
	UIFont* font = [self textFontForItem:item];
	CGSize size = [item.text sizeWithFont:font
						constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
							lineBreakMode:UILineBreakModeTailTruncation];
	if (size.height > kMaxLabelHeight) {
		size.height = kMaxLabelHeight;
	}
	
	return size.height + kVPadding*2;*/
	return 90;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
	[super layoutSubviews];
    
	CGFloat left = kCellPadding;
	CGFloat top = kCellPadding;
	CGFloat imageSize = self.contentView.height-kCellPadding-kCellPadding;
	
	// Layout the graphics views
	if (_badgeImageView.image) {
		_badgeImageView.frame = CGRectMake(left-7, top-7, imageSize/2, imageSize/2);
	} else {
		_badgeImageView.frame = CGRectZero;
	}

	if (_statusImageView.image) {
		_statusImageView.frame = CGRectMake(left, top, imageSize, imageSize);
	} else {
		_statusImageView.frame = CGRectZero;
	}
	
	if (_pictureView.image || _pictureView.urlPath.length) {
		_pictureView.frame = CGRectMake(left, top, imageSize, imageSize);
	} else {
		_pictureView.frame = CGRectZero;
	}

	// If there is any picture (including badge or status image) allign the
	// next to them, so there isnt any overlapping
	if (_pictureView.width) {
		left = _pictureView.right+kCellMargin;
	} else if (_statusImageView.width) {
		left = _statusImageView.right+kCellMargin;
	} else if (_badgeImageView.width) {
		left = _badgeImageView.right+kCellMargin;
	}
	
	// Layout the text
	CGFloat textWidth = self.contentView.width-left-kCellMargin;
	
	if (_titleLabel.text.length) {
		_titleLabel.frame = CGRectMake(left, top, textWidth, 20);
		[_titleLabel sizeToFit];
		top = _titleLabel.bottom;
	} else {
		_titleLabel.frame = CGRectZero;
	}
	
	if (_subtitleLabel.text.length) {
		_subtitleLabel.frame = CGRectMake(left, top, textWidth, 10);
		[_subtitleLabel sizeToFit];
		_subtitleLabel.width = textWidth;
		top = _subtitleLabel.bottom;
	} else {
		_subtitleLabel.frame = CGRectZero;
	}

	if (_descriptionLabel.text.length) {
		_descriptionLabel.frame = CGRectMake(left, top, textWidth, 0);
		[_descriptionLabel sizeToFit];
		
		CGFloat height = (self.contentView.height-top-kCellPadding+4);
		if (height < _descriptionLabel.height) {
			_descriptionLabel.height = height;
		}
		
	} else {
		_descriptionLabel.frame = CGRectZero;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewCell

- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];
		
		TableChallengeItem* item = object;
		
		if (item.title.length) {
			self.titleLabel.text = item.title;
		} else {
			_titleLabel.text = @"";
		}

		if (item.subtitle.length) {
			self.subtitleLabel.text = item.subtitle;
		} else {
			_subtitleLabel.text = @"";
		}
		
		if (item.description.length) {
			self.descriptionLabel.text = item.description;
		} else {
			_descriptionLabel.text = @"";
		}
		
		// Apply any images there are to the picture view
		if (item.defaultImage && item.imageURL.length) {
			self.pictureView.defaultImage = item.defaultImage;
			self.pictureView.urlPath = item.imageURL;
		} else if (item.defaultImage){
			self.pictureView.defaultImage = item.defaultImage;
			self.pictureView.urlPath = @"";
		} else if (item.imageURL.length){
			self.pictureView.defaultImage = nil;
			self.pictureView.urlPath = item.imageURL;
		} else {
			_pictureView.defaultImage = nil;
			_pictureView.urlPath = @"";
		}

		if (item.statusImage) {
			self.statusImageView.image = item.statusImage;
		} else {
			_statusImageView.image = nil;
		}		
		
		if (item.badgeImage) {
			self.badgeImageView.image = item.badgeImage;
		} else {
			_badgeImageView.image = nil;
		}
	}  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {
		_pictureView = nil;
		_badgeImageView = nil;
		_statusImageView = nil;
		_titleLabel = nil;
		_subtitleLabel = nil;
		_descriptionLabel = nil;
	}
	
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_pictureView);
	TT_RELEASE_SAFELY(_badgeImageView);
	TT_RELEASE_SAFELY(_statusImageView);
	TT_RELEASE_SAFELY(_titleLabel);
	TT_RELEASE_SAFELY(_subtitleLabel);
	TT_RELEASE_SAFELY(_descriptionLabel);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (TTImageView*)pictureView {
	if (!_pictureView) {
		_pictureView = [[TTImageView alloc] init];
		_pictureView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:_pictureView];
	}
	
	return _pictureView;
}

- (UIImageView*)badgeImageView {
	if (!_badgeImageView) {
		_badgeImageView = [[UIImageView alloc] init];
		_badgeImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:_badgeImageView];
	}
	
	return _badgeImageView;
}

- (UIImageView*)statusImageView {
	if (!_statusImageView) {
		_statusImageView = [[UIImageView alloc] init];
		_statusImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:_statusImageView];
	}
	
	return _statusImageView;
}

- (UILabel*)titleLabel {
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc] init];
		_titleLabel.font = TTSTYLEVAR(tableFont);
		_titleLabel.textColor = TTSTYLEVAR(textColor);
		_titleLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
		_titleLabel.numberOfLines = 0;
		[self.contentView addSubview:_titleLabel];
	}
	
	return _titleLabel;
}

- (UILabel*)subtitleLabel {
	if (!_subtitleLabel) {
		_subtitleLabel = [[UILabel alloc] init];
		_subtitleLabel.font = TTSTYLEVAR(tableTimestampFont);
		_subtitleLabel.textColor = TTSTYLEVAR(timestampTextColor);
		_subtitleLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
		_subtitleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:_subtitleLabel];
	}
	
	return _subtitleLabel;
}

- (UILabel*)descriptionLabel {
	if (!_descriptionLabel) {
		_descriptionLabel = [[UILabel alloc] init];
		_descriptionLabel.font = TTSTYLEVAR(tableSubTextFont);
		_descriptionLabel.textColor = TTSTYLEVAR(tableSubTextColor);
		_descriptionLabel.highlightedTextColor = TTSTYLEVAR(highlightedTextColor);
		_descriptionLabel.numberOfLines = 0;
		[self.contentView addSubview:_descriptionLabel];
	}
	
	return _descriptionLabel;
}

@end
