//
//  HighPassDataFilter.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-18.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_HighPassDataFilter_h
#define Drone_Foundation_HighPassDataFilter_h


#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _POINT6f_T{
    float x1, y1, z1;
    float x2, y2, z2;
}point6f_t;

typedef struct _HIGHPASSDATAFILTER_T{
    float x, y, z;
    float filterConstant;
    float lastX, lastY, lastZ;
}highPassDataFilter_t;

/**
 * @Precondition:
 *      1) Enough memory available in our computer.
 *      2) "rate" must be a non-zero number.
 *      3) "cutoffFrequency" must be a non-zero number.
 * @Postcondition:
 */
highPassDataFilter_t * hpdfInit(const float rate, const float cutoffFrequency);

/**
 * @Precondition:
 *      1) "hpdf" is an instantiated object of "HighPassDataFilter" type.
 *      2) "x", "y", and "z" are valid numbers.
 * @Postcondition:
 *      1) Add the data to our filter.
 */
void hpdfAdd(highPassDataFilter_t * hpdf, const float x, const float y, const float z);

/**
 * @Precondition:
 *      1) "hpdf" is an instantiated object of "HighPassDataFilter" type.
 * @Postcondition:
 *      1) Deallocates the intantiated object and associated memory gets freed.
 */
void hpdfDealloc(highPassDataFilter_t * hpdf);

float hpdfGetConstant(const highPassDataFilter_t * hpdf);

point6f_t hpdfGetPoint(const highPassDataFilter_t * hpdf);

#endif
