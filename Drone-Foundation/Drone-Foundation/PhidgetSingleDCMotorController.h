//
//  PhidgetSingleDCMotorController.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-19.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_PhidgetSingleDCMotorController_h
#define Drone_Foundation_PhidgetSingleDCMotorController_h


// Standard Libraries
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

// Custom Library
// Portablility:
//      If we are not running a Apple Mac computer, then we will have to
//      get our Phidget library in a manner that is acceptiable for a UNIX-like
//      operating system.Else, we will load up for a mac computer.
#ifndef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
    #include <phidget21.h>
#else
    #ifndef PHIDGET_LIBRARY_INCLUDE
        #include <Phidget21/phidget21.h>
        #define PHIDGET_LIBRARY_INCLUDE
    #endif
#endif

typedef struct _PHIDGETSINGLEDCMOTOR_T{
    // Object which handles communicating with the phidget hardware.
    CPhidgetMotorControlHandle motoControlHandler;
    
    // Device Information
    int serialNo, version, numInputs, numMotors;
	const char* ptrName;
    
    // Device Run-Time operation information
    int errorCode;
    char * errorDescription;
    int state;
    float velocity;
    float current;
    
    // Min/Max
    float accelerationMax;
    float accelerationMin;
    
    unsigned int isOperational;
    
}phidgetSingleDCMotorController_t;

#define PHIDGET_DC_MOTOR_3274_0 1

phidgetSingleDCMotorController_t * phidgetSingleDCMotorInit();

void phidgetSingleDCMotorDealloc(phidgetSingleDCMotorController_t * ptrMotor);

int phidgetSingleDCMotorSetAcceleration(phidgetSingleDCMotorController_t * ptrMotor,
                                        const float acceleration);

int phidgetSingleDCMotorSetVelocity(phidgetSingleDCMotorController_t * ptrMotor,
                                    const float velocity);

float phidgetSingleDCMotorGetVelocity(phidgetSingleDCMotorController_t * ptrMotor);

float phidgetSingleDCMotorGetAcceleration(phidgetSingleDCMotorController_t * ptrMotor);

float phidgetSingleDCMotorGetCurrent(phidgetSingleDCMotorController_t * ptrMotor);

float phidgetSingleDCMotorGetSupplyVoltage(phidgetSingleDCMotorController_t * ptrMotor);

float phidgetSingleDCMotorDeviceIsOperational(phidgetSingleDCMotorController_t * ptrMotor);

#endif
