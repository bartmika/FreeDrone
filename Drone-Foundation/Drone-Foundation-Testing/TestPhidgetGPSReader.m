//
//  TestPhidgetGPSReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestPhidgetGPSReader.h"

@implementation TestPhidgetGPSReader

static phidgetGPSReader_t *gpsReader = NULL;

+ (void)setUp
{
    // Set-up code here.
    gpsReader = phidgetGPSReaderInit();
    NSAssert(gpsReader, @"Failed init+alloc\n");
}

+ (void)tearDown
{
    // Tear-down code here.
    phidgetGPSReaderDealloc(gpsReader); gpsReader = NULL;
}

+ (void)testGetCoordinate
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (NSUInteger poll = 1; poll <= 10; poll++) {
        sdd_t coordinate = phidgetGPSReaderGetCoordinate(gpsReader);
        
        NSAssert(coordinate.latitude, @"Please leave your latitude of zero\n");
        NSAssert(coordinate.longitude, @"Please leave your longitude of zero\n");
        NSLog(@"Poll %lu/10\tLat: %f\tLon: %f\n", (unsigned long)poll, coordinate.latitude, coordinate.longitude);
        [NSThread sleepForTimeInterval: 0.5f];
    }
    [pool drain]; pool = nil;
}

+ (void)testGetHeading
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (NSUInteger poll = 1; poll <= 10; poll++) {
        float heading = phidgetGPSReaderGetHeading(gpsReader);
        
        NSLog(@"Poll %lu/10\tHed: %f\n", (unsigned long)poll, heading);
        [NSThread sleepForTimeInterval: 0.5f];
    }
    [pool drain]; pool = nil;
}

+ (void)testGetVelocity
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (NSUInteger poll = 1; poll <= 10; poll++) {
        float velocity = phidgetGPSReaderGetVelocity(gpsReader);
        
        NSLog(@"Poll %lu/10\tVel: %f\n", (unsigned long)poll, velocity);
        [NSThread sleepForTimeInterval: 0.5f];
    }
    [pool drain]; pool = nil;
}

+ (void)testGetAltitude
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (NSUInteger poll = 1; poll <= 10; poll++) {
        float altitude = phidgetGPSReaderGetAltitude(gpsReader);
        
        NSLog(@"Poll %lu/10\tAlt: %f\n", (unsigned long)poll, altitude);
        [NSThread sleepForTimeInterval: 0.5f];
    }
    [pool drain]; pool = nil;
}

+ (void)testGetDate
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (NSUInteger poll = 1; poll <= 10; poll++) {
        GPSDate date = phidgetGPSReaderGetDate(gpsReader);
        
        NSLog(@"Poll %lu/10\tDay: %hd Mon: %hd Yr: %hd\n", (unsigned long)poll,
                                                              date.tm_mday,
                                                              date.tm_mon,
                                                              date.tm_year);
        [NSThread sleepForTimeInterval: 0.5f];
    }
    [pool drain]; pool = nil;
}

+ (void)testGetTime
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (NSUInteger poll = 1; poll <= 10; poll++) {
        GPSTime time = phidgetGPSReaderGetTime(gpsReader);
        
        NSLog(@"Poll %lu/10\tHr: %hd Min: %hd Ms: %hd Sec: %hd\n",
              (unsigned long)poll, time.tm_hour, time.tm_min, time.tm_ms, time.tm_sec);
        [NSThread sleepForTimeInterval: 0.5f];
    }
    [pool drain]; pool = nil;
}

+ (void)testGetData
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (NSUInteger poll = 1; poll <= 10; poll++) {
        gpsReceiverData_t gpsData = phidgetGPSReaderGetData(gpsReader);
        
        NSLog(@"Poll %lu/10\tGetGPSData\n", (unsigned long)poll);
        NSAssert(gpsData.latitude != 0 && gpsData.longitude != 0, @"Bad GPS Data");
        [NSThread sleepForTimeInterval: 0.5f];
    }
    [pool drain]; pool = nil;
}

+(void) performUnitTests
{
    NSLog(@"PhidgetGPSReader\n");
    [self setUp];
    [self testGetCoordinate];
    [self testGetHeading];
    [self testGetVelocity];
    [self testGetAltitude];
    [self testGetDate];
    [self testGetTime];
    [self testGetData];
    [self tearDown];
    NSLog(@"PhidgetGPSReader: Successful\n\n");
}

@end
