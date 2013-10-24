//
//  TestLowPassDataFilter.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import "TestLowPassDataFilter.h"

@implementation TestLowPassDataFilter

static id dataFilter = NULL;

+(void)setUp
{
    // Set-up code here.
    const float rate = 1000.0f / 32.0f;
    
    // Rate = 1000 entries / 32 bits
    dataFilter = (id)lpdfInit(rate, 7.5);
    
    NSAssert(dataFilter, @"Failed to Alloc+Init\n");
}

+(void)tearDown
{
    // Tear-down code here.
    lpdfDealloc((lowPassDataFilter_t*)dataFilter); dataFilter=NULL;
}

+(void)testAdd {
    lpdfAdd((lowPassDataFilter_t*)dataFilter, 1, 1, 1);
    lpdfAdd((lowPassDataFilter_t*)dataFilter, 2, 2, 2);
    lpdfAdd((lowPassDataFilter_t*)dataFilter, 3, 3, 3);
    lpdfAdd((lowPassDataFilter_t*)dataFilter, 4, 4, 4);
    lpdfAdd((lowPassDataFilter_t*)dataFilter, 5, 5, 5);
    lpdfAdd((lowPassDataFilter_t*)dataFilter, 6, 6, 6);
    lpdfAdd((lowPassDataFilter_t*)dataFilter, 7, 7, 7);
    lpdfAdd((lowPassDataFilter_t*)dataFilter, 8, 8, 8);
    lpdfAdd((lowPassDataFilter_t*)dataFilter, 9, 9, 9);
    
    NSAssert(lpdfGetConstant((lowPassDataFilter_t *)dataFilter) != 0, @"Wrong constant");
    point3f_t point = lpdfGetPoint((lowPassDataFilter_t*)dataFilter);
    NSAssert(point.x != 0, @"Wrong X\n");
    NSAssert(point.y != 0, @"Wrong X\n");
    NSAssert(point.x != 0, @"Wrong Z\n");
}


+(void) performUnitTests
{
    NSLog(@"LowPassDataFilter\n");
    [self setUp];
    [self testAdd];
    [self tearDown];
    NSLog(@"LowPassDataFilter: Successful\n\n");
}


@end
