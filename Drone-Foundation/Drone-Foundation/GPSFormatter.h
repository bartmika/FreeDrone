//
//  GPSFormatter.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Structure which holds the Degree Minute Second of a coordinate.
#ifndef DEGREE_MINUTE_SECONDS_EXISTS
#define DEGREE_MINUTE_SECONDS_EXISTS
typedef struct _DMS_T{
    float degree;
    float minute;
    float second;
}dms_t;  // Signed Decimal Degrees Minutes Seconds
#endif

@interface GPSFormatter : NSObject {
    
}

+(float) degreesToRadians: (const float *) ptrDegrees;

+(float) radiansToDegrees: (const float *) ptrRadians;

+(float) degreesMinutesSecondsToDegrees: (const dms_t *) ptrDMS;

+(dms_t) degreesToDegreesMinutesSeconds: (const float *) ptrAngleDegree;

@end
