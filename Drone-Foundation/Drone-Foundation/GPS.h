//
//  GPS.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_GPS_h
#define Drone_Foundation_GPS_h

#include <assert.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>     /* abs */

// Structure holds the "Signed Decimal degree" of the coordinate, where a -ve is
// used to indicate West or South Value.
#ifndef SIGNED_DECIMAL_DEGREES_EXISTS
#define SIGNED_DECIMAL_DEGREES_EXISTS
typedef struct _SDD_T{
	float latitude;
    float longitude;
}sdd_t;
#endif

// Structure which holds the Degree Minute Second of a coordinate.
#ifndef DEGREE_MINUTE_SECONDS_EXISTS
#define DEGREE_MINUTE_SECONDS_EXISTS
typedef struct _DMS_T{
    float degree;
    float minute;
    float second;
}dms_t;
#endif

#ifndef GLOBAL_POSITIONING_S_TYPE
#define GLOBAL_POSITIONING_S_TYPE
// Structure which holds the degrees and direction of a cooridnate
typedef struct _GPS_T{
    float lat;
    char lat_dir;
    float lon;
    char lon_dir;
}gps_t;
#endif

// Struc. holds a bearing calculation in a compass.
// Note: 0, 360 = North
//           90 = East
//          180 = South
//          270 = West
typedef struct _BEARING_T{
    float value;
    char unit; // r=rad, d=degrees, '\0'= undeclared
}bearing_t;

/**
 * @Precondition:
 *      1) "angel_degree" must be a decimal value.
 * @Postcondition:
 *      1) Converts a signed degree formatted numeral into a
 *        Degree-Minute-Second formated one.
 */
dms_t deg2dms(const float *angle_degree);

/**
 * @Precondition:
 *      1) "dms" must be a non-null/empty value of a degree-minute-second
 *          type.
 * @Postcondition:
 *      1) Converts degree-minute-second format item into a signed degree.
 */
float dms2deg(const dms_t * dms);

/**
 * Task -
 */
/**
 * @Precondition:
 *      1) "deg" must be a reference to a decimal value.
 * @Postcondition:
 *      1) Converts degrees to radians and returns the radians.
 */
float deg2rad(const float *deg);

/**
 * @Precondition:
 *      1) "rad" must be reference to a decimal value.
 * @Postcondition:
 *      1) Converts radians to degrees.
 */
float rad2deg(const float *rad);

/**
 * @Precondition:
 *      1) "naut" must be a reference to a decimal value.
 * @Postcondition:
 *      1) Converts nautical miles to radians.
 */
float nm2rad(const float *naut);

/**
 * @Precondition:
 *      1) "rad" must be a reference to a decimal value.
 * @Postcondition:
 *      1) Converts radians to nautical miles and returns the value.
 */
float rad2nm(const float *rad);

/**
 * @Precondition:
 *      1) "naut" must be a regerence to a decimal value.
 * @Postcondition:
 *      1) Converts nautical miles to kilometers.
 */
float nm2km(const float * naut);


/**
 * @Precondition:
 *      1) "signed_decimal_degrees" must be a non-null, nor empty value.
 * @Postcondition:
 *      1) Converts from signed decimal degrees to GPS.
 */
gps_t sdd2gps(const sdd_t * sdd);

/**
 * @Precondition:
 *      1) "global_position_system_type" must be a non-null, nor empty value.
 * @Postcondition:
 *      1) Converts GPS to signed decimal degrees cordinate.
 */
sdd_t gps2sdd(const gps_t *gps);


/**
 * @Precondition:
 *      1) "search" must be a non-null, nor empty value.
 *      2) "target" must be a non-null, nor empty value.
 * @Postcondition:
 *      1) Compares two GPS coordinates returns:
 *          - "1" if they are equal.
 *          - "0" if they are not equal.
 */
unsigned int gpscmp(const gps_t *search, const gps_t *target);

/**
 * @Precondition:
 *      1) "b1" & "b2" must be valid, non-null, bearing values.
 * @Postcondition:
 *      1) Converts into a Degree-Minute-Second formated one.
 */
dms_t bearing2dms(bearing_t * bearing);

/**
 * @Precondition:
 *      1) "b1" & "b2" must be valid, non-null, bearing values.
 * @Postcondition:
 *      1) Returns the absolute difference between two bearing angles.
 */
float bearingsAbsoluteDifference(bearing_t b1, bearing_t b2);

#endif
