//
//  main.m
//  Drone-Application
//
//  Created by Bartlomiej Mika on 2013-06-18.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "DroneController.h"

// Default values
#define kMainIntervalDelay 0.05f

int main(int argc, const char * argv[])
{
    // The main garbage collection object for
    NSAutoreleasePool * applicationPool = [NSAutoreleasePool new];
    DroneController * app = [[DroneController new] autorelease];
    
    // Run the main application.
    while ([app is
            Running]) {
        [app tickWithDelay: kMainIntervalDelay];
    }
    
    // Memory Management.
    [applicationPool drain]; applicationPool = nil;
    return EXIT_SUCCESS;
}

// Note:
// (1) How to debug code for GNUstep
//  http://www.gnustep.org/resources/documentation/Developer/Base/General/Debugging.html
