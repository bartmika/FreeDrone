//
//  BatteryMonitor.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "Battery.h"
#import "BatteryMonitoring.h"

@interface BatteryMonitor : NSObject <BatteryMonitoring> {
    NSDate * startUsageTime;
    Battery * battery;
}

+(BatteryMonitor*)sharedInstance;

-(void)dealloc;

-(void)setBatteryWithAmps: (float) amps powerRating: (float) power;

-(void)startMonitoring;

@end

// Special help:
//  http://www.societyofrobots.com/batteries.shtml
