//
//  TestReliableSocket.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ReliableSocket.h"

#ifndef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__

#define kHostname @"raspberrypi"

#else

#define kHostname @"Bartlomiejs-Mac-mini.local"

#endif

#define kPortNumber 12345

@interface TestReliableSocket : NSObject

+(void) performUnitTests;

@end
