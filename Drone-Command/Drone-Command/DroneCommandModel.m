//
//  DroneCommandModel.m
//  Drone-Command
//
//  Created by Bartlomiej Mika on 2013-07-07.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "DroneCommandModel.h"

@implementation DroneCommandModel

static DroneCommandModel * sharedDroneCommandModel = nil;

+(DroneCommandModel*) sharedInstance {
    @synchronized([DroneCommandModel class]) {
        if (!sharedDroneCommandModel) {
            sharedDroneCommandModel = [[DroneCommandModel alloc] init];
        }
    }
    
    return sharedDroneCommandModel;
}

+(id) alloc {
    @synchronized([DroneCommandModel class]) {
        sharedDroneCommandModel = [super alloc];
    }
    
    return sharedDroneCommandModel;
}

-(id)init{
    if (self = [super init]) {
        taskQueue = [NSOperationQueue new];
        remoteControl = [RemoteControlOperation new];
        remoteMonitor = [RemoteMonitorOperation new];
        virtualMotorController = [VirtualMotorController new];
        virtualServoController = [VirtualServoController new];
        
        [remoteControl setMotorController: virtualMotorController];
        [remoteControl setServoController: virtualServoController];
        [taskQueue addOperation: remoteControl];
        [taskQueue addOperation: remoteMonitor];
    }
    
    return self;
}


-(void) dealloc {
    [taskQueue release]; taskQueue = nil;
    [remoteControl release]; remoteControl = nil;
    [remoteMonitor release]; remoteMonitor = nil;
    [virtualServoController release]; virtualServoController = nil;
    [virtualMotorController release]; virtualMotorController = nil;
    [super dealloc];
}

-(BOOL) isConnectedWithRemoteServer {
    return connectedWithDroneServer;
}

-(BOOL) connectToHostname: (NSString*) remoteComputerHostname
        remoteControlPort: (int) remoteControlPort
        remoteMonitorPort: (int) remoteMonitorPort {
    [remoteControl connectToServerAtHostname: remoteComputerHostname port: remoteControlPort];
    [remoteMonitor connectToServerAtHostname: remoteComputerHostname port: remoteMonitorPort];
    connectedWithDroneServer = YES;
    return connectedWithDroneServer;
}


-(void) setVelocity: (float) motorVelocity {
    NSAssert(motorVelocity >= 0, @"Cannot be negative\n");
    [remoteControl setMotorVelocity: motorVelocity];
    [remoteControl setIsReadyToSend: YES];
}

-(void) setAcceleration: (float) motorAcceleration {
    
    NSAssert(motorAcceleration >= 0, @"Cannot be negative\n");
    [remoteControl setMotorAcceleration: motorAcceleration];
    [remoteControl setIsReadyToSend: YES];
}

-(void) engage {
    [remoteControl setServoEngaged: YES];
    [remoteControl setIsReadyToSend: YES];
}

-(void) setPosition: (float) servoPosition {
    NSAssert(servoPosition >= 0, @"Cannot be negative\n");
    [remoteControl setServoPosition: servoPosition];
    [remoteControl setIsReadyToSend: YES];
}

-(void) disengage {
    [remoteControl setServoEngaged: NO];
    [remoteControl setIsReadyToSend: YES];
}


-(NSDictionary *) remoteDeviceInformation {
    return [remoteMonitor deviceInformation];
}


-(void) disconnect {
    if ([remoteControl isExecuting]) {
         [remoteControl cancel];
    }
    if ([remoteMonitor isExecuting]) {
        [remoteMonitor cancel];
    }
}

@end
