//
//  TrackingController+Debug.h
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 10.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import "TrackingController.h"
#import "../UDP/AsyncUdpSocket.h"

@interface TrackingController (Debug) <AsyncUdpSocketDelegate>

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag;

@end
