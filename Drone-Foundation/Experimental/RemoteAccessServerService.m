//
//  RemoteAccessServerService.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-01.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "RemoteAccessServerService.h"

@implementation RemoteAccessServerService

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

-(BOOL) vendSharedInstance: (id) sharedInstance
                serverName: (NSString *) name
{
    // Initialize the object that will be our ports.
    NSSocketPort * port = [[NSSocketPort alloc] init];
    
    // Initialize the object that will be 'vending' our object over TCP IP.
    NSConnection *theConnection = [NSConnection connectionWithReceivePort: port
                                                                 sendPort: port];
    // Set the object we are going to 'vend'.
    [theConnection setRootObject: sharedInstance];
    
    // Attempt to 'vend' our object over TCP IP / IPC.
    if ([theConnection registerName: name
                     withNameServer: [NSSocketPortNameServer sharedInstance]] == NO) {
        NSLog(@"Impossible to vend this object.");
        // TODO: handle
        return NO;
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

@synthesize gpsReader;
@synthesize spatialReader;
@synthesize motorController;
@synthesize servoController;
@synthesize batteryMonitor;

- (id) init {
    if (self = [super init]) {
        // Connect all the singleton objects which are responsible for
        // handling the hardware.
        gpsReader = [GPSReader sharedInstance];
        spatialReader = [SpatialReader sharedInstance];
        servoController = [ServoController sharedInstance];
        motorController = [MotorController sharedInstance];
        batteryMonitor = [BatteryMonitor sharedInstance];
        return self;
    } else {
        return nil;
    }
}

- (void) dealloc {
    gpsReader = nil; // Dealloc is not done to singleton.
    spatialReader = nil;
    motorController = nil;
    servoController = nil;
    batteryMonitor = nil;
    [super dealloc];
}

- (void) startListeningForClient {
    // Go through and vend all our objects.
    [self vendSharedInstance: gpsReader serverName: @"gpsServer"];
    [self vendSharedInstance: spatialReader serverName: @"motionServer"];
    [self vendSharedInstance: motorController serverName:@"motorServer"];
    [self vendSharedInstance: servoController serverName:@"servoServer"];
    [self vendSharedInstance: batteryMonitor serverName:@"batteryServer"];
}

@end

// Special Thanks:
//  http://www.gnustep.org/resources/documentation/Developer/Base/ProgrammingManual/manual_7.html
//  http://www.read-write.fr/blog/blog/2010/11/22/cocoa-distributed-objects-part-1/
