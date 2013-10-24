//
//  DroneCommandController.h
//  Drone-Command
//
//  Created by Bartlomiej Mika on 2013-07-07.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "Common.h"
#import "DroneCommandView.h"
#import "DroneCommandModel.h"

@interface DroneCommandController : NSObject {
    // Controller based variables
    BOOL serviceLoopIsRunning;
    NSTimeInterval serviceLoopDelayInterval;
    NSString * remoteHostName;
    int remoteControlPort;
    int remoteMonitorPort;
    
    // View based variables
    DroneCommandView * view;
    
    // Model Based Variables.
    DroneCommandModel * model;
}

+(DroneCommandController*) sharedInstance;

-(void) dealloc;

-(void) runMainServiceLoop;

@end
