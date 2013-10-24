//
//  AutoPilotOperation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "AutoPilotOperation.h"

@implementation AutoPilotOperation

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

-(void) performAutonomousPilotingLogic
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    
    // Get the destination the drone is to travel to.
    GPSCoordinate * waypoint = [waypoints objectAtIndex: 0];
    
    // Get the current position the drone is on.
    GPSCoordinate * position = [gpsReader coordinate];
    
    // Make the judgement of whether we arrived at the waypoint.
    if ( [GPSNavigation nearByCoord: position
                          withCoord: waypoint
                   distanceInMetres: arrivedAtWaypointAcceptedDistanceInMetres] ) {
        
        [waypointsIO lock];
        [waypoints removeObjectAtIndex: 0];
        [waypointsIO unlock];
        NSLog(@"WAYPOINT: Arrived at Lat: %f Lon: %f\n",
              [position latitudeDegrees],
              [position longitudeDegrees]);
        
        [servoController setPosition: 90.0f]; // Straighten out the rudder.
        
    } else { // Else make the move.
        // Detect the position the drone is facing from the digital compass.
        float currentBearing = [motionReader compassHeadingInDegrees];
        
        // Calculate what the bearing is for the position we want to go to.
        float bearing = [GPSNavigation bearingBetweenOriginCoord: position
                                                 destinationCoord: waypoint];
        
        // Calculate which way we should turn towards getting to our destination.
        char turn = [GPSNavigation turningDirectionFromCurrentBearing: currentBearing
                                                       towardsBearing: bearing
                                                            precision: turningDegreePrecision];
        
        if (turn == 'R') {
            if (abs(currentBearing - bearing) > largeBearingDegrees) {
                [servoController setPosition: 120.0f];
            } else {
                [servoController setPosition: 91.0f];
            }
            
        } else if (turn == 'L') {
            if (abs(currentBearing - bearing) > largeBearingDegrees) {
                [servoController setPosition: 7.0f];
            } else {
                [servoController setPosition: 89.0f];
            }
        } else {
            
            // To prevent hammering the hardware, only adjust position if
            // necessary/
            if ([servoController position] != 90.0f) {
                [servoController setPosition: 90.0f];
            }
            
        }
        
        [motorController setVelocity: targetTravellingVelocity];
    }
    
    // Memory Management.
    [pool drain]; pool = nil;
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

@synthesize manualOverride;
@synthesize gpsReader;
@synthesize motionReader;
@synthesize motorController;
@synthesize servoController;

- (id) init
{
    self = [super init];
    
    if (self) {
        // Initialize operation variables.
        executing = NO;
        finished = NO;
        
        // Config
        autoPilotDelayInterval = 1.0f;
        waypoints = [[NSMutableArray alloc] initWithCapacity: 100.0f];
        waypointsIO = [[NSLock alloc] init];
        arrivedAtWaypointAcceptedDistanceInMetres = 5.0f;
        turningDegreePrecision = 5.00f;
        targetTravellingVelocity = 10.0f; // 10.0 km/sec
        currentVelocity = 0.0f;
        
        // Turning
        largeBearingDegrees = 25.0f;
    }
    
    return self;
}

- (void) dealloc
{
    // Memory Management.
    [waypoints removeAllObjects];
    [waypoints release]; waypoints = nil;
    [waypointsIO release]; waypointsIO = nil;
    gpsReader = nil; // Dealloc is not done to singleton.
    motionReader = nil;
    motorController = nil;
    servoController = nil;
    
    [super dealloc];
}

- (void) start
{
    // Verify our shared objects are set.....
    if (gpsReader == nil || motionReader == nil || motorController == nil || servoController == nil) {
        NSLog(@"AUTOPILOT: Hardware device failed starting - Autopilot is offline.\n");
        return;
    }
    
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
    NSAutoreleasePool * threadPool = [NSAutoreleasePool new];
    
    // Name our thread to aid in debugging.
    [[NSThread currentThread] setName:@"AutoPilotOperation"];
    
    @try {
        while ( ![self isCancelled] ) {
            // If the pilot takes control of the drone, a manual override
            // occured so the drone lets go of controlling the ship.
            while (manualOverride) {
                [NSThread sleepForTimeInterval: autoPilotDelayInterval];
            }
            
            // Once the pilot has specified a coordinate (or set of coordiantes)
            // to traverse to, then perform the traversing.
            if ([waypoints count] > 0) {
                [self performAutonomousPilotingLogic];
            }
            
            [NSThread sleepForTimeInterval: autoPilotDelayInterval];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [self completeOperation];
    }
    
    [threadPool drain]; threadPool = nil;
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


-(void) addWaypointAtLatitude: (float) latitudeValue longitude: (float) longitudeValue {
    GPSCoordinate * coord = [[[GPSCoordinate alloc] initWithLatitudeDegrees: latitudeValue
                                                          longitudeDegrees: longitudeValue] autorelease];
    [waypointsIO lock];
    [waypoints enqueue: coord];
    [waypointsIO unlock];
}

-(NSUInteger) numberOfWaypoints {
    return [waypoints count];
}

@end
