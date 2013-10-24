//
//  TestVirtualSpatialReader.h
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

    #define kVirtualSpatialReaderFileURL @"/Users/bartlomiejmika/Eurasiasoft/Development/Drone/Drone-Foundation/Drone-Foundation-Testing/DroneLoggerSample.csv"
#else

    #define kVirtualSpatialReaderFileURL @"/home/pi/Drone-Foundation/test/DroneLoggerSample.csv"

#endif

// Custom
#import "VirtualSpatialReader.h"

@interface TestVirtualSpatialReader : NSObject

+(void) performUnitTests;

@end
