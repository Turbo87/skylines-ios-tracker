//
//  TrackingController.h
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 10.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackingController : NSObject

- (id)init;

- (BOOL)openWithHost: (NSString *)host;
- (void)close;

@end
