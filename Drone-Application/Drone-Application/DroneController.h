//
//  DroneApplication.h
//  Drone-Application
//
//  Created by Bartlomiej Mika on 2013-06-18.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "GPSReader.h"
#import "SpatialReader.h"
#import "MotorController.h"
#import "ServoController.h"
#import "BatteryMonitor.h"
#import "RemoteControlOperation.h"
#import "RemoteMonitorOperation.h"
#import "AutoPilotOperation.h"
#import "DroneLoggerOperation.h"

#ifndef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
    #define kHostname @"raspberrypi"
#else
    #define kHostname @"Bartlomiejs-Mac-mini.local"
#endif
#define kPortNumberForRemoteControl 12345
#define kPortNumberForRemoteMonitor 123456

@interface DroneController : NSObject {
    // Static Variables
    NSOperationQueue * taskQueue;
    
    // Services
    RemoteControlOperation * remoteControlOperation;
    RemoteMonitorOperation * remoteMonitorOperation;
    AutoPilotOperation * autoPilotOperation;
    DroneLoggerOperation * droneLoggerOperation;
    
    // Hardware Abstract layers
    GPSReader * gpsReader;
    SpatialReader * spatialReader;
    MotorController * motorController;
    ServoController * servoController;
    BatteryMonitor * batteryMonitor;
    
    BOOL isRunning;
    
}

@property (atomic) BOOL isRunning;

-(id) init;

-(void) dealloc;

-(void) tickWithDelay: (NSTimeInterval) sec;

@end
