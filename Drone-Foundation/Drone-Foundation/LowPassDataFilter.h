//
//  LowPassDataFilter.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-18.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_LowPassDataFilter_h
#define Drone_Foundation_LowPassDataFilter_h


#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _POINT3F_t{
    float x;
    float y;
    float z;
}point3f_t;

typedef struct _LOWPASSDATAFILTER_T{
    float x, y, z;
    float filterConstant;
    
}lowPassDataFilter_t;

/**
 * @Precondition:
 *      1) Enough memory available in our computer.
 *      2) "rate" must be a non-zero number.
 *      3) "cutoffFrequency" must be a non-zero number.
 * @Postcondition:
 *      1) Instantiated object.
 *      2) Returns pointer to object.
 */
lowPassDataFilter_t * lpdfInit(const float rate, const float cutoffFrequency);

/**
 * @Precondition:
 *      1) "lpdf" is an instantiated object of "LowPassDataFilter" type.
 *      2) "x", "y", and "z" are valid numbers.
 * @Postcondition:
 *      1) Add the data to our filter.
 */
void lpdfAdd(lowPassDataFilter_t * lpdf,
             const float x,
             const float y,
             const float z);

/**
 * @Precondition:
 *      1) "lpdf" is an instantiated object of "LowPassDataFilter" type.
 * @Postcondition:
 *      1) Deallocates the intantiated object and associated memory gets freed.
 */
void lpdfDealloc(lowPassDataFilter_t * lpdf);

float lpdfGetConstant(const lowPassDataFilter_t * ptrLpdf);

point3f_t lpdfGetPoint(const lowPassDataFilter_t * ptrLpdf);

#endif
