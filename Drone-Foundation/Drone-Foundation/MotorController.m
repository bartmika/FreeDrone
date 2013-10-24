//
//  MotorController.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "MotorController.h"

@implementation MotorController

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

static MotorController *sharedMotor = nil;

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

+(MotorController*)sharedInstance {
    @synchronized([MotorController class]){
        if (!sharedMotor) {
            sharedMotor = [[MotorController alloc] init];
        }
    }
    
    return sharedMotor;
}

+(id)alloc
{
    @synchronized([MotorController class]) {
        sharedMotor = [super alloc];
    }
    
    return sharedMotor;
}

-(id) init
{
    self = [super init];
    if ( self != nil) {
        motor = (id)phidgetSingleDCMotorInit();
    }
    
    return self;
}

-(void)dealloc {
    // If the connected device is a "Phidget", then handle it.
    phidgetSingleDCMotorDealloc((phidgetSingleDCMotorController_t*)motor);
    motor = nil;
    
    [super dealloc];
}



-(void)setAcceleration: (const float) acceleration {
    @synchronized([MotorController class]){
        if (motor) { // Defensive Code: Only set acceleration on working hardware.
            phidgetSingleDCMotorSetAcceleration((phidgetSingleDCMotorController_t*)motor, acceleration);
        }
    }
}

-(void)setVelocity: (const float) velocity {
    @synchronized([MotorController class]){
        if (motor) { // Defensive Code: Only set velocity on working hardware.
            phidgetSingleDCMotorSetVelocity((phidgetSingleDCMotorController_t*)motor, velocity);
        }
    }
}

-(const float)acceleration {
    float acceleration;
    
    @synchronized([MotorController class]){
        // If hardware is working, get data from hardware, else return zero.
        acceleration = motor ? phidgetSingleDCMotorGetAcceleration((phidgetSingleDCMotorController_t*)motor) : 0.0f;
    }
    
    return acceleration;
}

-(const float)velocity {
    float velocity;
    
    @synchronized([MotorController class]){
        // If hardware is working, get data from hardware, else return zero.
        velocity = motor ? phidgetSingleDCMotorGetVelocity((phidgetSingleDCMotorController_t*)motor) : 0.0f;
    }
    
    return velocity;
}

-(BOOL) deviceIsOperational {
    return motor ? phidgetSingleDCMotorDeviceIsOperational((phidgetSingleDCMotorController_t*)motor) : NO;
}

-(NSDictionary*) pollDeviceForData
{
    NSDictionary *data = nil;
    
    // If hardware is working, get data from hardware, else return zero.
    if (motor == nil) {
        return NULL;
    }
    
    @synchronized([MotorController class]){
        NSNumber * nsMotorAcc = [NSNumber numberWithFloat: phidgetSingleDCMotorGetAcceleration((phidgetSingleDCMotorController_t*)motor)];
        NSNumber * nsMotorVel = [NSNumber numberWithFloat: phidgetSingleDCMotorGetVelocity((phidgetSingleDCMotorController_t*)motor)];
        
        data = [NSDictionary dictionaryWithObjectsAndKeys:
                nsMotorAcc, @"Acceleration",
                nsMotorVel, @"Velocity",
                nil];
    }
    
    return data;
}

@end
