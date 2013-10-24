//
//  GPS.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#include "GPS.h"

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

sdd_t degcoord2radcoord( const float *latitude,
                        const float *longitude)
{
	// Create the first point and convert to radians.
	sdd_t p1;
	p1.latitude = deg2rad(latitude);
	p1.longitude= deg2rad(longitude);
    
	return p1;
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

dms_t deg2dms(const float * ptrAngleDegree)
{
    assert(ptrAngleDegree);
    
    // If our input is negative, then we must remove the negative and
    // add later.
    unsigned int isNegative = *ptrAngleDegree <= 0 ? 1 : 0;
    float angleDegrees = isNegative ? (-1.0f * *ptrAngleDegree) : *ptrAngleDegree;
    
    // Declare our output variable
    dms_t result = {};
    
	// 1) Find the degree.
	result.degree = floor (angleDegrees);
    
	// 2) Find the minutes.
	float minutes = ( 60.0f *( angleDegrees - floor (angleDegrees) ) );
	result.minute = floor (minutes);
    
    
	// Set the precision of minutes so it cuts of the trailing 0.0000001
	minutes -= fmod (minutes, 1E-5);
    
	// Special case: If the remainder of minutes is zero, then make seconds equal zero and exit function.
	if ( minutes <= 0 && result.minute <= 0 ) {
		result.second = 0;
		return result;
	}
    
	// 3) Find the seconds.
	float seconds = ( minutes - result.minute ) * 60.0f;
    
    // Round up seconds to TWO decimal places.
    seconds *= 100.0f;
    seconds = ceil(seconds);
    seconds /= 100.0f;
    result.second = seconds;
    
    // Convert back to a negative degree if it was negative.
    result.degree = isNegative ? (result.degree * -1.0f) : result.degree;
    
    return result;
}


float dms2deg(const dms_t * ptrDMS)
{
    assert(ptrDMS);
    
	// Formula:
	// SignedDegree = Degree + Minute * 1/60 + Second * 1/3600
	return ( ptrDMS->degree + ( ( ptrDMS->minute ) * ( 1.0 / 60.0 ) ) +
            ( ( ptrDMS->second ) * ( 1.0 / 3600.0 ) ) );
}

float deg2rad(const float * ptrDegrees)
{
    assert(ptrDegrees);
	return ( ( *ptrDegrees ) * ( M_PI / 180.0 ) );
}

float rad2deg(const float * ptrRadians)
{
    assert(ptrRadians);
	return ( ( *ptrRadians ) * ( 180.0 / M_PI ) );
}

float nm2rad(const float * ptrNauticalMiles)
{
    assert(ptrNauticalMiles);
	return ( (*ptrNauticalMiles) * ( M_PI / ( 180 * 60 ) ) );
}

float rad2nm(const float *ptrMiles)
{
    assert(ptrMiles);
	return ( (*ptrMiles) * ( ( 180 * 60 ) / M_PI ) );
}

float nm2km(const float * ptrNauticalMiles){
    assert(ptrNauticalMiles);
    return ( *ptrNauticalMiles ) * 1.852;
}

gps_t sdd2gps(const sdd_t * ptrSDD){
    assert(ptrSDD);
    
    gps_t gps = {0,'?',0,'?'}; // Create our GPS data set.
    gps.lat = ptrSDD->latitude;    // Copy our signed decimal degrees data set.
    gps.lon = ptrSDD->longitude;
    
    // Calculate direction.
    if ( ptrSDD->latitude >= 0 ) {
        gps.lat_dir = 'N';
    } else {
        gps.lat *= (-1); // Change sign
        gps.lat_dir ='S';
    } if ( ptrSDD->longitude >= 0 ) {
        gps.lon_dir = 'E';
    } else {
        gps.lon_dir = 'W';
        gps.lon *= (-1); // Change sign.
    }
    
    return gps;
}

sdd_t gps2sdd(const gps_t * ptrGPS){
    assert(ptrGPS);
    
    sdd_t sdd = {0,0};      // Create our signed decimal degrees data set.
    sdd.latitude = ptrGPS->lat; // Copy our gps data set
    sdd.longitude= ptrGPS->lon;
    
    // Change direction.
    if ( ptrGPS->lat_dir == 'S' || ptrGPS->lat_dir == 's' ) {
        sdd.latitude *= (-1);
    } if ( ptrGPS->lon_dir == 'W' || ptrGPS->lon_dir == 'w' ) {
        sdd.longitude *= (-1);
    }
    
    return sdd;
}

unsigned int gpscmp(const gps_t *search, const gps_t *target){
    if (search == NULL || target == NULL) { // Defensive Code: Either are nulls.
        return 0;
    }
    
    if (search->lat == target->lat &&
        search->lon == target->lon &&
        search->lat_dir == target->lat_dir &&
        search->lon_dir == search->lon_dir) {
        return 1;
    }else{
        return 0;
    }
}

dms_t bearing2dms(bearing_t * ptrBearing){
    assert(ptrBearing);
    return deg2dms(&(ptrBearing->value));
}

float bearingsAbsoluteDifference(bearing_t b1, bearing_t b2){
    float diff = b1.value - b2.value;
    return abs(diff);
}
