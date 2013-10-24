//
//  TestVirtualreader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-09.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestVirtualGPSReader.h"

@implementation TestVirtualGPSReader

static VirtualGPSReader * reader = nil;
static NSAutoreleasePool * pool = nil;
+ (void)setUp
{
    pool = [NSAutoreleasePool new];
    reader = [VirtualGPSReader sharedInstance];
    NSAssert(reader, @"Failed to alloc+init\n");
    
    // Attempt to populate our mock device handler with data from a file
    [reader populateFromCsvFile: kVirtualGPSCSVFileURL];
}

+ (void)tearDown
{
    // Tear-down code here.
    [pool drain]; pool = nil;
}

+ (void)testGetters
{
    // Verify coordinates have been populated
    GPSCoordinate * coordinate;
    do {
        coordinate = [reader coordinate];
    } while (coordinate.longitudeDegrees != 0.0f && coordinate.latitudeDegrees != 0.0f);
    
    // Verify headings where populated
    double heading;
    do {
        heading = [reader heading];
    } while (heading != 0.0f);
    
    // Verify altitude
    double altitude;
    do {
        altitude = [reader altitude];
    } while (altitude != 0.0f);
    
    // Verfiy speed
    double speed;
    do {
        speed = [reader speed];
    } while (speed != 0.0f);
    
    // Verify latitude
    double latitude;
    do {
        latitude = [reader latitude];
    } while (latitude != 0.0f);
    
    // Verify longitude
    double longitude;
    do {
        longitude = [reader longitude];
    } while (longitude != 0.0f);
    
    // Verify time
    GPSTime time;
    do {
        time = [reader time];
    } while (time.tm_hour != 0);
    
    // Verify date
    GPSDate date;
    do {
        date = [reader date];
    } while (date.tm_mday != 0);
}

+(void)testPollDeviceForData
{
    NSUInteger counter = 0;
    NSDictionary * data;
    do {
        data = [reader pollDeviceForData];
        if (data) {
            counter++;
        }
    } while (data != nil);
    
    if (counter <= 0) {
        NSAssert(NO, @"No data");
    }
}

+(void)testUsageLogging
{
    // Enable logging
    [reader setKeepUsageLog: YES];
    
    // Perform some actions and see if they where logged
    [reader coordinate];
    [reader altitude];
    [reader heading];
    [reader coordinate];
    [reader pollDeviceForData];
    [reader pollDeviceForData];
    
    NSMutableArray * usageLog = [reader usageLog];
    NSAssert(usageLog, @"Usage log is null");
    NSAssert([usageLog count] >= 0, @"Failed to keep any records for logging\n");
    NSAssert([usageLog count] == 6, @"Failed to keep accurate records\n");
    usageLog = nil;
}

+(void) performUnitTests {
    NSLog(@"Virtual GPS Reader\n");
    [self setUp]; [self testGetters]; [self tearDown];
    [self setUp]; [self testPollDeviceForData]; [self tearDown];
    [self setUp]; [self testUsageLogging]; [self tearDown];
    [self setUp]; [self tearDown]; [self tearDown];
    NSLog(@"Virtual GPS Reader: Successfull\n\n");
}

@end
