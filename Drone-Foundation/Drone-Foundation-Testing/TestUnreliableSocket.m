//
//  TestUnUnreliableSocket.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestUnreliableSocket.h"

@implementation TestUnreliableSocket

static NSAutoreleasePool * pool = nil;
static UnreliableSocket * unreliableServerSocket = nil;
static UnreliableSocket * unreliableClientSocket = nil;
static NSUInteger sessionFinishCount = 0;

+(void) setUp {
    pool = [NSAutoreleasePool new];
    unreliableServerSocket = [UnreliableSocket new];
    unreliableClientSocket = [UnreliableSocket new];
}

+(void) tearDown {
    [unreliableServerSocket release]; unreliableServerSocket = nil;
    [unreliableClientSocket release]; unreliableClientSocket = nil;
    [pool drain]; pool = nil;
}

+(void) serverSession {
    NSAutoreleasePool * serverPool = [NSAutoreleasePool new];
    [[NSThread currentThread] setName:@"Unit-Test-Server"];
    
    // Start accepting connects from any available client and make this thread
    // wait until a client has connected.
    [unreliableServerSocket startListeningOnPort: kPortNumber];
    [NSThread sleepForTimeInterval: 0.5f];
    
    // Verify our socket configuration.
    NSAssert([unreliableServerSocket isServer], @"Wrong socket configuration! Not server\n");

    // Test out receiving data and then verify we received a 'Nihao'.
    NSData * testData = [unreliableServerSocket blockingReceiveData];
    NSAssert(testData, @"Failed to receive anything from Client\n");
    NSString * receivedText = [[[NSString alloc] initWithData: testData
                                                     encoding: NSUTF8StringEncoding]
                               autorelease];
    NSAssert([receivedText isEqualToString: @"Nihao"] == NSOrderedSame, @"Failed to receive Nihao\n");
    
    // Test out our sending of text messages
    NSData* sendData = [@"Czech" dataUsingEncoding: NSUTF8StringEncoding];
    [unreliableServerSocket sendData: sendData];
    
    // Artifically delay the thread to give time for the client to disconnect.
    // Then make the server disconnect.
    [NSThread sleepForTimeInterval: 5.0f];
    [unreliableServerSocket disconnect];
    
    [serverPool drain]; serverPool = nil;
    sessionFinishCount++;
}

+(void) clientSession {
    NSAutoreleasePool * clientPool = [NSAutoreleasePool new];
    [[NSThread currentThread] setName:@"Unit-Test-Client"];
    
    // Connect to server
    [unreliableClientSocket connectToServerAtIPAddress: kIPAddress port: kPortNumber];
    
    [NSThread sleepForTimeInterval: 0.5f];
        
    // Verify our socket configuration.
    NSAssert([unreliableClientSocket isClient], @"Wrong socket configuration! Not client\n");
    
    // Test sending our data. The receive function will verify if this function
    // was successfull.
    NSData* testData = [@"Nihao" dataUsingEncoding: NSUTF8StringEncoding];
    [unreliableClientSocket sendData: testData];

    // Test out receiving a string message and verify it is "Czech".
    NSData * receivedData = [unreliableClientSocket blockingReceiveData];
    NSAssert(receivedData, @"Failed to receive Czech data\n");
    NSString * receivedText = [[[NSString alloc] initWithData: receivedData
                                                     encoding: NSUTF8StringEncoding]
                               autorelease];
    NSAssert([receivedText isEqualToString: @"Czech"] == NSOrderedSame, @"Failed to read Czech\n");
    
    // Disconnect from the server.
    [unreliableClientSocket disconnect];
    
    [clientPool drain]; clientPool = nil;
    sessionFinishCount++;
}


+(void) performUnitTests {
    NSLog(@"UnreliableSocket\n");
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
    NSLog(@"UnUnreliableSocket: Successful\n\n");
}


@end
