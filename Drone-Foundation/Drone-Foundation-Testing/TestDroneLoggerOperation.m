//
//  TestDroneLoggerOperation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-09.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestDroneLoggerOperation.h"

@implementation TestDroneLoggerOperation

static NSAutoreleasePool *pool = nil;
static DroneLoggerOperation * logger = nil;
static NSOperationQueue * queue = nil;

+ (void)setUp
{
    // Set-up code here.
    pool = [NSAutoreleasePool new];
    logger = [[DroneLoggerOperation alloc] init];
    NSAssert(logger, @"Failed to alloc+init operation\n");
    
    queue = [NSOperationQueue new];
}

+ (void)tearDown
{
    // Tear-down code here.
    [pool drain]; pool = nil;
}

+ (void)testOperation
{
    [queue addOperation: logger];
    
    NSUInteger maxTimer = 50;
    
    // Make the current thread wait for 10 seconds while the
    // DroneLoggerOperation will run seperately generating
    // the file.
    for (NSUInteger timer = 1; timer <= maxTimer; timer++) {
        NSLog(@"Write Cycle: %lu / %lu\n", (unsigned long)timer, (unsigned long)maxTimer);
        [NSThread sleepForTimeInterval: 0.5f];
    }
    
    // Turn off the operation.
    [logger cancel];
    
    // Give a few seconds for the operation to terminate.
    while ([logger isFinished] == NO) {
        [NSThread sleepForTimeInterval: 1.0f];
    }
    
    NSAssert([logger isFinished] == YES, @"Failed to finish DroneLogger\n");
}


+(void) performUnitTests {
    NSLog(@"DroneLoggerOperation\n");
    [self setUp];
    [self testOperation];
    [self tearDown];
    NSLog(@"DroneLoggerOperation: Successfull\n\n");
}

@end
