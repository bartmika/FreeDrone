//
//  DroneCommandView.h
//  Drone-Command
//
//  Created by Bartlomiej Mika on 2013-07-07.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>
#include <stdlib.h>

// Custom
#import "Common.h"
#import "DroneCommandModel.h"

// XCode Setup Required
//  1) In your Terminal, type "echo $TERM" and copy the output
//  2) Then paste the value into:
//      Edit Schema -> Environmental Variables -> +
//      Name= TERM
//      Value= xterm-256color

@interface DroneCommandView : NSObject {
    DroneCommandModel * model;
}

+(DroneCommandView*) sharedInstance;

-(void) dealloc;

-(void) clearConsoleScreen;

-(void) printAppTitle;

-(char) printInitializationMenu;

-(enum command_t) printMainMenu;

-(enum command_t) printMotorMenu;

-(enum command_t) printServoMenu;

-(enum command_t) printAutoPilotMenu;

-(enum command_t) printStatusMenu;

-(char) getCharFromConsoleWithString: (char *) text;

-(float) getFloatFromConsoleWithString: (char*) text;

@end
