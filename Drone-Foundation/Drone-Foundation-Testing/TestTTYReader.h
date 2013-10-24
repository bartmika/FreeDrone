//
//  TestTTYReader.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "TTYReader.h"

// Define
#ifdef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
    #define kGlobalSatBU353GPSReceiverDevice "/dev/cu.usbserial" // Mac
#else
    #define kGlobalSatBU353GPSReceiverDevice "/dev/ttyUSB0"      // Raspberry Pi
#endif
#define kGlobalSatBU353GPSReceiverBaud 4800

@interface TestTTYReader : NSObject

+(void) performUnitTests;

@end
