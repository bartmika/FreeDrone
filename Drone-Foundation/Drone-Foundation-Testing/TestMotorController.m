//
//  TestMotorController.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-09.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestMotorController.h"

@implementation TestMotorController

static MotorController * motor = nil;

+ (void) velocityTesting
{
    float actualAcceleration = 0.0f;
    float actualVelocity = 0.0f;
    float expectedAcceleration = 50.0f;
    float expectedVelocity = 100.0f;
    [motor setAcceleration: expectedAcceleration];
    [motor setVelocity: expectedVelocity];
    
    [NSThread sleepForTimeInterval: 10];
    actualAcceleration = [motor acceleration];
    NSAssert(actualAcceleration - expectedAcceleration <= 0.5f, @"Wrong acc");
    
    actualVelocity = [motor velocity];
    NSAssert(actualVelocity - expectedVelocity <= 0.5f, @"Wrong vel\n");
    
    expectedAcceleration = 0;
    expectedVelocity = 0;
    [motor setAcceleration: expectedAcceleration];
    [motor setVelocity: expectedVelocity];
    
    [NSThread sleepForTimeInterval: 10.0f];
    actualVelocity = [motor velocity];
    NSAssert(actualVelocity - expectedVelocity <= 0.5f, @"Wrong vel\n");
}

+ (void) accelerationTesting
{
    float testAcceleration = 10.0f;
    float actualAcceleration = 0.0f;
    float expectedAcceleration = 24.51f;
    
    // Test out acceleration that is BELOW the hardwares acceptable value
    // and verify the class properly handles it.
    [motor setAcceleration: testAcceleration];
    actualAcceleration = [motor acceleration];
    NSAssert(actualAcceleration - expectedAcceleration <= 0.5f, @"Wrong min value\n");
    
    // Test out acceleration that is ABOVE the hardwares acceptable range.
    testAcceleration = 100000.0f;
    expectedAcceleration = 6250.0f;
    [motor setAcceleration: testAcceleration];
    actualAcceleration = [motor acceleration];
    NSAssert(actualAcceleration - expectedAcceleration <= 0.5, @"Wrong max value\n");
}

+ (void)setUp
{    
    // Set-up code here.
    motor = [MotorController sharedInstance];
    NSAssert(motor, @"Failed to alloce + init singleton object\n");
    
    MotorController *anotherMotor = [MotorController sharedInstance];
    NSAssert(anotherMotor, @"Failed to alloc a singleton object\n");
    NSAssert(motor == anotherMotor, @"Singleton desing pattern failed\n");
    anotherMotor = nil;
}

+ (void)tearDown
{
    // Tear-down code here.
    [motor release]; motor = nil;
}

+ (void)testPollDeviceForData
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    for (NSUInteger poll = 1; poll <= 10; poll++) {
        NSDictionary * data = [motor pollDeviceForData];
        
        NSAssert(data, @"No data returned!\n");
        NSAssert([data objectForKey: @"Acceleration"], @"Failed to read acceleration");
        NSAssert([data objectForKey: @"Velocity"], @"Failed to read velocity");
        NSLog(@"Poll %lu / 10\tpollDeviceForData\n", (unsigned long)poll);
        [NSThread sleepForTimeInterval: 0.5f];
    }
    [pool drain]; pool = NULL;
}

// Note: Because we are working with unit testing code that's interfacing
//       with hardware. It is best that we do not do the 'setup' & 'teardown'
//       everytime so lets just perform a series of test skipping those two
//       steps.

+(void) performUnitTests {
    
    // Test hardware interfacing.
    [self setUp];
    [self accelerationTesting];
    [self velocityTesting];
    [self testPollDeviceForData];
    [self tearDown];
}

@end
