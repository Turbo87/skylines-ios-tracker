//
//  TrackingController.m
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 10.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import "TrackingController.h"
#import "Protocol.h"
#import "../UDP/AsyncUdpSocket.h"
#import "../Util/ByteOrder.h"
#import "../Util/crc.h"

@interface TrackingController ()

@property AsyncUdpSocket *socket;

@end

@implementation TrackingController

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        self.key = 0;
    }

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

- (BOOL)sendPingWithId:(uint16_t)id
{
    if (self.key == 0)
        return NO;

    struct PingPacket packet;
    packet.header.magic = ToBE32(MAGIC);
    packet.header.crc = 0;
    packet.header.type = ToBE16(PING);
    packet.header.key = ToBE64(self.key);
    packet.id = ToBE16(id);
    packet.reserved = 0;
    packet.reserved2 = 0;

    crc_t crc = crc_init();
    crc = crc_update(crc, (const unsigned char *)&packet, sizeof(packet));
    crc = crc_finalize(crc);

    packet.header.crc = ToBE16(crc);

    NSData *data = [NSData dataWithBytes:&packet length:sizeof(packet)];
    return [self.socket sendData:data withTimeout:-1 tag:1];
}

@end
