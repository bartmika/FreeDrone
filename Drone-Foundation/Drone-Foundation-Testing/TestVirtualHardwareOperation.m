//
//  TestVirtualHardwareOperation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-12.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestVirtualHardwareOperation.h"

@implementation TestVirtualHardwareOperation

static NSAutoreleasePool * pool;
static VirtualHardwareOperation * hardwareSimulator = nil;
static VirtualGPSReader * gpsReader = nil;
static VirtualSpatialReader * motionReader = nil;
static VirtualMotorController * motorController = nil;
static VirtualServoController * servoController = nil;

+ (void)setUp
{    
    // Set-up code here.
    pool = [NSAutoreleasePool new];
    gpsReader = [VirtualGPSReader sharedInstance];
    motionReader = [VirtualSpatialReader sharedInstance];
    motorController = [VirtualMotorController sharedInstance];
    servoController = [VirtualServoController sharedInstance];
    hardwareSimulator = [[VirtualHardwareOperation alloc] initWithGPSReader: gpsReader
                                                               motionReader: motionReader
                                                            motorController: motorController
                                                            servoController: servoController];
    NSAssert(hardwareSimulator, @"Failed to alloc+init with custom constructor\n");
    
    // Start running
    [hardwareSimulator start];
}

+ (void)tearDown
{
    // Tear-down code here.
    [hardwareSimulator cancel]; // Stop the operation.
    [hardwareSimulator release]; hardwareSimulator = nil;
    [pool drain]; pool = nil;
}

+ (void)testSimulateMovingNorth
{
    // Please look at "HardwareSimulationResearch.csv" file and look at trial #1
    // for how to setup this test.
    
    // SETUP 1 of 3
    //--------------
    // Set the environment parameters
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.959995 // [Deg]
                                  longitudeDegrees: -81.277523];     // [Deg]
    [gpsReader setCoordinate: startCoord];
    [gpsReader setAltitudeValue: 262.0f];                            // [Meters]
    [motionReader setCompassHeading: 0.0f];                          // North [Deg]
    
    // SETUP 2 of 3
    //--------------
    // Set the hardware parameters
    // Note: 1.4 [m/s] = 25[%] x 5.6 [m/s]
    [hardwareSimulator setVelocityEfficiencyFactor: 0.25f];     // [%] of velocity is used
    [hardwareSimulator setVirtualHardwareDelayInterval: 1.0f];  // [Seconds]
    
    // SETUP 3 of 3
    //--------------
    // Set the hardware to move forward.
    [motorController setVelocity: 5.6f];  // [m/s]
    [servoController setPosition: 90.0f]; // [Deg]
    
    // Poll the hardware simulator every second and get the coordinates.
    // Keep count how long the operation runs for in seconds.
    NSUInteger operationDurrationInSeconds = 1;
    while (operationDurrationInSeconds < 60) {
        NSLog(@"Second: %lu\tLat: %f\tLon: %f\n", (unsigned long)operationDurrationInSeconds++,
              [gpsReader latitude], [gpsReader longitude]);
        
        [NSThread sleepForTimeInterval: 1.0f]; // [Seconds]
    }
    
    // Stop velocity! We have arrived at the destination point so set the
    // velocity to zero and the hardware simulators stops simulating
    [motorController setVelocity: 0.0f];
    
    // Lets calculate the distance from the velocity travelled for the durration.
    // Note: d = v * t;
    float theoreticalDistanceInMetres = 1.4 * operationDurrationInSeconds; // [m/s] * [s]
    GPSCoordinate * finishCoord = [gpsReader coordinate]; // Note: Autoreleased obj.
    float distanceInKm = [GPSNavigation distanceBetweenOriginCoord: startCoord
                                                   destinationCoord: finishCoord];
    float distanceInMeters = distanceInKm * 1000.0f;
    
    NSAssert(fabsf(distanceInMeters - theoreticalDistanceInMetres <= 7.0f),
             @"Failed to simulate latitude traversal\n");
    
    // Note: If you look in the file "HardwareSimulationResearch.csv" and look
    //       for trial one, you will see a real-life experiment has yielded
    //       a distance of "81 metres" in "1 minute" at travelling velocity
    //       of "1.4 m/s [n]". Lets verify it's somewhat similar to real-life
    //       considitions by checking to see if the simulated data range is
    //       is within to +/- 5.0 meters of the actual distance travelled in
    //       the experiment.
    //
    float actualDistanceInMeters = 81.0f;
    NSUInteger actualSecondsDurration = 60.0f;
    NSAssert(fabsf(distanceInMeters - actualDistanceInMeters) <= 10.0f,
             @"Failed to simulate realistic distance.\n");
    NSAssert(fabsf(operationDurrationInSeconds - actualSecondsDurration) <= 5.0f,
             @"Failed to simulate realistic time durration.\n");
    
    // Memory Management
    [startCoord release]; startCoord = nil;
}

