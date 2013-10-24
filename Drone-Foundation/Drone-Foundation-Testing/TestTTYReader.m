//
//  TestTTYReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestTTYReader.h"

@implementation TestTTYReader

static NSAutoreleasePool *pool = nil;

+(void)setUp
{
    // Set-up code here.
    pool = [NSAutoreleasePool new];
}

+(void)tearDown
{
    // Tear-down code here.
    [pool drain]; pool = nil;
}

+(void) testTTYReaderBuffered
{
    const unsigned int numberOfTrials = 50;
    const unsigned int bufferLen = 127;
    char buffer[bufferLen] = {};
    printf("TTYReader [Buffered]: Unit Tests\n");
    printf("\tInit\n");
    ttyReader_t * ptrTTYReader = ttyrInit(kGlobalSatBU353GPSReceiverDevice,
                                          kGlobalSatBU353GPSReceiverBaud,
                                          "\r\n");
    assert(ptrTTYReader); // Verify reader was initialized
    
    // Next give the GPS Receiver 5 seconds to load up.
    printf("\tWarming Up... ");
    [NSThread sleepForTimeInterval: 5.0f];
    
    // Next go through and poll for the GPS coordinates.
    printf("\n\tReady\n");
    for ( unsigned int trial = 0; trial < numberOfTrials; trial++ ) {
        
        // Verify our read function works properly
        ttyrRead(ptrTTYReader, buffer, bufferLen); // Make buffered read.
        if (strlen(buffer) <= 0) {
            printf("Nothing Returned!\n");
        } else {
            printf("\t\tRead:\n");
            printf("\t\t\t%s\n", buffer);
            memset(buffer, 0, bufferLen); // Clear the data in the variable.
        }
        
        [NSThread sleepForTimeInterval: 1.0f]; // Add artifical delay.
    }
    
    printf("\tDealloc\n");
    ttyrDealloc(ptrTTYReader); ptrTTYReader = NULL;
    printf("TTYReader [Buffered]: Successful\n\n");
    return;
    
}

+(void) performUnitTests {
    NSLog(@"TTYReader\n");
    [self setUp]; [self testTTYReaderBuffered]; [self tearDown];
    NSLog(@"TTYReader: Finished\n\n");
}

@end
