//
//  DroneCommandController.m
//  Drone-Command
//
//  Created by Bartlomiej Mika on 2013-07-07.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "DroneCommandController.h"

@implementation DroneCommandController

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

static DroneCommandController * sharedDroneCommandController = nil;

-(void) initializationProcessing {
    char command = [view printInitializationMenu];
    NSAssert(command, @"No command returned");
    
    switch (command) {
        case '1': // Remote to local computer
            [model connectToHostname: kCurrentComputerHostname
                   remoteControlPort: kRemoteControlPort
                   remoteMonitorPort: kRemoteMonitorPort];
            break;
        case '2': // Connect to remote computer
            [model connectToHostname: kRemoteComputerHostname
                   remoteControlPort: kRemoteControlPort
                   remoteMonitorPort: kRemoteMonitorPort];
            break;
        default:
            break;
    }
}

-(void) mainMenuProcessing {
    char command = [view printMainMenu];
    
    float value = 0.0f;
    
    // Perform the following
    switch (command) {
        case SET_VELOCITY:
            value = [view getFloatFromConsoleWithString: "Velocity (m/s): "];
            [model setVelocity: value];
            break;
        case SET_ACCELERATION:
            value = [view getFloatFromConsoleWithString: "Acceleration (m/s^2): "];
            [model setAcceleration: value];
            break;
        case ENGAGE:
            [model engage];
            break;
        case SET_POSITION:
            value = [view getFloatFromConsoleWithString: "Position (degrees): "];
            [model setPosition: value];
            break;
        case DISENGAGE:
            [model disengage];
            break;
        case NULL_COMMAND: // Do Nothing
            break;
        case EXIT_APPLICATION:
            [model disconnect];
            serviceLoopIsRunning = NO;
            break;
        default:
            printf("Unsupported operation\n");
            break;
    }
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

+(DroneCommandController*) sharedInstance {
    @synchronized([DroneCommandController class]) {
        if (!sharedDroneCommandController) {
            sharedDroneCommandController = [[DroneCommandController alloc] init];
        }
    }
    
    return sharedDroneCommandController;
}

+(id) alloc {
    @synchronized([DroneCommandController class]) {
        sharedDroneCommandController = [super alloc];
    }
    
    return sharedDroneCommandController;
}

-(id)init{
    if (self = [super init]) {
        model = [DroneCommandModel sharedInstance];
        view = [DroneCommandView sharedInstance];
        serviceLoopDelayInterval = 0.5f;
        serviceLoopIsRunning = YES;
    }
    
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) runMainServiceLoop {
    while (serviceLoopIsRunning) {
        NSAutoreleasePool * serviceLoopPool = [NSAutoreleasePool new];
        
        // If we are not connected with the server then perform the following
        // set of logic.
        if (![model isConnectedWithRemoteServer]) {
            [self initializationProcessing];
        } else {
            [self mainMenuProcessing];
        }
        
        [NSThread sleepForTimeInterval: serviceLoopDelayInterval];
        [serviceLoopPool drain]; serviceLoopPool = nil;
    }
}

@end
