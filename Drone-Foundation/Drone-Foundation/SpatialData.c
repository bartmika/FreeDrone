//
//  SpatialData.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-19.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//


#include "SpatialData.h"

const unsigned int spatialEqualsSpatial(const spatialData_t *ptrSearch,
                                        const spatialData_t *ptrTarget){
    if (ptrSearch->acc.x == ptrTarget->acc.x &&
        ptrSearch->acc.y == ptrTarget->acc.y &&
        ptrSearch->acc.z == ptrTarget->acc.z &&
        ptrSearch->ang.x == ptrTarget->ang.x &&
        ptrSearch->ang.y == ptrTarget->ang.y &&
        ptrSearch->ang.z == ptrTarget->ang.z &&
        ptrSearch->mag.x == ptrTarget->mag.x &&
        ptrSearch->mag.y == ptrTarget->mag.y &&
        ptrSearch->mag.z == ptrTarget->mag.z &&
        ptrSearch->compassHeading==ptrTarget->compassHeading) {
        return 1;
    }else{
        return 0;
    }
}

const float spatial2tilt(const spatialData_t input){
    // tilt = 180/3.14 * (asin(data$Accel_X) + asin(data$Accel_Y))
    float tilt = 180.0 / 3.14;
    tilt *= (asin(input.acc.x) + asin(input.acc.y));
    
    return tilt;
}
