//
//  SpatialReading.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "HardwareLogging.h"
#import "SpatialData.h"

@protocol SpatialReading <HardwareLogging>

@required
- (rotation_t) anglesOfRotationInDegrees;

- (double) compassHeadingInDegrees;

-(acceleration_t) acceleration;

-(angularRotation_t) angularRotation;

-(magneticField_t) magneticField;

@end
