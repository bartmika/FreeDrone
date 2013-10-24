//
//  TestGPSReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestGPSReader.h"

@implementation TestGPSReader

static GPSReader *gpsReader = nil;

+ (void)setUp
{    
    // Set-up code here.
    gpsReader = [GPSReader sharedInstance];
    NSAssert(gpsReader, @"Failed init+alloc singleton object\n");
}

+ (void)tearDown
{
    // Tear-down code here.
    [gpsReader release];
    gpsReader = nil;
}

+ (void)testGetCoordinateAndAltitudeAndHeadingAndSpeed
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    GPSCoordinate* coordinate = nil;
    double altitude = 0.0f;
    double heading = 0.0f;
    double speed = 0.0f;
    
    for (NSUInteger i = 0; i < 10; i++) {
        coordinate = [gpsReader coordinate];
        altitude = [gpsReader altitude];
        heading = [gpsReader heading];
        speed = [gpsReader speed];
        
        if ([coordinate latitudeDegrees] == 0 || [coordinate longitudeDegrees] == 0) {
            NSAssert(NO, @"Wrong gps - please get out of the north pole as well!\n");
        }
        NSLog(@"Lat: %f Lon: %f\n", coordinate.latitudeDegrees, coordinate.longitudeDegrees);
        
        if ( heading > 360 || heading < 0) {
            NSAssert(NO, @"Wrong heading - outside acceptable range!\n");
        }
        NSLog(@"Hed: %f\n", heading);
        NSLog(@"Alt: %f\n", altitude);
        NSLog(@"Spd: %f\n", speed);
        
        // Test getting the string of data.
        NSDictionary * gpsData = [gpsReader pollDeviceForData];
        NSAssert(gpsData, @"Failed to poll device for data");
        NSAssert([gpsData objectForKey:@"Latitude"], @"Failed to read latitude\n");
        NSAssert([gpsData objectForKey:@"Longitude"], @"Failed to read longitude\n");
        NSAssert([gpsData objectForKey:@"Heading"], @"Failed to read heading\n");
        NSAssert([gpsData objectForKey:@"Altitude"], @"Failed to read altitude\n");
        gpsData = nil;
        
        [NSThread sleepForTimeInterval: 1.0f]; // Add artificial delay to give time
        // for the gps to poll more data.
    }
    
    [pool drain];
}


+(void) performUnitTests {
    NSLog(@"GPSReader\n");
    [self setUp];
    [self testGetCoordinateAndAltitudeAndHeadingAndSpeed];
    [self tearDown];
    NSLog(@"GPSReader: Successfull\n\n");
}



@end
