//
//  TrackerViewController.h
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 09.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location/LocationController.h"
#import "Tracking/TrackingController.h"

@interface TrackerViewController : UIViewController <LocationControllerProtocol>
{
    LocationController *locationController;
    TrackingController *trackingController;
}

- (IBAction)startTracking:(id)sender;

- (void)onUpdate:(CLLocation *)location;
- (void)onError:(NSError *)error;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end
