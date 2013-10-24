//
//  TestDroneRemoteOperation.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-17.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "RemoteControlOperation.h"
#import "VirtualMotorController.h"
#import "VirtualServoController.h"

#ifndef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__

    #define kRemoteControlHostname @"raspberrypi"

#else

    #define kRemoteControlHostname @"Bartlomiejs-Mac-mini.local"

#endif

#define kRemoteControlPortNumber 12345

@interface TestRemoteControlOperation : NSObject

+(void) performUnitTests;

@end
