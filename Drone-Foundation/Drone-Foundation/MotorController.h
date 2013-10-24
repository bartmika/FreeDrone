//
//  MotorController.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "PhidgetSingleDCMotorController.h"
#import "MotorControlling.h"
#import "HardwareLogging.h"

@interface MotorController : NSObject <MotorControlling, HardwareLogging> {
    id motor;
}

+(MotorController*)sharedInstance;
-(void)dealloc;
-(void)setAcceleration: (const float) acceleration;
-(void)setVelocity: (const float) velocity;
-(const float)acceleration;
-(const float)velocity;
-(BOOL) deviceIsOperational;
-(NSDictionary*) pollDeviceForData;

@end
