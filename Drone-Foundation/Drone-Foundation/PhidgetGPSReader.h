//
//  PhidgetGPSReader.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-19.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_PhidgetGPSReader_h
#define Drone_Foundation_PhidgetGPSReader_h

#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>

// Custom Library
#include "GPSReceiverData.h"

// Structure holds the "Signed Decimal degree" of the coordinate, where a -ve is
// used to indicate West or South Value.
#ifndef SIGNED_DECIMAL_DEGREES_EXISTS
#define SIGNED_DECIMAL_DEGREES_EXISTS
typedef struct _SDD_T{
	float latitude;
    float longitude;
}sdd_t;
#endif

typedef struct _PHIDGETGPSREADER_T{
    CPhidgetGPSHandle gpsHandler;
    gpsReceiverData_t data;
    unsigned int isOperational;
    
    pthread_mutex_t runningIO;
    
}phidgetGPSReader_t;

phidgetGPSReader_t * phidgetGPSReaderInit();

void phidgetGPSReaderDealloc(phidgetGPSReader_t * gpsReader);

sdd_t phidgetGPSReaderGetCoordinate(phidgetGPSReader_t * gpsReader);

float phidgetGPSReaderGetHeading(phidgetGPSReader_t * gpsReader);

float phidgetGPSReaderGetVelocity(phidgetGPSReader_t * gpsReader);

float phidgetGPSReaderGetAltitude(phidgetGPSReader_t * gpsReader);

GPSDate phidgetGPSReaderGetDate(phidgetGPSReader_t * gpsReader);

GPSTime phidgetGPSReaderGetTime(phidgetGPSReader_t * gpsReader);

gpsReceiverData_t phidgetGPSReaderGetData(phidgetGPSReader_t * gpsReader);

int phidgetGPSReaderIsOperational(const phidgetGPSReader_t * gpsReader);


#endif
