//
//  DIYComicAppDelegate.m
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2moro Mobile 2010. All rights reserved.
//

#import "DIYComicAppDelegate.h"
#import "StyleSheet.h"
#import "FlickrRequest.h"

#import "ChallengesHomeViewController.h"
#import "ChallengeInfoViewController.h"
#import "ComicEditorViewController.h"
#import "ComicViewerViewController.h"
#import "ComicAssemblerViewController.h"
#import "ChallengeEntriesListViewController.h"
#import "SettingsViewController.h"

#import "Konstants.h"
#import "FlurryAPI.h"


@implementation DIYComicAppDelegate

@synthesize locationManager;
@synthesize deviceToken;
@synthesize deviceAlias;

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	T2Log(@"applicationDidFinishLaunching");
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[FlurryAPI startSession:kFLURRY_ID];
	
	T2Log(@"registerForRemoteNotificationTypes");
	//Register for notifications
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
	// Overwrite the style sheet
	[TTStyleSheet setGlobalStyleSheet:[[[StyleSheet alloc] init] autorelease]];
	
	// Allow for larger content
	[[TTURLRequestQueue mainQueue] setMaxContentLength:300000]; 
	
	// Reset DATA Cache
	[FlickrRequest clearCache];
	
	// Set up the navigator
	TTNavigator* navigator = [TTNavigator navigator];
	navigator.persistenceMode = TTNavigatorPersistenceModeAll;
	navigator.window = [[[UIWindow alloc] initWithFrame:TTScreenBounds()] autorelease];
	[navigator setOpensExternalURLs:YES];
	
	TTURLMap* map = navigator.URLMap;
		
	// Any URL that doesn't match will fall back on this one, and open in the web browser
	[map from:@"*" toViewController:[TTWebController class]];
	
	// Map the view controllers
	[map from:@"tt://challengeshome" toSharedViewController:[ChallengesHomeViewController class]];
	[map from:@"tt://challenge/(initWithChallenge:)" toViewController:[ChallengeInfoViewController class]];
	[map from:@"tt://viewcomic/(initWithComic:)" toViewController:[ComicViewerViewController class]];
	[map from:@"tt://viewcomic/(initWithComic:)/(challenge:)" toViewController:[ComicViewerViewController class]];
	[map from:@"tt://previewcomic/(initWithChallenge:)" toViewController:[ComicViewerViewController class]];
	[map from:@"tt://makecomic/(initWithChallenge:)" toViewController:[ComicAssemblerViewController class]];
	[map from:@"tt://entries/(initWithChallenge:)" toViewController:[ChallengeEntriesListViewController class]];
	[map from:@"tt://editcomic/(initWithChallenge:)/(slideID:)" toViewController:[ComicEditorViewController class]];
	[map from:@"tt://settings" toViewController:[SettingsViewController class]];
	
	if (![navigator restoreViewControllers]) {
		// This is the first launch, so we just start with the tab bar
		[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://challengeshome"] applyAnimated:NO]];
	}
	
	// Start location manager
	locationDelegates = [[NSMutableSet alloc] init];	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	//[locationManager startUpdatingLocation];	
	[self locationManagerSetToMaximum:NO];	
	
	
	// Reset badge number to 0
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	T2Log(@"NavigatorURL: %@",[[TTNavigator navigator] URL]);
	[FlickrRequest clearCache];
	[[[TTNavigator navigator] topViewController] viewDidAppear:NO];
	// Reset badge number to 0
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[[TTNavigator navigator] topViewController] viewWillDisappear:NO];
}


#pragma mark -
#pragma mark Push Notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
	T2Log(@"Registered Device for Remote Notifications: DEVICE: %@",[_deviceToken description]);

