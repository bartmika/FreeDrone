//
//  TestSpatialReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestSpatialReader.h"

@implementation TestSpatialReader

static SpatialReader * reader = nil;

+ (void)setUp
{
    // Set-up code here.
    reader = [SpatialReader sharedInstance];
    NSAssert(reader, @"Failed to alloc+init\n");
}

+ (void)tearDown
{
    // Tear-down code here.
    [reader release]; reader = nil;
}

+ (void)testPollDeviceForData
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    for (NSUInteger poll = 1; poll <= 10; poll++) {
        NSAssert([reader deviceIsOperational], @"Device not operational\n");
        
        NSDictionary *data = [reader pollDeviceForData];
        NSAssert(data, @"Failed to poll device for data\n");
    
        NSLog(@"Poll %lu / 10\tPollDeviceForData\n", (unsigned long)poll);
        [NSThread sleepForTimeInterval: 0.5f]; // Artifical delay.
    }
    [pool drain]; pool = NULL;
}


/*
 //TODO
 -(NSDictionary*) pollDeviceForData;
 
 - (rotation_t) anglesOfRotationInDegrees;
 
 - (float) compassHeadingInDegrees;
 
 -(acceleration_t) acceleration;
 
 -(angularRotation_t) angularRotation;
 
 -(magneticField_t) magneticField;
 */

+(void) performUnitTests {
    NSLog(@"SpatialReader\n");
    [self setUp];
    [self testPollDeviceForData];
    [self tearDown];
    NSLog(@"SpatialReader: Successfull\n\n");
}

@end
