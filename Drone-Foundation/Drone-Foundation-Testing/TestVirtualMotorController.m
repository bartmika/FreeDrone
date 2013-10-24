//
//  TestVirtualMotorController.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-09.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestVirtualMotorController.h"

@implementation TestVirtualMotorController

static NSAutoreleasePool * pool = nil;
static VirtualMotorController * motorController = nil;

+ (void)setUp
{  
    // Set-up code here.
    pool = [NSAutoreleasePool new];
    motorController = [VirtualMotorController sharedInstance];
    NSAssert(motorController, @"Failed to Alloc+ Init\n");
}

+ (void)tearDown
{
    // Tear-down code here.
    [pool drain]; pool = nil;
}

+ (void)testGetterAndSetterAcceleration
{
    double testAcceleration = 10.0f;
    double expectedAcceleration = 10.0f;
    double actualAcceleration = 0.0f;
    
    // Attempt to set and get
    [motorController setAcceleration: testAcceleration];
    actualAcceleration = [motorController acceleration];
    
    // Verify the setting and getting worked
    NSAssert(actualAcceleration - expectedAcceleration <= 0.0f, @"Failed acceleration");
}

+ (void)testGetterAndSetterVelocity
{
    double testVelocity = 10.0f;
    double expectedVelocity = 10.0f;
    double actualVelocity = 0.0f;
    
    // Attempt to set and get
    [motorController setVelocity: testVelocity];
    actualVelocity = [motorController velocity];
    
    // Verify the setting and getting worked
    NSAssert(actualVelocity - expectedVelocity <= 0.0f, @"Failed velocity");
}

+ (void) testAccelerationLog
{
    // Enable Acceleration Logging
    [motorController setKeepAccelerationLog: YES];
    
    // Attempt to populate
    [motorController setAcceleration: 1.0f];
    [motorController setAcceleration: 2.0f];
    [motorController setAcceleration: 3.0f];
    [motorController setAcceleration: 4.0f];
    [motorController setAcceleration: 5.0f];
    [motorController setAcceleration: 6.0f];
    [motorController setAcceleration: 7.0f];
    [motorController setAcceleration: 8.0f];
    [motorController setAcceleration: 9.0f];
    [motorController setAcceleration: 10.0f];
    
    NSMutableArray * accelerationLog = [motorController accelerationLog];
    
    if ([accelerationLog count] <= 0) {
        NSAssert(NO, @"Failed keeping any records\n");
    }
    if ([accelerationLog count] != 10) {
        NSAssert(NO, @"Failed keeping accurate records\n");
    }
}

+ (void) testVelocityLog
{
    // Enable Velocity Logging
    [motorController setKeepVelocityLog: YES];
    
    // Attempt to populate
    [motorController setVelocity: 1.0f];
    [motorController setVelocity: 2.0f];
    [motorController setVelocity: 3.0f];
    [motorController setVelocity: 4.0f];
    [motorController setVelocity: 5.0f];
    [motorController setVelocity: 6.0f];
    [motorController setVelocity: 7.0f];
    [motorController setVelocity: 8.0f];
    [motorController setVelocity: 9.0f];
    [motorController setVelocity: 10.0f];
    
    NSMutableArray * velocityLog = [motorController velocityLog];
    
    if ([velocityLog count] <= 0) {
        NSAssert(NO, @"Failed to keep records!\n");
    }
    
    if ([velocityLog count] != 10) {
        NSAssert(NO, @"Failed keeping accurate records.\n");
    }
}

+ (void) testUsageLogging
{
    // Enable usage logging
    [motorController setKeepUsageLog: YES];
    
    // Perform some general tasks...
    [motorController acceleration];
    [motorController setAcceleration: 42.0f];
    [motorController acceleration];
    [motorController velocity];
    [motorController setVelocity: 69.0f];
    [motorController velocity];
    [motorController pollDeviceForData];
    
    // Verify the logging worked.
    NSMutableArray * usageLog = [motorController usageLog];
    NSAssert(usageLog, @"Failed to receive usage log\n");
    if ([usageLog count] <= 0) {
        NSAssert(NO, @"Failed to count any records logged\n");
    }
    if ( [usageLog count] != 7) {
        NSAssert(NO, @"Failed to keep accurate record\n");
    }
    usageLog = nil;
}

+(void) performUnitTests {
    NSLog(@"VirtualMotorController\n");
    [self setUp]; [self testGetterAndSetterAcceleration]; [self tearDown];
    [self setUp]; [self testGetterAndSetterVelocity]; [self tearDown];
    [self setUp]; [self testAccelerationLog]; [self tearDown];
    [self setUp]; [self testVelocityLog]; [self tearDown];
    [self setUp]; [self testUsageLogging]; [self tearDown];
    NSLog(@"VirtualMotorController: Successfull\n\n");
}

@end
