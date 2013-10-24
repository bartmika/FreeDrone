//
//  TestVirtualServoController.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-09.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestVirtualServoController.h"

@implementation TestVirtualServoController

static NSAutoreleasePool * pool = nil;
static VirtualServoController *servoController = nil;

+ (void)setUp
{
    // Set-up code here.
    pool = [NSAutoreleasePool new];
    servoController = [VirtualServoController sharedInstance];
    NSAssert(servoController, @"Failed Alloc+Init\n");
}

+ (void)tearDown
{
    // Tear-down code here.
    [pool drain]; pool = nil;
}

+ (void)testGetAndSet
{
    double testPosition = 20.0f;
    double expectedPosition = 20.0f;
    
    // Attempt to set the position.
    [servoController setPosition: testPosition];
    
    // Attempt to get the position to verify the position was set.
    double actualPosition = [servoController position];
    NSAssert(actualPosition - expectedPosition <= 0, @"Failed setting");
}

+ (void)testEngagedment
{
    BOOL isEngaged = [servoController engaged];
    NSAssert(isEngaged == NO, @"Should be disengaged!\n");
    
    [servoController engage];
    isEngaged = [servoController engaged];
    NSAssert(isEngaged == YES, @"Should be engaged!\n");
    
    [servoController disengage];
    isEngaged = [servoController engaged];
    NSAssert(isEngaged == NO, @"Should be disengaged!\n");
}

+ (void) testPositionLogging
{
    // Enable Position Logging
    [servoController setKeepPositionLog: YES];
    
    // Attempt to populate with various positions.
    [servoController setPosition: 1.0f];
    [servoController setPosition: 2.0f];
    [servoController setPosition: 3.0f];
    [servoController setPosition: 4.0f];
    [servoController setPosition: 5.0f];
    [servoController setPosition: 6.0f];
    [servoController setPosition: 7.0f];
    [servoController setPosition: 8.0f];
    [servoController setPosition: 9.0f];
    [servoController setPosition: 10.0f];
    
    NSMutableArray * log = [servoController positionLog];
    NSAssert(log, @"Failed to get the usage log\n");
    
    if ([log count] != 10) {
        NSAssert(NO, @"Failed to keep an accurate record of device usage.\n");
    }
}

+ (void) testUsageLogging
{
    // Enable usage logging
    [servoController setKeepUsageLog: YES];
    
    // Perform some simple tasks.
    [servoController engage];
    [servoController position];
    [servoController setPosition: 20.0f];
    [servoController position];
    [servoController pollDeviceForData];
    [servoController pollDeviceForData];
    [servoController pollDeviceForData];
    [servoController disengage];
    
    // Verify the logging worked.
    NSMutableArray * usageLog = [servoController usageLog];
    NSAssert(usageLog, @"Failed to get usage log\n");
    
    if ([usageLog count] <= 0) {
        NSAssert(NO, @"Failed to keep track of records for usage\n");
    }
    
    if ([usageLog count] != 8) {
        NSAssert(NO, @"Failed to keep track of records accurately\n");
    }
    
    usageLog = nil;
}

+(void) performUnitTests {
    NSLog(@"VirtualServoController\n");
    [self setUp]; [self testEngagedment]; [self tearDown];
    [self setUp]; [self testGetAndSet]; [self tearDown];
    [self setUp]; [self testPositionLogging]; [self tearDown];
    [self setUp]; [self testUsageLogging]; [self tearDown];
    NSLog(@"VirtualServoController: Succesful\n\n");
}


@end
