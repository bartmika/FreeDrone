//
//  TestAutoPilotOperation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-12.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestAutoPilotOperation.h"

@implementation TestAutoPilotOperation

static NSAutoreleasePool * pool = nil;
static VirtualHardwareOperation * hardwareSimulator = nil;
static AutoPilotOperation * autoPilot = nil;
static NSOperationQueue * queue = nil;

static VirtualGPSReader * gpsReader = nil;
static VirtualSpatialReader * motionReader = nil;
static VirtualMotorController * motorController = nil;
static VirtualServoController * servoController = nil;

// DEVELOPERS NOTE:
// Set to YES if you would like to have all the coordinates printed to screen.
static const BOOL kDebugAutoPilot = NO;

+(void)runSimulateSessionWithStartingCoord: (GPSCoordinate*) startCoord
                          startingAltitude: (double) altitude
                    startingCompassHeading: (double) compassHeading
                                finalCoord: (GPSCoordinate*) waypointCoord
              hardwarePollingDelayInterval: (NSTimeInterval) delay
{
    NSAssert(delay == 1.0f, @"Please program simulator hardware to support other polling delay\n");
    
    // SETUP 1 of 3
    //--------------
    // setup the environment parameters
    [gpsReader setCoordinate: startCoord];
    [gpsReader setAltitudeValue: altitude];                            // [Metres]
    [motionReader setCompassHeading: compassHeading];                  // North [Deg]
    [servoController setPosition: 90.0f];                              // [Deg]
    
    // SETUP 2 of 3
    //--------------
    // Set the hardware parameters
    // Note: 1.4 [m/s] = 25[%] x 5.6 [m/s]
    [hardwareSimulator setVelocityEfficiencyFactor: 0.25f];     // 25 [%]
    [hardwareSimulator setVirtualHardwareDelayInterval: delay];  // 1 [Seconds]
    
    // SETUP 3 of 3
    //--------------
    // Add a waypoint
    [autoPilot addWaypointAtLatitude: [waypointCoord latitudeDegrees]
                           longitude: [waypointCoord longitudeDegrees] ];
    
    NSUInteger durrationInSeconds = 1.0f;
    while ([autoPilot numberOfWaypoints] > 0) {
        if (kDebugAutoPilot) {
            NSLog(@"i: %lu lat: %f lon: %f head: %f", (unsigned long)durrationInSeconds,
                  [gpsReader latitude], [gpsReader longitude], [motionReader compassHeading] );
        }
        
        [NSThread sleepForTimeInterval: delay];
        durrationInSeconds++;
    }
}

#pragma mark -
#pragma mark Start and Finish
+ (void)setUp
{
    pool = [NSAutoreleasePool new];
    
    // 1 of 3: Initialize our objects for our tests.
    autoPilot = [AutoPilotOperation new];
    queue = [NSOperationQueue new];
    gpsReader = [VirtualGPSReader sharedInstance];
    motionReader = [VirtualSpatialReader sharedInstance];
    motorController = [VirtualMotorController sharedInstance];
    servoController = [VirtualServoController sharedInstance];
    hardwareSimulator = [VirtualHardwareOperation new];
    
    // 2 of 3: Make the virtual hardware connect to the autopilot.
    [autoPilot setGpsReader: gpsReader];
    [autoPilot setMotionReader: motionReader];
    [autoPilot setMotorController: motorController];
    [autoPilot setServoController: servoController];
    [hardwareSimulator setGpsReader: gpsReader];
    [hardwareSimulator setMotionReader: motionReader];
    [hardwareSimulator setMotorController: motorController];
    [hardwareSimulator setServoController: servoController];
    
    // 3 of 3: Start the autopilot!
    [queue addOperation: hardwareSimulator]; // Add the environment simulator.
    [queue addOperation: autoPilot]; // Add our autopilot and start running it.
}

