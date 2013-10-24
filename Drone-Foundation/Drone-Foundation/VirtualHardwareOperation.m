//
//  VirtualHardwareOperation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "VirtualHardwareOperation.h"

@implementation VirtualHardwareOperation

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

@synthesize velocityEfficiencyFactor;
@synthesize virtualHardwareDelayInterval;
@synthesize gpsReader;
@synthesize motionReader;
@synthesize motorController;
@synthesize servoController;

-(id) init
{
    return [self initWithGPSReader: nil
                      motionReader: nil
                   motorController: nil
                   servoController: nil];
}

-(id)initWithGPSReader: (VirtualGPSReader*) gps
          motionReader: (VirtualSpatialReader*) motion
       motorController: (VirtualMotorController*) motor
       servoController: (VirtualServoController*) servo
{
    self = [super init];
    
    if (self) {
        gpsReader = gps;
        motionReader = motion;
        motorController = motor;
        servoController = servo;
        
        virtualHardwareDelayInterval = 1.0f;
        currentHeading = 0.0f;
        
        // The actual velocity achieved by our drone device is 25% of
        // the inputted theoretical velocity.
        velocityEfficiencyFactor = 0.25;
    }
    
    return self;
}

-(void) dealloc
{
    [super dealloc];
}

- (void) start
{
    // Verify our shared objects are set.....
    if (gpsReader == nil || motionReader == nil || motorController == nil || servoController == nil) {
        NSLog(@"Failed to start, not all virtual devices set\n");
        return; // Intercept running this function.
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
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    @try {
        while ( ![self isCancelled] ) {
            // Detect if we have any propulsion to be applied on our physical
            // body (Hint: our drone!)
            if ([motorController velocity] > 0) {
                // For every iteration of the loop, collect all the 'autorelease'
                // tagged objects and deallcate them by the end of the loop and
                // repeat the process of purging memory every loop iteration.
                NSAutoreleasePool * loopPool = [NSAutoreleasePool new];
                
                // Calculate the actual velocity to be achieved of the
                // drone device in our simulated environment.
                actualPropulsionVelocity = velocityEfficiencyFactor * [motorController velocity];
                
                // Simulate the distance moved of our device.
                // Note:
                // v = d / t
                // or
                // d = v * t
                float distanceInMeters = actualPropulsionVelocity * virtualHardwareDelayInterval;
                float distanceInKm = distanceInMeters / 1000.0f;
                
                // Get the compass direction
                currentHeading = [motionReader compassHeading];
                
                // If the rudder is to change the direction that we are travelling
                // then take this into account.
                if ([servoController position] != 90.0f) {
                    
                    // Adjust the current heading according to our servo
                    float currentHeadingAdjustment;
                    
                    // If we are to make the heading turn left
                    if ([servoController position] > 90.0f) {
                        currentHeadingAdjustment = [servoController position] - 90.0f;
                        currentHeading += currentHeadingAdjustment;
                        
                        // If the value is greater then 360.0 degrees, reset to zero
                        if (currentHeading > 360) {
                            currentHeading = currentHeading - 360.0f;
                        }
                        
                        // Else we are to move the heading to the right
                    } else {
                        currentHeadingAdjustment = 90.0f - [servoController position];
                        currentHeading -= currentHeadingAdjustment;
                        
                        // If the value is negative, then re-adjust
                        if (currentHeading < 0) {
                            currentHeading = 360.0f + currentHeading;
                        }
                    }
                    
                    // Update our drone devices compass heading by the servo
                    // modification.
                    [motionReader setCompassHeading: currentHeading];
                }
                
                // Get the current coordinate in our simulated environment.
                GPSCoordinate * currentCoord = [gpsReader coordinate];
                
                // Get the gps coordinate of our device after travelling
                // for one second.
                GPSCoordinate * destinationCoord = [GPSNavigation findDestinationCoordFromCoord: currentCoord
                                                                                 bearingDegrees: currentHeading
                                                                             distanceKilometers: distanceInKm];
                // Set the new position in our simulated environment.
                [gpsReader setCoordinate: destinationCoord];
                
                // Memory Management.                
                [loopPool drain]; loopPool = nil;
            }
            
            [NSThread sleepForTimeInterval: virtualHardwareDelayInterval];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [self completeOperation];
    }
    
    [pool drain]; pool = nil;
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

@end
