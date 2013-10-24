//
//  main.m
//  Drone-Command
//
//  Created by Bartlomiej Mika on 2013-06-21.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "DroneCommandModel.h"
#import "DroneCommandView.h"
#import "DroneCommandController.h"

#ifndef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
    #define kHostname @"raspberrypi"
#else
    #define kHostname @"Bartlomiejs-Mac-mini.local"
#endif
#define kPortNumber 12345

static DroneCommandView * view = nil;
static DroneCommandController * controller = nil;
static DroneCommandModel * model = nil;

int main(int argc, const char * argv[])
{
    NSAutoreleasePool * applicationMemoryPool = [NSAutoreleasePool new];
    model = [DroneCommandModel sharedInstance];
    view = [DroneCommandView sharedInstance];
    controller = [DroneCommandController sharedInstance];
    
    // Delegate application control to the controller object to handle all
    // model-view-controller coordination.
    [controller runMainServiceLoop];
    
    [applicationMemoryPool drain]; applicationMemoryPool = nil;
    return 0;
}

