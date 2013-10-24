//
//  GPSFormatter.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "GPSFormatter.h"

@implementation GPSFormatter

+(float) degreesToRadians: (const float *) ptrDegrees
{
    assert(ptrDegrees);
	return ( ( *ptrDegrees ) * ( M_PI / 180.0f ) );
}

+(float) radiansToDegrees: (const float *) ptrRadians
{
    assert(ptrRadians);
	return ( ( *ptrRadians ) * ( 180.0f / M_PI ) );
}

+ (float) degreesMinutesSecondsToDegrees: (const dms_t *) ptrDMS
{
    assert(ptrDMS);
    
    // Determine if the degrees are negative...
    BOOL isNegative = ptrDMS->degree <= 0 ? YES : NO;
    float signedDegree;
    
    // Formula:
	// SignedDegree = Degree + Minute * 1/60 + Second * 1/3600
    if (isNegative) {
        signedDegree =  ( -1.0f * ptrDMS->degree );
        signedDegree += ( ptrDMS->minute * ( 1.0f / 60.0f ) );
        signedDegree += ( ptrDMS->second * ( 1.0f / 3600.0f ) );
        signedDegree *= -1.0f;
    } else {
        signedDegree =  ( ptrDMS->degree );
        signedDegree += ( ptrDMS->minute * ( 1.0f / 60.0f ) );
        signedDegree += ( ptrDMS->second * ( 1.0f / 3600.0f ) );
    }
    
	return signedDegree;
}

+(dms_t) degreesToDegreesMinutesSeconds: (const float *) ptrAngleDegree
{
    assert(ptrAngleDegree);
    
    // If our input is negative, then we must remove the negative and
    // add later.
    BOOL isNegative = *ptrAngleDegree <= 0 ? YES : NO;
    float angleDegrees = isNegative ? (-1.0f * *ptrAngleDegree) : *ptrAngleDegree;
    
    // Declare our output variable
    dms_t result = {0,0,0};
    
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

@end
