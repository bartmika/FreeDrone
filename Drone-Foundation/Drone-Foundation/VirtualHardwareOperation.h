//
//  VirtualHardwareOperation.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "VirtualGPSReader.h"
#import "VirtualSpatialReader.h"
#import "VirtualMotorController.h"
#import "VirtualServoController.h"

@interface VirtualHardwareOperation : NSOperation {
    // Virtual Hardware Interface
    VirtualGPSReader * gpsReader;
    VirtualSpatialReader * motionReader;
    VirtualMotorController * motorController;
    VirtualServoController * servoController;
    
    // Concurrency related variables
    BOOL executing;
    BOOL finished;
    
    // Variable dictates how long we are to delay before we run a loop.
    NSTimeInterval virtualHardwareDelayInterval;
    
    // Physics
    float actualPropulsionVelocity; // meters per second
    float velocityEfficiencyFactor;
    float currentHeading;
}

@property (atomic, retain) VirtualGPSReader * gpsReader;
@property (atomic, retain) VirtualSpatialReader * motionReader;
@property (atomic, retain) VirtualMotorController * motorController;
@property (atomic, retain) VirtualServoController * servoController;
@property (atomic) NSTimeInterval virtualHardwareDelayInterval;
@property (atomic) float velocityEfficiencyFactor;

-(id) init;

-(id)initWithGPSReader: (VirtualGPSReader*) gps
          motionReader: (VirtualSpatialReader*) motion
       motorController: (VirtualMotorController*) motor
       servoController: (VirtualServoController*) servo;

-(void) dealloc;

- (void) start;

- (BOOL)isConcurrent;

- (BOOL)isExecuting;

- (BOOL)isFinished;

- (void)completeOperation;

@end
