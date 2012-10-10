//
//  TrackingController.m
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 10.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import "TrackingController.h"
#import "AsyncUdpSocket.h"

@interface TrackingController () <AsyncUdpSocketDelegate>

@property AsyncUdpSocket *socket;

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag;

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

- (BOOL)sendTestData
{
    NSData *data = [@"somedata" dataUsingEncoding:NSUTF8StringEncoding];
    return [self.socket sendData:data withTimeout:-1 tag:1];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"sent message with tag: %ld", tag);
}

@end
