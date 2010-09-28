//
//  OverlayView.m
//  DIYComic
//
//  Created by Andreas Wulf on 21/07/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "OverlayView.h"


@implementation OverlayView
@synthesize content=_content, delegate=_delegate;

- (id)init {
	if (self=[super init]) {
		_delegate = nil;

		self.backgroundColor = [UIColor clearColor];
		self.style = TTSTYLE(overlayBoxStyle);

		// Scrollable view to contain the content
		_contentView = [[UIScrollView alloc] init];
		[self addSubview:_contentView];

		// View that will show the set image
		_instructionView = [[UIImageView alloc] init];		
		_instructionView.contentMode = UIViewContentModeTop;
		[_contentView addSubview:_instructionView];

		// Button to dismiss the content view
		_dismissButton = [[TTButton alloc] init];
		[_dismissButton setStylesWithSelector:@"toolBarButton:"];
		[_dismissButton addTarget:self action:@selector(dismissPressed:) forControlEvents:UIControlEventTouchUpInside];
		[_dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
		[self addSubview:_dismissButton];
	}
	
	return self;
}


- (id)initWithContent:(UIImage*)image {
	if (self=[self init]) {
		self.content = image;
	}
	
	return self;
}

- (void)dismissPressed:(id)sender {
	[_delegate overlayViewdismissPressed];
}

- (void)setFrame:(CGRect)frame {
	super.frame = frame;
	CGFloat padd = 8;
	
	// Set up the frames of the internal views
	_dismissButton.frame = CGRectMake(round((self.width-80)/2.0), self.height-padd-31, 80, 31);
	_contentView.frame = CGRectMake(padd, padd, self.width-padd-padd, self.height-padd-padd-_dismissButton.height-padd);
	
	[_instructionView sizeToFit];
	_instructionView.frame = CGRectMake(round((_contentView.width-_instructionView.width)/2.0), 0, _instructionView.width, _instructionView.height);
	_contentView.contentSize=_instructionView.size;
}

- (void)setContent:(UIImage *)image {
	UIImage *old = _content;
	_content = [image retain];
	[old release];
	
	_instructionView.image = image;
	
	// Recalibrate the view's frame
	self.frame = self.frame;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_instructionView);
	TT_RELEASE_SAFELY(_contentView);
	TT_RELEASE_SAFELY(_dismissButton);
	TT_RELEASE_SAFELY(_content);
	[super dealloc];
}

@end
