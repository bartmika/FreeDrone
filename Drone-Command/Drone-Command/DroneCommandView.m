//
//  DroneCommandView.m
//  Drone-Command
//
//  Created by Bartlomiej Mika on 2013-07-07.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "DroneCommandView.h"

@implementation DroneCommandView

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

static DroneCommandView * sharedDroneCommandView = nil;

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

// Source:
//  http://stackoverflow.com/questions/10082625/how-do-i-clear-the-console-in-objective-c
-(void) clearConsoleScreen
{
//    NSTask *task;
//    task = [[NSTask alloc]init];
//    [task setLaunchPath: @"/bin/bash"];
//    
//    NSArray *arguments;
//    arguments = [NSArray arrayWithObjects: @"clear", nil];
//    [task setArguments: arguments];
//    
//    [task launch];
//    [task waitUntilExit];
    system("clear");
}

+(DroneCommandView*) sharedInstance {
    @synchronized([DroneCommandView class]) {
        if (!sharedDroneCommandView) {
            sharedDroneCommandView = [[DroneCommandView alloc] init];
        }
    }
    
    return sharedDroneCommandView;
}

+(id) alloc {
    @synchronized([DroneCommandView class]) {
        sharedDroneCommandView = [super alloc];
    }
    
    return sharedDroneCommandView;
}

-(id)init{
    if (self = [super init]) {
        model = [DroneCommandModel sharedInstance];
    }
    
    return self;
}


-(void) dealloc {
    [super dealloc];
}

-(void) printAppTitle {
    printf("##################################\n");
    printf("#\t Drone Command Console\t#\n");
    printf("##################################\n");
}

-(char) printInitializationMenu {
    [self printAppTitle];
    printf("Please select your option:\n");
    printf("Hosts: \n");
    printf("\t1 - %s\n", [kCurrentComputerHostname UTF8String]);
    printf("\t2 - %s\n", [kRemoteComputerHostname UTF8String]);
    printf("Command: ");
    //TODO: Add defensive code
    char command = [self getCharFromConsoleWithString: "Command: "];
    [self clearConsoleScreen];
    return command;
}

-(enum command_t) printMainMenu {
    [self printAppTitle];
    printf("Please select your option:\n");
    printf("\tMain Menu:\n");
    printf("\t\t\'m\' - Motor\n");
    printf("\t\t\'s\' - Servo\n");
    printf("\t\t\'a\' - AutoPilot\n");
    printf("\t\t\'i\' - Status\n");
    printf("\t\t\'e\' - Exit Command\n");
    //TODO: Add defensive coding
    enum menu_command_t command = (char)[self getCharFromConsoleWithString: "Command: "];
    [self clearConsoleScreen];
    
    switch (command) {
        case MOTOR_MENU: // Motor
            return  [self printMotorMenu];
            break;
        case SERVO_MENU: // Servo
            return [self printServoMenu];
            break;
        case AUTOPITLOT_MENU: // AutoPilot
            return [self printAutoPilotMenu];
            break;
        case STATUS_MENU: // Status Information
            return [self printStatusMenu];
            break;
        case EXIT_MENU: // Logout/Exit
            return EXIT_APPLICATION;
            break;
        default:
            printf("Please select from option(s)\n");
            return NULL_COMMAND;
            break;
    }
    return NULL_COMMAND;
}

-(enum command_t) printMotorMenu {
    [self printAppTitle];
    printf("Please select your option:\n");
    printf("\tMotor Menu:\n");
    printf("\t\tv - SetVelocity\n");
    printf("\t\ta - SetAcceleration\n");
    //TODO: Add defensive code
    char command = [self getCharFromConsoleWithString: "Command: "];
    [self clearConsoleScreen];
    if (command == 'v') {
        return SET_VELOCITY;
    } else if (command == 'a') {
        return SET_ACCELERATION;
    } else {
        return NULL_COMMAND;
    }
}


-(enum command_t) printServoMenu {
    [self printAppTitle];
    printf("Please select your option:\n");
    printf("\tServo Menu:\n");
    printf("\t\ts - Engage\n");
    printf("\t\tp - SetPosition\n");
    printf("\t\td - Disengage\n");
    //TODO: Add defensive code
    char command = [self getCharFromConsoleWithString: "Command: "];
    [self clearConsoleScreen];
    if (command == 's') {
        return ENGAGE;
    } else if (command == 'p') {
        return SET_POSITION;
    } else if (command == 'd') {
        return DISENGAGE;
    } else {
        return NULL_COMMAND;
    }
}

