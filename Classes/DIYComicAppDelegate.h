//
//  DIYComicAppDelegate.h
//  DIYComic
//
//  Created by Andreas Wulf on 31/03/10.
//  Copyright 2moro Mobile 2010. All rights reserved.
//

#import <Three20/Three20.h>
#import <CoreLocation/CoreLocation.h>


@interface DIYComicAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
	CLLocationManager *locationManager;	 /**< Keeps track of the current location */
	NSMutableSet<CLLocationManagerDelegate> *locationDelegates; /**< Stores objects that have registered to be location delegates */

	
	NSString *deviceToken; /**< for Push Notification Registration */
	NSString *deviceAlias; /**< for Push Notification Registration with UrbanAirship */

}

@property(readonly) CLLocationManager *locationManager;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSString *deviceAlias;


/*!
 Returns the current location registered by the location manager 
 @result the current location
 */
- (CLLocation*)currentLocation;

/*!
 Registers an object to become a location delegate
 @param an object that conforms to the CLLocationManagerDelegate protocole
 */
- (void)registerForLocationDelegate:(id<CLLocationManagerDelegate>)delegate;

/*!
 Removes an object that has been registered as a location delegate
 @param a registered object that conforms to the CLLocationManagerDelegate protocole
 */
- (void)removeFromLocationDelegate:(id<CLLocationManagerDelegate>)delegate;

/*!
 Set the location manager to be more or less agressive in precision
 @param maximum YES for more precise NO for better battery
 */
- (void)locationManagerSetToMaximum:(BOOL)maximum;

/*!
 Enables the compas for direction
 @param enable YES, NO to disable
 */
- (void)locationManagerEnableHeading:(BOOL)enable;

@end