+ (void)tearDown
{
    // Tear-down code here.
    [hardwareSimulator cancel];
    [autoPilot cancel];
    
    [gpsReader release]; gpsReader = nil;
    [motionReader release]; motionReader = nil;
    [motorController release]; motorController = nil;
    [servoController release]; servoController = nil;
    [hardwareSimulator release]; hardwareSimulator = nil;
    [autoPilot release]; autoPilot = nil;
    [queue release]; queue = nil;
    
    [pool drain]; pool = nil;
}

#pragma mark -
#pragma mark Point to Point Movement

// Note: Runs for ~103 seconds
+ (void)testMoveTopLeft
{
    NSLog(@"\ttestMoveTopLeft\n");
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995f// [Deg]
                                  longitudeDegrees: -81.277523f];    // [Deg]
    GPSCoordinate * finalCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.962f
                                  longitudeDegrees: -81.279f];
    
    [self runSimulateSessionWithStartingCoord: startCoord
                             startingAltitude: 262.0f
                       startingCompassHeading: 0.0f
                                   finalCoord: finalCoord
                 hardwarePollingDelayInterval: 1.0f];
    
    // Memory Management.
    [startCoord release]; startCoord = nil;
    [finalCoord release]; finalCoord = nil;
}

// Note: Runs for ~30 seconds
+ (void)testMoveTopMiddle
{
    NSLog(@"\ttestMoveTopMiddle\n");
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995f// [Deg]
                                  longitudeDegrees: -81.277523f];    // [Deg]
    GPSCoordinate * finalCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.960689f
                                  longitudeDegrees: -81.277523f];
    
    [self runSimulateSessionWithStartingCoord: startCoord
                             startingAltitude: 262.0f
                       startingCompassHeading: 0.0f
                                   finalCoord: finalCoord
                 hardwarePollingDelayInterval: 1.0f];
    
    // Memory Management.
    [startCoord release]; startCoord = nil;
    [finalCoord release]; finalCoord = nil;
}

// Note: Runs for ~121 seconds
+ (void)testMoveTopRight
{
    NSLog(@"\ttestMoveTopRight\n");
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995f// [Deg]
                                  longitudeDegrees: -81.277523f];    // [Deg]
    GPSCoordinate * finalCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.962f
                                  longitudeDegrees: -81.275f];
    
    [self runSimulateSessionWithStartingCoord: startCoord
                             startingAltitude: 262.0f
                       startingCompassHeading: 0.0f
                                   finalCoord: finalCoord
                 hardwarePollingDelayInterval: 1.0f];
    
    // Memory Management.
    [startCoord release]; startCoord = nil;
    [finalCoord release]; finalCoord = nil;
}

// Note: Runs for ~103 seconds
+ (void) testMoveMiddleLeft
{
    NSLog(@"\ttestMoveMiddleLeft\n");
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995f// [Deg]
                                  longitudeDegrees: -81.277523f];    // [Deg]
    GPSCoordinate * finalCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.962f
                                  longitudeDegrees: -81.279f];
    
    [self runSimulateSessionWithStartingCoord: startCoord
                             startingAltitude: 262.0f
                       startingCompassHeading: 0.0f
                                   finalCoord: finalCoord
                 hardwarePollingDelayInterval: 1.0f];
    
    // Memory Management.
    [startCoord release]; startCoord = nil;
    [finalCoord release]; finalCoord = nil;
}

// Note: Runs for ~102 seconds
+ (void) testMoveMiddleRight
{
    NSLog(@"\ttestMoveMiddleRight\n");
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995f// [Deg]
                                  longitudeDegrees: -81.277523f];    // [Deg]
    GPSCoordinate * finalCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995f
                                  longitudeDegrees: -81.2744f];
    
    [self runSimulateSessionWithStartingCoord: startCoord
                             startingAltitude: 262.0f
                       startingCompassHeading: 0.0f
                                   finalCoord: finalCoord
                 hardwarePollingDelayInterval: 1.0f];
    
    // Memory Management.
    [startCoord release]; startCoord = nil;
    [finalCoord release]; finalCoord = nil;
}

