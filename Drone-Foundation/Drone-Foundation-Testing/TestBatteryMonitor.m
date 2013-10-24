//
//  TestBatteryMonitor.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestBatteryMonitor.h"

@implementation TestBatteryMonitor

static NSAutoreleasePool * pool = nil;
static BatteryMonitor * batteryMonitor = nil;

+ (void)setUp
{
    pool = [NSAutoreleasePool new];
    batteryMonitor = [BatteryMonitor new];
}

+(void)tearDown
{
    [batteryMonitor release]; batteryMonitor = nil;
    [pool drain]; pool = nil;
}

+(void)testBatteryRuntimeInHours {
    // Start the battery usgage now, meaning the battery is being used currently.
    [batteryMonitor startMonitoring];
    
    [NSThread sleepForTimeInterval: 5.0f]; // Wait for 5 second.
    NSAssert([batteryMonitor batteryRuntimeInHours] > 0, @"Wrong runtime durration\n");
}

+(void)testPercentEnergyRating
{
    // Power Rating = 1200 mAh
    // Amps = 1.2 amps = 1200 mili-amps
    [batteryMonitor setBatteryWithAmps: 1200 powerRating: 1200];
    
    // Start the battery usgage now, meaning the battery is being used currently.
    [batteryMonitor startMonitoring];
    
    [NSThread sleepForTimeInterval: 5.0f]; // Wait for 5 second.
    
    float percentEnergyRemaining = [batteryMonitor percentEnergyRemaining];
    NSAssert(percentEnergyRemaining <= 100.0f, @"Wrong percent!");
}

+(void)testRemainingBatteryRuntimeInHours
{
    // Power Rating = 1200 mAh
    // Amps = 1.2 amps = 1200 mili-amps
    [batteryMonitor setBatteryWithAmps: 1200 powerRating: 1200];
    
    // Start the battery usgage now, meaning the battery is being used currently.
    [batteryMonitor startMonitoring];
    
    [NSThread sleepForTimeInterval: 5.0f]; // Wait for 5 second.
    
    float hoursRemaining = [batteryMonitor remainingBatteryRuntimeInHours];
    NSAssert(hoursRemaining < 1.0f && hoursRemaining > 0.95f, @"Wrong hours remaining");
}

+(void) testPollDeviceForData {
    NSDictionary * data = [batteryMonitor pollDeviceForData];
    NSAssert(data, @"Failed to poll for data\n");
    NSAssert([data objectForKey: @"PercentRemaining"], @"Failed to get Percent remaining");
    NSAssert([data objectForKey: @"RemainingHours"], @"Failed to get Remaining hours");
}

+(void) performUnitTests {
    NSLog(@"BatteryMonitor\n");
    [self setUp]; [self testBatteryRuntimeInHours];          [self tearDown];
    [self setUp]; [self testPercentEnergyRating];            [self tearDown];
    [self setUp]; [self testRemainingBatteryRuntimeInHours]; [self tearDown];
    [self setUp]; [self testPollDeviceForData];              [self tearDown];
    NSLog(@"BatteryMonitor: Successful\n\n");
}

@end
