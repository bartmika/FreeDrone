//
//  RemoteMonitorOperation.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-29.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "ReliableSocket.h"
#import "GPSReading.h"
#import "SpatialReading.h"
#import "MotorControlling.h"
#import "ServoControlling.h"
#import "BatteryMonitoring.h"
#import "NSArray+CSV.h"
#import "NSMutableArray+Queue.h"
#import "NSMutableArray+Stack.h"

@interface RemoteMonitorOperation : NSOperation {
    // NSOperational related variables
    //---------------------------------------
    BOOL executing;
    BOOL finished;
    
    // Network related variables
    //---------------------------------------
    // Our network connection between the two computers.
    ReliableSocket * socket; //TODO: Replace with unreliable sockets.
    
    // Variable determines how long we will delay the threading loop in-between
    // loop cycles so the computer doesn't use too-much computer cycles on the
    // loops.
    NSTimeInterval serviceLoopDelayInterval;
        
    // Hardware related variables
    //----------------------------------------
    id <GPSReading> gpsReader;
    id <SpatialReading> spatialReader;
    id <MotorControlling> motorController;
    id <ServoControlling> servoController;
    id <BatteryMonitoring> batteryMonitor;
    
    // Our Recent Most Data
    NSDictionary * deviceInformation;
}


// SERVER
//--------

- (void)startListeningOnPort: (NSUInteger) hostPort;

@property (atomic, strong) id <GPSReading> gpsReader;
@property (atomic, strong) id <SpatialReading> spatialReader;
@property (atomic, strong) id <MotorControlling> motorController;
@property (atomic, strong) id <ServoControlling> servoController;
@property (atomic, strong) id <BatteryMonitoring> batteryMonitor;
@property (atomic) NSTimeInterval serviceLoopDelayInterval;

// CLIENT
//--------

- (void) connectToServerAtHostname: (NSString*) hostnameString port: (NSUInteger) hostPort;

// BOTH
//--------

- (id)init;

- (void)dealloc;

@property (atomic, readonly) NSDictionary * deviceInformation;

@end