// Note: Runs for ~69 seconds
+ (void) testMoveBottomLeft
{
    NSLog(@"\ttestMoveBottomLeft\n");
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995f// [Deg]
                                  longitudeDegrees: -81.277523f];    // [Deg]
    GPSCoordinate * finalCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.9589f
                                  longitudeDegrees: -81.279f];
    
    [self runSimulateSessionWithStartingCoord: startCoord
                             startingAltitude: 262.0f       // [Metres]
                       startingCompassHeading: 180.0f       // South [Deg]
                                   finalCoord: finalCoord
                 hardwarePollingDelayInterval: 1.0f];
    
    // Memory Management.
    [startCoord release]; startCoord = nil;
    [finalCoord release]; finalCoord = nil;
}

// Note: Runs for ~30 seconds
+ (void) testMoveBottomMiddle
{
    NSLog(@"\ttestMoveBottomMiddle\n");
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995f// [Deg]
                                  longitudeDegrees: -81.277523f];    // [Deg]
    GPSCoordinate * finalCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.9593f
                                  longitudeDegrees: -81.277523f];
    
    [self runSimulateSessionWithStartingCoord: startCoord
                             startingAltitude: 262.0f       // [Metres]
                       startingCompassHeading: 180.0f       // South [Deg]
                                   finalCoord: finalCoord
                 hardwarePollingDelayInterval: 1.0f];
    
    // Memory Management.
    [startCoord release]; startCoord = nil;
    [finalCoord release]; finalCoord = nil;
}

// Note: Runs for ~116 seconds
+ (void) testMoveBottomRight
{
    NSLog(@"\ttestMoveBottomRight\n");
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995f// [Deg]
                                  longitudeDegrees: -81.277523f];    // [Deg]
    GPSCoordinate * finalCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.9589f
                                  longitudeDegrees: -81.2743f];
    
    [self runSimulateSessionWithStartingCoord: startCoord
                             startingAltitude: 262.0f       // [Metres]
                       startingCompassHeading: 180.0f       // South [Deg]
                                   finalCoord: finalCoord
                 hardwarePollingDelayInterval: 1.0f];
    
    // Memory Management.
    [startCoord release]; startCoord = nil;
    [finalCoord release]; finalCoord = nil;
}

#pragma mark -
#pragma mark Multi-Point to Multi-Point Movement

// Note: Runs for ~580 seconds
+ (void) testMoveMultipleWaypoints
{
    NSLog(@"\ttestMoveMultipleWaypoints\n");
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995f// [Deg]
                                  longitudeDegrees: -81.277523f];    // [Deg]
    GPSCoordinate * finalCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.969
                                  longitudeDegrees: -81.275];
    
    // Add some waypoints.
    [autoPilot addWaypointAtLatitude: 42.9615f longitude: -81.277523f];
    [autoPilot addWaypointAtLatitude: 42.9615f longitude: -81.274f];
    [autoPilot addWaypointAtLatitude: 42.964f longitude: -81.2756f];
    [autoPilot addWaypointAtLatitude: 42.966f longitude: -81.273f];
    
    // Start the initial initial session and track while the first
    // waypoint is being
    [self runSimulateSessionWithStartingCoord: startCoord
                             startingAltitude: 262.0f
                       startingCompassHeading: 0.0f
                                   finalCoord: finalCoord
                 hardwarePollingDelayInterval: 1.0f];
    
    // Memory Management.
    [startCoord release]; startCoord = nil;
    [finalCoord release]; finalCoord = nil;
}



+(void) performUnitTests {
    [self setUp]; [self testMoveTopLeft]; [self tearDown];
    [self setUp]; [self testMoveTopMiddle]; [self tearDown];
    [self setUp]; [self testMoveTopRight]; [self tearDown];
    [self setUp]; [self testMoveMiddleLeft]; [self tearDown];
    [self setUp]; [self testMoveMiddleRight]; [self tearDown];
    [self setUp]; [self testMoveBottomLeft]; [self tearDown];
    [self setUp]; [self testMoveBottomMiddle]; [self tearDown];
    [self setUp]; [self testMoveBottomRight]; [self tearDown];
    [self setUp]; [self testMoveMultipleWaypoints]; [self tearDown];
}

@end
