//
//  TrackingController.h
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 10.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"

@interface TrackingController : NSObject <AsyncUdpSocketDelegate>

- (id)init;

- (BOOL)openWithHost: (NSString *)host;
- (void)close;

- (BOOL)sendTestData;

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag;

@end
