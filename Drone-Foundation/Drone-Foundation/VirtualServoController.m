//
//  VirtualServoController.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "VirtualServoController.h"

@implementation VirtualServoController

@synthesize keepUsageLog;
@synthesize usageLog;
@synthesize keepPositionLog;
@synthesize positionLog;
@synthesize engaged;

static VirtualServoController * sharedVirtualServo = nil;

+(VirtualServoController*) sharedInstance {
    @synchronized([VirtualServoController class]) {
        if (sharedVirtualServo == nil) {
            sharedVirtualServo = [[VirtualServoController alloc] init];
        }
    }
    
    return sharedVirtualServo;
}

+(id)alloc
{
    @synchronized([VirtualServoController class]) {
        sharedVirtualServo = [super alloc];
    }
    
    return sharedVirtualServo;
}

- (id)init {
    self = [super init];
    if (self) {
        keepUsageLog = NO;
        keepPositionLog = NO;
        engaged = NO;
        position = 7;
        positionLog = [[NSMutableArray alloc] initWithCapacity: 500];
        usageLog = [[NSMutableArray alloc] initWithCapacity: 500];
    }
    return self;
}

-(void) dealloc {
    [usageLog removeAllObjects];
    [usageLog release]; usageLog = nil;
    [positionLog removeAllObjects];
    [positionLog release]; positionLog = nil;
    sharedVirtualServo = nil;
    [super dealloc];
}


-(const float) position {
    if (keepUsageLog) { // Keep a record of usage
        NSString * log = [NSString stringWithFormat:@"Position: %f", position];
        [usageLog addObject: log];
    }
    
    return position;
}

-(void)setPosition: (const float) inputPosition {
    // Set the position
    position = inputPosition;
    
    if (keepPositionLog) { // Keep a record of the positions set.
        NSNumber * positionNumber = [NSNumber numberWithFloat: inputPosition];
        [positionLog addObject: positionNumber];
    }
    
    if (keepUsageLog) { // Keep a record of usage
        NSNumber * positionNumber = [NSNumber numberWithFloat: inputPosition];
        NSString * log = [NSString stringWithFormat: @"SetPosition: %@", positionNumber];
        [usageLog addObject: log];
    }
}

-(void) engage {
    engaged = YES;
    
    if (keepUsageLog) {
        // Keep a record of usage
        NSString * log = @"Engage";
        [usageLog addObject: log];
    }
}

-(void) disengage {
    engaged = NO;
    
    if (keepUsageLog) {
        // Keep a record of usage
        NSString * log = @"Disengage";
        [usageLog addObject: log];
    }
}

-(BOOL)deviceIsOperational
{
    return YES;
}

-(NSDictionary*) pollDeviceForData {
    if (keepUsageLog) {
        // Keep a record of usage
        NSString * log = @"PollDeviceForData";
        [usageLog addObject: log];
    }
    
    NSNumber * positionNumber = [NSNumber numberWithFloat: position];
    NSNumber * isEngaged = [NSNumber numberWithBool: engaged];
    
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:
                           positionNumber, @"Position", isEngaged, @"IsEngaged", nil];
    
    return data;
}

-(BOOL) isEngaged {
    return engaged;
}

@end
