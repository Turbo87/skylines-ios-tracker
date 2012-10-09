//
//  TrackerViewController.m
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 09.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import "TrackerViewController.h"

@interface TrackerViewController ()

@end

@implementation TrackerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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

@end