-(enum command_t) printAutoPilotMenu {
    //TODO: Finish Autopilot menu
    return NULL_COMMAND;
}

-(enum command_t) printStatusMenu {
    [self printAppTitle];
    NSDictionary * deviceInformation = [[model remoteDeviceInformation] retain];
    if (deviceInformation == nil) {
        return NULL_COMMAND;
    }
    
    NSDictionary * batteryInformation = [deviceInformation objectForKey: @"Battery"];
    NSDictionary * motorInformation = [deviceInformation objectForKey: @"Motor"];
    NSDictionary * servoInformation = [deviceInformation objectForKey: @"Servo"];
    NSDictionary * spatialInformation = [deviceInformation objectForKey: @"Spatial"];
    NSDictionary * gpsInformation = [deviceInformation objectForKey: @"GPS"];
    
    NSNumber * percentEnergyRemaining = [batteryInformation objectForKey: @"PercentRemaining"];
    NSNumber * remainingBatteryRuntimeInHours = [batteryInformation objectForKey: @"RemainingHours"];
    
    NSNumber * acceleration = [motorInformation objectForKey: @"Acceleration"];
    NSNumber * velocity = [motorInformation objectForKey: @"Velocity"];
    
    NSNumber * position = [servoInformation objectForKey: @"Position"];
    NSNumber * servoAcceleration = [servoInformation objectForKey: @"Acceleration"];
    NSNumber * engaged = [servoInformation objectForKey: @"IsEngaged"];
    
    NSNumber * compassHeading = [spatialInformation objectForKey: @"Compass"];
    
    NSNumber * latitude = [gpsInformation objectForKey: @"Latitude"];
    NSNumber * longitude = [gpsInformation objectForKey: @"Longitude"];
    NSNumber * altitude = [gpsInformation objectForKey: @"Altitude"];
    NSNumber * heading = [gpsInformation objectForKey: @"Heading"];
    NSNumber * speed = [gpsInformation objectForKey: @"Speed"];
    
    //TODO: Impl.
    printf("\tInformation\n");
    printf("\t\tBattery\n");
    printf("\t\t\tPercent Energy Remaining: %f\n", [percentEnergyRemaining floatValue]);
    printf("\t\t\tRemaining Runtime: %f\n", [remainingBatteryRuntimeInHours floatValue]);
    printf("\t\tMotor\n");
    printf("\t\t\tAcceleration: %f\n", [acceleration floatValue]);
    printf("\t\t\tVelocity: %f\n", [velocity floatValue]);
    printf("\t\tServo\n");
    printf("\t\t\tPosition: %f\n", [position floatValue]);
    printf("\t\t\tAcceleration: %f\n", [servoAcceleration floatValue]);
    printf("\t\t\tIsEngaged: %i\n", [engaged boolValue]);
    printf("\t\tSpatial\n");
    printf("\t\t\tCompass Heading: %f\n", [compassHeading floatValue]);
    printf("\t\tGPS\n");
    printf("\t\t\tLatitude: %f\n", [latitude floatValue]);
    printf("\t\t\tLongitude: %f\n", [longitude floatValue]);
    printf("\t\t\tAltitude: %f\n", [altitude floatValue]);
    printf("\t\t\tHeading: %f\n", [heading floatValue]);
    printf("\t\t\tSpeed: %f\n", [speed floatValue]);
    printf("\n");
    
    [deviceInformation release];
    return NULL_COMMAND;
}

-(char) getCharFromConsoleWithString: (char *) text {
    printf("%s", text);
    
    char str[50] = {};                  // init all to 0
    scanf("%s", str);                    // read and format into the str buffer
    return str[0];
}


-(float) getFloatFromConsoleWithString: (char*) text {
    printf("%s", text);
    
    char str[50] = {};                  // init all to 0
    scanf("%s", str);                   // read and format into the str buffer
    return atof(str);                   // Convert to float
}

@end
