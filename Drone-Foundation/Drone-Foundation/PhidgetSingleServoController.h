//
//  PhidgetSingleServoController.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-18.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_PhidgetSingleServoController_h
#define Drone_Foundation_PhidgetSingleServoController_h


// Standard Libraries
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

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

/**
 * phidgetSingleServo_t
 * --------------------
 * The following object is responsible for holding our hardware abstract
 * layer instance of the phidget single servo controller & servo.
 */
typedef struct _PHIDGETSINGLESERVOCONTROLLER_t{
    int result;
	float currentPosition;
	const char *err;
	float minAccel, maxVel;
    int engaged;
    
    // Min/Max Values
    float maxPosition, minPosition;
    float maxVelocity, minVelocity;
    float maxAcceleration, minAcceleration;
    
	//Declare an advanced servo handle
	CPhidgetAdvancedServoHandle servoHandler;
    
    int serialNo, version, numMotors;
	const char * ptrName;
    
    unsigned int isOperational;
}phidgetSingleServoController_t;

/**
 *  @Precondition:
 *      (1) Enough memory available in our computer.
 *      (2) "deviceType" must contain a single value from the following list:
 *          (a) PHIDGET_SERVO_HITEC_HS645MG
 *  @Postcondition:
 *      (1) Instantiated singleton object.
 */
phidgetSingleServoController_t * phidgetSingleServoInit();

/**
 *  @Precondition:
 *      (1) Singleton object was instantiated.
 *  @Postcondition:
 *      (1) Deallocates the singleton object
 */
void phidgetSingleServoDealloc(phidgetSingleServoController_t * ptrServo);

/**
 *  @Precondition:
 *      (1) Singleton object was instantiated.
 *  @Postcondition:
 *      (1) Returns the position the servo is currently on.
 */
float phidgetSingleServoGetPosition(phidgetSingleServoController_t * ptrServo);

/**
 *  @Precondition:
 *      (1) Singleton object was instantiated.
 *  @Postcondition:
 *      (1) Engages the servo - a.k.a makes servo wait for commands.
 */
int phidgetSingleServoEngage(phidgetSingleServoController_t * ptrServo);

/**
 *  @Precondition:
 *      (1) Singleton object was instantiated.
 *  @Postcondition:
 *      (1) Disengages the servo - a.k.a. makes servo no longer wait for
 *          commands.
 */
int phidgetSingleServoDisengage(phidgetSingleServoController_t * ptrServo);

/**
 *  @Precondition:
 *      (1) Singleton object was instantiated.
 *      (2) "newPosition" must be from 0 - 360
 *  @Postcondition:
 *      (1) Makes servo rotate to the new position.
 */
int phidgetSingleServoSetPosition(phidgetSingleServoController_t * ptrServo,
                                  const float newPosition);

int phidgetSingleServoSetAcceleration(phidgetSingleServoController_t * ptrServo,
                                  const float newAcceleration);

float phidgetSingleServoGetAcceleration(const phidgetSingleServoController_t * ptrServo);

int phidgetSingleServoDeviceIsOperational(const phidgetSingleServoController_t * ptrServo);

int phidgetSingleServoIsEngaged(const phidgetSingleServoController_t * ptrServo);

#endif
