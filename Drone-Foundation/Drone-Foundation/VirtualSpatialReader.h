//
//  VirtualSpatialReader.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "SpatialReading.h"
#import "NSMutableArray+Queue.h"
#import "NSArray+CSV.h"

@interface VirtualSpatialReader : NSObject <SpatialReading> {
    NSMutableArray * angles;
    NSMutableArray * compass;
    NSMutableArray * acc;
    NSMutableArray * ang;
    NSMutableArray * mag;
    
    NSMutableArray * usageLog;
    BOOL keepUsageLog;
    
    // Manual
    float compassHeading;
}

@property (atomic) float compassHeading;
@property (atomic, retain) NSMutableArray * usageLog;
@property (atomic) BOOL keepUsageLog;

+(VirtualSpatialReader*) sharedInstance;

- (rotation_t) anglesOfRotationInDegrees;

- (float) compassHeadingInDegrees;

-(acceleration_t) acceleration;

-(angularRotation_t) angularRotation;

-(magneticField_t) magneticField;

-(NSDictionary*) pollDeviceForData;

-(void) populateFromCsvFile: (NSString*) csvFilePathURL;

@end
