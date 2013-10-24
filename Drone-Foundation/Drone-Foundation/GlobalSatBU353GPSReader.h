//
//  GlobalSatBU353GPSReader.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_GlobalSatBU353GPSReader_h
#define Drone_Foundation_GlobalSatBU353GPSReader_h

// Standard Libraries
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// Custom Libraries
#include "GPS.h"
#include "TTYReader.h"
#include "NMEA183.h"
#include "DetachedThread.h"
#include "GPSReceiverData.h"

typedef struct _GLOBALSATBU353GPSRECEIVER_T{
    ttyReader_t * gpsReader;
    nmea183_t *protocol;
    detachedThread_t * gpsDecoderServiceLoopThread;
    
    // Variable which handles whether we need to shutdown the GPS receiver or not.
    unsigned int shutdown;
    unsigned int operational;
    
    // Variables which will handle storing our GPS related information.
    gps_t coordinate;
    float altitude;
    float heading;
    float speed;
}globalSatBU353GPSReader_t;

globalSatBU353GPSReader_t * globalSatBU353GPSReaderInit();

sdd_t globalSatBU353GPSReaderGetCoordinate(globalSatBU353GPSReader_t * ptrDriver);

float globalSatBU353GPSReaderGetAltitude(globalSatBU353GPSReader_t * ptrDriver);

float globalSatBU353GPSReaderGetHeading(globalSatBU353GPSReader_t * ptrDriver);

float globalSatBU353GPSReaderGetSpeed(globalSatBU353GPSReader_t * ptrDriver);

void globalSatBU353GPSReaderDealloc(globalSatBU353GPSReader_t * ptrDriver);

unsigned int globalSatBU353GPSReaderIsOperational(globalSatBU353GPSReader_t * ptrDriver);

gpsReceiverData_t globalSatBU353GPSReaderGetData(globalSatBU353GPSReader_t * ptrDriver);

#endif
