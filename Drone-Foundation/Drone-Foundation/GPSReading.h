//
//  GPSReading.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "GPSFormatter.h"
#import "GPSCoordinate.h"
#import "GPSNavigation.h"
#import "HardwareLogging.h"

@protocol GPSReading <HardwareLogging>

@required
-(GPSCoordinate*) coordinate;

@optional
-(const float) altitude;

-(const float) heading;

-(const float) speed;

@end
