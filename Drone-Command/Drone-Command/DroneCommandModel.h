//
//  DroneCommandModel.h
//  Drone-Command
//
//  Created by Bartlomiej Mika on 2013-07-07.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "Common.h"
#import "RemoteMonitorOperation.h"
#import "RemoteControlOperation.h"
#import "VirtualMotorController.h"
#import "VirtualServoController.h"

@interface DroneCommandModel : NSObject {
    // Internal Variables
    NSOperationQueue * taskQueue;
    RemoteControlOperation * remoteControl;
    RemoteMonitorOperation * remoteMonitor;
    VirtualMotorController * virtualMotorController;
    VirtualServoController * virtualServoController;
    
    // External Variables
    BOOL connectedWithDroneServer;
}

+(DroneCommandModel*) sharedInstance;

-(void) dealloc;

-(BOOL) isConnectedWithRemoteServer;

-(BOOL) connectToHostname: (NSString*) remoteComputerHostname
        remoteControlPort: (int) remoteControlPort
        remoteMonitorPort: (int) remoteMonitorPort;

-(void) setVelocity: (float) motorVelocity;

-(void) setAcceleration: (float) motorAcceleration;

-(void) engage;
-(void) setPosition: (float) servoPosition;
-(void) disengage;

-(NSDictionary *) remoteDeviceInformation;

-(void) disconnect;
@end
