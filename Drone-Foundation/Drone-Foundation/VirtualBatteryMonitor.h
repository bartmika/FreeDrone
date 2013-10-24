//
//  VirtualBatteryMonitor.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "BatteryMonitoring.h"

@interface VirtualBatteryMonitor : NSObject <BatteryMonitoring> {
    NSDate * startUsageTime;
    float powerRating;
    float amps;
    float percentEnergyRemaining;
    float remainingBatteryRuntimeInHours;
    NSTimeInterval batteryRuntimeInHours;
}

@property (atomic, copy) NSDate* startUsageTime;
@property (atomic) float powerRating;
@property (atomic) float amps;
@property (atomic) float percentEnergyRemaining;
@property (atomic) float remainingBatteryRuntimeInHours;
@property (atomic) NSTimeInterval batteryRuntimeInHours;

-(id)init;

-(void)startMonitoring;

-(void)dealloc;

@end
