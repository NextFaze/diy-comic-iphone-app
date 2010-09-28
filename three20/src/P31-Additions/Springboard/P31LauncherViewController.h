//
//  TTLauncherViewController.h
//  Three20
//
//  Created by Rodrigo Mazzilli on 9/25/09.

#import "Three20/TTViewController.h"

@class TTLauncherView;

@interface P31LauncherViewController : TTViewController <UINavigationControllerDelegate>
{
	UIView *_overlayView;
	TTLauncherView *_launcherView;
	UINavigationController *_launcherNavigationController;
}
@property(nonatomic, retain) UINavigationController *launcherNavigationController;
@property(nonatomic, readonly) TTLauncherView *launcherView;

@end
