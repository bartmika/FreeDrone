//
//  RemoteMonitorOperation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-29.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "RemoteMonitorOperation.h"

@implementation RemoteMonitorOperation

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

// Responsible for sending.
-(void) serverSessionTick {
    // Create the packet to send and delegate memory management to
    // NSAutoReleasePool in the main service loop.
    NSMutableData * data = [[NSMutableData alloc] init];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData: data];
    
    @try {
        // Poll all the attached devices and get their current information.
        NSDictionary * servoData = [servoController pollDeviceForData];
        NSDictionary * motorData = [motorController pollDeviceForData];
        NSDictionary * spatialData = [spatialReader pollDeviceForData];
        NSDictionary * gpsData = [gpsReader pollDeviceForData];
        NSDictionary * batteryData = [batteryMonitor pollDeviceForData];
        
        // Create a single dictionary with all our devices information and
        // encode it into binary.
        NSDictionary * droneData = [NSDictionary dictionaryWithObjectsAndKeys:
                                    servoData, @"Servo",
                                    motorData, @"Motor",
                                    spatialData, @"Spatial",
                                    gpsData, @"GPS",
                                    batteryData, @"Battery", nil];
        [droneData encodeWithCoder: archiver];
        [archiver finishEncoding]; // Finish Encoding
        
        // Transmit our encoded binary to the client.
        [socket sendData: data];
    }
    @catch (NSException *exception) {
        NSLog(@"%@\n", exception);
    }
    @finally {
        [data release];
        [archiver release];
    }
}

// Responsible for receiving
-(void) clientSessionTick {
    NSData * dronePacketBinary = nil;
    NSKeyedUnarchiver * unarchiver = nil;
    NSDictionary * receivedPacket = nil;
    
    @try {
        // Wait to receive data from the server.
        dronePacketBinary = [socket receiveData];
        
        // Perform our conversion back into our object and verify it worked
        unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: dronePacketBinary];
        receivedPacket = [[NSDictionary alloc] initWithCoder: unarchiver];
        
        // ALGORITHM:
        //  1) If the dicitonary object has already been initialized, then
        //     release it.
        //  2) Assign the new device information to the dictionary object and
        //     increase the retain count so it doesn't get cleaned up by the
        //     memory management.
        if (deviceInformation) {
            [deviceInformation release];
        }
        deviceInformation = [receivedPacket retain];
    }
    @catch (NSException *exception) {
        NSLog(@"%@\n", exception);
    }
    @finally { // Memory Management.
        [unarchiver release]; unarchiver = nil;
        [receivedPacket release]; receivedPacket = nil;
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
@synthesize serviceLoopDelayInterval;
@synthesize deviceInformation;

- (id) init
{
    self = [super init];
    
    if (self) {
        // Initialize operation variables.
        executing = NO;
        finished = NO;
        
        // Initialize network variables
        socket = [ReliableSocket new];
        serviceLoopDelayInterval = 5.0f;
    }
    
    return self;
}

- (void) dealloc
{
    // Memory Management.
    [socket release]; socket = nil;
    gpsReader = nil; // Dealloc is not done to singleton.
    spatialReader = nil;
    motorController = nil;
    servoController = nil;
    
    [super dealloc];
}

- (void) start
{
    // Always check for cancellatio before launching the tasks.
    if ( [self isCancelled] ) {
        // Must move the operation to the finished state if it is cancelled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not cancelled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void) main
{
    // Every thread must start off with a AutoreleasePool object.
    NSAutoreleasePool * threadPool = [NSAutoreleasePool new];
    
    // Name our thread according to the class name to make this thread easily
    // identificable.
    if ([socket isServer]) {
        [[NSThread currentThread] setName:@"RemoteServerMonitorOperation"];
    } else {
        [[NSThread currentThread] setName:@"RemoteClientMonitorOperation"];
    }
    
    // Algorithm:
    //  Attempt to wait until the socket becomes connected then run a single
    //  service loop tick according to the socket configuration. If we are a
    //  server then run a function which handles all server communication, or
    //  a function to handle all client communication.
    @try {
        // Check if our thread is running.
        while ( ![self isCancelled] ) {
            NSAutoreleasePool * mainServiceLoopPool = [NSAutoreleasePool new];
            
            // Check if our thread is running and we are not connected.
            while ( ![self isCancelled] && ![socket isConnected]) {
                [NSThread sleepForTimeInterval: serviceLoopDelayInterval];
            }
            
            // If we are connected then run the loop associated with the server,
            // else run the client. Note: Run the client ONLY if we are to send
            // something.
            if ([socket isServer]) {
                [self serverSessionTick];
            } else if ([socket isClient]) {
                [self clientSessionTick];
            }
            
            // Artificially delay the thread so we don't up hammering the system.
            [NSThread sleepForTimeInterval: serviceLoopDelayInterval];
            [mainServiceLoopPool drain]; mainServiceLoopPool = nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@\n", exception);
    }
    @finally {
        [threadPool drain]; threadPool = nil;
        [self completeOperation];
    }
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isFinished
{
    return finished;
}

- (void)completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void) startListeningOnPort: (NSUInteger) hostPort {
    [socket startListeningOnPort: hostPort];
}

- (void) connectToServerAtHostname: (NSString*) hostnameString port: (NSUInteger) hostPort {
    [socket connectToServerAtHostname: hostnameString port: hostPort];
}

@end
