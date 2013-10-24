//
//  ServoController.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "PhidgetSingleServoController.h"
#import "ServoControlling.h"
#import "HardwareLogging.h"

@interface ServoController : NSObject <ServoControlling, HardwareLogging> {
    id servo;
}

+(ServoController*) sharedInstance;

-(void)dealloc;

-(void)setPosition: (const float) position;

-(const float) position;

-(void) engage;

-(void) disengage;

-(BOOL) isEngaged;

-(BOOL)deviceIsOperational;

-(NSDictionary*) pollDeviceForData;

@end
