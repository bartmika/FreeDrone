//
//  DroneLoggerOperation.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "GPSReader.h"
#import "SpatialReader.h"
#import "MotorController.h"
#import "ServoController.h"
#import "NSArray+CSV.h"

@interface DroneLoggerOperation : NSOperation {
    // State management
    BOOL executing;
    BOOL finished;
    
    // Objects which communicate with our hardware devices.
    GPSReader * gpsReader;
    SpatialReader * spatialReader;
    MotorController * motorController;
    ServoController * servoController;
    
    // Temporal management variables
    NSTimeInterval timeDelayInterval;
    
    // Writing objects
    NSString * gpsReaderLoggingFileLocation;
    NSString * SpatialReaderLoggingFileLocation;
    NSString * servoControllerLoggingFileLocation;
    NSString * motorControllerLoggingFileLocation;
    
    NSStringEncoding encoding;
    NSError * error;
    
    NSFileHandle * fileHandler;
}

@property (atomic) NSTimeInterval timeDelayInterval;

- (id)init;

- (void)start;

@end