+ (void)testSimulateMovingWest
{
    // Please look at "HardwareSimulationResearch.csv" file and look at trial #3
    // for how to setup this test.
    
    // SETUP 1 of 3
    //--------------
    // Set the environment parameters
    GPSCoordinate * startCoord = [[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.960701 // [Deg]
                                  longitudeDegrees: -81.277223];     // [Deg]
    [gpsReader setCoordinate: startCoord];
    [gpsReader setAltitudeValue: 261.0f];                            // [Meters]
    [motionReader setCompassHeading: 270.0f];                        // East [Deg]
    
    // SETUP 2 of 3
    //--------------
    // Set the hardware parameters
    // Note: 1.7 [m/s] = 25[%] x 6.8 [m/s]
    [hardwareSimulator setVelocityEfficiencyFactor: 0.25f];     // 25 [%]
    [hardwareSimulator setVirtualHardwareDelayInterval: 1.0f];  // 1 [Seconds]
    
    // SETUP 3 of 3
    //--------------
    // Set the hardware to move forward.
    [motorController setVelocity: 6.8f];  // [m/s]
    [servoController setPosition: 90.0f]; // [Deg]
    
    // Poll the hardware simulator every second and get the coordinates.
    // Keep count how long the operation runs for in seconds.
    NSUInteger operationDurrationInSeconds = 1;
    while ([gpsReader longitude] >= -81.278459) {
        NSLog(@"Second: %lu\tLatitude: %f\tLongitude: %f\n",(unsigned long)operationDurrationInSeconds++,
              [gpsReader latitude], [gpsReader longitude]);
        
        [NSThread sleepForTimeInterval: 1.0f]; // [Seconds]
    }
    
    // Stop velocity! We have arrived at the destination point so set the
    // velocity to zero and the hardware simulators stops simulating
    [motorController setVelocity: 0.0f];
    
    // Lets calculate the distance from the velocity travelled for the durration.
    // Note: d = v * t;
    float theoreticalDistanceInMetres = 1.7 * operationDurrationInSeconds; // [m/s] * [s]
    GPSCoordinate * finishCoord = [gpsReader coordinate];
    float distanceInKm = [GPSNavigation distanceBetweenOriginCoord: startCoord
                                                   destinationCoord: finishCoord];
    float distanceInMeters = distanceInKm * 1000.0f;
    
    NSAssert(fabsf(distanceInMeters - theoreticalDistanceInMetres) <= 10.0f,
             @"Failed to simulate longitude traversal\n");
    
    float actualDistanceInMeters = 105.0f;
    NSUInteger actualSecondsDurration = 60.0f;
    NSAssert(fabsf(distanceInMeters - actualDistanceInMeters) <= 10.0f,
             @"Failed to simulate realistic distance.\n");
    NSAssert(fabsf(operationDurrationInSeconds - actualSecondsDurration) <= 10.0f,
             @"Failed to simulate realistic time durration.\n");
    
    // Memory Management
    [startCoord release]; startCoord = nil;
}

+ (void)testSimulateMovingNorthWest
{
    // SETUP 1 of 3
    //--------------
    // Set the environment parameters
    GPSCoordinate * startCoord = [[[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.960701            // [Deg]
                                  longitudeDegrees: -81.277223] autorelease];   // [Deg]
    [gpsReader setCoordinate: startCoord];
    [gpsReader setAltitudeValue: 261.0f];                            // [Meters]
    [motionReader setCompassHeading: 300.0f];                        // East [Deg]
    
    // SETUP 2 of 3
    //--------------
    // Set the hardware parameters
    // Note: 1.7 [m/s] = 25[%] x 6.8 [m/s]
    [hardwareSimulator setVelocityEfficiencyFactor: 0.25f];     // 25 [%]
    [hardwareSimulator setVirtualHardwareDelayInterval: 1.0f];  // 1 [Seconds]
    
    // SETUP 3 of 3
    //--------------
    // Set the hardware to move forward.
    [motorController setVelocity: 6.8f]; // [m/s]
    [servoController setPosition: 90.0f]; // [Deg]
    
    // Poll the hardware simulator every second and get the coordinates.
    // Keep count how long the operation runs for in seconds.
    NSUInteger operationDurrationInSeconds = 1;
    while ([gpsReader longitude] >= -81.278309) {
        NSLog(@"Second: %lu\tLatitude: %f\tLongitude: %f\n", (unsigned long)operationDurrationInSeconds++,
              [gpsReader latitude], [gpsReader longitude]);
        
        [NSThread sleepForTimeInterval: 1.0f]; // [Seconds]
    }
    
    // Stop velocity! We have arrived at the destination point so set the
    // velocity to zero and the hardware simulators stops simulating
    [motorController setVelocity: 0.0f];
    
    // Lets calculate the distance from the velocity travelled for the durration.
    // Note: d = v * t;
    float theoreticalDistanceInMetres = 1.7 * operationDurrationInSeconds; // [m/s] * [s]
    GPSCoordinate * finishCoord = [gpsReader coordinate];
    float distanceInKm = [GPSNavigation distanceBetweenOriginCoord: startCoord
                                                   destinationCoord: finishCoord];
    float distanceInMeters = distanceInKm * 1000.0f;
    
    NSAssert(fabsf(distanceInMeters - theoreticalDistanceInMetres) <= 10.0f,
             @"Failed to simulate longitude traversal\n");
}

+ (void)testSimulateMovingNorthWithArcingLeft
{
    // SETUP 1 of 3
    //--------------
    // Set the environment parameters
    GPSCoordinate * startCoord = [[[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.960701          // [Deg]
                                  longitudeDegrees: -81.277223] autorelease]; // [Deg]
    [gpsReader setCoordinate: startCoord];
    [gpsReader setAltitudeValue: 261.0f];                            // [Meters]
    [motionReader setCompassHeading: 0.0f];                        // East [Deg]
    
    // SETUP 2 of 3
    //--------------
    // Set the hardware parameters
    // Note: 1.7 [m/s] = 25[%] x 6.8 [m/s]
    [hardwareSimulator setVelocityEfficiencyFactor: 0.25f];     // 25 [%]
    [hardwareSimulator setVirtualHardwareDelayInterval: 1.0f];  // 1 [Seconds]
    
    // SETUP 3 of 3
    //--------------
    // Set the hardware to move forward.
    [motorController setVelocity: 6.8f];  // [m/s]
    [servoController setPosition: 89.0f]; // [Deg]
    
    // Poll the hardware simulator every second and get the coordinates.
    // Keep count how long the operation runs for in seconds.
    NSUInteger operationDurrationInSeconds = 1;
    while (operationDurrationInSeconds <= 60) { // Run for 1 minute
        NSLog(@"Sec: %lu\tLat: %f Lon: %f Head: %f\n", (unsigned long)operationDurrationInSeconds++,
              [gpsReader latitude], [gpsReader longitude], [motionReader compassHeading]);
        
        [NSThread sleepForTimeInterval: 1.0f]; // [Seconds]
    }
    
    // Stop velocity! We have arrived at the destination point so set the
    // velocity to zero and the hardware simulators stops simulating
    [motorController setVelocity: 0.0f];
    
    // Lets calculate the distance from the velocity travelled for the durration.
    // Note: d = v * t;
    float theoreticalDistanceInMetres = 1.7 * operationDurrationInSeconds; // [m/s] * [s]
    GPSCoordinate * finishCoord = [gpsReader coordinate];
    float distanceInKm = [GPSNavigation distanceBetweenOriginCoord: startCoord
                                                   destinationCoord: finishCoord];
    float distanceInMeters = distanceInKm * 1000.0f;
    
    NSAssert(fabsf(distanceInMeters - theoreticalDistanceInMetres) <= 15.0f,
             @"Failed to simulate longitude traversal\n");
}

+ (void)testSimulateMovingNorthWithArcingRight
{
    // SETUP 1 of 3
    //--------------
    // Set the environment parameters
    GPSCoordinate * startCoord = [[[GPSCoordinate alloc]
                                  initWithLatitudeDegrees: 42.960701            // [Deg]
                                  longitudeDegrees: -81.277223] autorelease];   // [Deg]
    [gpsReader setCoordinate: startCoord];
    [gpsReader setAltitudeValue: 261.0f];                            // [Meters]
    [motionReader setCompassHeading: 0.0f];                        // East [Deg]
    
    // SETUP 2 of 3
    //--------------
    // Set the hardware parameters
    // Note: 1.7 [m/s] = 25[%] x 6.8 [m/s]
    [hardwareSimulator setVelocityEfficiencyFactor: 0.25f];     // 25 [%]
    [hardwareSimulator setVirtualHardwareDelayInterval: 1.0f];  // 1 [Seconds]
    
    // SETUP 3 of 3
    //--------------
    // Set the hardware to move forward.
    [motorController setVelocity: 6.8f];  // [m/s]
    [servoController setPosition: 91.0f]; // [Deg]
    
    // Poll the hardware simulator every second and get the coordinates.
    // Keep count how long the operation runs for in seconds.
    NSUInteger operationDurrationInSeconds = 1;
    while (operationDurrationInSeconds <= 60) { // Run for 1 minute
        NSLog(@"Sec: %lu\tLat: %f Lon: %f Head: %f\n", (unsigned long)operationDurrationInSeconds,
              [gpsReader latitude], [gpsReader longitude], [motionReader compassHeading]);
        
        [NSThread sleepForTimeInterval: 1.0f]; // [Seconds]
        operationDurrationInSeconds++;
    }
    
    // Stop velocity! We have arrived at the destination point so set the
    // velocity to zero and the hardware simulators stops simulating
    [motorController setVelocity: 0.0f];
    
    // Lets calculate the distance from the velocity travelled for the durration.
    // Note: d = v * t;
    float theoreticalDistanceInMetres = 1.7 * operationDurrationInSeconds; // [m/s] * [s]
    GPSCoordinate * finishCoord = [gpsReader coordinate];
    float distanceInKm = [GPSNavigation distanceBetweenOriginCoord: startCoord
                                                   destinationCoord: finishCoord];
    float distanceInMeters = distanceInKm * 1000.0f;
    
    NSAssert(fabsf(distanceInMeters - theoreticalDistanceInMetres) <= 15.0f,
             @"Failed to simulate longitude traversal\n");
}


+(void) performUnitTests {
    NSLog(@"VirtualHardwareOperation\n");
    [self setUp];
    [self testSimulateMovingNorth];
    [self tearDown];
    
    [self setUp];
    [self testSimulateMovingNorthWest];
    [self tearDown];
    
    [self setUp];
    [self testSimulateMovingWest];
    [self tearDown];
    
    [self setUp];
    [self testSimulateMovingNorthWithArcingLeft];
    [self tearDown];
    
    [self setUp];
    [self testSimulateMovingNorthWithArcingRight];
    [self tearDown];
    NSLog(@"VirtualHardwareOperation: Successfull\n\n");
}

@end
