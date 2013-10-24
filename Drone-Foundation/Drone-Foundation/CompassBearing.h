//
//  CompassBearing.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-19.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_CompassBearing_h
#define Drone_Foundation_CompassBearing_h

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

typedef struct _COMPASSBEARING_T{
    float ax,ay,az,cx,cy,cz;
	float declination;
	float bearing, bearingDegrees;
	float filterConstant;
	unsigned int useDeclination;
    
    float pitchAngle;
    float rollAngle;
    float yawAngle;
}compassBearing_t;

/**
 * @Precondition:
 *      1) Enough memory available in our computer.
 *      2) "rate" must be a non-zero, valid number.
 *      3) "cufoffFrequency" must be a non-zero, valid number.
 * @Postcondition:
 *      1) Sets up an internal low pass filter
 *      2) Instantiates a compass calculating object and returns a pointer to it
 */
compassBearing_t * compassBearingInit(const float rate, const float cutoffFrequency);

/**
 * @Precondition:
 *      1) "cb" is a valid instantiated "CompassBearing" object.
 * @Postcondition:
 *      1) Deallocates the instantiation and frees the associated memory with it
 */
void compassBearingDealloc(compassBearing_t * cb);

/**
 * @Precondition:
 *      1) "cb" is a valid instantiated "CompassBearing" object.
 *      2) etc must be valid numbers.
 * @Postcondition:
 *      1) Stores the data into object.
 */
void compassBearingSetData(compassBearing_t * cb,
                           const float ax,
                           const float ay,
                           const float az,
                           const float cx,
                           const float cy,
                           const float cz);

/**
 * @Precondition:
 *      1) "cb" is a valid instantiated "CompassBearing" object.
 * @Postcondition:
 *      1) Computes the compass bearing, measured in degrees and stores it
 *         internally.
 *      2) Also returns the calculated value.
 */
float compassBearingCompute(compassBearing_t * cb);

/**
 * @Precondition:
 *      1) "cb" is a valid instantiated "CompassBearing" object.
 *      2) "rate" must be a non-zero, valid number.
 *      3) "cufoffFrequency" must be a non-zero, valid number.
 * @Postcondition:
 *      1) Sets the new low pass data filters calculations.
 */
void compassBearingSetSampleRate(compassBearing_t * cb, const float rate, const float freq);

/**
 * @Precondition:
 *      1) "cb" is a valid instantiated "CompassBearing" object.
 *      2) "declination" must be a valid number.
 * @Postcondition:
 *      1) Sets the declination.
 */
void compassBearingSetDeclination(compassBearing_t * cb, const float declination);

/**
 * @Precondition:
 *      1) "cb" is a valid instantiated "CompassBearing" object.
 *      2) "useDeclination" must be either "1" or "0"
 * @Postcondition:
 *      1) Sets whether we will use declination in our computation.
 */
void compassBearingSetUseDeclination(compassBearing_t * cb, const float useDeclination);

#endif
