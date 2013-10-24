//
//  TestGPSFormatter.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestGPSFormatter.h"

@implementation TestGPSFormatter

static NSAutoreleasePool * pool = nil;

+ (void)setUp
{
    // Set-up code here.
    pool = [NSAutoreleasePool new];
}

+ (void)tearDown
{
    // Tear-down code here.
    [pool drain]; pool = nil;
}

+ (void)testDegreesToRadians
{
    // Verified
    float expectedRadians = 1.211607567f;
    float degrees = 69.42f;
    
    // Attempt to convert
    float actualRadians = [GPSFormatter degreesToRadians: &degrees];
    
    // Verify
    NSAssert(expectedRadians - actualRadians <= 0.000001f, @"Failed to convert to radians\n");
}

+ (void)testRadiansToDegrees
{
    // Verified
    float expectedDegrees = 69.42f;
    float radians = 1.211607567f;
    
    // Attempt to convert
    float actualDegrees = [GPSFormatter radiansToDegrees: &radians];
    
    // Verify
    NSAssert(expectedDegrees - actualDegrees <= 0.001f, @"Failed to convert to degrees\n");
}

+(void)testDegreesMintuesSecondsToDegrees
{
    // Coordinates of London, Ontario, Canada
    // 42° 59′ 1.32″ N, 81° 14′ 58.92″ W
    // 42.9837, -81.2497
    //---------------------------------------
    dms_t verifiedLatitude = {42.0f, 59.0f, 1.32f};
    dms_t verifiedLongitude = {-81.0f, 14.0f, 58.92f};
    float latitude = 42.9837f;
    float longitude = -81.2497f;
    
    dms_t actualLatitude = [GPSFormatter degreesToDegreesMinutesSeconds: &latitude];
    dms_t actualLongitude = [GPSFormatter degreesToDegreesMinutesSeconds: &longitude];
    
    NSAssert(actualLatitude.degree - verifiedLatitude.degree <= 0.01f, @"Degrees");
    NSAssert(actualLatitude.minute - verifiedLatitude.minute <= 0.01f, @"Minutes");
    NSAssert(actualLatitude.second - verifiedLatitude.second <= 0.01f, @"Seconds");
    NSAssert(actualLongitude.degree - verifiedLongitude.degree <= 0.01f, @"Degrees");
    NSAssert(actualLongitude.minute - verifiedLongitude.minute <= 0.01f, @"Minutes");
    NSAssert(actualLongitude.second - verifiedLongitude.second <= 0.1f, @"Seconds");
    
}

+(void)testDegreesToDegreesMinutesSEconds
{
    // Coordinates of London, Ontario, Canada
    // 42° 59′ 1.32″ N, 81° 14′ 58.92″ W
    //---------------------------------------
    dms_t londonLatitude = {42,59,1.32};
    dms_t londonLongitude = {-81,14,58.92};
    float verifiedlatitude = 42.9837f;
    float verifiedlongitude = -81.2497f;
    
    float actualLatitude = [GPSFormatter degreesMinutesSecondsToDegrees: &londonLatitude];
    float actualLongitude = [GPSFormatter degreesMinutesSecondsToDegrees: &londonLongitude];
    
    NSAssert(actualLatitude - verifiedlatitude <= 0.0001f, @"latitude\n");
    NSAssert(actualLongitude - verifiedlongitude <= 0.0001f, @"longitude\n");
}


+(void) performUnitTests {
    NSLog(@"GPSFormatter\n");
    [self setUp]; [self testDegreesToRadians]; [self tearDown];
    [self setUp]; [self testRadiansToDegrees]; [self tearDown];
    [self setUp]; [self testDegreesMintuesSecondsToDegrees]; [self tearDown];
    [self setUp]; [self testDegreesToDegreesMinutesSEconds]; [self tearDown];
    NSLog(@"GPSFormatter: Successfull\n\n");
}

@end
