//
//  VirtualMotorController.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Customer
#import "MotorControlling.h"
#import "NSMutableArray+Queue.h"
#import "NSArray+CSV.h"

@interface VirtualMotorController : NSObject <MotorControlling> {
    float acceleration;
    float velocity;
    
    BOOL keepAccelerationLog;
    NSMutableArray * accelerationLog;
    
    BOOL keepVelocityLog;
    NSMutableArray * velocityLog;
    
    BOOL keepUsageLog;
    NSMutableArray * usageLog;
}

@property (atomic) BOOL keepUsageLog;
@property (atomic, assign) NSMutableArray * usageLog;
@property (atomic) BOOL keepAccelerationLog;
@property (atomic, assign) NSMutableArray * accelerationLog;
@property (atomic) BOOL keepVelocityLog;
@property (atomic, assign) NSMutableArray * velocityLog;


+(VirtualMotorController*) sharedInstance;

-(void) dealloc;

-(void)setAcceleration: (const float) acceleration;

-(void)setVelocity: (const float) velocity;

-(const float)acceleration;

-(const float)velocity;

-(NSDictionary*) pollDeviceForData;

@end
