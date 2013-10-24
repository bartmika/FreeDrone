//
//  Common.h
//  Drone-Command
//
//  Created by Bartlomiej Mika on 2013-07-07.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Command_Common_h
#define Drone_Command_Common_h

// Macros
#ifndef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
    #define kCurrentComputerHostname @"raspberrypi"
    #define kRemoteComputerHostname @"Bartlomiejs-Mac-mini.local"
#else
    #define kCurrentComputerHostname @"Bartlomiejs-Mac-mini.local"
    #define kRemoteComputerHostname @"raspberrypi"
#endif

#define kRemoteControlPort 12345
#define kRemoteMonitorPort 123456

enum menu_command_t {
    MOTOR_MENU = 'm',
    SERVO_MENU = 's',
    AUTOPITLOT_MENU = 'a',
    STATUS_MENU = 'i',
    EXIT_MENU = 'e',
    NULL_MENU = '\0'
};

enum command_t {
    SET_VELOCITY,
    SET_ACCELERATION,
    ENGAGE,
    DISENGAGE,
    SET_POSITION,
    VIEW_STATUS,
    EXIT_APPLICATION,
    NULL_COMMAND
    };

#endif
