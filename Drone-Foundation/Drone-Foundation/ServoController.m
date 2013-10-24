//
//  ServoController.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "ServoController.h"
@implementation ServoController

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

static ServoController * sharedServo = nil;

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

+(ServoController*) sharedInstance {
    @synchronized([ServoController class]) {
        if (!sharedServo) {
            sharedServo = [[ServoController alloc] init];
            return sharedServo;
        }
    }
    
    return sharedServo;
}

+(id)alloc
{
    @synchronized([ServoController class]){
        sharedServo = [super alloc];
    }
    
    return sharedServo;
}

-(id) init
{
    self = [super init];
    if (self != nil) {
        servo = (id)phidgetSingleServoInit();
        return self;
    }
    
    return nil;
}

-(void)dealloc
{
    phidgetSingleServoDealloc((phidgetSingleServoController_t*)servo);
    servo = nil;
    [super dealloc];
}

-(void)engage
{
    if (servo) { // Defensive Code: Only set position on working hardware.
        phidgetSingleServoEngage((phidgetSingleServoController_t*)servo);
    }
}

-(void)disengage
{
    if (servo) { // Defensive Code: Only set position on working hardware.
        phidgetSingleServoDisengage((phidgetSingleServoController_t*)servo);
    }
}

-(BOOL) isEngaged {
    return servo ? phidgetSingleServoIsEngaged((phidgetSingleServoController_t*)servo) : NO;
}

-(void)setPosition: (const float) thePosition
{
    @synchronized([ServoController class]) {
        if (servo) { // Defensive Code: Only set position on working hardware.
            phidgetSingleServoSetPosition((phidgetSingleServoController_t*)servo, thePosition);
        }
    }
}

-(const float) position
{
    float thePosition;
    
    @synchronized([ServoController class]) {
        // If the hardware is working then return the polled data, else
        // return zero.
        thePosition = servo ? phidgetSingleServoGetPosition((phidgetSingleServoController_t*)servo) : 0.0f;
    }
    return (const float)thePosition;
}

-(BOOL) deviceIsOperational {
    return servo ? phidgetSingleServoDeviceIsOperational((phidgetSingleServoController_t*)servo) : NO;
}

-(NSDictionary*) pollDeviceForData
{
    NSDictionary * data;
    
    // If the hardware is working then return the polled data, else
    // return zero.
    if (servo == NULL) {
        return NULL;
    }
    
    @synchronized([ServoController class]) {
        float cServoPosition = phidgetSingleServoGetPosition((phidgetSingleServoController_t*)servo);
        float cServoAcc = phidgetSingleServoGetAcceleration((phidgetSingleServoController_t*)servo);
        
        NSNumber * servoPos = [NSNumber numberWithFloat: cServoPosition];
        NSNumber * servoAcc = [NSNumber numberWithFloat: cServoAcc];
        NSNumber * servoEng = [NSNumber numberWithBool: [self isEngaged]];
        
        data = [NSDictionary dictionaryWithObjectsAndKeys: servoPos, @"Position", servoAcc, @"Acceleration", servoEng, @"IsEngaged", nil];
    }
    
    return data;
}

@end
