//
//  TestCompassBearing.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import "TestCompassBearing.h"

// Custom
#import "CompassBearing.h"

@implementation TestCompassBearing

static id compassBearing = NULL;

+ (void)setUp
{
    // Set-up code here.
    const double rate = 1000.0f / 32.0f;
    const double freq = 15.0; // hertz
    compassBearing = (id)compassBearingInit(rate, freq);
    NSAssert(compassBearing, @"Failed init\n");
    
    compassBearingSetUseDeclination((compassBearing_t *)compassBearing, 0); // Turn off inclination
}

+ (void)tearDown
{
    // Tear-down code here.
    compassBearingDealloc((compassBearing_t *)compassBearing); compassBearing = NULL;
}

+ (void) testSetData
{
    compassBearingSetData((compassBearing_t *)compassBearing, 1, 1, 1, 1, 1, 1);
    
    double result = compassBearingCompute((compassBearing_t *)compassBearing);
    NSAssert(result, @"Wrong computation for compass bearing\n");
}

+(void) performUnitTests
{
    NSLog(@"CompassBearing\n");
    [self setUp];
    [self testSetData];
    [self tearDown];
    NSLog(@"CompassBearing: Successfull\n\n");
}

@end
