//
//  TestGlobalSatBU353GPSReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestGlobalSatBU353GPSReader.h"

@implementation TestGlobalSatBU353GPSReader


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

+(void) smokeTestGPSDriver {
    printf("\tInit\n");
     // Attempt to load the proper driver
    printf("\t\tWarming Up...\n");
    globalSatBU353GPSReader_t * ptrGPSReader = globalSatBU353GPSReaderInit();
    [NSThread sleepForTimeInterval: 5.0f]; // Add artificial delay.
    printf("\t\tFinished!\n");
    
    printf("\tGetGPSCoord\n");
    // Test out and verify our GetGPSCoordinates functionality works.
    size_t count;
    const size_t max = 25;
      
    printf("\tGetSDDCoord\n");
    // Test out and verify our GetGPSCoordinates functionality works.
    for (count = 1; count <= max ; count++) {
        sdd_t sddCoordinate = globalSatBU353GPSReaderGetCoordinate(ptrGPSReader);
        assert(sddCoordinate.latitude);
        assert(sddCoordinate.longitude);
        printf("\t\t%zd\n", count);
        [NSThread sleepForTimeInterval: 1.0f]; // Add artifical delay.
    }
    
    printf("\tDealloc\n");
    // Attempt to close and deallocate our GPS hardware from our system.
    globalSatBU353GPSReaderDealloc(ptrGPSReader);
    ptrGPSReader = NULL;
}

+(void) performUnitTests {
    [self setUp];
    [self smokeTestGPSDriver];
    [self tearDown];
}

@end
