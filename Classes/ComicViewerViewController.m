//
//  ComicViewerViewController.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2010 2moro Mobile. All rights reserved.
//

#import "ComicViewerViewController.h"
#import "StyleSheet.h"
#import "FlurryAPI.h"
#import "DIYComicAppDelegate.h"

#import "Konstants.h"

@interface ComicViewerViewController (Private) 

/*!
 Show the mailer
 @param sender that activated the call (can be nil)
 */
- (void)mailPressed:(id)sender;

/*!
 Show the twitter poster
 @param sender that activated the call (can be nil)
 */
- (void)twitterPressed:(id)sender;

/*!
 Post comic to facebook
 */
- (void)postFaceBook;


@end



@implementation ComicViewerViewController

- (id)init {
	if (self = [super init]) {
		connector = [[Connector alloc] init];
		connector.delegate = self;
				
		_comic = nil;
		_challenge = nil;
		
		_data = nil;		
	}
	
	return self;
}

- (id)initWithComic:(NSString*)comicID {
	return [self initWithComic:comicID challenge:@""];
}

- (id)initWithComic:(NSString*)comicID challenge:(NSString*)challengeID {
	[FlurryAPI logEvent:@"COMIC_VIEW" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:comicID,@"comicID",nil]];

	if (self = [self init]) {
		_comic = [comicID retain];
		_challenge = [challengeID retain];
		
		_viewTitle = @"Comic Viewer";
		self.title = _viewTitle;
		
		UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style: UIBarButtonItemStyleBordered target:self action:@selector(sharePressed:)];
		self.navigationItem.rightBarButtonItem=shareButton;
		[shareButton release];
	}
	
	return self;
}

- (id)initWithChallenge:(NSString*)challengeID {
	[FlurryAPI logEvent:@"COMIC_PREVIEW" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:challengeID,@"challengeID",nil]];

	if (self = [self init]) {
		_challenge = [challengeID retain];

		_viewTitle = @"Comic Preview";
		self.title = _viewTitle;
	}
	
	return self;
}

- (void)dealloc {
	connector.delegate = nil;
	[connector release];
	_scrollView.delegate = nil;
	_scrollView.dataSource = nil;
	[_scrollView release];
	[_descView release];
	[_descLabel release];
	[loadingView release];
	[_data release];
	[_challenge release];
	[_comic release];
	[super dealloc];
}

- (void)loadView {
	[super loadView];	
	self.view.backgroundColor = [UIColor whiteColor];
	
	// The paging commic scroll view
	_scrollView = [[ComicScrollView alloc] init];
	_scrollView.frame = self.view.frame;
	_scrollView.dataSource = self;
	[self.view addSubview:_scrollView];
	
	// The description view
	_descView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.width, self.view.width, self.view.height-self.view.width)];
	_descView.backgroundColor = TTSTYLEVAR(detailColor);
	[self.view addSubview:_descView];
	
	_descLabel = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(10, 10, self.view.width, 0)];
	NSString *descString = @" ";
	TTStyledText *styledText = [TTStyledText textFromXHTML:descString lineBreaks:YES URLs:YES];
	_descLabel.text = styledText;
	_descLabel.backgroundColor = [UIColor clearColor];
	_descLabel.textColor = [UIColor whiteColor];
	[_descView addSubview:_descLabel];
	
	////////////////
	// Model views
	loadingView = [[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleWhiteBox];
	loadingView.frame = self.view.frame;
	loadingView.text = @"Loading...";
	loadingView.hidden = YES;
	loadingView.backgroundColor = self.view.backgroundColor;
	[self.view addSubview:loadingView];
	
	errorView = [[TTErrorView alloc] init];
	errorView.title = @"Error";
	errorView.image = TTIMAGE(@"bundle://Three20.bundle/images/error.png");
	errorView.frame = self.view.frame;
	errorView.hidden = YES;
	errorView.backgroundColor = TTSTYLEVAR(backgroundColor);
	[self.view addSubview:errorView];
	[errorView release];
	
	[self showLoading:YES];	
	
	// Preview or Comic View mode?
	// Make the appropriate call
	if (_comic) {
		[connector grabChallengeEntry:_comic];
	} else {
		[connector grabComicDetailsForChallenge:_challenge];
	}
}

- (void)updatePageTitle {
	_scrollView.frame = self.view.frame;
	
	// If in landscape, hide the details (as there is no room for it)
	if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
		_descView.hidden = YES;
		
		NSString *title = [_data valueForKey:@"title"];
		if (title.length == 0) {
			self.title = @"(Untitled)";
		} else {
			self.title = title;
		}

	} else {
		_descView.hidden = NO;
		_descView.frame = CGRectMake(0, _scrollView.width, _scrollView.width, self.view.height-_scrollView.width);
		_descLabel.width=_scrollView.width;
		[_descLabel sizeToFit];
		_descView.contentSize = CGSizeMake(self.view.width, _descLabel.height+20);
		self.title = _viewTitle;
	}
}

