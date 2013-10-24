//
//  TestDroneRemoteOperation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-17.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestRemoteControlOperation.h"

@implementation TestRemoteControlOperation

static NSUInteger sessionFinishCount = 0;
static NSAutoreleasePool * pool = nil;
static NSOperationQueue *operationQueue = nil;
static RemoteControlOperation *serverOperation = nil;
static RemoteControlOperation *clientOperation = nil;
static VirtualMotorController *serverMotorController = nil;
static VirtualServoController *serverServoController = nil;

+(void)setUp {
    sessionFinishCount = 0;
    pool = [NSAutoreleasePool new];
    operationQueue = [[NSOperationQueue new] autorelease];
    serverOperation = [[RemoteControlOperation new] autorelease];
    clientOperation = [[RemoteControlOperation new] autorelease];
    
    // Initialize our services
    serverMotorController = [[VirtualMotorController new] autorelease];
    serverServoController = [[VirtualServoController new] autorelease];
    [serverOperation setServoController: serverServoController];
    [serverOperation setMotorController: serverMotorController];
    [operationQueue addOperation: serverOperation];
    [operationQueue addOperation: clientOperation];
    
    // Setup our services
    [serverOperation startListeningOnPort: kRemoteControlPortNumber];
    [NSThread sleepForTimeInterval: 0.25f];
    [clientOperation connectToServerAtHostname: kRemoteControlHostname
                                          port: kRemoteControlPortNumber];
}

+(void)tearDown {
    sessionFinishCount = 0;
    [pool drain]; pool = nil;
}

+(void)serverSession {
    NSAutoreleasePool * threadPool = [NSAutoreleasePool new];
    
    [[NSThread currentThread] setName:@"Unit-Test-Server"];
    
    // Run for a durration of 1 minute
    for (NSUInteger timeDurration = 1.; timeDurration <= 61; timeDurration++) {        
        if ([serverServoController isEngaged]) {
            NSAssert([serverServoController position], @"Wrong position\n");
            NSAssert([serverMotorController acceleration], @"Wrong acceleration\n");
            NSAssert([serverMotorController velocity], @"Wrong velocity\n");
            NSLog(@"Time: %li sec Vel: %f Acc: %f Pos: %f Eng: %i\n",
                  (unsigned long)timeDurration,
                  [serverOperation motorVelocity],
                  [serverOperation motorAcceleration],
                  [serverOperation servoPosition],
                  [serverOperation servoEngaged]);
        }
                
        // Wait for 1 second.
        [NSThread sleepForTimeInterval: 1.0f];
    }
    
    [threadPool drain]; threadPool = nil;
    sessionFinishCount++;
}

+(void)clientSession {
    NSAutoreleasePool * threadPool = [NSAutoreleasePool new];
    
    // Name the thread to aid debugging.
    [[NSThread currentThread] setName:@"Unit-Test-Client"];
    
    // Run for a durration of 30 seconds
    for (NSUInteger timeDurration = 1.; timeDurration <= 31; timeDurration++) {
        // Attemp our controls
        [clientOperation setMotorAcceleration: timeDurration];
        [clientOperation setMotorVelocity: timeDurration];
        [clientOperation setServoPosition: timeDurration];
        [clientOperation setServoEngaged: YES];
        
        // Indicate to our service we have finished our command and transmit it.
        [clientOperation setIsReadyToSend: YES];
        
        // Wait for 1 second.
        [NSThread sleepForTimeInterval: 1.0f];
    }
    
    
    [threadPool drain]; threadPool = nil;
    sessionFinishCount++;
}

+(void) performUnitTests {
    NSLog(@"DroneRemoteOperation\n");
    [self setUp];
    
    // Algorithm:
    //  Load up the server thread which will handle all server-side unit tests
    //  and then wait for a few seconds to give time for the server to load up
    //  before calling a client thread with all client-based unit tests.
    [NSThread detachNewThreadSelector: @selector(serverSession) toTarget: self withObject: nil];
    [NSThread sleepForTimeInterval: 1.0f];
    [NSThread detachNewThreadSelector: @selector(clientSession) toTarget: self withObject: nil];
    
    // While the server and client sessions are running, make our main thread
    // sleep.
    while (sessionFinishCount < 2) {
        [NSThread sleepForTimeInterval: 1.0f];
    }
    
    [self tearDown];
    NSLog(@"DroneRemoteOperation: Successful\n\n");
}

@end
