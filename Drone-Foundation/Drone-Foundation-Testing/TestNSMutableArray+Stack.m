//
//  TestNSMutableArray+Stack.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-05.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestNSMutableArray+Stack.h"

@implementation TestNSMutableArray_Stack

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

+ (void)testPush
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    NSString * china = @"China";
    NSString * russia = @"Russia";
    NSString * japan = @"Japan";
    NSString * korea = @"Korea";
    NSString * mongolia = @"Mongolia";
    NSString * poland = @"Poland";
    [array push: china];
    [array push: russia];
    [array push: japan];
    [array push: korea];
    [array push: mongolia];
    [array push: poland];
    
    NSString * country = [array objectAtIndex:0];
    assert(country == china);
    country = [array objectAtIndex:1];
    assert(country == russia);
    country = [array objectAtIndex:2];
    assert(country == japan);
    country = [array objectAtIndex:3];
    assert(country == korea);
    country = [array objectAtIndex:4];
    assert(country == mongolia);
    country = [array objectAtIndex:5];
    assert(country == poland);
    
    [array release]; array = nil;
}

+ (void)testPop
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    NSString * china = @"China";
    NSString * russia = @"Russia";
    NSString * japan = @"Japan";
    NSString * korea = @"Korea";
    NSString * mongolia = @"Mongolia";
    NSString * poland = @"Poland";
    [array addObject: china];
    [array addObject: russia];
    [array addObject: japan];
    [array addObject: korea];
    [array addObject: mongolia];
    [array addObject: poland];
    
    NSString * country = [array pop];
    assert(country == country);
    country = [array pop];
    assert(country == mongolia);
    country = [array pop];
    assert(country == korea);
    country = [array pop];
    assert(country == japan);
    country = [array pop];
    assert(country == russia);
    country = [array pop];
    assert(country == china);
    
    [array release]; array = nil;
}


+(void) performUnitTests {
    NSLog(@"NSMutableArray+Stack");
    [self setUp]; [self testPop]; [self tearDown];
    [self setUp]; [self testPush]; [self tearDown];
    NSLog(@"NSMutableArray+Stack: Finished\n\n");
}

@end
