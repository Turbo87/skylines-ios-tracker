//
//  TrackingController+Debug.m
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 10.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import "TrackingController+Debug.h"

@implementation TrackingController (Debug)

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"sent message with tag: %ld", tag);
}

@end
