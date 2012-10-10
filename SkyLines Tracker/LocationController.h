//
//  LocationController.h
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 09.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LocationControllerProtocol

@required

- (void)onUpdate:(CLLocation *)location;
- (void)onError:(NSError *)error;

@end

@interface LocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) id delegate;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end