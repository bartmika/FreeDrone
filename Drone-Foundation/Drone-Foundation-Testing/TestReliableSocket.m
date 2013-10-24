//
//  TestReliableSocket.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestReliableSocket.h"

@implementation TestReliableSocket

static NSAutoreleasePool * pool = nil;
static ReliableSocket * reliableServerSocket = nil;
static ReliableSocket * reliableClientSocket = nil;
static NSUInteger sessionFinishCount = 0;

+(void) setUp {
    pool = [NSAutoreleasePool new];
    reliableServerSocket = [ReliableSocket new];
    reliableClientSocket = [ReliableSocket new];
}

+(void) tearDown {
    [reliableServerSocket release]; reliableServerSocket = nil;
    [reliableClientSocket release]; reliableClientSocket = nil;
    [pool drain]; pool = nil;
}

+(void) serverSession {
    NSAutoreleasePool * serverPool = [NSAutoreleasePool new];
    [[NSThread currentThread] setName:@"Unit-Test-Server"];
    
    // Start accepting connects from any available client and make this thread
    // wait until a client has connected.
    [reliableServerSocket startListeningOnPort: kPortNumber];
    while ([reliableServerSocket isConnected] == NO) {
        [NSThread sleepForTimeInterval: 0.5f];
    }
    
    // Verify our socket configuration.
    NSAssert([reliableServerSocket isServer], @"Wrong socket configuration! Not server\n");
    
    // Test out receiving data and then verify we received a 'Nihao'.
    NSData * testData = [reliableServerSocket receiveData];
    NSAssert(testData, @"Failed to receive anything from Client\n");
    NSString * receivedText = [[[NSString alloc] initWithData: testData
                                                     encoding: NSUTF8StringEncoding]
                               autorelease];
    NSAssert([receivedText compare: @"Nihao"] == NSOrderedSame, @"Failed to receive Nihao\n");
    
    // Test out our sending of text messages
    NSData* sendData = [@"Czech" dataUsingEncoding: NSUTF8StringEncoding];
    [reliableServerSocket sendData: sendData];
    
    // Artifically delay the thread to give time for the client to disconnect.
    // Then make the server disconnect.
    [NSThread sleepForTimeInterval: 5.0f];
    [reliableServerSocket disconnect];
    
    [serverPool drain]; serverPool = nil;
    sessionFinishCount++;
}

+(void) clientSession {
    NSAutoreleasePool * clientPool = [NSAutoreleasePool new];
    [[NSThread currentThread] setName:@"Unit-Test-Client"];
    // Connect to server
    [reliableClientSocket connectToServerAtHostname: kHostname port: kPortNumber];
    
    while ([reliableClientSocket isConnected] == NO) {
        [NSThread sleepForTimeInterval: 0.5f];
    }
    
    // Verify our socket configuration.
    NSAssert([reliableServerSocket isClient], @"Wrong socket configuration! Not client\n");
    
    // Test sending our data. The receive function will verify if this function
    // was successfull.
    NSData* testData = [@"Nihao" dataUsingEncoding: NSUTF8StringEncoding];
    [reliableClientSocket sendData: testData];

    // Test out receiving a string message and verify it is "Czech".
    NSData * receivedData = [reliableClientSocket receiveData];
    NSAssert(receivedData, @"Failed to receive Czech data\n");
    NSString * receivedText = [[[NSString alloc] initWithData: receivedData
                                                     encoding: NSUTF8StringEncoding]
                               autorelease];
    NSAssert([receivedText compare: @"Czech"] == NSOrderedSame, @"Failed to read Czech\n");
    
    // Disconnect from the server.
    [reliableClientSocket disconnect];
    
    [clientPool drain]; clientPool = nil;
    sessionFinishCount++;
}


+(void) performUnitTests {
    NSLog(@"ReliableSocket\n");
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
    NSLog(@"ReliableSocket: Successful\n\n");
}

@end
