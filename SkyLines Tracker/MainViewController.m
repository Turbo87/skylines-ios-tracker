/*
 * Copyright (C) 2012 Tobias Bieniek <Tobias.Bieniek@gmx.de>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the
 * distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * FOUNDATION OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MainViewController.h"

@interface MainViewController ()
{
    LocationController *locationController;
    TrackingController *trackingController;
}

- (BOOL)configureKey;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    trackingController = [[TrackingController alloc] init];
    [trackingController openWithHost:@"localhost"];
    [self configureKey];

    locationController = [[LocationController alloc] init];
    [locationController addDelegate:self];

    [self updateControls];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)configureKey
{
    id defaults = [NSUserDefaults standardUserDefaults];
    NSString *keyString = [defaults stringForKey:@"tracking_key"];
    if (keyString == nil)
        return NO;

    NSScanner *scanner = [NSScanner scannerWithString: keyString];

    unsigned key;
    if ([scanner scanHexInt: &key] == NO)
        return NO;

    [trackingController setKey:key];
    return YES;
}

- (IBAction)startTracking:(id)sender
{
    if (locationController.running)
        [locationController stop];
    else
        [locationController start];

    [self updateControls];
}

- (void)updateControls
{
    if (locationController.running) {
        [self.startButton setTitle:@"Stop Tracking" forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    } else {
        self.locationLabel.text = @"Tracking deactivated";
        [self.startButton setTitle:@"Start Tracking" forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor colorWithRed:0.196 green:0.275 blue:0.522 alpha:1] forState:UIControlStateNormal];
    }
}

- (void)onUpdate:(CLLocation *)location
{
    self.locationLabel.text =
    [NSString stringWithFormat:@"Latitude: %0.3f\nLongitude: %0.3f\nAltitude: %0.0f",
     location.coordinate.latitude, location.coordinate.longitude, location.altitude];
    [trackingController sendFix:location];
}

- (void)onError:(NSError *)error
{
    self.locationLabel.text =
    [NSString stringWithFormat:@"Unknown Location\n(Error %d)", error.code];
}

@end
