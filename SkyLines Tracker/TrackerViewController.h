//
//  TrackerViewController.h
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 09.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationController.h"
#import "AsyncUdpSocket.h"

@interface TrackerViewController : UIViewController <LocationControllerDelegate, AsyncUdpSocketDelegate>
{
    LocationController *locationController;
}

- (IBAction)startTracking:(id)sender;

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end
