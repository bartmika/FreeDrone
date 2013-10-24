//
//  SpatialReader.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "SpatialReading.h"
#import "LowPassDataFilter.h"
#import "CompassBearing.h"
#import "PhidgetSpatialReader.h"
#import "HardwareLogging.h"

@interface SpatialReader : NSObject <SpatialReading, HardwareLogging>{
    // Hardware Variables.
    id reader;
}

+(SpatialReader*) sharedInstance;

-(void)dealloc;

-(BOOL) deviceIsOperational;

-(NSDictionary*) pollDeviceForData;

- (rotation_t) anglesOfRotationInDegrees;

- (float) compassHeadingInDegrees;

-(acceleration_t) acceleration;

-(angularRotation_t) angularRotation;

-(magneticField_t) magneticField;

@end
