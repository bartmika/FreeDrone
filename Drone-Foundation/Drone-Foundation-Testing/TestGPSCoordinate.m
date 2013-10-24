//
//  TestGPSCoordinate.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestGPSCoordinate.h"

@implementation TestGPSCoordinate

static NSAutoreleasePool *pool = nil;
static GPSCoordinate * coordinate = nil;

+ (void)setUp
{
    // Set-up code here.
    pool = [NSAutoreleasePool new];
    coordinate = [GPSCoordinate new];
    NSAssert(coordinate, @"Failed to alloc + init\n");
}

+(void)tearDown
{
    // Tear-down code here.
    [coordinate release]; coordinate = nil;
    [pool drain]; pool = nil;
}

+(void)testGetterAndSetter
{
    float testLatitude = 69.0f;
    float testLongitude = 42.0f;
    float expectedLatitude = 69.0f;
    float expectedLongitude = 42.0f;
    
    [coordinate setLatitudeDegrees: testLatitude];
    [coordinate setLongitudeDegrees: testLongitude];
    
    float actualLatitude = [coordinate latitudeDegrees];
    float actualLongitude = [coordinate longitudeDegrees];
    
    NSAssert(actualLatitude == expectedLatitude, @"Failed: Latitude\n");
    NSAssert(actualLongitude == expectedLongitude, @"Failed: Longitude\n");
}

+(void)testInitWithLongitudeAndLatitude
{
    float expectedLatitude = 69.0f;
    float expectedLongitude = 42.0f;
    GPSCoordinate * coord = [[GPSCoordinate alloc] initWithLatitudeDegrees: 69.0f
                                                          longitudeDegrees: 42.0f];
    
    float actualLatitude = [coord latitudeDegrees];
    float actualLongitude = [coord longitudeDegrees];
    NSAssert(expectedLatitude == actualLatitude, @"Failed alloc with init\n");
    NSAssert(expectedLongitude == actualLongitude, @"Failed alloc with init\n");
    
    [coord release]; coord = nil;
}

+(void)testEqualsGPSCoordinate
{
    [coordinate setLongitudeDegrees: 42.0f];
    [coordinate setLatitudeDegrees: 69.0f];
    
    GPSCoordinate * coord = [[GPSCoordinate alloc] initWithLatitudeDegrees: 99
                                                          longitudeDegrees: 666];
    
    BOOL falseResult = [coordinate equalsGPSCoordinate: coord];
    NSAssert(falseResult == NO, @"Equals when they should not be!\n");
    [coord release]; coord = nil;
    
    coord = [[GPSCoordinate alloc] initWithLatitudeDegrees: 69.0f
                                          longitudeDegrees: 42.0f];
    BOOL trueResult = [coord equalsGPSCoordinate: coordinate];
    NSAssert(trueResult == YES, @"Not equals when the should be!\n");
    [coord release]; coord = nil;
}

+(void)testDegreesWithRadians
{
    // Verified conversion from third party
    float expectedLatDeg = 69.0f;
    float expecteLonDeg = 42.4242f;
    float expectedLatRad = 1.204277184f;
    float expectedLonRad = 0.740442706f;
    [coordinate setLatitudeDegrees: expectedLatDeg];
    [coordinate setLongitudeDegrees: expecteLonDeg];
    
    // Attempt to get the longitude & latitude which is formatted in radians.
    float lat = [coordinate latitudeRadians];
    float lon = [coordinate longitudeRadians];
    
    // Verify results worked.
    NSAssert(expectedLatRad - lat <= 0.01f, @"Wrong radians lat\n");
    NSAssert(expectedLonRad - lon <= 0.01f, @"Wrong radians lon\n");
    
    // Attempt to use convience initializer for radians
    GPSCoordinate * coord = [[GPSCoordinate alloc] initWithLatitudeRadians: expectedLatRad
                                                          longitudeRadians: expectedLonRad];
    // Verify
    NSAssert(coord, @"Failed using convience initializer\n");
    lat = [coord latitudeDegrees];
    lon = [coord longitudeDegrees];
    NSAssert(expectedLatDeg - lat <= 0.01f, @"Wrong degrees lat\n");
    NSAssert(expecteLonDeg - lon <= 0.01f, @"Wrong degrees lon\n");
    
    [coord release]; coord = nil;
}

+(void)testWithDegreesMinutesSeconds
{
    // Coordinates of London, Ontario, Canada
    // 42° 59′ 1.32″ N, 81° 14′ 58.92″ W
    //---------------------------------------
    // Verified
    float expectedLatitude = 42.9837f;
    float expectedLongitude = -81.2497f;
    dms_t latitudeDMS = {42,59,1.32};
    dms_t longitudeDMS = {-81,14,58.92};
    
    // Attempt to use convience initializer which converts DMS to SDD.
    GPSCoordinate * dmsLondon = [[GPSCoordinate alloc]
                                 initWithLatitudeDegreesMinuteSeconds: latitudeDMS
                                 longitudeDegreesMinutesSeconds: longitudeDMS];
    // Verify it worked...
    NSAssert(dmsLondon, @"Failed to load convience init\n");
    
    // Attempt to get the latitude & longitude.
    float latitudeDegrees = [dmsLondon latitudeDegrees];
    float longitudeDegrees = [dmsLondon longitudeDegrees];
    
    NSAssert(expectedLatitude - latitudeDegrees <= 0.01f, @"Wrong latitude\n");
    NSAssert(expectedLongitude - longitudeDegrees <= 0.01f, @"Wrong longitude\n");
    
    // Attempt to get the converted data.
    dms_t actualLatitudeDMS = [dmsLondon latitudeDegreesMinutesSeconds];
    dms_t actualLongitudDMS = [dmsLondon longitudeDegreesMinutesSeconds];
    
    // Verify our conversion from SDD to DMS is valid.
    NSAssert(actualLatitudeDMS.degree - latitudeDMS.degree <= 0.01f, @"Wrong degree\n");
    NSAssert(actualLatitudeDMS.minute - latitudeDMS.minute <= 0.01f, @"Wrong minute\n");
    NSAssert(actualLatitudeDMS.second - latitudeDMS.second <= 0.1f, @"Wrong second\n");
    NSAssert(actualLongitudDMS.degree - longitudeDMS.degree <= 0.1f, @"Wrong degree\n");
    NSAssert(actualLongitudDMS.minute - longitudeDMS.minute <= 0.1f, @"Wrong minute\n");
    NSAssert(actualLongitudDMS.second - longitudeDMS.second <= 0.1f, @"Wrong second\n");
    
    [dmsLondon release]; dmsLondon = nil;
}


+(void) performUnitTests {
    NSLog(@"GPSCoordinate\n");
    [self setUp]; [self testGetterAndSetter]; [self tearDown];
    [self setUp]; [self testInitWithLongitudeAndLatitude]; [self tearDown];
    [self setUp]; [self testDegreesWithRadians]; [self tearDown];
    [self setUp]; [self testEqualsGPSCoordinate]; [self tearDown];
    [self setUp]; [self testWithDegreesMinutesSeconds]; [self tearDown];
    NSLog(@"GPSCoordinate: Succesfull\n\n");
}

@end
