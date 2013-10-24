//
//  PhidgetSingleServoController.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-18.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#include "PhidgetSingleServoController.h"

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                     PRIVATE VARIABLES / FUNCTIONS                          //
//----------------------------------------------------------------------------//

// Private Functions
int CCONV phidgetServoAttachHandler(CPhidgetHandle ADVSERVO, void *userptr)
{
	// Defensive Code
    assert(userptr);
    
    phidgetSingleServoController_t * ptrServo = (phidgetSingleServoController_t*)userptr;
    
    // Indicate that we are operational.
    ptrServo->isOperational = 1;
    
	return 0;
}

int CCONV phidgetServoDetachHandler(CPhidgetHandle ADVSERVO, void *userptr)
{
    // Defensive Code
    assert(userptr);
    
    phidgetSingleServoController_t * ptrServo = (phidgetSingleServoController_t*)userptr;
    
    // Indicate that we are operational.
    ptrServo->isOperational = 0;
    
	return 0;
}

/**
 * Call-back functuin which gets called everytime a error occurs.
 */
int CCONV phidgetServoErrorHandler(CPhidgetHandle ADVSERVO,
                                   void *userptr,
                                   int ErrorCode,
                                   const char *Description)
{
    // Defensive Code
    assert(userptr);
    
    phidgetSingleServoController_t * ptrServo = (phidgetSingleServoController_t*)userptr;
    
    // Indicate that we are operational.
    ptrServo->isOperational = 0;
    
    
    
	printf("Error handled. %d - %s\n", ErrorCode, Description);
	return 0;
}

/**
 * Call-back function which gets called every time the servo moves.
 */
int CCONV phidgetServoPositionChangeHandler(CPhidgetAdvancedServoHandle ADVSERVO,
                                            void *usrptr,
                                            int Index,
                                            double Value)
{
    // Defensive Code
    assert(usrptr);
    
    phidgetSingleServoController_t * ptrServo = (phidgetSingleServoController_t*)usrptr;
    
    ptrServo->currentPosition = (float)Value; // Store the devices current position.
    
    
    //printf("Motor: %d > Current Position: %f\n", Index, Value);
    //ptrSingletonSingleServo->currentPosition = Value;
	return 0;
}


int phidgetSingleServoOpen(phidgetSingleServoController_t *ptrServo){
    assert(ptrServo);
    
    int result;
	const char *error;
	
	//Declare an advanced servo handle
	CPhidgetAdvancedServoHandle servo = 0;
    
	//create the advanced servo object
	CPhidgetAdvancedServo_create(&servo);
    
	//Set the handlers to be run when the device is plugged in or opened from software, unplugged or closed from software, or generates an error.
	CPhidget_set_OnAttach_Handler((CPhidgetHandle)servo,
                                  phidgetServoAttachHandler,
                                  ptrServo);
	CPhidget_set_OnDetach_Handler((CPhidgetHandle)servo,
                                  phidgetServoDetachHandler,
                                  ptrServo);
	CPhidget_set_OnError_Handler((CPhidgetHandle)servo,
                                 phidgetServoErrorHandler,
                                 ptrServo);
    
	//Registers a callback that will run when the motor position is changed.
	//Requires the handle for the Phidget, the function that will be called, and an arbitrary pointer that will be supplied to the callback function (may be NULL).
	CPhidgetAdvancedServo_set_OnPositionChange_Handler(servo,
                                                       phidgetServoPositionChangeHandler,
                                                       ptrServo);
    
	//open the device for connections
	CPhidget_open((CPhidgetHandle)servo, -1);
    
	//get the program to wait for an advanced servo device to be attached
	if((result = CPhidget_waitForAttachment((CPhidgetHandle)servo, 10000)))
	{
		CPhidget_getErrorDescription(result, &error);
		printf("SERVO: Problem waiting for attachment: %s\n", error);
		return 0;
	}
    
    // Store the variables we used for opening the servo into our object.
    ptrServo->servoHandler = servo;
    ptrServo->result = result;
    
    return 1;
}

void phidgetSingleServoSetup(phidgetSingleServoController_t * ptrServo){
    // To make code easly readable, dereference the servo handler into a
    // variable and use throughout this function.
    CPhidgetAdvancedServoHandle servo = ptrServo->servoHandler;
    
	double curr_pos;
    double minAccel, maxVel;
    int serialNo, version, numMotors;
	const char* ptrName;
    
    //Set up some initial acceleration and velocity values
    CPhidgetAdvancedServo_getAccelerationMin(servo, 0, &minAccel);
    CPhidgetAdvancedServo_setAcceleration(servo, 0, minAccel*2);
    CPhidgetAdvancedServo_getVelocityMax(servo, 0, &maxVel);
    CPhidgetAdvancedServo_setVelocityLimit(servo, 0, maxVel/2);
    
    // Get the current position that the servo is at.
    CPhidgetAdvancedServo_getPosition(servo, 0, &curr_pos);
    
    // Get misc. information
	CPhidget_getDeviceType((CPhidgetHandle)servo, &ptrName);
	CPhidget_getSerialNumber((CPhidgetHandle)servo, &serialNo);
	CPhidget_getDeviceVersion((CPhidgetHandle)servo, &version);
	CPhidgetAdvancedServo_getMotorCount (servo, &numMotors);
    
    // Store the local variables to our object.
    ptrServo->currentPosition = (float)curr_pos;
    ptrServo->ptrName = ptrName;
    ptrServo->serialNo = serialNo;
    ptrServo->version = version;
    ptrServo->numMotors = numMotors;
    
    double maxPosition, minPosition, maxVelocity, minVelocity, maxAcceleration, minAcceleration;
    CPhidgetAdvancedServo_getPositionMax(servo, 0, &maxPosition);
    CPhidgetAdvancedServo_getPositionMin(servo, 0, &minPosition);
    CPhidgetAdvancedServo_getVelocityMax(servo, 0, &maxVelocity);
    CPhidgetAdvancedServo_getVelocityMin(servo, 0, &minVelocity);
    CPhidgetAdvancedServo_getAccelerationMax(servo, 0, &maxAcceleration);
    CPhidgetAdvancedServo_getAccelerationMin(servo, 0, &minAcceleration);
    ptrServo->maxAcceleration = (float)maxAcceleration;
    ptrServo->maxAcceleration = (float)minAcceleration;
    ptrServo->maxPosition = (float)maxPosition;
    ptrServo->minPosition = (float)minPosition;
    ptrServo->maxVelocity = (float)maxVelocity;
    ptrServo->minVelocity = (float)minVelocity;
}


