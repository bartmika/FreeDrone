//
//  VirtualServoController.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "ServoControlling.h"
#import "NSMutableArray+Queue.h"
#import "NSArray+CSV.h"

@interface VirtualServoController : NSObject <ServoControlling> {
    float position;
    BOOL engaged;
    
    NSMutableArray * positionLog;
    BOOL keepPositionLog;
    
    NSMutableArray * usageLog;
    BOOL keepUsageLog;
}

@property (atomic) BOOL keepUsageLog;
@property (atomic, assign) NSMutableArray * usageLog;
@property (atomic) BOOL keepPositionLog;
@property (atomic, assign) NSMutableArray * positionLog;
@property (atomic, readonly) BOOL engaged;

+(VirtualServoController*) sharedInstance;

-(void) dealloc;

-(const float) position;

-(void)setPosition: (const float) position;

-(void) engage;

-(void) disengage;

-(NSDictionary*) pollDeviceForData;

@end
