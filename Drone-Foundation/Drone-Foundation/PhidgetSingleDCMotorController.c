//
//  PhidgetSingleDCMotorController.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-19.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//


#include "PhidgetSingleDCMotorController.h"


#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                     PRIVATE VARIABLES / FUNCTIONS                          //
//----------------------------------------------------------------------------//


int CCONV phidgetSingleDCMotorAttachHandler(CPhidgetHandle MC, void *userptr)
{
    assert(MC); // Defensive Code
    assert(userptr);
    
	int serialNo;
	const char *name;
    
	CPhidget_getDeviceName (MC, &name);
	CPhidget_getSerialNumber(MC, &serialNo);
	//printf("%s %10d attached!\n", name, serialNo);
    
    phidgetSingleDCMotorController_t * ptrMotor = (phidgetSingleDCMotorController_t*)userptr;
    ptrMotor->serialNo = serialNo;
    ptrMotor->ptrName = name;
    ptrMotor->isOperational = 1;
	return 0;
}

int CCONV phidgetSingleDCMotorDetachHandler(CPhidgetHandle MC, void *userptr)
{
    assert(MC); // Defensive Code
    assert(userptr);
    
	int serialNo;
	const char *name;
    
	CPhidget_getDeviceName (MC, &name);
	CPhidget_getSerialNumber(MC, &serialNo);
	//printf("%s %10d detached!\n", name, serialNo);
    
    phidgetSingleDCMotorController_t * ptrMotor = (phidgetSingleDCMotorController_t*)userptr;
    ptrMotor->serialNo = serialNo;
    ptrMotor->ptrName = name;
    ptrMotor->isOperational = 0;
    
	return 0;
}

int CCONV phidgetSingleDCMotorErrorHandler(CPhidgetHandle MC,
                                           void *userptr,
                                           int ErrorCode,
                                           const char *Description)
{
	assert(userptr);
    assert(MC);
    
    //printf("Error handled. %d - %s\n", ErrorCode, Description);
    phidgetSingleDCMotorController_t * ptrMotor = (phidgetSingleDCMotorController_t*)userptr;
    ptrMotor->errorCode = ErrorCode;
    ptrMotor->errorDescription = (char*)Description;
    ptrMotor->isOperational = 0;
    
	return 0;
}


int CCONV phidgetSingleDCMotorInputChangeHandler(CPhidgetMotorControlHandle MC,
                                                 void *usrptr, int Index, int State)
{
    assert(usrptr);
    assert(MC);
    
    phidgetSingleDCMotorController_t * ptrMotor = (phidgetSingleDCMotorController_t*)usrptr;
    ptrMotor->state = State;
    
	//printf("Input %d > State: %d\n", Index, State);
	return 0;
}

int CCONV phidgetSingleDCMotorVelocityChangeHandler(CPhidgetMotorControlHandle MC,
                                                    void *usrptr,
                                                    int Index,
                                                    double Value)
{
    assert(usrptr);
    assert(MC);
    
    phidgetSingleDCMotorController_t * ptrMotor = (phidgetSingleDCMotorController_t*)usrptr;
    ptrMotor->velocity = (float)Value;
    
	//printf("Motor %d > Current Speed: %f\n", Index, Value);
	return 0;
}

int CCONV phidgetSingleDCMotorCurrentChangeHandler(CPhidgetMotorControlHandle MC,
                                                   void *usrptr,
                                                   int Index,
                                                   double Value)
{
    assert(usrptr);
    assert(MC);
    
    phidgetSingleDCMotorController_t * ptrMotor = (phidgetSingleDCMotorController_t*)usrptr;
    ptrMotor->current = (float)Value;
    
	//printf("Motor: %d > Current Draw: %f\n", Index, Value);
	return 0;
}

