//
//  TestVirtualSpatialReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-09.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestVirtualSpatialReader.h"

@implementation TestVirtualSpatialReader

static NSAutoreleasePool * pool = nil;
static VirtualSpatialReader * spatialReader = nil;

+ (void)setUp
{    
    // Set-up code here.
    pool = [NSAutoreleasePool new];
    spatialReader = [VirtualSpatialReader sharedInstance];
    NSAssert(spatialReader, @"Failed to alloc+init\n");
    
    [spatialReader populateFromCsvFile: kVirtualSpatialReaderFileURL];
}

+ (void)tearDown
{
    // Tear-down code here.
    [pool drain]; pool = nil;
}

+ (void)testGetterAndSetter
{
    rotation_t rot;
    do {
        rot = [spatialReader anglesOfRotationInDegrees];
    } while (rot.pitch != 0.0f && rot.yaw != 0.0f && rot.roll != 0.0f);
    
    double compass;
    do {
        compass = [spatialReader compassHeadingInDegrees];
    } while (compass != 0.0f);
    
    acceleration_t acc;
    do {
        acc = [spatialReader acceleration];
    } while (acc.x != 0 && acc.y != 0 && acc.z != 0);
    
    angularRotation_t ang;
    do {
        ang = [spatialReader angularRotation];
    } while (ang.x != 0 && ang.y != 0 && ang.z != 0);
    
    magneticField_t mag;
    do {
        mag = [spatialReader magneticField];
    } while (mag.x != 0 && mag.y != 0 && mag.z != 0);
}

+ (void) testWithLogging
{
    [spatialReader setKeepUsageLog: YES];
    [spatialReader acceleration];
    [spatialReader angularRotation];
    [spatialReader magneticField];
    [spatialReader compassHeadingInDegrees];
    [spatialReader anglesOfRotationInDegrees];
    [spatialReader pollDeviceForData];
    
    NSMutableArray * usageLog = [spatialReader usageLog];
    NSAssert(usageLog, @"Failed to log records\n");
    if ([usageLog count] <= 0) {
        NSAssert(NO, @"Failed to count\n");
    }
    
    if ([usageLog count] != 6) {
        NSAssert(NO, @"Failed to keep accurate records\n");
    }
    
    usageLog = nil;
}


+(void) performUnitTests {
    NSLog(@"VirtualSpatialReader\n");
    [self setUp]; [self testGetterAndSetter]; [self tearDown];
    [self setUp]; [self testWithLogging]; [self tearDown];
    NSLog(@"VirtualSpatialReader: Successfull\n\n");
}

@end
