//
//  TrackerViewController.m
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 09.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import "TrackerViewController.h"

@interface TrackerViewController ()

@property AsyncUdpSocket *socket;

@end

@implementation TrackerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.socket = [[AsyncUdpSocket alloc] initWithDelegate:self];

    NSError *error = nil;
    [self.socket connectToHost:@"localhost" onPort:5597 error:&error];

    NSData *data = [@"somedata" dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket sendData:data withTimeout:-1 tag:1];

    [self.socket closeAfterSending];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startTracking:(id)sender
{
    NSLog(@"Tracking Button pressed");
    
    locationController = [[LocationController alloc] init];
    locationController.delegate = self;
    [locationController.locationManager startUpdatingLocation];
}

- (void)locationUpdate:(CLLocation *)location
{
    self.locationLabel.text = [location description];
}

- (void)locationError:(NSError *)error
{
    self.locationLabel.text = [error description];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"sent message with tag: %ld", tag);
}

@end
