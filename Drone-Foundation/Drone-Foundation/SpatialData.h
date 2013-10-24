//
//  SpatialData.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-19.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_SpatialData_h
#define Drone_Foundation_SpatialData_h

#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#include <limits.h> // Limits of various data types
#include <float.h>  // Limits of float types
#include <math.h>

#ifndef Acceleration
typedef struct _ACCELERATION{
    float x;
    float y;
    float z;
}acceleration_t;
#endif

#ifndef AngularRotation

typedef struct _ANGULARROTATION{
    float x;
    float y;
    float z;
}angularRotation_t;
#endif

#ifndef MagneticField
typedef struct _MAGNETICFIELD{
    float x;
    float y;
    float z;
}magneticField_t;
#endif

#ifndef Rotation
typedef struct _ROTATION_T{
    double pitch;
    double roll;
    double yaw;
}rotation_t;
#endif

#ifndef SpatialData
typedef struct _SPATIAL_T{
    acceleration_t acc;
    angularRotation_t ang; // x = pitch, y = yaw , z= roll
    magneticField_t mag;
    float compassHeading; // Measured in degrees
    time_t timestamp;
    time_t utimestamp;
    rotation_t rot;
}spatialData_t;
#endif

/**
 * @Precondition:
 *      1) "search" must be a valid, non-null "SpatialData" type.
 *      2) "target" must be a valid, non-null "SpatialData" type.
 * @Postcondition:
 *      1) Returns "1" if content of the spatial data match.
 *      2) Returns "0" if content of the spatial data does not match.
 */
const unsigned int spatialEqualsSpatial(const spatialData_t *ptrSearch,
                                        const spatialData_t *ptrTarget);

const float spatial2tilt(const spatialData_t input);


#endif
