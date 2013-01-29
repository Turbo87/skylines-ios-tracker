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

#import "TrackingController.h"
#import "Protocol.h"
#import "../UDP/AsyncUdpSocket.h"
#import "../Util/ByteOrder.h"
#import "../Util/crc.h"
#import "../Util/TimeUtil.h"

@interface TrackingController ()

@property NSString *host;
@property AsyncUdpSocket *socket;
@property NSDate *lastFix;

@end

@implementation TrackingController

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        self.lastFix = nil;

        self.key = 0;
        self.interval = 20;
    }

    return self;
}

- (void)openWithHost: (NSString *)host
{
    self.host = host;
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
    return [self.socket sendData:data toHost:self.host port:5597 withTimeout:-1 tag:1];
}

- (BOOL)sendFix:(CLLocation *)location
{
    if (self.key == 0)
        return NO;

    if (self.lastFix != nil) {
        // Ignore fixes below tracking interval
        NSTimeInterval dt = [location.timestamp timeIntervalSinceDate:self.lastFix];
        if (round(dt) < self.interval)
            return NO;
    }

    self.lastFix = location.timestamp;

    struct FixPacket packet;
    packet.header.magic = ToBE32(MAGIC);
    packet.header.crc = 0;
    packet.header.type = ToBE16(FIX);
    packet.header.key = ToBE64(self.key);
    packet.flags = ToBE32(FLAG_LOCATION) | ToBE32(FLAG_ALTITUDE);

    // Set location timestamp for packet
    NSTimeInterval seconds_since_midnight = getSecondsSinceMidnight(location.timestamp);
    packet.time = ToBE32((unsigned)(seconds_since_midnight * 1000));
    packet.reserved = 0;

    // Add location data to packet
    packet.location.latitude = ToBE32((int)(location.coordinate.latitude * 1000000));
    packet.location.longitude = ToBE32((int)(location.coordinate.longitude * 1000000));

    // Add altitude data to packet
    packet.altitude = ToBE16((int)location.altitude);

    // Add course data to packet (if available)
    if (location.course >= 0) {
        packet.flags |= ToBE32(FLAG_TRACK);
        packet.track = ToBE16((unsigned)location.course);
    } else
        packet.track = 0;

    // Add speed data to packet (if available)
    if (location.speed >= 0) {
        packet.flags |= ToBE32(FLAG_GROUND_SPEED);
        packet.ground_speed = ToBE16((unsigned)(location.speed * 16));
    } else
        packet.ground_speed = 0;

    // Set unknown values to zero
    packet.airspeed = 0;
    packet.vario = 0;
    packet.engine_noise_level = 0;

    // Calculate CRC for filled packet
    crc_t crc = crc_init();
    crc = crc_update(crc, (const unsigned char *)&packet, sizeof(packet));
    crc = crc_finalize(crc);
    packet.header.crc = ToBE16(crc);

    // Send packet via UDP socket
    NSData *data = [NSData dataWithBytes:&packet length:sizeof(packet)];
    return [self.socket sendData:data toHost:self.host port:5597 withTimeout:-1 tag:1];
}

@end
