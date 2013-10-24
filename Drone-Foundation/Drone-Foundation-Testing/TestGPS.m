//
//  TestGPS.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestGPS.h"

@implementation TestGPS

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

+(void) testNavigationAngleToDMS {
    printf("\tAngleToDMS\n");
    
    // Coordinates of London, Ontario, Canada
    // 42.9837, -81.2497
    //---------------------------------------
    float degrees = 42.9837f;
    dms_t dms = deg2dms(&degrees);
    assert(dms.degree == 42 && dms.minute == 59 && dms.second >= 1.3 && dms.second <= 1.4);
    
    degrees = 81.2497f;
    dms = deg2dms(&degrees);
    assert(dms.degree == 81 && dms.minute == 14 && dms.second >= 58.9 && dms.second <= 59.0);
    
    // Coordinates of Toronto, Ontario, Canada
    // 43.716589, -79.340686
    //----------------------------------------
    degrees = 43.716589f;
    dms = deg2dms(&degrees);
    assert(dms.degree == 43 && dms.minute == 42 && dms.second >= 59.7 && dms.second <= 59.8);
    
    degrees = 79.340686;
    dms = deg2dms(&degrees);
    assert(dms.degree == 79 && dms.minute == 20 && dms.second >= 26.4 && dms.second <= 26.5);
}

+(void) testNavigationDMSToAngle {
    printf("\tDMSToAngle\n");
    
    // Coordinates of London, Ontario, Canada
    // 42° 59′ 1.32″ N, 81° 14′ 58.92″ W
    //---------------------------------------
    dms_t london_x = {42,59,1.32};
    dms_t london_y = {81,14,58.92};
    
    float output = dms2deg(&london_x);
    assert(output >= 42.9836 && output <= 42.9837); // Good, the approx. is 42.9837
    
    output = dms2deg(&london_y); // Good, the approx. is -81.2497. Ignore neg for now.
    assert(output >= 81.2496 && output >= 81.249 && output <= 81.25);
    
    // Coordinates of Toronto, Ontario, Canada
    // 43° 42′ 59.72″ N, 79° 20′ 26.47″ W
    //----------------------------------------
    dms_t toronto_x = {43,42,59.72};
    dms_t toronto_y = {79,20,26.47};
    
    output = dms2deg(&toronto_x);
    assert(output >= 43.716 && output <= 43.717); // Good, the approx. is 43.716589
    
    output = dms2deg(&toronto_y);
    assert(output >= 79.3406 && output <= 79.3407); // Good, the approx. is -79.340686. Ignore neg for now.
}

+(void) testNavigationDegreesToRadians {
    printf("\tDegreesToRadians\n");
    float degrees = 45.45;
    float radians = deg2rad(&degrees);
    assert(radians >= 0.793252 && radians < 0.79326);
}

+(void) testNavigationRadiansToDegrees {
    printf("\tRadiansToDegrees\n");
    float radians = 0.4509;
    float degrees = rad2deg(&radians);
    assert(degrees < 26 && degrees > 25);
}

+(void) testNavigationNauticalMilesToRadians {
    printf("\tNauticalMilesToRadians\n");
    // TODO
}

+(void)  testNavigationRadiansToNauticalMiles {
    printf("\tRadiansToNauticalMiles\n");
    // TODO
}

+(void) testNavigationSddAndGps {
    printf("\tSDDandGPS\n");
    
    // CASE 1: REAL DATA
    //--------------------------
    sdd_t london = {42.9837, -81.2497};
    sdd_t toronto= {43.716589, -79.340686};
    sdd_t hongkong= {22.278333, 114.158889};
    sdd_t rio = {-22.908333, -43.196389}; // A.K.A.: Rio de Janeiro
    
    gps_t gpsLondon = sdd2gps(&london);
    gps_t gpsToronto= sdd2gps(&toronto);
    gps_t gpsHongkong = sdd2gps(&hongkong);
    gps_t gpsRio = sdd2gps(&rio);
    
    assert(gpsLondon.lat == london.latitude);
    assert(-gpsLondon.lon == london.longitude);
    assert(gpsLondon.lat_dir == 'N');
    assert(gpsLondon.lon_dir == 'W');
    assert(gpsToronto.lat == toronto.latitude);
    assert(-gpsToronto.lon == toronto.longitude);
    assert(gpsToronto.lat_dir == 'N');
    assert(gpsToronto.lon_dir == 'W');
    assert(gpsHongkong.lat == hongkong.latitude);
    assert(gpsHongkong.lon == hongkong.longitude);
    assert(gpsHongkong.lat_dir == 'N');
    assert(gpsHongkong.lon_dir == 'E');
    assert(-gpsRio.lat == rio.latitude);
    assert(-gpsRio.lon == rio.longitude);
    assert(gpsRio.lat_dir == 'S');
    assert(gpsRio.lon_dir == 'W');
}


+(void) performUnitTests {
    [self setUp];
    printf("GPS\n");
    [self testNavigationAngleToDMS];
    [self testNavigationDMSToAngle];
    [self testNavigationDegreesToRadians];
    [self testNavigationRadiansToDegrees];
    [self testNavigationNauticalMilesToRadians];
    [self testNavigationRadiansToNauticalMiles];
    [self testNavigationSddAndGps];
    printf("GPS: Successful\n\n");
    [self tearDown];
}

@end
