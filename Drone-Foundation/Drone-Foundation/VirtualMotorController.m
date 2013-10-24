//
//  VirtualMotorController.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "VirtualMotorController.h"

@implementation VirtualMotorController

@synthesize keepUsageLog;
@synthesize keepAccelerationLog;
@synthesize accelerationLog;
@synthesize keepVelocityLog;
@synthesize velocityLog;
@synthesize usageLog;

static VirtualMotorController * sharedVirtualMotor = nil;

+(VirtualMotorController*) sharedInstance {
    @synchronized([VirtualMotorController class]) {
        if (sharedVirtualMotor == nil) {
            sharedVirtualMotor = [[VirtualMotorController alloc] init];
        }
    }
    
    return sharedVirtualMotor;
}

+(id)alloc
{
    @synchronized([VirtualMotorController class]) {
        sharedVirtualMotor = [super alloc];
    }
    
    return sharedVirtualMotor;
}

- (id)init {
    self = [super init];
    if (self) {
        keepAccelerationLog = NO;
        accelerationLog = [[NSMutableArray alloc] initWithCapacity: 500];
        keepVelocityLog = NO;
        velocityLog = [[NSMutableArray alloc] initWithCapacity: 500];
        keepUsageLog = NO;
        usageLog = [[NSMutableArray alloc] initWithCapacity: 500];
    }
    return self;
}

-(void) dealloc {
    [accelerationLog removeAllObjects];
    [accelerationLog release]; accelerationLog = nil;
    [velocityLog removeAllObjects];
    [velocityLog release]; velocityLog = nil;
    [usageLog removeAllObjects];
    [usageLog release]; usageLog = nil;
    
    sharedVirtualMotor = nil;
    [super dealloc];
}


-(void)setAcceleration: (const float) inputAcceleration {
    acceleration = inputAcceleration;
    
    if (keepAccelerationLog) {
        // Keep a record of our acceleration inputs.
        [accelerationLog addObject: [NSNumber numberWithFloat: inputAcceleration]];
    }
    
    if (keepUsageLog) {
        // Keep a record of our acceleration inputs.
        NSString * log = [NSString stringWithFormat: @"SetAcceleration: %f", inputAcceleration];
        [usageLog addObject: log];
    }
}

-(void)setVelocity: (const float) inputVelocity {
    velocity = inputVelocity;
    
    if (keepVelocityLog) {        // Keep a record of our velocity inputs.
        [velocityLog addObject: [NSNumber numberWithFloat: inputVelocity]];
    }
    
    if (keepUsageLog) {         // Keep a record of our acceleration inputs.
        NSString * log = [NSString stringWithFormat: @"SetVelocity: %f", inputVelocity];
        [usageLog addObject: log];
    }
}

-(const float)acceleration {
    if (keepUsageLog) { // Keep a record of our acceleration inputs.
        [usageLog addObject: [NSString stringWithFormat:@"Acceleration: %f", acceleration]];
    }
    
    return acceleration;
}

-(const float)velocity {
    if (keepUsageLog) { // Keep a record of our velocity inputs.
        [usageLog addObject: [NSString stringWithFormat:@"Velocity: %f", velocity]];
    }
    
    return velocity;
}

-(BOOL)deviceIsOperational
{
    return NO;
}

-(NSDictionary*) pollDeviceForData {
    if (keepUsageLog) {
        [usageLog addObject: @"PollDeviceForData"];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat: acceleration], @"Acceleration",
            [NSNumber numberWithFloat: velocity], @"Velocity",
            nil];
}

@end