- (void)showLoading:(BOOL)show {
	loadingView.hidden = !show;
}

- (void)showError:(BOOL)show {
	errorView.hidden = !show;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	_scrollView.frame = self.view.frame;
	[self updatePageTitle];
}

#pragma mark ComicScrollViewDataSource
- (NSInteger)numberOfPagesInScrollView:(ComicScrollView*)scrollView {
	return ((NSArray*)[_data valueForKey:@"frames"]).count;
}

- (NSString*)scrollView:(ComicScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
	NSDictionary *dict = [((NSArray*)[_data valueForKey:@"frames"]) objectAtIndex:pageIndex];
	NSString *image = [dict valueForKey:@"imageURL"];
	return image;
}

#pragma mark ConnectorDelegate
- (void)connectorRequestDidFinishWithData:(id)data call:(NSString*)call {
	if ([data isKindOfClass:[NSDictionary class]]) {
		
		if ([call isEqualToString:@"grabComicDetailsForChallenge"]||[call isEqualToString:@"grabChallengeEntry"]) {
			_data = [data retain];
			[self updatePageTitle];
			[_scrollView reloadData];
			
			NSString *title = [_data valueForKey:@"title"];
			if (!title.length) title = @"(Untitled)";
			NSString *user = [_data valueForKey:@"user"];
			if (!user.length) user = @"(Unknown)";
			NSString *detail = [_data valueForKey:@"detail"];
			
			NSString *descString = [NSString stringWithFormat:@"<b>%@</b><br/>By %@<br/><br/>%@",
								  title,user,detail];
			TTStyledText *styledText = [TTStyledText textFromXHTML:descString lineBreaks:YES URLs:YES];
			_descLabel.text = styledText;
			[_descLabel sizeToFit];
			_descView.contentSize = CGSizeMake(self.view.width, _descLabel.height+20);
			[_descView addSubview:_descLabel];
		}
		
	}
	
	[self showLoading:NO];
	[self showError:NO];
}

- (void)connectorRequestDidFailWithError:(NSError*)error call:(NSString*)call {
	// On an error, show the error
	errorView.subtitle = [error localizedDescription];
	errorView.title = [error localizedFailureReason];
	[errorView layoutSubviews];
	[self showLoading:NO];
	[self showError:YES];
}

- (void)sharePressed:(id)sender {
	// Show a a variety of choices for sharing
	UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"Share this Comic" 
															delegate:self 
												   cancelButtonTitle:@"Cancel" 
											  destructiveButtonTitle:nil 
												   otherButtonTitles:@"Facebook",@"Twitter",@"Email",nil];
	[shareSheet showInView:self.view];
	[shareSheet release];
}

#pragma mark FBSessionDelegate
- (void)facebookPressed:(id)sender {
	if (!_facebook) {
		//_fbSession = [[FBSession sessionForApplication:kFbApiKey secret:kFbAppSecret delegate:self] retain];
		_facebook = [[Facebook alloc] init];
		
	}
	
	/*if ([_fbSession isConnected]) {
		[self postFaceBook];
		
	} else {
		if (![_fbSession resume]) {
			FBLoginDialog* dialog = [[[FBLoginDialog alloc] init] autorelease];
			[dialog show];
		}
	}*/
	[_facebook authorize:kFbApiKey permissions:[NSArray arrayWithObject:@"publish_stream"] delegate:self];
	
}

