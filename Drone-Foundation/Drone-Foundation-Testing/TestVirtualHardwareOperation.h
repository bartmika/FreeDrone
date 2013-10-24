//
//  TestVirtualHardwareOperation.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-12.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Customn
#import "VirtualHardwareOperation.h"
#import "VirtualGPSReader.h"
#import "VirtualSpatialReader.h"
#import "VirtualMotorController.h"
#import "VirtualServoController.h"

@interface TestVirtualHardwareOperation : NSObject

+(void) performUnitTests;

@end
