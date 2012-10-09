//
//  TrackerViewController.h
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 09.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationController.h"

@interface TrackerViewController : UIViewController <LocationControllerDelegate>
{
    LocationController *locationController;
}

- (IBAction)startTracking:(id)sender;

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end
