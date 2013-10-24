//
//  MotorControlling.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "HardwareLogging.h"

@protocol MotorControlling <HardwareLogging>

@required
-(void)setAcceleration: (const float) acceleration;

-(void)setVelocity: (const float) velocity;

-(const float)acceleration;

-(const float)velocity;

@end
