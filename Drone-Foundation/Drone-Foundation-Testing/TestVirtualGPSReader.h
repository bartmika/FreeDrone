//
//  TestVirtualGPSReader.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-09.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Portablility:
//      If we are running a Apple Mac computer, then this will be our
//      configuration for the unit tests which is tailerd for a Mac environment
//      . Else, we will load up the configuration designed for a UNIX computer
//      (raspberry pi computer).
#ifdef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__

#define kVirtualGPSCSVFileURL @"/Users/bartlomiejmika/Eurasiasoft/Development/Drone/Drone-Foundation/Drone-Foundation-Testing/DroneLoggerGPSReaderSample.csv"

#else

    #define kVirtualGPSCSVFileURL @"/home/pi/Drone-Foundation/test/DroneLoggerGPSReaderSample.csv"

#endif

// Custom
#import "VirtualGPSReader.h"

@interface TestVirtualGPSReader : NSObject

+(void) performUnitTests;

@end
