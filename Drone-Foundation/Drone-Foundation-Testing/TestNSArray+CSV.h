//
//  TestNSArray+CSV.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import <Foundation/Foundation.h>

// Portablility:
//      If we are running a Apple Mac computer, then this will be our
//      configuration for the unit tests which is tailerd for a Mac environment
//      . Else, we will load up the configuration designed for a UNIX computer
//      (raspberry pi computer).
#ifdef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__

    #define kAustralianPostcodesFileURL @"/Users/bartlomiejmika/Eurasiasoft/Development/Drone/Drone-Foundation/Drone-Foundation-Testing/AustralianPostcodes.csv"

    #define kAustralianPostcodesFileSaveURL @"/tmp/AustralianPostcodes.csv"

    #define kAppendFileSaveURL @"/tmp/append_test.csv"

#else

    #define kAustralianPostcodesFileURL @"/home/pi/Drone-Foundation/test/AustralianPostcodes.csv"

    #define kAustralianPostcodesFileSaveURL @"/home/pi/Drone-Foundation/test/AustralianPostcodes_SAVED.csv"

    #define kAppendFileSaveURL @"/home/pi/Drone-Foundation/test/append_test.csv"

#endif

@interface TestNSArray_CSV : NSObject

+(void) performUnitTests;

@end
