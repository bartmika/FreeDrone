//
//  AutoPilotOperation.h
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
#import "NSMutableArray+Queue.h"
#import "NSMutableArray+Stack.h"

@interface AutoPilotOperation : NSOperation {
    // NSOperational related variables
    BOOL executing;
    BOOL finished;
    
    // Hardware Abstraction Layer
    id <GPSReading> gpsReader;
    id <SpatialReading> motionReader;
    id <MotorControlling> motorController;
    id <ServoControlling> servoController;
    
    // AutoPilot configuration variables
    NSTimeInterval autoPilotDelayInterval;
    BOOL manualOverride;
    float arrivedAtWaypointAcceptedDistanceInMetres;
    float turningDegreePrecision;
    float targetTravellingVelocity;
    float currentVelocity;
    
    // Turing
    float largeBearingDegrees;
    
    // Usage variables
    NSMutableArray * waypoints;
    NSLock * waypointsIO;
}

@property (atomic) BOOL manualOverride;
@property (atomic, strong) id <GPSReading> gpsReader;
@property (atomic, strong) id <SpatialReading> motionReader;
@property (atomic, strong) id <MotorControlling> motorController;
@property (atomic, strong) id <ServoControlling> servoController;

- (id)init;

- (void)dealloc;

- (void) start;

- (BOOL)isConcurrent;

- (BOOL)isExecuting;

- (BOOL)isFinished;

- (void)completeOperation;

-(void) addWaypointAtLatitude: (float) latitudeValue longitude: (float) longitude;

-(NSUInteger) numberOfWaypoints;

@end
