//
//  TestServoController.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-09.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestServoController.h"

@implementation TestServoController

static ServoController * servo = nil;

+ (void)setterAndGetterTesting
{
    double testPosition = 200.0f;
    double expectedPosition = testPosition;
    double actualPosition = 275.0f;
    [servo engage];
    [servo setPosition: testPosition];
    [NSThread sleepForTimeInterval: 10];
    [servo disengage];
    actualPosition = [servo position];
    NSAssert(actualPosition - expectedPosition <= 0.5f, @"Wrong pos");
}

+ (void)setUp
{    
    // Set-up code here.
    // Verify our init + alloc work for the singleton pattern.
    servo = [ServoController sharedInstance];
    NSAssert(servo, @"Failed alloc+init our singleton object\n");
    
    // Verify our singleton design pattern is enforced.
    ServoController *anotherServo = [ServoController sharedInstance];
    NSAssert(anotherServo, @"Failed to initialize a singleton object\n");
    NSAssert(servo == anotherServo, @"Singleton design failed\n");
    anotherServo = nil;
}

+ (void)testPollDeviceForData
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    for (NSUInteger poll = 1; poll <= 10; poll++) {
        NSDictionary * data = [servo pollDeviceForData];
        
        NSAssert(data, @"No data returned!\n");
        NSLog(@"Poll %lu / 10\tpollDeviceForData\n", (unsigned long)poll);
        [NSThread sleepForTimeInterval: 0.5f];
    }
    [pool drain]; pool = NULL;
}

+ (void)tearDown
{
    // Tear-down code here.
    [servo release]; servo = nil;
}

// Note: Because we are working with unit testing code that's interfacing
//       with hardware. It is best that we do not do the 'setup' & 'teardown'
//       everytime so lets just perform a series of test skipping those two
//       steps.
+(void) performUnitTests {
    [self setUp];
    [self setterAndGetterTesting];
    [self testPollDeviceForData];
    [self tearDown];
}

@end
