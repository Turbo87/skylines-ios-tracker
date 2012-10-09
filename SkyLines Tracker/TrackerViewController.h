//
//  TrackerViewController.h
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 09.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationController.h"

@interface TrackerViewController : UIViewController
{
    LocationController *locationController;
}

- (IBAction)startTracking:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end
