//
//  LowPassDataFilter.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-18.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//


#include "LowPassDataFilter.h"


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

lowPassDataFilter_t * lpdfInit(const float rate, const float freq){
    // Defensive Code: Prevent invalid entries.
    assert(rate != 0 && freq != 0);
    
    lowPassDataFilter_t * filter = (lowPassDataFilter_t*)malloc(sizeof(lowPassDataFilter_t));
    if ( filter == NULL ) {
        perror("malloc"); return NULL;
    } else {
        memset(filter, 0, sizeof(lowPassDataFilter_t));
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
    
    // Alpha Value.
    filter->filterConstant = dt / (dt + RC);
    
    return filter;
}

void lpdfAdd(lowPassDataFilter_t * ptrLpdf,
             const float x1,
             const float y1,
             const float z1){
    if ( ptrLpdf == NULL ) {
        return;
    }
    //assert(ptrLpdf); // Defensive Code: Prevent null and uninstantiated object.
    
    // The alpha value determines exactly how much weight to give the previous
    // data vs the raw data.
    const float alpha = ptrLpdf->filterConstant;
    
    // It’s basically a weighted average: some of the data is from the
    // previously filtered value, and some of the data is from the raw stream.
    ptrLpdf->x = x1 * alpha + ptrLpdf->x * (1.0 - alpha);
    ptrLpdf->y = y1 * alpha + ptrLpdf->y * (1.0 - alpha);
    ptrLpdf->z = z1 * alpha + ptrLpdf->z * (1.0 - alpha);
}

void lpdfDealloc(lowPassDataFilter_t * ptrLpdf){
    assert(ptrLpdf); // Defensive Code: Prevent null and uninstantiated object.
    free(ptrLpdf); ptrLpdf = NULL;
}


float lpdfGetConstant(const lowPassDataFilter_t * ptrLpdf){
    assert(ptrLpdf);
    return ptrLpdf->filterConstant;
}

point3f_t lpdfGetPoint(const lowPassDataFilter_t * ptrLpdf)
{
    assert(ptrLpdf);
    point3f_t point = {ptrLpdf->x, ptrLpdf->y, ptrLpdf->z};
    return point;
}