//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"didRegisterForRemoteNotificationsWithDeviceToken" 
//                                                    message: [_deviceToken description]
//                                                   delegate: nil
//                                          cancelButtonTitle: @"ok"
//                                          otherButtonTitles: nil];
//    [alert show];
//    [alert release];
	

	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
		T2Log(@"Notifications are disabled for this application. Not registering with Urban Airship");
		return;
	}

    // Get a hex string from the device token with no spaces or < >
    self.deviceToken = [[[[_deviceToken description]
						  stringByReplacingOccurrencesOfString: @"<" withString: @""] 
						 stringByReplacingOccurrencesOfString: @">" withString: @""] 
						stringByReplacingOccurrencesOfString: @" " withString: @""];	
	T2Log(@"Device Token: %@", self.deviceToken);
	
    self.deviceAlias = [Connector getUserName];
	T2Log(@"Device Alias: %@", self.deviceAlias);
	
    // Display the network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    // Register with UrbanAirship
    NSString *UAServer = @"https://go.urbanairship.com";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/", UAServer, @"/api/device_tokens/", self.deviceToken];
    NSURL *url = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];
    
    // Send along our device alias as the JSON encoded request body
    if(self.deviceAlias != nil && [self.deviceAlias length] > 0) {
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[[NSString stringWithFormat: @"{\"alias\": \"%@\"}", self.deviceAlias]
                              dataUsingEncoding:NSUTF8StringEncoding]];
    }
		
    // Authenticate to the server
    [request addValue:[NSString stringWithFormat:@"Basic %@",
                       [Connector base64forData:[[NSString stringWithFormat:@"%@:%@",
                                                        kApnsKey,
                                                        kApnsSecret] dataUsingEncoding: NSUTF8StringEncoding]]] forHTTPHeaderField:@"Authorization"];
    
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	[FlurryAPI logError:@"APN" message:@"didFailToRegisterForRemoteNotificationsWithError" error:error];
	
//	UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"didFailToRegisterForRemoteNotificationsWithError" 
//														message: [error description]
//													   delegate: self
//											  cancelButtonTitle: @"Ok"
//											  otherButtonTitles: nil];
//    [someError show];
//    [someError release];
	
    T2Log(@"Failed to register with error: %@", error);
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
    T2Log(@"didReceiveResponse %d", [(NSHTTPURLResponse *)response statusCode]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue: self.deviceToken forKey: @"_UALastDeviceToken"];
    [userDefaults setValue: self.deviceAlias forKey: @"_UALastAlias"];
	
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Registered Device Sucessful" 
//                                                    message: [NSString stringWithFormat:@"Token: %@, Alias: %@", self.deviceToken, self.deviceAlias]
//                                                   delegate: nil
//                                          cancelButtonTitle: @"ok"
//                                          otherButtonTitles: nil];
//    [alert show];
//    [alert release];
	
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

//	UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Error Registering Device"
//														message: [error description]
//													   delegate: self
//											  cancelButtonTitle: @"Ok"
//											  otherButtonTitles: nil];
//    [someError show];
//    [someError release];
	
	
	[FlurryAPI logError:@"UrbanAirship" message:@"didFailWithError" error:error];
	T2Log(@"ERROR: NSError query result: %@", error);    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    T2Log(@"remote notification: %@ ",userInfo);
	
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Remote Notification" 
//                                                    message: [userInfo descriptionWithLocale: nil indent: 1]
//                                                   delegate: nil
//                                          cancelButtonTitle: @"ok"
//                                          otherButtonTitles: nil];
//    [alert show];
//    [alert release];
	
}

#pragma mark -
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	//T2Log(@"LOCATION ERROR %@",error);
	
	for (id<CLLocationManagerDelegate> locDelegate in locationDelegates) {
		if ([locDelegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
			[locDelegate locationManager:manager didFailWithError:error];
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	//T2Log(@"LOCATION UPDATE %@",newLocation);
	[FlurryAPI setLocation:newLocation];
	for (id<CLLocationManagerDelegate> locDelegate in locationDelegates) {
		if ([locDelegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
			[locDelegate locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	//T2Log(@"LOCATION DIRECTION UPDATE %@",newHeading);
	
	for (id<CLLocationManagerDelegate> locDelegate in locationDelegates) {
		if ([locDelegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
			[locDelegate locationManager:manager didUpdateHeading:newHeading];
		}
	}
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

- (void)locationManagerSetToMaximum:(BOOL)maximum {
	if (maximum) {
		locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
		locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
	} else {
		locationManager.distanceFilter = 10000; // 10km
		locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers; // 3km accuracy
	}
	
}

- (void)locationManagerEnableHeading:(BOOL)enable {
	if (locationManager.headingAvailable) {
		if (enable) {
			[locationManager startUpdatingHeading];
		} else {
			[locationManager stopUpdatingHeading];
		}
	}
}

- (CLLocation*)currentLocation {
	return locationManager.location;
}

- (void)registerForLocationDelegate:(id<CLLocationManagerDelegate>)delegate {
	[locationDelegates addObject:delegate];
}

- (void)removeFromLocationDelegate:(id<CLLocationManagerDelegate>)delegate {
	[locationDelegates removeObject:delegate];
}

#pragma mark -
- (void)dealloc {
	locationManager.delegate = nil;
	[locationManager release];
	[locationDelegates release];
    [super dealloc];
}

@end
