//
//  TestHighPassDataFilter.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestHighPassDataFilter.h"

@implementation TestHighPassDataFilter

static id dataFilter = NULL;

+ (void)setUp
{
    // Set-up code here.
    const double rate = 1000.0f / 32.0f;
    const double freq = 7.5; // 7.5 Hertz
    dataFilter = (id)hpdfInit(rate, freq);
    
    NSAssert(dataFilter, @"Failed to Alloc+Init\n");
}

+ (void)tearDown
{
    // Tear-down code here.
    hpdfDealloc((highPassDataFilter_t*)dataFilter); dataFilter = NULL;
}

+ (void)testAdd
{
    hpdfAdd((highPassDataFilter_t*)dataFilter, 1, 1, 1);
    hpdfAdd((highPassDataFilter_t*)dataFilter, 2, 2, 2);
    hpdfAdd((highPassDataFilter_t*)dataFilter, 3, 3, 3);
    hpdfAdd((highPassDataFilter_t*)dataFilter, 4, 4, 4);
    hpdfAdd((highPassDataFilter_t*)dataFilter, 5, 5, 5);
    hpdfAdd((highPassDataFilter_t*)dataFilter, 6, 6, 6);
    hpdfAdd((highPassDataFilter_t*)dataFilter, 7, 7, 7);
    hpdfAdd((highPassDataFilter_t*)dataFilter, 8, 8, 8);
    hpdfAdd((highPassDataFilter_t*)dataFilter, 9, 9, 9);
    
    NSAssert(hpdfGetConstant((highPassDataFilter_t*)dataFilter), @"Wrong constant\n");
    point6f_t point = hpdfGetPoint((highPassDataFilter_t*)dataFilter);
    NSAssert(point.x1 != 0, @"Wrong X\n");
    NSAssert(point.y1 != 0, @"Wrong Y\n");
    NSAssert(point.z1 != 0, @"Wrong X\n");
    NSAssert(point.x2 != 0, @"Wrong X2\n");
    NSAssert(point.y2 != 0, @"Wrong Y2\n");
    NSAssert(point.z2 != 0, @"Wrong Z2\n");
}


+(void) performUnitTests {
    NSLog(@"HighPassDataFilter\n");
    [self setUp];
    [self testAdd];
    [self tearDown];
    NSLog(@"HighPassDataFilter: Successfull\n");
}

@end