int phidgetSingleDCMotorSetup(CPhidgetMotorControlHandle phid,
                              phidgetSingleDCMotorController_t * ptrMotor)
{
	int serialNo, version, numInputs, numMotors;
	const char* ptr;
    
    double accelerationMax, accelerationMin;
    
	CPhidget_getDeviceType((CPhidgetHandle)phid, &ptr);
	CPhidget_getSerialNumber((CPhidgetHandle)phid, &serialNo);
	CPhidget_getDeviceVersion((CPhidgetHandle)phid, &version);
	
	CPhidgetMotorControl_getInputCount(phid, &numInputs);
	CPhidgetMotorControl_getMotorCount(phid, &numMotors);
    
    CPhidgetMotorControl_getAccelerationMax(phid, 0, &accelerationMax);
	CPhidgetMotorControl_getAccelerationMin(phid, 0, &accelerationMin);
    
    
    ptrMotor->serialNo = serialNo;
    ptrMotor->version = version;
    ptrMotor->numInputs = numInputs;
    ptrMotor->numMotors = numMotors;
    ptrMotor->accelerationMax = (float)accelerationMax;
    ptrMotor->accelerationMin = (float)accelerationMin;
    
	return 0;
}

int phidgetSingleDCMotorOpen(phidgetSingleDCMotorController_t * ptrMotor){
    assert(ptrMotor); // Defensive Code.
    
    int result;
	const char *err;
    
	//Declare a motor control handle
	CPhidgetMotorControlHandle motoControl = 0;
    
	//create the motor control object
	CPhidgetMotorControl_create(&motoControl);
    
	//Set the handlers to be run when the device is plugged in or opened from software, unplugged or closed from software, or generates an error.
	CPhidget_set_OnAttach_Handler((CPhidgetHandle)motoControl,
                                  phidgetSingleDCMotorAttachHandler,
                                  ptrMotor
                                  );
    
	CPhidget_set_OnDetach_Handler((CPhidgetHandle)motoControl,
                                  phidgetSingleDCMotorDetachHandler,
                                  ptrMotor
                                  );
    
	CPhidget_set_OnError_Handler((CPhidgetHandle)motoControl,
                                 phidgetSingleDCMotorErrorHandler,
                                 ptrMotor
                                 );
    
	//Registers a callback that will run if an input changes.
	//Requires the handle for the Phidget, the function that will be called, and a arbitrary pointer that will be supplied to the callback function (may be NULL).
	CPhidgetMotorControl_set_OnInputChange_Handler (motoControl,
                                                    phidgetSingleDCMotorInputChangeHandler,
                                                    ptrMotor
                                                    );
    
	//Registers a callback that will run if a motor changes.
	//Requires the handle for the Phidget, the function that will be called, and a arbitrary pointer that will be supplied to the callback function (may be NULL).
	CPhidgetMotorControl_set_OnVelocityChange_Handler (motoControl,
                                                       phidgetSingleDCMotorVelocityChangeHandler, ptrMotor
                                                       );
    
	//Registers a callback that will run if the current draw changes.
	//Requires the handle for the Phidget, the function that will be called, and a arbitrary pointer that will be supplied to the callback function (may be NULL).
	CPhidgetMotorControl_set_OnCurrentChange_Handler (motoControl, phidgetSingleDCMotorCurrentChangeHandler, ptrMotor);
    
	//open the motor control for device connections
	CPhidget_open((CPhidgetHandle)motoControl, -1);
    
	//get the program to wait for a motor control device to be attached
	//printf("Waiting for MotorControl to be attached....");
	if((result = CPhidget_waitForAttachment((CPhidgetHandle)motoControl, 10000)))
	{
		CPhidget_getErrorDescription(result, &err);
		printf("MOTOR: Problem waiting for attachment: %s\n", err);
		return 0;
	}
    
	phidgetSingleDCMotorSetup(motoControl, ptrMotor);
    
    // Set variable.
	ptrMotor->motoControlHandler = motoControl;
    return 1;
}

