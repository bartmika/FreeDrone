//
//  TestVirtualBatteryMonitor.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestVirtualBatteryMonitor.h"

@implementation TestVirtualBatteryMonitor

static NSAutoreleasePool * pool = nil;
static VirtualBatteryMonitor * batteryMonitor = nil;

+ (void)setUp
{
    pool = [NSAutoreleasePool new];
    batteryMonitor = [VirtualBatteryMonitor new];
}

+(void)tearDown
{
    [batteryMonitor release]; batteryMonitor = nil;
    [pool drain]; pool = nil;
}

+(void)testPercentEnergyRating
{
    [batteryMonitor setPowerRating: 1200]; // 1200 mAh
    [batteryMonitor setAmps: 1200]; // 1.2 amps = 1200 mili-amps
    
    // Start the battery usgage now, meaning the battery is being used currently.
    [batteryMonitor startMonitoring];
    
    [NSThread sleepForTimeInterval: 5.0f]; // Wait for 5 second.
    
    // Virtual settings.
    [batteryMonitor setPercentEnergyRemaining: 99.9f];
    
    float percentEnergyRemaining = [batteryMonitor percentEnergyRemaining];
    NSAssert(percentEnergyRemaining <= 100.0f, @"Wrong percent!");
}

+(void)testRemainingBatteryRuntimeInHours
{
    [batteryMonitor setPowerRating: 1200]; // 1200 mAh
    [batteryMonitor setAmps: 1200]; // 1.2 amps = 1200 mili-amps
    
    // Start the battery usgage now, meaning the battery is being used currently.
    [batteryMonitor startMonitoring];
    
    [NSThread sleepForTimeInterval: 5.0f]; // Wait for 5 second.
    
    // Virtual setting
    [batteryMonitor setRemainingBatteryRuntimeInHours: 0.98f];
    
    float hoursRemaining = [batteryMonitor remainingBatteryRuntimeInHours];
    NSAssert(hoursRemaining < 1.0f && hoursRemaining > 0.95f, @"Wrong hours remaining");
}

+(void) performUnitTests {
    NSLog(@"VirtualBatteryMonitor\n");
    [self setUp];
    [self testPercentEnergyRating];
    [self tearDown];
    [self setUp];
    [self testRemainingBatteryRuntimeInHours];
    [self tearDown];
    NSLog(@"VirtualBatteryMonitor: Successful\n\n");
}

@end
