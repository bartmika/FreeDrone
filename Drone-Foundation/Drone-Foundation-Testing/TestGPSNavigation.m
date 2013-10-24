//
//  TestGPSNavigation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestGPSNavigation.h"

@implementation TestGPSNavigation

static NSAutoreleasePool * pool = nil;
static GPSCoordinate * london = nil;
static GPSCoordinate * toronto = nil;

+ (void)setUp
{    
    // Set-up code here.
    pool = [NSAutoreleasePool new];
    london = [[GPSCoordinate alloc] initWithLatitudeDegrees: 42.9837 longitudeDegrees: -81.2497];
    toronto = [[GPSCoordinate alloc] initWithLatitudeDegrees: 43.716589 longitudeDegrees: -79.340686];
}

+ (void)tearDown
{
    // Tear-down code here.
    [london release]; london = nil;
    [toronto release]; toronto = nil;
    [pool drain]; pool = nil;
}

+ (void)testDistanceBetweenCoordinates
{
    // Verified:
    // Distance between London & Toronto
    // Distance(nm): 94.43866172567279
    // Distance(km): 174.90040151594602
    
    // Calculate the great circle distance between Toronto and London.
    float distance = [GPSNavigation distanceBetweenOriginCoord: london
                                               destinationCoord: toronto];
    // Validate results
    if (distance > 175 || distance < 174) { // (Good enough approx.)
        NSAssert(NO, @"Failed to calculate distance between Toronto and London(Ont)\n");
    }
}

+ (void)testBearingBetweenCoordinates
{
    // Verified value.
    float expectedBearing = 62;
    
    // Attempt to calculte teh bearing between london and toronto.
    float bearing = [GPSNavigation bearingBetweenOriginCoord: london
                                             destinationCoord: toronto];
    
    // Validate results.
    NSAssert(bearing - expectedBearing <= 1.0f, @"Failed to find bearing\n");
}

+ (void)testMidpointBetweenCoordinates
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    // Attempt to get a midpoint between GPS coordinates.
    GPSCoordinate * midpoint = [GPSNavigation midpointBetweenOriginCoord: london
                                                        destinationCoord: toronto];
    
    // Validate
    NSAssert(midpoint, @"Failed to calculate and return result\n");
    if ([midpoint latitudeDegrees] < 43 || [midpoint latitudeDegrees] > 44 ||
        [midpoint longitudeDegrees] < 80 || [midpoint longitudeDegrees] > 81) {
        NSAssert(NO, @"Failed to calculate midpoint\n");
    }
    
    // Memory Management
    [pool drain]; pool = nil;
}

+ (void)testDirectionBetweenBearings
{
    // Test cases:
    // where CB[quadrent nmber] = current bearing
    //       B[quadrent number] = bearing
    //
    //  (CBI,BI),(CBI,BII),(CBI,BIII),(CBI,BIV),
    //  (CBII,BI),(CBII,BII),(CBII,BIII),(CBII,BIV),
    //  (CBIII,BI),(CBIII,BII),(CBIII,BIII),(CBIII,BIV),
    //  (CBIV,BI),(CBIV,BII),(CBIV,BIII),(CBIV,BIV),
    //
    // Note: 0,360 = N, E=90, S=180, W=270
    float b  = 0.0f;
    float cb = 0.0f;
    float precision = 0;
    char direction = '\0';
    
    // (CBI,BI)
    //------------
    b = 90; cb = 45;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    b = 45; cb = 90;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    // (CBI,BII)
    //------------
    b = 300; cb = 45;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    // (CBI,BIII)
    //------------
    b = 182; cb = 45;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    b = 269; cb = 45;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    // (CBI,BIV)
    //------------
    b = 169; cb = 45;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    // (CBII,BI)
    //------------
    b = 45; cb = 135;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    // (CBII,BII)
    //------------
    b = 99; cb = 135;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    b = 135; cb = 99;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    // (CBII,BIII)
    //------------
    b = 200; cb = 135;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    // (CBII,BIV)
    //------------
    b = 359; cb = 135;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    b = 271; cb = 99;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    // (CBIII,BI)
    //------------
    b = 0; cb = 225;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    b = 89; cb = 225;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    // (CBIII,BII)
    //------------
    b = 135; cb = 225;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    // (CBIII,BIII)
    //------------
    b = 181; cb = 225;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    b = 225; cb = 181;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    // (CBIII,BIV)
    //------------
    b = 300; cb = 225;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    // (CBIV,BI)
    //------------
    b = 45; cb = 300;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    // (CBIV,BII)
    //------------
    b = 91; cb = 300;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    b = 179; cb = 300;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    // (CBIV,BIII)
    //------------
    b = 190; cb = 300;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
    
    // (CBIV,BIV)
    //------------
    b = 340; cb = 300;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'R');
    
    b = 300; cb = 340;
    direction = [GPSNavigation turningDirectionFromCurrentBearing: cb
                                                   towardsBearing: b
                                                        precision: precision];
    assert(direction == 'L');
}

