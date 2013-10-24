//
//  PhidgetGPSReader.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-19.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#include "PhidgetGPSReader.h"

int CCONV phidgetGPSReaderAttachHandler(CPhidgetHandle phid, void *userptr)
{
//	GPSTime time;
//	CPhidgetGPSHandle gps = (CPhidgetGPSHandle)phid;
//	if(!CPhidgetGPS_getTime(gps, &time))
//		printf("Attach handler ran at: %02d:%02d:%02d.%03d\n", time.tm_hour, time.tm_min, time.tm_sec, time.tm_ms);
//	else
//		printf("Attach handler ran!\n");
	return 0;
}

int CCONV phidgetGPSReaderDetachHandler(CPhidgetHandle phid, void *userptr)
{
//	printf("Detach handler ran!\n");
	return 0;
}

int CCONV phidgetGPSReaderErrorHandler(CPhidgetHandle phid, void *userptr, int ErrorCode, const char *unknown)
{
//	printf("Error handler ran!\n");
	return 0;
}

int CCONV phidgetGPSReaderPosnChange(CPhidgetGPSHandle phid, void *userPtr, double latitude, double longitude, double altitude)
{
    assert(userPtr);
    phidgetGPSReader_t * gpsReader = (phidgetGPSReader_t*)userPtr;
    
	GPSDate date;
	GPSTime time;
	CPhidgetGPSHandle gps = (CPhidgetGPSHandle)phid;
	double heading = 0.0f, velocity = 0.0f;
    
    // Defensive Code: Ensure order is maintainted among threads.
    pthread_mutex_lock(&(gpsReader->runningIO)); // Lock this object
    
	if(!CPhidgetGPS_getDate(gps, &date) && !CPhidgetGPS_getTime(gps, &time)) {
        gpsReader->data.date = date;
        gpsReader->data.time = time;
    }
	if(!CPhidgetGPS_getHeading(gps, &heading) && !CPhidgetGPS_getVelocity(gps, &velocity)) {
        gpsReader->data.heading = (float)heading;
        gpsReader->data.speed = (float)velocity;
    }
    
    gpsReader->data.latitude = (float)latitude;
    gpsReader->data.longitude = (float)longitude;
    gpsReader->data.altitude = (float)altitude;
    
    pthread_mutex_unlock(&(gpsReader->runningIO));
	return 0;
}

int CCONV gpsReaderFixChange(CPhidgetGPSHandle phid, void *userPtr, int status)
{
	//printf("Fix change event: %d\n", status);
	return 0;
}

phidgetGPSReader_t * phidgetGPSReaderInit() {
    phidgetGPSReader_t * gpsReader = (phidgetGPSReader_t*) malloc( sizeof(phidgetGPSReader_t) );
    assert(gpsReader);
    memset(gpsReader, 0, sizeof(phidgetGPSReader_t));
    
    // Initialize the variable which we'll use to sync between our thread
    // and the current thread.
    pthread_mutex_init(&(gpsReader->runningIO), NULL);
    
    int result;
	CPhidgetGPSHandle gps;
	
    // Turn this on if we have any problems, else keep it commented out.
    //CPhidget_enableLogging(PHIDGET_LOG_VERBOSE, NULL);
    
	CPhidgetGPS_create(&gps);
    
	CPhidget_set_OnAttach_Handler((CPhidgetHandle)gps, phidgetGPSReaderAttachHandler, gpsReader);
	CPhidget_set_OnDetach_Handler((CPhidgetHandle)gps, phidgetGPSReaderDetachHandler, gpsReader);
	CPhidget_set_OnError_Handler((CPhidgetHandle)gps, phidgetGPSReaderErrorHandler, gpsReader);
    
	CPhidgetGPS_set_OnPositionChange_Handler(gps, phidgetGPSReaderPosnChange, gpsReader);
	//CPhidgetGPS_set_OnPositionFixStatusChange_Handler(gps, gpsReaderFixChange, gpsReader);
    
	CPhidget_open((CPhidgetHandle)gps, -1);
    
	result = CPhidget_waitForAttachment((CPhidgetHandle)gps, 10000);
    
    if(result)
	{
		const char *err;
		CPhidget_getErrorDescription(result, &err);
		printf("GPS: Problem waiting for attachment: %s\n", err);
        free(gpsReader);
        gpsReader = NULL;
		return NULL;
	}
    
    gpsReader->gpsHandler = gps;
    gpsReader->isOperational = 1;
    
    return gpsReader;
}

void phidgetGPSReaderDealloc(phidgetGPSReader_t * gpsReader) {
    pthread_mutex_lock(&(gpsReader->runningIO)); // Lock this thread.
    pthread_mutex_unlock(&(gpsReader->runningIO)); // Unlock this thread.
    pthread_mutex_destroy(&(gpsReader->runningIO));
    
    CPhidget_close((CPhidgetHandle)gpsReader->gpsHandler);
	CPhidget_delete((CPhidgetHandle)gpsReader->gpsHandler);
    
    free(gpsReader); gpsReader = NULL;
    
    return;
}

sdd_t phidgetGPSReaderGetCoordinate(phidgetGPSReader_t * gpsReader) {
    // Defensive Code: Ensure order is maintainted among threads.
    pthread_mutex_lock(&(gpsReader->runningIO)); // Lock this object
    sdd_t coordinate = {gpsReader->data.latitude, gpsReader->data.longitude};
    pthread_mutex_unlock(&(gpsReader->runningIO));
    return coordinate;
}

float phidgetGPSReaderGetHeading(phidgetGPSReader_t * gpsReader) {
    pthread_mutex_lock(&(gpsReader->runningIO)); // Lock this object
    float heading = gpsReader->data.heading;
    pthread_mutex_unlock(&(gpsReader->runningIO));
    return heading;
}

float phidgetGPSReaderGetVelocity(phidgetGPSReader_t * gpsReader) {
    pthread_mutex_lock(&(gpsReader->runningIO)); // Lock this object
    float velocity = gpsReader->data.speed;
    pthread_mutex_unlock(&(gpsReader->runningIO));
    return velocity;
}

float phidgetGPSReaderGetAltitude(phidgetGPSReader_t * gpsReader) {
    pthread_mutex_lock(&(gpsReader->runningIO)); // Lock this object
    float altitude = gpsReader->data.altitude;
    pthread_mutex_unlock(&(gpsReader->runningIO));
    return altitude;
}

GPSDate phidgetGPSReaderGetDate(phidgetGPSReader_t * gpsReader) {
    pthread_mutex_lock(&(gpsReader->runningIO)); // Lock this object
    GPSDate date = gpsReader->data.date;
    pthread_mutex_unlock(&(gpsReader->runningIO));
    return date;
}

GPSTime phidgetGPSReaderGetTime(phidgetGPSReader_t * gpsReader) {
    pthread_mutex_lock(&(gpsReader->runningIO)); // Lock this object
    GPSTime time = gpsReader->data.time;
    pthread_mutex_unlock(&(gpsReader->runningIO));
    return time;
}

gpsReceiverData_t phidgetGPSReaderGetData(phidgetGPSReader_t * gpsReader) {
    pthread_mutex_lock(&(gpsReader->runningIO)); // Lock this object
    gpsReceiverData_t dataPoint = gpsReader->data;
    pthread_mutex_unlock(&(gpsReader->runningIO));
    return dataPoint;
}

int phidgetGPSReaderIsOperational(const phidgetGPSReader_t * gpsReader) {
    if (gpsReader) {
        int operational = gpsReader->isOperational;
        return operational;
    } else {
        return 0;
    }
}
