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

static const NSTimeInterval
getSecondsSinceMidnight(NSDate *now)
{
    // Create NSCalendar for NSDate calculations
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    // Extract date components from current timestamp
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:now];

    // Create new NSDate for UTC midnight
    NSDate *midnight = [calendar dateFromComponents:components];

    // Return seconds between current timestamp and midnight
    return [now timeIntervalSinceDate:midnight];
}

- (BOOL)sendFix:(CLLocation *)location
{
    if (self.key == 0)
        return NO;

    struct FixPacket packet;
    packet.header.magic = ToBE32(MAGIC);
    packet.header.crc = 0;
    packet.header.type = ToBE16(FIX);
    packet.header.key = ToBE64(self.key);
    packet.flags = 0;

    // Set location timestamp for packet
    NSTimeInterval seconds_since_midnight = getSecondsSinceMidnight(location.timestamp);
    packet.time = ToBE32((unsigned)(seconds_since_midnight * 1000));
    packet.reserved = 0;

    // Add location data to packet
    packet.flags |= ToBE32(FLAG_LOCATION);
    packet.location.latitude = ToBE32((int)(location.coordinate.latitude * 1000000));
    packet.location.longitude = ToBE32((int)(location.coordinate.longitude * 1000000));

    // Add altitude data to packet
    packet.flags |= ToBE32(FLAG_ALTITUDE);
    packet.altitude = ToBE16((int)location.altitude);

    // Add course data to packet (if available)
    if (location.course < 0) {
        packet.flags |= ToBE32(FLAG_TRACK);
        packet.track = ToBE16((unsigned)location.course);
    } else
        packet.track = 0;

    // Add speed data to packet (if available)
    if (location.speed < 0) {
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
    return [self.socket sendData:data withTimeout:-1 tag:1];
}

@end
