//
//  TestAutoPilotOperation.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-12.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard.
#import <Foundation/Foundation.h>

// Code to test out
#import "AutoPilotOperation.h"

// Support code to help out in simulating.
#import "VirtualGPSReader.h"
#import "VirtualSpatialReader.h"
#import "VirtualMotorController.h"
#import "VirtualServoController.h"
#import "VirtualHardwareOperation.h"

@interface TestAutoPilotOperation : NSObject

+(void) performUnitTests;

@end
