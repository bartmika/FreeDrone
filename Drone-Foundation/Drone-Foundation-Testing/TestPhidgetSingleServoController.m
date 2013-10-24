//
//  TestPhidgetSingleServoController.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-09.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestPhidgetSingleServoController.h"

@implementation TestPhidgetSingleServoController

static id servo = NULL;

+ (void)accelerationTesting
{
    double testAcceleration = 0.0f;
    double expectedAcceleration = 0.0f;
    double actualAcceleration = 0.0f;
    
    // Verify hardware defends against ABOVE acceptable acceleration values.
    testAcceleration = 1000000.0f;
    expectedAcceleration = 320000.0f;
    phidgetSingleServoSetAcceleration((phidgetSingleServoController_t*)servo, testAcceleration);
    actualAcceleration = phidgetSingleServoGetAcceleration((const phidgetSingleServoController_t*)servo);
    
    NSAssert(actualAcceleration - expectedAcceleration <= 0.0f,
                               @"Not valid max value\n");
    
    // Verify hardware defends agains BELOW acceptable acceleration values.
    testAcceleration = -10.0f;
    expectedAcceleration = 19;
    phidgetSingleServoSetAcceleration((phidgetSingleServoController_t*)servo, testAcceleration);
    actualAcceleration = phidgetSingleServoGetAcceleration((const phidgetSingleServoController_t*)servo);
    NSAssert(actualAcceleration - expectedAcceleration <= 1.0f,
                               @"Not valid min value\n");
    
    // Verify hardware defends agains WITHIN acceptable acceleration values.
    testAcceleration = 100.0f;
    expectedAcceleration = 100.0f;
    phidgetSingleServoSetAcceleration((phidgetSingleServoController_t*)servo, testAcceleration);
    actualAcceleration = phidgetSingleServoGetAcceleration((const phidgetSingleServoController_t*)servo);
    NSAssert(actualAcceleration - expectedAcceleration <= 0.5f,
                               @"Not valid min value\n");
}

+ (void)positionTesting
{
    double testPosition = 0.0f;
    double expectedPosition = 0.0f;
    double actualPosition = 0.0f;
    
    // Verify code defends over ABOVE hardware allowed values.
    testPosition = 1000000.0f;
    expectedPosition = 220.0f;
    phidgetSingleServoSetPosition((phidgetSingleServoController_t*)servo, testPosition);
    [NSThread sleepForTimeInterval: 5.0f];
    actualPosition = phidgetSingleServoGetPosition((phidgetSingleServoController_t*)servo);
    NSAssert(actualPosition - expectedPosition <= 0.5f, @"Wrong pos");
    
    // Verify code defends under BELOW hardware allowed values.
    testPosition = 0.0f;
    expectedPosition = 0.0f;
    phidgetSingleServoSetPosition((phidgetSingleServoController_t*)servo, testPosition);
    [NSThread sleepForTimeInterval: 10.0f];
    actualPosition = phidgetSingleServoGetPosition((phidgetSingleServoController_t*)servo);
    NSAssert(actualPosition - expectedPosition <= 0.5f, @"Wrong pos");
    
    // Verify code accepts values that are WITHIN hardware allowed values.
    expectedPosition = 100.0f;
    phidgetSingleServoSetPosition((phidgetSingleServoController_t*)servo, expectedPosition);
    [NSThread sleepForTimeInterval: 5.0f];
    actualPosition = phidgetSingleServoGetPosition((phidgetSingleServoController_t*)servo);
    NSAssert(actualPosition - expectedPosition <= 0.5f, @"Wrong pos");
    
    // The next series of tests basically enters values and sees
    // if the hardware messes up or anything comes up.
    
    expectedPosition = 150.0f;
    phidgetSingleServoSetPosition((phidgetSingleServoController_t*)servo, expectedPosition);
    [NSThread sleepForTimeInterval: 5.0f];
    actualPosition = phidgetSingleServoGetPosition((phidgetSingleServoController_t*)servo);
    NSAssert(actualPosition - expectedPosition <= 0.5f, @"Wrong pos");
    
    expectedPosition = 200.0f;
    phidgetSingleServoSetPosition((phidgetSingleServoController_t*)servo, expectedPosition);
    [NSThread sleepForTimeInterval: 5.0f];
    actualPosition = phidgetSingleServoGetPosition((phidgetSingleServoController_t*)servo);
    NSAssert(actualPosition - expectedPosition <= 0.5f, @"Wrong pos");
    
    expectedPosition = 74.0f;
    phidgetSingleServoSetPosition((phidgetSingleServoController_t*)servo, expectedPosition);
    [NSThread sleepForTimeInterval: 5.0f];
    actualPosition = phidgetSingleServoGetPosition((phidgetSingleServoController_t*)servo);
    NSAssert(actualPosition - expectedPosition <= 0.5f, @"Wrong pos");
}


+ (void)setUp
{
    // Set-up code here.
    servo = (id)phidgetSingleServoInit();
    
    phidgetSingleServoEngage((phidgetSingleServoController_t*)servo);
    
    NSAssert(servo, @"Failed to alloc+init\n");
    
}

+ (void)tearDown
{
    // Tear-down code here.
    phidgetSingleServoDisengage((phidgetSingleServoController_t*)servo);
    phidgetSingleServoDealloc((phidgetSingleServoController_t*)servo);
}

// Note: Because we are working with unit testing code that's interfacing
//       with hardware. It is best that we do not do the 'setup' & 'teardown'
//       everytime so lets just perform a series of test skipping those two
//       steps.
+(void) performUnitTests;
{
    [self setUp];
    [self accelerationTesting];
    [self positionTesting];
    [self tearDown];
}


@end
