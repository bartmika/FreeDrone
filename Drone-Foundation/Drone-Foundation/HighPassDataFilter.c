//
//  HighPassDataFilter.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-18.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//


#include "HighPassDataFilter.h"

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

highPassDataFilter_t * hpdfInit(const float rate, const float freq){
    // Defensive Code: Prevent invalid entries.
    assert(rate != 0 && freq != 0);
    
    highPassDataFilter_t * filter = (highPassDataFilter_t*)malloc(sizeof(highPassDataFilter_t));
    if ( filter == NULL ) {
        perror("malloc"); return NULL;
    } else{
        memset(filter, 0, sizeof(highPassDataFilter_t));
    }
    
    // The dt is how much time elapsed between samples.
    const float dt = 1.0f / rate;
    
    // RC value comes from the electrical low-pass filter, which is made up of
    // a resistor and capacitor. R and C are literally the resistance and
    // capacitance of the circuit, which determine the 'cutoff' frequency that
    // the filter operates on.
    //
    // Simply put, the higher the RC value, the lower the cutoff frequency,
    // which means that more high frequencies get filtered out (or as you said,
    // the more aggressive the filter becomes).
    const float RC = 1.0f / freq;
    
    // The weight average value.
    filter->filterConstant = RC / ( dt + RC );
    
    return filter;
}

void hpdfAdd(highPassDataFilter_t * ptrHpdf,
             const float x1,
             const float y1,
             const float z1){
    assert(ptrHpdf); // Defensive Code: Prevent nulls.
    
    const float alpha = ptrHpdf->filterConstant;
    
    ptrHpdf->x = alpha * ( ptrHpdf->x + x1 - ptrHpdf->lastX );
    ptrHpdf->y = alpha * ( ptrHpdf->y + x1 - ptrHpdf->lastY );
    ptrHpdf->z = alpha * ( ptrHpdf->z + x1 - ptrHpdf->lastZ );
    
    ptrHpdf->lastX = x1;
    ptrHpdf->lastY = y1;
    ptrHpdf->lastZ = z1;
}

void hpdfDealloc(highPassDataFilter_t * ptrHpdf){
    assert(ptrHpdf); // Defensive Code.
    free(ptrHpdf); ptrHpdf = NULL;
}

float hpdfGetConstant(const highPassDataFilter_t * hpdf){
    assert(hpdf);
    return hpdf->filterConstant;
}

point6f_t hpdfGetPoint(const highPassDataFilter_t * hpdf)
{
    assert(hpdf);
    point6f_t point = {hpdf->x, hpdf->y, hpdf->z, hpdf->lastX, hpdf->lastY, hpdf->lastZ};
    return point;
}
