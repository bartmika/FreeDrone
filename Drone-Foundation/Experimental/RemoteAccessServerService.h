//
//  RemoteAccessServerService.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-01.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "GPSReader.h"
#import "SpatialReader.h"
#import "ServoController.h"
#import "MotorController.h"
#import "BatteryMonitor.h"

@interface RemoteAccessServerService : NSObject {
    GPSReader * gpsReader;
    SpatialReader * spatialReader;
    ServoController * servoController;
    MotorController * motorController;
    BatteryMonitor * batteryMonitor;
}

@property (atomic, assign) GPSReader * gpsReader;
@property (atomic, assign) SpatialReader * spatialReader;
@property (atomic, assign) ServoController * servoController;
@property (atomic, assign) MotorController * motorController;
@property (atomic, assign) BatteryMonitor * batteryMonitor;

- (id) init;

- (void) dealloc;

- (void) startListeningForClient;

@end
