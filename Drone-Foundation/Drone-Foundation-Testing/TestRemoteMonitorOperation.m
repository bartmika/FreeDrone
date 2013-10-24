//
//  TestRemoteMonitorOperation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-29.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestRemoteMonitorOperation.h"

@implementation TestRemoteMonitorOperation

static NSUInteger sessionFinishCount = 0;
static NSAutoreleasePool * pool = nil;
static NSOperationQueue *operationQueue = nil;
static RemoteMonitorOperation *serverOperation = nil;
static RemoteMonitorOperation *clientOperation = nil;
static VirtualMotorController *serverMotorController = nil;
static VirtualServoController *serverServoController = nil;
static VirtualGPSReader * serverGPSReader = nil;
static VirtualSpatialReader * serverSpatialReader = nil;
static VirtualBatteryMonitor * serverBatteryMonitor = nil;

+(void)setUp {
    sessionFinishCount = 0;
    pool = [NSAutoreleasePool new];
    operationQueue = [[NSOperationQueue new] autorelease];
    serverOperation = [[RemoteMonitorOperation new] autorelease];
    clientOperation = [[RemoteMonitorOperation new] autorelease];
    
    // Initialize our services
    serverMotorController = [[VirtualMotorController new] autorelease];
    serverServoController = [[VirtualServoController new] autorelease];
    serverGPSReader = [[VirtualGPSReader new] autorelease];
    serverSpatialReader = [[VirtualSpatialReader new] autorelease];
    serverBatteryMonitor = [[VirtualBatteryMonitor new] autorelease];
    [serverOperation setServoController: serverServoController];
    [serverOperation setMotorController: serverMotorController];
    [serverOperation setGpsReader: serverGPSReader];
    [serverOperation setSpatialReader: serverSpatialReader];
    [serverOperation setBatteryMonitor: serverBatteryMonitor];
    [operationQueue addOperation: serverOperation];
    [operationQueue addOperation: clientOperation];
    
    // Setup our services
    [serverOperation startListeningOnPort: kRemoteMonitorPortNumber];
    [NSThread sleepForTimeInterval: 0.25f];
    [clientOperation connectToServerAtHostname: kRemoteMonitorHostname
                                          port: kRemoteMonitorPortNumber];
}

+(void)tearDown {
    sessionFinishCount = 0;
    [pool drain]; pool = nil;
}

+(void)serverSession {
    NSAutoreleasePool * threadPool = [NSAutoreleasePool new];
    
    [[NSThread currentThread] setName:@"Unit-Test-Server"];
    
    NSLog(@"[Server: Started]");
    
    // Run for a durration of 1 minute
    for (NSUInteger timeDurration = 1.; timeDurration <= 61; timeDurration++) {
        
        [serverServoController setPosition: timeDurration];
        [serverServoController engage];
        [serverMotorController setVelocity: timeDurration];
        [serverMotorController setAcceleration: timeDurration];
        [serverServoController setPosition: timeDurration];
        [serverSpatialReader setCompassHeading: timeDurration];
        [serverGPSReader setLatitudeValue: timeDurration];
        [serverGPSReader setLongitudeValue: timeDurration];
        [serverGPSReader setAltitudeValue: timeDurration];
        [serverGPSReader setHeadingValue: timeDurration];
        [serverBatteryMonitor setBatteryRuntimeInHours: timeDurration];
        [serverBatteryMonitor setPercentEnergyRemaining: timeDurration];
        
        // Wait for 1 second.
        [NSThread sleepForTimeInterval: 1.0f];
    }
    
    [threadPool drain]; threadPool = nil;
    sessionFinishCount++;
    NSLog(@"[Server: Finished]\n");
}

+(void)clientSession {
    NSAutoreleasePool * threadPool = [NSAutoreleasePool new];
    
    // Name the thread to aid debugging.
    [[NSThread currentThread] setName:@"Unit-Test-Client"];
    
    NSLog(@"[Client: Started]");
    
    // Run for a durration of 30 seconds
    for (NSUInteger timeDurration = 1.; timeDurration <= 31; timeDurration++) {
        NSDictionary * deviceInformation = [clientOperation deviceInformation];
        if (deviceInformation) {
            NSLog(@"[Client: Testing]\n");
            
            // Device Specific Information
            NSDictionary * servoInformation = [[deviceInformation objectForKey: @"Servo"] retain];
            NSAssert(servoInformation, @"Did not receive any Servo information");
            NSDictionary * motorInformation = [[deviceInformation objectForKey: @"Motor"] retain];
            NSAssert(motorInformation, @"Did not receive motor info.");
            NSDictionary * spatialInformation = [[deviceInformation objectForKey: @"Spatial"] retain];
            NSAssert(spatialInformation, @"No Spatial");
            NSDictionary * gpsInformation = [[deviceInformation objectForKey: @"GPS"] retain];
            NSAssert(gpsInformation, @"No GPS");
            NSDictionary * batteryInformation = [[deviceInformation objectForKey: @"Battery"] retain];
            NSAssert(batteryInformation, @"No battery!");
            
            [servoInformation release];
            [motorInformation release];
            [spatialInformation release];
            [gpsInformation release];
            [batteryInformation release];
        }
        
        // Wait for 1 second.
        [NSThread sleepForTimeInterval: 1.0f];
    }
    
    [threadPool drain]; threadPool = nil;
    sessionFinishCount++;
    NSLog(@"[Client: Finished]\n");
}


+(void) performUnitTests {
    NSLog(@"RemoteMonitorOperation\n");
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
    NSLog(@"RemoteMonitorOperation: Successful\n\n");
}

@end
