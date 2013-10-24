//
//  BatteryMonitoring.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-29.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "HardwareLogging.h"

@protocol BatteryMonitoring <HardwareLogging>

-(NSTimeInterval)batteryRuntimeInHours;

-(float)percentEnergyRemaining;

-(NSTimeInterval)remainingBatteryRuntimeInHours;

@end
