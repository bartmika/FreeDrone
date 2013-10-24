//
//  VirtualBatteryMonitor.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "VirtualBatteryMonitor.h"

@implementation VirtualBatteryMonitor

@synthesize startUsageTime;
@synthesize powerRating;
@synthesize amps;
@synthesize percentEnergyRemaining;
@synthesize remainingBatteryRuntimeInHours;
@synthesize batteryRuntimeInHours;

-(id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

-(void)dealloc {
    [super dealloc];
}

-(void)startMonitoring {
    startUsageTime = [NSDate date];
}

-(BOOL) deviceIsOperational {
    return YES;
}

-(NSDictionary *) pollDeviceForData {
    NSNumber * percentEnergyRemainingNumber = [NSNumber numberWithFloat: [self percentEnergyRemaining]];
    NSNumber * remainingRuntimeHours = [NSNumber numberWithFloat: (float)[self remainingBatteryRuntimeInHours]];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:
                           percentEnergyRemainingNumber, @"PercentRemaining",
                           remainingRuntimeHours, @"RemainingHours", nil];
    
    return data;
}

@end
