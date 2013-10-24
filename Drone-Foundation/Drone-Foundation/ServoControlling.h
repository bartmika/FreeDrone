//
//  ServoControlling.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//
// Standard
#import <Foundation/Foundation.h>

// Custom
#import "HardwareLogging.h"

@protocol ServoControlling <HardwareLogging>

@required
-(const float) position;

-(void)setPosition: (const float) position;

-(void) engage;

-(void) disengage;

-(BOOL) isEngaged;

@end