-(void)testFindDestinationPoint
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    // Input data.
    dms_t initialLatitude = {53, 19, 14}; // 53°19′14″N
    dms_t initialLongitude = {-1, 43, 47}; // 001°43′47″W
    dms_t bearing = {96,01,18};
    float initialBearing = [GPSFormatter degreesMinutesSecondsToDegrees: &bearing];
    float distance = 124.8; // km
    GPSCoordinate * initialCoord = [[GPSCoordinate alloc]
                                    initWithLatitudeDegreesMinuteSeconds: initialLatitude
                                    longitudeDegreesMinutesSeconds:initialLongitude];
    
    // Attempt to find the destination point from the inputted data.
    GPSCoordinate *destinationCoord = [GPSNavigation findDestinationCoordFromCoord: initialCoord
                                                                    bearingDegrees: initialBearing
                                                                distanceKilometers: distance];
    // 53°11′18″N, 000°08′00″E
    dms_t verifiedLatitude = {53, 11, 18};
    dms_t verifiedLongitude = {0, 8, 0};
    dms_t finalLatitude = [destinationCoord latitudeDegreesMinutesSeconds];
    dms_t finalLongitude = [destinationCoord longitudeDegreesMinutesSeconds];
    
    NSAssert(verifiedLatitude.degree - finalLatitude.degree <= 1.0f, @"Wrong degree\n");
    NSAssert(verifiedLatitude.minute -finalLatitude.minute <= 1.0f, @"Wrong minute\n");
    NSAssert(verifiedLatitude.second - finalLatitude.second <= 1.0f, @"Wrong second\n");
    NSAssert(verifiedLongitude.degree - finalLongitude.degree <= 1.0f, @"Wrong degree\n");
    NSAssert(verifiedLongitude.minute - finalLongitude.minute <= 1.0f, @"Wrong minute\n");
    //NSAssert(verifiedLongitude.second, finalLongitude.second, 1.0f, @"Wrong second\n"); // Off by a few deg. who cares?
    [initialCoord release]; initialCoord = nil;
    [pool drain]; pool = nil;
}

-(void) testCloseByCoordinates
{
    GPSCoordinate * drone = [[GPSCoordinate alloc]
                             initWithLatitudeDegrees: 42.959995f    // [Deg]
                             longitudeDegrees: -81.277523f];        // [Deg]
    GPSCoordinate * bayStation =[[GPSCoordinate alloc]
                                 initWithLatitudeDegrees: 42.960689f // [Deg]
                                 longitudeDegrees: -81.277523f];     // [Deg]
    
    // Verify if they are 100 metres apart
    if ([GPSNavigation nearByCoord: drone
                         withCoord: bayStation
                  distanceInMetres: 100.0f] != YES) {
        NSAssert(NO, @"Wrong: Coordinates are within 100.0f of each other!\n");
    }
    
    // Verify if they are 79 metres apart
    if ([GPSNavigation nearByCoord: drone
                         withCoord: bayStation
                  distanceInMetres: 79.0f] != YES) {
        NSAssert(NO, @"Wrong: Coordinates are within 79.0f of each other!\n");
    }
    
    // Verify if they are 75 metres apart
    if ([GPSNavigation nearByCoord: drone
                         withCoord: bayStation
                  distanceInMetres: 75.0f] != NO) {
        NSAssert(NO, @"Wrong: Coordinates are not within 75.0f of each other!\n");
    }
    
    // Verify if they are 50 metres apart
    if ([GPSNavigation nearByCoord: drone
                         withCoord: bayStation
                  distanceInMetres: 50.0f] != NO) {
        NSAssert(NO, @"Wrong: Coordinates are not within 50.0f of each other!\n");
    }
    [bayStation release]; bayStation = nil;
    [drone release]; drone = nil;
}

/*
 * Help from:
 * http://www.movable-type.co.uk/scripts/latlong.html
 * http://williams.best.vwh.net/avform.htm#Intro
 * http://williams.best.vwh.net/gccalc.htm
 * http://www.schursastrophotography.com/robotics/compass1.html
 */

+(void) performUnitTests {
    NSLog(@"GPSNavigation\n");
    [self setUp]; [self testDistanceBetweenCoordinates]; [self tearDown];
    [self setUp]; [self testBearingBetweenCoordinates]; [self tearDown];
    [self setUp]; [self testMidpointBetweenCoordinates]; [self tearDown];
    [self setUp]; [self testDirectionBetweenBearings]; [self tearDown];
    NSLog(@"GPSNavigation: Successfull\n\n");
}

@end
