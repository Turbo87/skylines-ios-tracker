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

@interface TrackerViewController : UIViewController <LocationControllerProtocol, AsyncUdpSocketDelegate>
{
    LocationController *locationController;
}

- (IBAction)startTracking:(id)sender;

- (void)onUpdate:(CLLocation *)location;
- (void)onError:(NSError *)error;

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end
