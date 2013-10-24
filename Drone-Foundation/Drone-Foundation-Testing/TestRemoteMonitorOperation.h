//
//  TestRemoteMonitorOperation.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-29.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "RemoteMonitorOperation.h"
#import "VirtualMotorController.h"
#import "VirtualServoController.h"
#import "VirtualSpatialReader.h"
#import "VirtualGPSReader.h"
#import "VirtualBatteryMonitor.h"

#ifndef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
#define kRemoteMonitorHostname @"raspberrypi"
#else
#define kRemoteMonitorHostname @"Bartlomiejs-Mac-mini.local"
#endif
#define kRemoteMonitorPortNumber 123456

@interface TestRemoteMonitorOperation : NSObject

+(void) performUnitTests;

@end
