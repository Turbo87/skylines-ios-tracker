//
//  TrackingController.m
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 10.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import "TrackingController.h"
#import "AsyncUdpSocket.h"

@interface TrackingController ()

@property AsyncUdpSocket *socket;

@end

@implementation TrackingController

- (id)init
{
    self = [super init];
    if (self != nil)
        self.socket = [[AsyncUdpSocket alloc] initWithDelegate:self];

    return self;
}

- (BOOL)openWithHost: (NSString *)host
{
    NSError *error = nil;
    return [self.socket connectToHost:host onPort:5597 error:&error] &&
        error == nil;
}

- (void)close
{
    [self.socket close];
}

@end
