//
//  CompassBearing.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-19.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#include "CompassBearing.h"

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

void normalize(float vect[4][2])
{
	float length = sqrt(vect[1][1]*vect[1][1]+vect[2][1]*vect[2][1]+vect[3][1]*vect[3][1]);
	vect[1][1]/=length;
	vect[2][1]/=length;
	vect[3][1]/=length;
}

//C will be rows1 x cols2
void crossProduct(float *A, float *B, float *C, int rows1, int cols1, int rows2, int cols2)
{
	int i,j,k;
	
    if (cols1 != rows2)
	{
        printf("Inner matrix dimensions must agree.");
		return;
	}
	
    for (i = 1; i <= rows1; i++)
    {
        for (j = 1; j <= cols2; j++)
        {
			*(C + i*(cols2+1) + j) = 0;
            for (k = 1; k <= cols1; k++)
            {
				*(C + i*(cols2+1) + j) += *(A + i*(cols1+1) + k) * *(B + k*(cols2+1) + j);
            }
        }
    }
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

compassBearing_t *compassBearingInit(const float rate, const float freq){
    assert(rate); // Defensive Code: Prevent division by zero.
    assert(freq);
    
    compassBearing_t * bearing = (compassBearing_t*)malloc(sizeof(compassBearing_t));
    if ( bearing == NULL ) {
        perror("malloc");
        return NULL;
    } else {
        memset(bearing, 0, sizeof(compassBearing_t));
    }
    
    const float dt = 1.0f / rate;
	const float RC = 1.0f / freq;
	bearing->filterConstant = dt / ( dt + RC );
    
    return bearing;
}

void compassBearingDealloc(compassBearing_t * ptrCompassBearing){
    assert(ptrCompassBearing);
    free(ptrCompassBearing);
    ptrCompassBearing = NULL;
}


void compassBearingSetSampleRate(compassBearing_t * ptrCompassBearing,
                                 const float rate,
                                 const float freq){
    assert(ptrCompassBearing);
    assert(rate != 0);
    assert(freq != 0);
    const float dt = 1.0 / rate;
    const float RC = 1.0 / freq;
    ptrCompassBearing->filterConstant = dt / (dt + RC);
}

void compassBearingSetDeclination(compassBearing_t * ptrCompassBearing,
                                  const float declination){
    assert(ptrCompassBearing);
    ptrCompassBearing->declination = declination * M_PI/180.0; //store in rads
}

void compassBearingSetUseDeclination(compassBearing_t * ptrCompassBearing,
                                     const float useDeclination){
    assert(ptrCompassBearing);
    ptrCompassBearing->useDeclination = useDeclination;
}

void compassBearingSetData(compassBearing_t * ptrCompassBearing,
                           const float ax,
                           const float ay,
                           const float az,
                           const float cx,
                           const float cy,
                           const float cz){
    assert(ptrCompassBearing); // Defensive Code: Prevent nulls.
    ptrCompassBearing->ax = ax;
    ptrCompassBearing->ay = ay;
    ptrCompassBearing->az = az;
    
    ptrCompassBearing->cx = cx;
    ptrCompassBearing->cy = cy;
    ptrCompassBearing->cz = cz;
}

//This finds a bearing, correcting for board tilt and roll as measured by the accelerometer
//This doesn't account for dynamic acceleration - ie accelerations other then gravity will throw off the calculation
// but we can help by feeding it low-pass filtered data
float compassBearingCompute(compassBearing_t * ptrCompassBearing){
    assert(ptrCompassBearing);    // Defensive Code: Prevent nulls
    
    float Xh = 0;
	float Yh = 0;
	
	//find the tilt of the board wrt gravity
	float gravity[4][2] = {};
	gravity[1][1] = ptrCompassBearing->ax;
	gravity[2][1] = ptrCompassBearing->az;
	gravity[3][1] = ptrCompassBearing->ay;
	normalize(gravity);
	
	float pitchAngle = asin(gravity[1][1]);
	float rollAngle = asin(gravity[3][1]);
	float yawAngle = atan2(ptrCompassBearing->cz * sin(rollAngle) - ptrCompassBearing->cy * cos(rollAngle) ,
                           ptrCompassBearing->cx + cos(pitchAngle) +
                           ptrCompassBearing->cy * sin(pitchAngle) * sin(rollAngle) +
                           ptrCompassBearing->cz * sin(pitchAngle) * cos(rollAngle)
                           );
    
	//The board is up-side down
	if (gravity[2][1] < 0)
	{
		pitchAngle = -pitchAngle;
		rollAngle = -rollAngle;
	}
	
	//Construct a rotation matrix for rotating vectors measured in the body frame, into the earth frame
	//this is done by using the angles between the board and the gravity vector.
	float xRotMatrix[4][4] = {};
	xRotMatrix[1][1] = cos(pitchAngle); xRotMatrix[2][1] = -sin(pitchAngle); xRotMatrix[3][1] = 0;
	xRotMatrix[1][2] = sin(pitchAngle); xRotMatrix[2][2] = cos(pitchAngle); xRotMatrix[3][2] = 0;
	xRotMatrix[1][3] = 0; xRotMatrix[2][3] = 0; xRotMatrix[3][3] = 1;
	
	float zRotMatrix[4][4] = {};
	zRotMatrix[1][1] = 1; zRotMatrix[2][1] = 0; zRotMatrix[3][1] = 0;
	zRotMatrix[1][2] = 0; zRotMatrix[2][2] = cos(rollAngle); zRotMatrix[3][2] = -sin(rollAngle);
	zRotMatrix[1][3] = 0; zRotMatrix[2][3] = sin(rollAngle); zRotMatrix[3][3] = cos(rollAngle);
	
	float rotMatrix[4][4] = {};
	crossProduct((float *)xRotMatrix, (float *)zRotMatrix, (float *)rotMatrix, 3, 3, 3, 3);
	
	//These represent the x and y components of the magnetic field vector in the earth frame
	Xh = -(rotMatrix[1][3] * ptrCompassBearing->cx + rotMatrix[2][3] * ptrCompassBearing->cz + rotMatrix[3][3] * -(ptrCompassBearing->cy));
	Yh = -(rotMatrix[1][1] * ptrCompassBearing->cx + rotMatrix[2][1] * ptrCompassBearing->cz + rotMatrix[3][1] * -(ptrCompassBearing->cy));
	
	//we use the computed X-Y to find a magnetic North bearing in the earth frame
	float _360inRads = (360 * M_PI / 180.0);
    
    // Note: If we don't initialize to '0.0f' then we get an xcode analyzer
    // warning saying: "The left operand of '!=' is a garbage value"
	float newBearing = 0.0f;
	if (Xh < 0)
		newBearing = M_PI - atan(Yh / Xh);
	else if (Xh > 0 && Yh < 0)
		newBearing = -atan(Yh / Xh);
	else if (Xh > 0 && Yh > 0)
		newBearing = M_PI * 2 - atan(Yh / Xh);
	else if (Xh == 0 && Yh < 0)
		newBearing = M_PI / 2.0;
	else if (Xh == 0 && Yh > 0)
		newBearing = M_PI * 1.5;
	
	//The board is up-side down
	if (gravity[2][1] < 0)
	{
		newBearing = fabs(newBearing - _360inRads);
	}
	
	//Add in declination
	if(ptrCompassBearing->useDeclination)
	{
		newBearing = (newBearing + ptrCompassBearing->declination);
		if(newBearing > _360inRads)
			newBearing -= _360inRads;
		if(newBearing < 0)
			newBearing += _360inRads;
	}
	
	if (fabs(newBearing - ptrCompassBearing->bearing) > 2) //2 radians == ~115 degrees
	{
		if(newBearing > ptrCompassBearing->bearing)
			ptrCompassBearing->bearing += _360inRads;
		else
			ptrCompassBearing->bearing -= _360inRads;
	}
	
	ptrCompassBearing->bearing = newBearing * ptrCompassBearing->filterConstant + ptrCompassBearing->bearing * (1.0 - ptrCompassBearing->filterConstant);
	
	ptrCompassBearing->bearingDegrees = ptrCompassBearing->bearing * (180.0 / M_PI);
    
    ptrCompassBearing->pitchAngle = pitchAngle;
    ptrCompassBearing->rollAngle = rollAngle;
    ptrCompassBearing->yawAngle = yawAngle;
    
    return ptrCompassBearing->bearingDegrees;
}
