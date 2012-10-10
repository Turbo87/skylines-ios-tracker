//
//  TrackingController+Debug.m
//  SkyLines Tracker
//
//  Created by Tobias Bieniek on 10.10.12.
//  Copyright (c) 2012 XCSoar. All rights reserved.
//

#import "TrackingController+Debug.h"
#import "Protocol.h"
#import "../Util/ByteOrder.h"

@implementation TrackingController (Debug)

@dynamic socket;

- (BOOL)sendTestData
{
    struct PingPacket packet;
    packet.header.magic = ToBE32(MAGIC);
    packet.header.crc = 0;
    packet.header.type = ToBE16(PING);
    packet.header.key = ToBE64(567);
    packet.id = ToBE16(5);
    packet.reserved = 0;
    packet.reserved2 = 0;

    //packet.header.crc = ToBE16(UpdateCRC16CCITT(&packet, sizeof(packet), 0));
    
    NSData *data = [NSData dataWithBytes:&packet length:sizeof(packet)];
    return [self.socket sendData:data withTimeout:-1 tag:1];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"sent message with tag: %ld", tag);
}

@end