void phidgetSingleServoClose(phidgetSingleServoController_t * ptrServo){
    assert(ptrServo);
    
    // To make code easly readable, dereference the servo handler into a
    // variable and use throughout this function.
    CPhidgetAdvancedServoHandle servo = ptrServo->servoHandler;
    
    CPhidget_close((CPhidgetHandle)servo);
	CPhidget_delete((CPhidgetHandle)servo);
    
    ptrServo->servoHandler = 0; // Set to intial value.
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

phidgetSingleServoController_t * phidgetSingleServoInit() {
    
    const CPhidget_ServoType deviceType = PHIDGET_SERVO_HITEC_HS645MG;
    
    phidgetSingleServoController_t * ptrServo =(phidgetSingleServoController_t*)
    malloc(sizeof(phidgetSingleServoController_t));
    
    if ( ptrServo ) {
        memset(ptrServo, 0, sizeof(phidgetSingleServoController_t));
        
        int condition;
        
        switch (deviceType) {
            case PHIDGET_SERVO_HITEC_HS645MG:
                condition = phidgetSingleServoOpen(ptrServo);
                phidgetSingleServoSetup(ptrServo);
                break;
                
            default:
                printf("Unsupported Phidget device type\n");
                exit(EXIT_FAILURE);
                break;
        }
        
        if (condition == 0) {
            phidgetSingleServoDealloc(ptrServo);
            ptrServo = NULL;
            return NULL;
        } else {
            return ptrServo;
        }
    } else {
        perror("malloc");
        exit(EXIT_FAILURE);
    }
}


void phidgetSingleServoDealloc(phidgetSingleServoController_t * ptrServo){
    assert(ptrServo); // Defensive Code.
    
    phidgetSingleServoClose(ptrServo);
    // Close connection w/ device.
    
    // Note: ptrServo->ptrName does not need to be freed.
    
    free(ptrServo);
    ptrServo = NULL;
}


float phidgetSingleServoGetPosition(phidgetSingleServoController_t * ptrServo){
    assert(ptrServo);
    
    double curr;
	if (CPhidgetAdvancedServo_getPosition(
                                          ptrServo->servoHandler,
                                          0,
                                          &curr) == EPHIDGET_OK ) {
        return (float)curr;
    } else {
        return 666.0f; // End value indicating failure.
    }
}


int phidgetSingleServoEngage(phidgetSingleServoController_t * ptrServo){
    assert(ptrServo);
    ptrServo->engaged = 1;
    return CPhidgetAdvancedServo_setEngaged(ptrServo->servoHandler,
                                            0, 1);
}

int phidgetSingleServoDisengage(phidgetSingleServoController_t * ptrServo){
    assert(ptrServo);
    ptrServo->engaged = 0;
    return CPhidgetAdvancedServo_setEngaged(ptrServo->servoHandler,
                                            0, 0);
}


int phidgetSingleServoSetPosition(phidgetSingleServoController_t * ptrServo,
                                  const float newPosition){
    assert(ptrServo);
    int result;
    if (newPosition >= ptrServo->maxPosition) {
        result = CPhidgetAdvancedServo_setPosition (ptrServo->servoHandler, 0, ptrServo->maxPosition);
    } else if ( newPosition <= ptrServo->minPosition) {
        result = CPhidgetAdvancedServo_setPosition (ptrServo->servoHandler, 0, ptrServo->minPosition);
    } else {
        result = CPhidgetAdvancedServo_setPosition (ptrServo->servoHandler, 0, newPosition);
    }
    
    return result;
}

int phidgetSingleServoSetAcceleration(phidgetSingleServoController_t * ptrServo,
                                      const float newAcceleration) {
    assert(ptrServo);
    int result;
    if (newAcceleration > ptrServo->maxAcceleration) {
        result = CPhidgetAdvancedServo_setAcceleration(ptrServo->servoHandler, 0, ptrServo->maxAcceleration);
    } else if ( newAcceleration <= ptrServo->minAcceleration) {
        result = CPhidgetAdvancedServo_setAcceleration(ptrServo->servoHandler, 0, ptrServo->minAcceleration);
    } else {
        result = CPhidgetAdvancedServo_setAcceleration(ptrServo->servoHandler, 0, newAcceleration);
    }
    
    return result;

}

float phidgetSingleServoGetAcceleration(const phidgetSingleServoController_t * ptrServo) {
    assert(ptrServo);
    double acc;
    CPhidgetAdvancedServo_getAcceleration(ptrServo->servoHandler, 0, &acc);
    return (float)acc;
}

int phidgetSingleServoDeviceIsOperational(const phidgetSingleServoController_t * ptrServo) {
    assert(ptrServo);
    return ptrServo->isOperational;
}

int phidgetSingleServoIsEngaged(const phidgetSingleServoController_t * ptrServo) {
    assert(ptrServo);
    return ptrServo->engaged;
}
