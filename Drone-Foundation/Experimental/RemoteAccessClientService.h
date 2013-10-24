//
//  RemoteAccessClientService.h
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
#import "MotorController.h"
#import "ServoController.h"
#import "BatteryMonitor.h"

@interface RemoteAccessClientService : NSObject  {
    GPSReader * gpsReader;
    SpatialReader * spatialReader;
    ServoController * servoController;
    MotorController * motorController;
    BatteryMonitor * batteryMonitor;
}

-(id) init;

-(void) dealloc;

-(BOOL) connectToServerAtHostname: (NSString*) hostname
                       portNumber: (NSUInteger) port;

@property (atomic, readonly) GPSReader * gpsReader;
@property (atomic, readonly) SpatialReader * spatialReader;
@property (atomic, readonly) ServoController * servoController;
@property (atomic, readonly) MotorController * motorController;
@property (atomic, readonly) BatteryMonitor * batteryMonitor;

@end
