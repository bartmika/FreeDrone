//
//  TestUnreliableSocket.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "UnreliableSocket.h"

#ifndef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
    #define kIPAddress @"192.168.0.35"
#else
    #define kIPAddress @"192.168.0.32"
#endif
#define kPortNumber 12345

@interface TestUnreliableSocket : NSObject

+(void) performUnitTests;

@end
