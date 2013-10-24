//
//  PhidgetSpatialReader.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-19.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_PhidgetSpatialReader_h
#define Drone_Foundation_PhidgetSpatialReader_h

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#include <limits.h> // Limits of various data types
#include <float.h>  // Limits of float types

// Custom Library
#include "LowPassDataFilter.h"
#include "CompassBearing.h"

// Load up the data type that will hold our spatial data.
#include "SpatialData.h"

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

typedef struct _PHIDGETSPATIALREADER_T{
    // Information about our variable
    unsigned int mode;
    lowPassDataFilter_t * acc_filter;
    lowPassDataFilter_t * mag_filter;
    lowPassDataFilter_t * ang_filter;
    double timestamp;
    double utimestamp;
    compassBearing_t * bearing;
    
    // This is the spatial handler to communicate with our hardware.
	CPhidgetSpatialHandle spatial;
    
    // This is the handler to communicate with the general hardware board.
    // In summary it's the above object but with different access.
    CPhidgetHandle handler;
    
    // Hardware variables
    int result;
	const char *err;
    
    // Information about our hardware.
    int serialNo, version;
	const char* ptr;
	int numAccelAxes, numGyroAxes, numCompassAxes, dataRateMax, dataRateMin;
    unsigned int isOperational;
}phidgetSpatialReader_t;


/**
 * @Precondition:
 *      1) "Phidget Spatial 3/3/3 High Resolution" must be connected to computer
 * @Postcondition:
 *      1) Instantiates the spatial object reader.
 */
phidgetSpatialReader_t * phidgetSpatialReaderInit();

/**
 * @Precondition:
 *      1) "Phidget Spatial 3/3/3 High Resolution" must be connected to computer
 *      2) Was instantiated
 * @Postcondition:
 *      1) Stops the device and terminates the connection
 *      2) Deallocates and clears the memory associated with what was loaded
 *         in memory.
 */
void phidgetSpatialReaderDealloc(phidgetSpatialReader_t * ptrReader);

/**
 * @Precondition:
 *      1) "Phidget Spatial 3/3/3 High Resolution" must be connected to computer
 *      2) Was instantiated
 * @Postcondition:
 *      1) Returns the spatial data which contains:
 *          Accelerameter x,y,z
 *          Gyroscope x,y,z
 *          Compass x,y,z
 *          timestamp (sec)
 *          timestamp (microsec)
 *          Compass Bearing (degrees)
 */
spatialData_t phidgetSpatialReaderGetData(phidgetSpatialReader_t * ptrReader);

/**
 * @Precondition:
 *      1) SpatialReader was instantiated
 * @Postcondition:
 *      1) Returns "1" if object is operational (no software/hardware errors)
 *      2) Returns "0" if object is not operational (has problems).
 */
const unsigned int phidgetSpatialReaderIsOperationial(phidgetSpatialReader_t * ptrReader);

acceleration_t phidgetSpatialReaderGetAccelerameter(const phidgetSpatialReader_t * ptrReader);

angularRotation_t phidgetSpatialReaderGetGyroscope(const phidgetSpatialReader_t * ptrReader);

magneticField_t phidgetSpatialReaderGetCompass(const phidgetSpatialReader_t * ptrReader);

float phidgetSpatialReaderGetTimestamp(const phidgetSpatialReader_t * ptrReader);

float phidgetSpatialReaderGetUTimestamp(const phidgetSpatialReader_t * ptrReader);

float phidgetSpatialReaderGetCompassBearing(const phidgetSpatialReader_t * ptrReader);

rotation_t phidgetSpatialReaderGetAnglesOfRotation(const phidgetSpatialReader_t * ptrReader);

#endif