- (void)fbDidLogin {
//	T2Log(@"User with id %lld logged in.", uid);
	T2Log(@"FaceBook User logged in.");
	[self postFaceBook];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	if (!cancelled) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Login Failed" 
														message:@"To share via facebook, you must succesfully log into facebook" 
													   delegate:nil
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)postFaceBook {
	
//		{
//		"name":"NAME COMIC",
//			"href":"http://developers.facebook.com/connect.php?tab=iphone",
//			"caption":"Zine-O-Tron, DIY Comics for iPhone",
//			"description":"COMIC DESCRIPTION",
//			"media":[{
//				"type":"image",
//				"src":"IMAGE 1",
//			}],
//			"properties":{
//				"another link":{
//					"text":"Facebook home page",
//					"href":"http://www.facebook.com"
//				}
//			}
//		}
	
	NSArray *viewControllers = self.navigationController.viewControllers;
	UIViewController *vc = [viewControllers objectAtIndex:viewControllers.count-2];
	NSString *challengeName = vc.title;
	NSString *cdetail = ([_data valueForKey:@"detail"] ? [_data valueForKey:@"detail"] : @"");
	NSString *ctitle = ([_data valueForKey:@"title"] ? [_data valueForKey:@"title"] : @"");
	NSString *cuser = ([_data valueForKey:@"user"] ? [NSString stringWithFormat:@", By: %@",[_data valueForKey:@"user"]] : @"");
	
	NSArray *photos = [_data valueForKey:@"frames"];
	NSString *photoStrip = @"";
	int i = 0;
	for (NSDictionary *photo in photos) {
		if (i) photoStrip = [NSString stringWithFormat:@"%@,",photoStrip,[photo valueForKey:@"imageURL"]];
		photoStrip = [NSString stringWithFormat:@"%@{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@entry/%@/%@\"}",photoStrip,[photo valueForKey:@"imageURL"],kWebViwerLink,_challenge,_comic];
		i++;
	}
	
	
	NSString *name = ctitle;
	NSString *description = cdetail;
	//photoStrip = @"";//[NSString stringWithFormat:@"{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@\"}", IMG_SRC , HREF_URL];

	NSString *fname = [NSString stringWithFormat:@"\"name\":\"%@ by%@\"",name,cuser];
	NSString *flink = [NSString stringWithFormat:@"\"href\":\"%@entry/%@/%@\"",kWebViwerLink,_challenge,_comic];
	NSString *fdescription = [NSString stringWithFormat:@"\"description\":\"%@\"",description];
	NSString *fmedia = [NSString stringWithFormat:@"\"media\":[%@]",photoStrip];
	NSString *fproperties = [NSString stringWithFormat:
							 @"\"properties\":"
							 "{\"App\":{\"text\":\"Zine-O-Tron, DIY Comics for iPhone\",\"href\":\"%@\"},\"Challenge\":{\"text\":\"%@\",\"href\":\"%@challenge/%@\"}}"
							 ,kAppLink,challengeName,kWebViwerLink,_challenge];

	NSString *data = [NSString stringWithFormat:@"{%@,%@,%@,%@,%@}",fname,flink,fdescription,fproperties,fmedia];
	NSLog(@"postFaceBook: data: %@", data);

	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
	 data,@"attachment",
	 nil];
	
	
	[_facebook dialog:@"stream.publish" andParams:params andDelegate:self];
}


- (void)dialogDidComplete:(FBDialog *)dialog {
	_p31LoadingView = [P31LoadingView loadingViewShowWithMessage:@"Processing"];
	[_p31LoadingView hideWithDoneImageAfterDelay:1.0];
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedFailureReason]
													message:[error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"Ok" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *buttonPressed = [actionSheet buttonTitleAtIndex:buttonIndex];
	
	// Determine what the user has decided to share with
	if ([buttonPressed isEqualToString:@"Facebook"]) {
		[self facebookPressed:nil];
	} else if ([buttonPressed isEqualToString:@"Twitter"]) {
		[self twitterPressed:nil];
	} else if ([buttonPressed isEqualToString:@"Email"]) {
		[self mailPressed:nil];
	}
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailPressed:(id)sender {
	// Cancel mail if the device doesn't support
	if (![MFMailComposeViewController canSendMail]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Send" 
														message:@"An active e-mail account is required on your device" 
													   delegate:nil
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
	}
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.navigationBar.tintColor = TTSTYLEVAR(navigationBarTintColor);
	picker.mailComposeDelegate = self;
	
	NSArray *viewControllers = self.navigationController.viewControllers;
	UIViewController *vc = [viewControllers objectAtIndex:viewControllers.count-2];
	NSString *challengeName = vc.title;
	NSString *cdetail = ([_data valueForKey:@"detail"] ? [_data valueForKey:@"detail"] : @"");
	NSString *ctitle = ([_data valueForKey:@"title"] ? [_data valueForKey:@"title"] : @"");
	NSString *cuser = ([_data valueForKey:@"user"] ? [NSString stringWithFormat:@"<i>By: %@</i>",[_data valueForKey:@"user"]] : @"");
	
	NSArray *photos = [_data valueForKey:@"frames"];
	NSString *photoStrip = @"";
	for (NSDictionary *photo in photos) {
		photoStrip = [NSString stringWithFormat:@"%@<img src=\"%@\">",photoStrip,[photo valueForKey:@"imageURL"]];
	}
	
	NSString *subject = [NSString stringWithFormat:@"Zine-O-Tron Comic: %@",ctitle];
	NSString *body = [NSString stringWithFormat:@"Hey,<br/><br/>Check out this comic from the Zine-O-Tron <a href=\"%@\">iPhone App</a>, <a href=\"%@challenge/%@\">\"%@\"</a> challenge:<br/><br/><b><a href=\"%@entry/%@/%@\">%@</a></b><br/>%@<br/>%@<br/><br/>%@",
					  kAppLink,kWebViwerLink,_challenge,challengeName,kWebViwerLink,_challenge,_comic,ctitle,cuser,cdetail,photoStrip];
	
	
	// Fill out the email body text	
	[picker setSubject:subject];
	[picker setMessageBody:body isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];	
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Twitter
- (void)twitterPressed:(id)sender {
	NSString *text = [NSString stringWithFormat:@"Check out the Zine-O-Tron Entry: %@entry/%@/%@",kWebViwerLink,_challenge,_comic];
	NSString *url = [NSString stringWithFormat:@"http://twitter.com/home?status=%@", [text stringByURLEncodingStringParameter]];
	T2Log(@"twitter url: %@", url);
	
	TTOpenURL(url);
}


@end