void phidgetSingleDCMotorClose(phidgetSingleDCMotorController_t * ptrMotorDevice){
    assert(ptrMotorDevice);
    
    CPhidget_close((CPhidgetHandle)ptrMotorDevice->motoControlHandler);
	CPhidget_delete((CPhidgetHandle)ptrMotorDevice->motoControlHandler);
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

phidgetSingleDCMotorController_t * phidgetSingleDCMotorInit(){
    const unsigned int motorID = PHIDGET_DC_MOTOR_3274_0;
    
    phidgetSingleDCMotorController_t * ptrMotor =
    (phidgetSingleDCMotorController_t*)malloc(sizeof(phidgetSingleDCMotorController_t));
    
    if ( ptrMotor ) {
        memset(ptrMotor, 0, sizeof(phidgetSingleDCMotorController_t));
        
        int condition;
        
        switch (motorID) {
            case PHIDGET_DC_MOTOR_3274_0:
                condition = phidgetSingleDCMotorOpen(ptrMotor);
                break;
            default:
                break;
        }
        
        // Self deallocate
        if (condition == 0) {
            phidgetSingleDCMotorDealloc(ptrMotor);
            ptrMotor = NULL;
            return NULL;
        } else {
            ptrMotor->isOperational = 1;
            return ptrMotor;
        }
    } else {
        perror("malloc");
        exit(EXIT_FAILURE);
    }
}

void phidgetSingleDCMotorDealloc(phidgetSingleDCMotorController_t * ptrMotor){
    assert(ptrMotor);
    
    phidgetSingleDCMotorClose(ptrMotor);
    
    free(ptrMotor);
    ptrMotor = NULL;
}


int phidgetSingleDCMotorSetAcceleration(phidgetSingleDCMotorController_t * ptrMotor,
                                        const float newAcceleration){
    assert(ptrMotor);
    int i;
    if ( newAcceleration >= ptrMotor->accelerationMax ) {
        i=CPhidgetMotorControl_setAcceleration (ptrMotor->motoControlHandler,
                                              0,
                                              ptrMotor->accelerationMax);
    } else if ( newAcceleration <= ptrMotor->accelerationMin ) {
        i=CPhidgetMotorControl_setAcceleration (ptrMotor->motoControlHandler,
                                              0,
                                              ptrMotor->accelerationMin);
    } else {
        i=CPhidgetMotorControl_setAcceleration (ptrMotor->motoControlHandler,
                                                0,
                                                newAcceleration);
    }
    return i;
}

int phidgetSingleDCMotorSetVelocity(phidgetSingleDCMotorController_t * ptrMotor,
                                    const float velocity){
    assert(ptrMotor);
    
    return CPhidgetMotorControl_setVelocity (ptrMotor->motoControlHandler,
                                             0,
                                             velocity);
}


float phidgetSingleDCMotorGetVelocity(phidgetSingleDCMotorController_t * ptrMotor) {
    assert(ptrMotor);
    double vel = 0;
    CPhidgetMotorControl_getVelocity(ptrMotor->motoControlHandler, 0, &vel);
    return (float)vel;
}

float phidgetSingleDCMotorGetAcceleration(phidgetSingleDCMotorController_t * ptrMotor) {
    assert(ptrMotor);
    double acc = 0;
    CPhidgetMotorControl_getAcceleration(ptrMotor->motoControlHandler, 0, &acc);
    return (float)acc;
}

float phidgetSingleDCMotorGetCurrent(phidgetSingleDCMotorController_t * ptrMotor) {
    assert(ptrMotor);
    double cur = 0;
    CPhidgetMotorControl_getCurrent(ptrMotor->motoControlHandler, 0, &cur);
    return (float)cur;
}

float phidgetSingleDCMotorGetSupplyVoltage(phidgetSingleDCMotorController_t * ptrMotor) {
    assert(ptrMotor);
    double vol = 0;
    CPhidgetMotorControl_getSupplyVoltage(ptrMotor->motoControlHandler, &vol);
    return (float)vol;
}

float phidgetSingleDCMotorDeviceIsOperational(phidgetSingleDCMotorController_t * ptrMotor) {
    assert(ptrMotor);
    return ptrMotor->isOperational;
}

