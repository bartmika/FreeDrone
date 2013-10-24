//
//  RemoteAccessClientService.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-01.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "RemoteAccessClientService.h"

@implementation RemoteAccessClientService


#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

-(id) vendedSharedSInstanceForHostname: (NSString *) hostname
                            portNumber: (NSUInteger) portNum
                        registeredName: (NSString*) name
{
    id proxy =
    [NSConnection rootProxyForConnectionWithRegisteredName: name
                                                      host: hostname
                                           usingNameServer: [NSSocketPortNameServer sharedInstance]];
    return proxy;
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

-(id) init {
    if (self = [super init]) {
        return self;
    } else {
        return nil;
    }
}

-(void) dealloc {
    gpsReader = nil;
    [super dealloc];
}

-(BOOL) connectToServerAtHostname: (NSString*) hostname
                       portNumber: (NSUInteger) portNum {
    
    // Store our reference to the 'vended object'.
    id vendedObject = [self vendedSharedSInstanceForHostname: hostname
                                                  portNumber: portNum
                                              registeredName: @"gpsServer"];
    gpsReader = (GPSReader*)vendedObject;
    
    vendedObject = [self vendedSharedSInstanceForHostname: hostname
                                               portNumber: portNum
                                           registeredName: @"motionServer"];
    spatialReader = (SpatialReader*)vendedObject;
    
    vendedObject = [self vendedSharedSInstanceForHostname: hostname
                                               portNumber: portNum
                                           registeredName: @"motorServer"];
    motorController = (MotorController*)vendedObject;
    
    vendedObject = [self vendedSharedSInstanceForHostname: hostname
                                               portNumber: portNum
                                           registeredName: @"servoServer"];
    servoController = (ServoController*)vendedObject;
    
    vendedObject = [self vendedSharedSInstanceForHostname: hostname
                                               portNumber: portNum
                                           registeredName: @"batteryServer"];
    batteryMonitor = (BatteryMonitor*)vendedObject;
    
    return YES;
}

@end
