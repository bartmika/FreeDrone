//
//  TestRemoteAccessService.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-01.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestRemoteAccessService.h"

@implementation TestRemoteAccessService

static RemoteAccessServerService * server = nil;
static RemoteAccessClientService * client = nil;
static NSUInteger threadFinishedCount = 0;
static NSThread * serverThread = nil;
static NSThread * clientThread = nil;
static NSLock * communicationThreadMutex = nil;
static NSAutoreleasePool * pool = nil;

// Private
+ (void)clientCommunicationThread
{
    NSAutoreleasePool * threadPool = [NSAutoreleasePool new];
    
    [communicationThreadMutex lock];
    
    // Note:
    //  If it is an asterisk ('*') then the nameserver checks all hosts on
    //  the local subnet (unless the nameserver is one that only manages
    //  local ports)
    //  http://www.mail-archive.com/discuss-gnustep@gnu.org/msg11405.html
    NSLog(@"Client: Connecting to server...\n");
    [client connectToServerAtHostname: @"*"
                           portNumber: 1666];
    NSLog(@"Client: Connected\n");
    [communicationThreadMutex unlock];
    
    //----------------//
    // GPS + SPATIAL  //
    //----------------//
    GPSReader * remoteGpsReader = [client gpsReader];
    NSAssert(remoteGpsReader, @"Failed to get access to remote GPS");
    
    NSLog(@"Client: Test: GPS + Spatial\n");
    for (NSUInteger i = 0; i < 10; i++) {
        
        [NSThread sleepForTimeInterval:1]; // Artificially delay.
        
        // Remotely poll GPS & Spatial data.
        GPSCoordinate * coordinate = [remoteGpsReader coordinate];
        NSAssert(coordinate, @"Failed to get GPS coordinate remotely\n");
        double heading = [remoteGpsReader heading];
        double altitude = [remoteGpsReader altitude];
        
        // Verify GPS & Spatial data is valid.
        if (coordinate.latitudeDegrees == 0.0f || coordinate.longitudeDegrees == 0.0f) {
            NSAssert(NO, @"Client: Failed remotely polling GPS device\n");
        } else {
            NSLog(@"Client: GPS: Lat: %f Lon: %f Hd: %f Alt: %f\n",
                  coordinate.latitudeDegrees,
                  coordinate.longitudeDegrees,
                  heading,
                  altitude);
        }
        
        //        if (pitch == 0.0f || roll == 0.0f || yaw == 0.0f) {
        //            STFail(@"Failed rempotely polling motion data.");
        //        }
        [coordinate release]; coordinate = nil;
    }
    
    //----------------//
    //      MOTOR     //
    //----------------//
//    MotorController * remoteMotorController = [client motorController];
//    NSAssert(remoteMotorController, @"Failed to get Remote Motor\n");
//    NSLog(@"Test: Motor\n");
//    [remoteMotorController setAcceleration: 100.0f];
//    [remoteMotorController setVelocity: 10.0f];
//    [NSThread sleepForTimeInterval: 5];
//    [remoteMotorController setAcceleration: 100.0f];
//    [remoteMotorController setVelocity: 0.0f];
//    [NSThread sleepForTimeInterval: 1];
    
    //----------------//
    //      SERVO     //
    //----------------//
//    NSLog(@"Test: Servo\n");
//    ServoController * remoteServoController = [client servoController];
//    NSAssert(remoteServoController, @"Failed to get Remote Servo\n");
//    [remoteServoController engage];
//    [remoteServoController setPosition: 0.0f];
//    [NSThread sleepForTimeInterval: 5.0f];
//    [remoteServoController setPosition: 90.0f];
//    [NSThread sleepForTimeInterval: 5.0f];
//    [remoteServoController disengage];
//    [NSThread sleepForTimeInterval: 1.0f];
    
    //----------------//
    //    AUTOPILOT   //
    //----------------//
    NSLog(@"Client: Test: AutoPilot\n");
    //TODO: Impl.
    
    NSLog(@"Client: Finished Client!\n");
    [communicationThreadMutex lock];
    threadFinishedCount++;
    [threadPool drain]; threadPool = nil;
    [communicationThreadMutex unlock];
}

+ (void)serverCommunicationThread
{
    NSAutoreleasePool *threadPool = [NSAutoreleasePool new];
    // Note: Synchronize the threads first. 'listenForClient' is thread safe
    //       so we lock the resource just to make sure the client doesn't
    //       access it first.
    [communicationThreadMutex lock];
    NSLog(@"Server: Listening for Clients\n");
    [server startListeningForClient];
    [communicationThreadMutex unlock];
    
    NSLog(@"Server: Finished Server\n");
    [communicationThreadMutex lock];
    threadFinishedCount++;
    [threadPool drain]; threadPool = nil;
    [communicationThreadMutex unlock];
}

+ (void)setUp
{
    pool = [NSAutoreleasePool new];
    // Set-up code here.
    NSLog(@"Server: Starting...\n");
    server = [[RemoteAccessServerService alloc] init];
    NSAssert(server, @"Failed Alloc+Init\n");
    NSLog(@"Server: Initialized...\n");
    
    NSLog(@"Client: Starting...\n");
    client = [[RemoteAccessClientService alloc] init];
    NSAssert(client, @"Failed Alloc+Init\n");
    NSLog(@"Client: Initialized\n");
    
    // Create the mutex that will coordinate between the two threads in our
    // unit test.
    communicationThreadMutex = [[NSLock alloc] init];
}

+ (void)tearDown
{
    // Tear-down code here.
    [client release]; client = nil;
    [server release]; server = nil;
    [communicationThreadMutex release]; communicationThreadMutex = nil;
    [pool drain]; pool = nil;
}

+(void) performUnitTests {
    NSLog(@"Remote Server+Client Communication\n");
    [self setUp];
    
    // Create our threads
    NSLog(@"Server: Starting Thread\n");
    serverThread = [[NSThread alloc] initWithTarget: self
                                           selector: @selector(serverCommunicationThread)
                                             object: nil];
    
    // Give time for the server to startup and get ready for unit testing.
    [NSThread sleepForTimeInterval: 1.0f];
    
    NSLog(@"Client: Starting Thread\n");
    clientThread = [[NSThread alloc] initWithTarget: self
                                           selector: @selector(clientCommunicationThread)
                                             object: nil];
    // Start our server unit test code
    [serverThread start];
    
    // Give time for the server to startup and get ready for unit testing.
    [NSThread sleepForTimeInterval: 1.0f];
    
    // Start our client unit test code
    [clientThread start];
    
    [[NSRunLoop currentRunLoop] runUntilDate: [NSDate distantFuture]];
    
    // While the client is running.
    do {
        [NSThread sleepForTimeInterval: 1];
    } while (threadFinishedCount < 1);
    
    [serverThread cancel]; // Once client finished, close our server as well!
    
    [clientThread release]; clientThread = nil;
    [serverThread release]; serverThread = nil;
    [self tearDown];
    NSLog(@"Remote Server+Client Communication: Successful\n\n");
}

@end
