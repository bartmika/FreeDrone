//
//  DroneRemoteOperation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-17.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "RemoteControlOperation.h"

@implementation RemoteControlOperation

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

// Responsible for receiving
-(void) serverSessionTick {
    // Defensive Code.
    NSAssert(motorController, @"Server cannot access Motor Controller\n");
    NSAssert(servoController, @"Server cannot access Servo Controller\n");
    
    NSData * incomingData = nil;
    NSKeyedUnarchiver *unarchiver = nil;
    
    @try {
        incomingData = [[socket receiveData] retain];
        
        // If we receive non-null packet data, then process it.
        if (incomingData) {
            unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData: incomingData];
            
            NSDictionary * receivedPacket = [[NSDictionary alloc] initWithCoder: unarchiver];
            NSDictionary * motorData = [receivedPacket objectForKey: @"Motor"];
            NSDictionary * servoData = [receivedPacket objectForKey: @"Servo"];
            NSNumber * velocity = [motorData objectForKey: @"Velocity"];
            NSNumber * acceleration = [motorData objectForKey: @"Acceleration"];
            NSNumber * position = [servoData objectForKey: @"Position"];
            NSNumber * engagement = [servoData objectForKey: @"IsEngaged"];
            
            // Step 1 / 2: Modify hardware with our values.
            [motorController setVelocity: [velocity floatValue]];
            [motorController setAcceleration: [acceleration floatValue]];
            if ([engagement boolValue] && [servoController isEngaged] == NO) {
                [servoController engage];
            } else {
                [servoController disengage];
            }
            [servoController setPosition: [position floatValue]];
            
            // Step 2 / 2: Modify our class with the new values.
            [self setMotorVelocity: [velocity floatValue]];
            [self setMotorAcceleration: [acceleration floatValue]];
            [self setServoEngaged: [engagement boolValue]];
            [self setServoPosition: [position floatValue]];
            
            [receivedPacket release]; receivedPacket = nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Unarchiving: %@\n", exception);
    }
    @finally {
        [incomingData release];
        [unarchiver release];
    }
}

// Responsible for sending.
-(void) clientSessionTick {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
                                 initForWritingWithMutableData: data];
    NSDictionary * packet = [NSDictionary new];
    
    @try {
        // Poll all the attached devices and get their current information.
        NSDictionary * servoData = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithFloat: servoPosition], @"Position",
                                    [NSNumber numberWithBool: servoEngaged], @"IsEngaged",
                                    nil];
        NSDictionary * motorData = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithFloat: motorAcceleration], @"Acceleration",
                                    [NSNumber numberWithFloat: motorVelocity], @"Velocity",
                                    nil];
        
        // Create a single dictionary with all our devices information and
        // encode it into binary.
        NSDictionary * droneData = [NSDictionary dictionaryWithObjectsAndKeys:
                                    servoData, @"Servo",
                                    motorData, @"Motor",
                                    nil];
        [droneData encodeWithCoder: archiver];
        [archiver finishEncoding]; // Finish Encoding
        
        // Transmit our encoded binary to the client.
        [socket sendData: data];    }
    @catch (NSException *exception) {
        NSLog(@"Archiving: %@\n", exception);
    }
    @finally {
        [self setIsReadyToSend: NO];
        [archiver release]; // Memory Management.
        [data release];
        [packet release]; packet = nil;
    }
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

@synthesize motorController;
@synthesize servoController;
@synthesize autoPilot;
@synthesize isReadyToSend;
@synthesize serviceLoopDelayInterval;
@synthesize motorVelocity;
@synthesize motorAcceleration;
@synthesize servoPosition;
@synthesize servoEngaged;
- (id) init
{
    self = [super init];
    
    if (self) {
        // Initialize operation variables.
        executing = NO;
        finished = NO;
        
        // Initialize network variables
        socket = [ReliableSocket new];
        [self setIsReadyToSend: NO];
    }
    
    return self;
}

- (void) dealloc
{
    // Memory Management.
    [socket release]; socket = nil;
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
        [[NSThread currentThread] setName:@"RemoteControlServerOperation"];
    } else {
        [[NSThread currentThread] setName:@"RemoteControlClientOperation"];
    }
    
    // Algorithm:
    //  Attempt to wait until the socket becomes connected then run a single
    //  service loop tick according to the socket configuration. If we are a
    //  server then run a function which handles all server communication, or
    //  a function to handle all client communication.
    @try {
        // Check if our thread is running.
        while ( ![self isCancelled] ) {
            //NSAutoreleasePool * mainServiceLoopPool = [NSAutoreleasePool new];
            
            // Check if our thread is running and we are not connected.
            while ( ![self isCancelled] && ![socket isConnected]) {
                [NSThread sleepForTimeInterval: serviceLoopDelayInterval];
            }
            
            // If we are connected then run the loop associated with the server,
            // else run the client. Note: Run the client ONLY if we are to send
            // something.
            if ([socket isServer]) {
                [self serverSessionTick];
            } else if ([socket isClient] && [self isReadyToSend]) {
                [self clientSessionTick];
            }
            
            // Artificially delay the thread so we don't up hammering the system.
            [NSThread sleepForTimeInterval: serviceLoopDelayInterval];
            //[mainServiceLoopPool drain]; mainServiceLoopPool = nil;
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
