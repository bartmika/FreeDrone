//
//  BatteryMonitor.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "BatteryMonitor.h"

@implementation BatteryMonitor

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

static BatteryMonitor *sharedBatteryMonitor = nil;

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

+(BatteryMonitor*)sharedInstance {
    @synchronized([BatteryMonitor class]){
        if (!sharedBatteryMonitor) {
            sharedBatteryMonitor = [[BatteryMonitor alloc] init];
            [sharedBatteryMonitor startMonitoring];
        }
    }
    
    return sharedBatteryMonitor;
}

+(id)alloc
{
    @synchronized([BatteryMonitor class]) {
        sharedBatteryMonitor = [super alloc];
    }
    
    return sharedBatteryMonitor;
}

-(id)init {
    if (self = [super init]) {
        // Power Rating = 1200 mAh
        // Amps = 1.2 amps = 1200 mili-amps
        
        // Load up a default battery
        battery = [[Battery alloc] initWithPowerRating: 1200 amps: 1200];
    }
    
    return self;
}

-(void)dealloc {
    [battery release]; battery = nil;
    [super dealloc];
}

-(void)setBatteryWithAmps: (float) amps powerRating: (float) power {
    NSAssert(battery, @"Failed accessing battery!\n");
    [battery setAmps: amps];
    [battery setPowerRating: power];
}

-(void)startMonitoring {
    startUsageTime = [NSDate date];
}

-(NSTimeInterval)batteryRuntimeInHours {
    // Calculate how much time (in seconds) elapsed since we started monitoring
    // the battery and convert the durration to hours (and remove negative).
    NSTimeInterval durrationInSeconds = [startUsageTime timeIntervalSinceNow];
    NSTimeInterval durrationInHours = durrationInSeconds / (-360.0f);
    return durrationInHours;
}


-(float) percentEnergyRemaining {
    NSTimeInterval durrationInHours = [self batteryRuntimeInHours];
    
    // Use the formulat for determine the power rating fora  batter and find out
    // how much amp hours we used up. The formula is:
    // C = xT
    // Where
    //      c = amp hours measured in amp hours
    //      x = amps measured in amps
    //      T = time measured in hours.
    float usedAmpHours = [battery amps] * (float)durrationInHours;
    
    // Subtract the currently used amp hours with the general battery power
    // rating and turn into percent to output remaining power left as a
    // percentage.
    return (([battery powerRating] - usedAmpHours) / [battery powerRating] ) * 100;
}

-(NSTimeInterval)remainingBatteryRuntimeInHours {
    // C = xT
    // :. T = C / x
    float newPowerRating = [battery powerRating] * ( [self percentEnergyRemaining] /100.0f );
    return newPowerRating / [battery amps];
}

-(BOOL) deviceIsOperational {
    return YES;
}

-(NSDictionary*) pollDeviceForData {
    NSNumber * percentEnergyRemainingNumber = [NSNumber numberWithFloat: [self percentEnergyRemaining]];
    NSNumber * remainingRuntimeHours = [NSNumber numberWithFloat: (float)[self remainingBatteryRuntimeInHours]];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:
                           percentEnergyRemainingNumber, @"PercentRemaining",
                           remainingRuntimeHours, @"RemainingHours", nil];
    
    return data;
}

@end
