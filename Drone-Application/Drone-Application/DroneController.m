//
//  DroneApplication.m
//  Drone-Application
//
//  Created by Bartlomiej Mika on 2013-06-18.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "DroneController.h"

@implementation DroneController

@synthesize isRunning;

void printAppInfo() {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString *processName = [processInfo processName];
    int processID = [processInfo processIdentifier];
    NSLog(@"Process Name: '%@' Process ID:'%d'", processName, processID);
}

-(id) init {
    if (self = [super init]) {
        // Print the following information.
//        printAppInfo();
        
        NSLog(@"Initialize Hardware\n");
        // Initialize the hardware
        batteryMonitor = [BatteryMonitor sharedInstance];
        [batteryMonitor setBatteryWithAmps: 1200 powerRating: 120];
        [batteryMonitor startMonitoring];
        gpsReader = [GPSReader sharedInstance];
        spatialReader = [SpatialReader sharedInstance];
        servoController = [ServoController sharedInstance];
        motorController = [MotorController sharedInstance];
        
        NSLog(@"Initialize Services\n");
        // Initialize our services
        taskQueue = [NSOperationQueue new];
        droneLoggerOperation = [DroneLoggerOperation new];
        autoPilotOperation = [AutoPilotOperation new];
        remoteControlOperation = [RemoteControlOperation new];
        remoteMonitorOperation = [RemoteMonitorOperation new];
        
        // Setup our services...
        
        // Algorithm
        //  We will load up the services depending on what the user has inputted
        //  from the console. Go through all the options and match the user input
        //  with what is acceptable.
        NSProcessInfo *pi = [NSProcessInfo processInfo];
        NSArray * arguments = [pi arguments];
        
        // Defensive Code: If user did not specify an argument.
        if ([arguments count] <= 1) {
            NSLog(@"ERROR: Please input at minimum one argument for app.\n");
            [self setIsRunning: NO];
            return self;
        }
        
        // Enable our systems.
        for (NSString *argument in arguments) {
            // Enable Logging
            if ([argument compare: @"-l" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
                NSLog(@"Logging: Enabled");
                [taskQueue addOperation: droneLoggerOperation];
                
            // Enable AutoPilot
            } else if ([argument compare: @"-a" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
                NSLog(@"AutoPilot: Enabled");
                [autoPilotOperation setGpsReader: gpsReader];
                [autoPilotOperation setMotionReader: spatialReader];
                [autoPilotOperation setMotorController: motorController];
                [autoPilotOperation setServoController: servoController];
                [taskQueue addOperation: autoPilotOperation];
                
            // Enable Remote Management
            } else if ([argument compare: @"-n" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
                NSLog(@"Remote Management: Enabled");
                [remoteControlOperation setMotorController: motorController];
                [remoteControlOperation setServoController: servoController];
                [remoteControlOperation setAutoPilot: autoPilotOperation];
                [remoteControlOperation startListeningOnPort: kPortNumberForRemoteControl];
                [taskQueue addOperation: remoteControlOperation];
                
                [remoteMonitorOperation setGpsReader: gpsReader];
                [remoteMonitorOperation setSpatialReader: spatialReader];
                [remoteMonitorOperation setServoController: servoController];
                [remoteMonitorOperation setMotorController: motorController];
                [remoteMonitorOperation setBatteryMonitor: batteryMonitor];
                [remoteMonitorOperation startListeningOnPort: kPortNumberForRemoteMonitor];
                [taskQueue addOperation: remoteMonitorOperation];
                
                // Configure refresh frequency
                [remoteControlOperation setServiceLoopDelayInterval: 1.0f];
                [remoteMonitorOperation setServiceLoopDelayInterval: 5.0f];
            }
        }
    }
    
    NSLog(@"Drone Started!");
    [self setIsRunning: YES];
    return self;
}

-(void) dealloc {
    [droneLoggerOperation release]; droneLoggerOperation = nil;
    [autoPilotOperation release]; autoPilotOperation = nil;
    [remoteControlOperation release]; remoteControlOperation = nil;
    [taskQueue release]; taskQueue = nil;
    [super dealloc];
}

-(void) tickWithDelay: (NSTimeInterval) delayInSeconds {
    NSLog(@"Tick\n");
    // While we have more then 5% of battery life left and our application state
    // is set to be continously running then do the following loop.
    while ([self isRunning]) {
        // If we're about to run out of battery then stop the application and
        // perform the following set of instructions...
        if ([batteryMonitor percentEnergyRemaining] <= 1.0f) {
            NSLog(@"Battery Remaining: %f\n", [batteryMonitor percentEnergyRemaining]);
            [self setIsRunning: NO];
        }
        
        [NSThread sleepForTimeInterval: delayInSeconds];
        // Take the current time and append it by 1 minutes from now.
        //NSDate * date = [[NSDate date] dateByAddingTimeInterval: 60]; // 1 min
        
        //[[NSRunLoop mainRunLoop] runUntilDate: [NSDate distantFuture]];
    }
}

@end
