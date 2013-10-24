//
//  TestBattery.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestBattery.h"

@implementation TestBattery

static NSAutoreleasePool * pool = nil;
static Battery * battery = nil;

+ (void)setUp
{
    pool = [NSAutoreleasePool new];
    battery = [Battery new];
    NSAssert(battery, @"Failed to init.\n");
}

+(void)tearDown
{
    [battery release]; battery = nil;
    [pool drain]; pool = nil;
}

+(void)testProperties {
    [battery setPowerRating: 1200];
    [battery setAmps: 1200];
    
    NSAssert([battery powerRating] == 1200, @"Wrong power rating\n");
    NSAssert([battery amps] == 1200, @"Wrong amps\n");
}

+(void) performUnitTests {
    NSLog(@"Battery\n");
    [self setUp];
    [self testProperties];
    [self tearDown];
    NSLog(@"Battery: Succesful\n\n");
}

@end
