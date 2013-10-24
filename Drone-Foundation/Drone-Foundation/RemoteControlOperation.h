//
//  DroneRemoteOperation.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-17.
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
#import "NSArray+CSV.h"
#import "NSMutableArray+Queue.h"
#import "NSMutableArray+Stack.h"
#import "AutoPilotOperation.h"

/**
 * DroneRemoteOperation
 *-------------
 *  This is a cross-platform networking socket used to communicate between
 *  a (baystation) client and a (drone) server. Currently 'distributed objects'
 *  betwen Apple & Non-Apple computers do not work; as a result, this class is
 *  ment to bridge the divide betwen the different platforms and allow them to
 *  communicate among themselves in relation to Drone controlling.
 *
 *  To use this class, two conditions need to be met:
 *      1) This class must run on a server (drone) and client (baystation).
 *          i) Both client and server must call "start" first
 *          ii) Client calls "connect"
 *          iii) Server calls "listen"
 *      2) Everytime a client wants to submit a command to the server, the
 *         client must use the "setIsReadyToSend: YES" function.
 */
@interface RemoteControlOperation : NSOperation {
    // NSOperational related variables
    //---------------------------------------
    BOOL executing;
    BOOL finished;
    
    // Network related variables
    //---------------------------------------
    // Our network connection between the two computers.
    ReliableSocket * socket;
    
    // Variable determines how long we will delay the threading loop in-between
    // loop cycles so the computer doesn't use too-much computer cycles on the
    // loops.
    NSTimeInterval serviceLoopDelayInterval;
    
    // Variable determines when we are ready to fully send a command from
    // the client to the server.
    BOOL isReadyToSend;
    
    // Hardware related variables
    //----------------------------------------
    // Server Side
    id <MotorControlling> motorController;
    id <ServoControlling> servoController;
    AutoPilotOperation * autoPilot;
    
    // Client Side
    float motorAcceleration;
    float motorVelocity;
    BOOL servoEngaged;
    float servoPosition;
}

// SERVER
//--------

- (void)startListeningOnPort: (NSUInteger) hostPort;

@property (atomic, strong) id <MotorControlling> motorController;
@property (atomic, strong) id <ServoControlling> servoController;
@property (atomic, strong) AutoPilotOperation *autoPilot;

// CLIENT
//--------

@property (atomic) float motorAcceleration;
@property (atomic) float motorVelocity;
@property (atomic) BOOL servoEngaged;
@property (atomic) float servoPosition;
@property (atomic) BOOL isReadyToSend;

- (void)connectToServerAtHostname: (NSString*) hostnameString
                             port: (NSUInteger) hostPort;

// BOTH
//--------

- (id)init;

- (void)dealloc;

@property (atomic) NSTimeInterval serviceLoopDelayInterval;

@end
