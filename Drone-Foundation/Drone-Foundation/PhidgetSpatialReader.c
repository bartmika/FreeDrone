//
//  PhidgetSpatialReader.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-19.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//


#include "PhidgetSpatialReader.h"

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                     PRIVATE VARIABLES / FUNCTIONS                          //
//----------------------------------------------------------------------------//

//Define data rate to be 32ms
#define dataRate 32

/**
 * @Precondition:
 *      1) "Phidget Spatial 3/3/3 High Res." must be connected to computer.
 *      2) "spatial" must be
 *          - A point to a an object which had the function
 *            "CPhidgetSpatial_create" called upon it.
 *      3) "userptr" can be null
 * @Postcondition:
 *      1) Attaches the device to the program through software library.
 *
 * @Notes:
 *      - Must be called after "CPhidgetSpatial_create" function used.
 */
int CCONV phidgetSpatialReaderAttachHandler(CPhidgetHandle spatial, void *userptr)
{
    // Defensive Code
    assert(userptr);
    
    phidgetSpatialReader_t * ptrReader = (phidgetSpatialReader_t*)userptr;
    
    // Indicate that we are operational.
    ptrReader->isOperational = 1;
    
	return 0;
}

/**
 * @Precondition:
 *      1) "Phidget Spatial 3/3/3 High Res." must be connected to computer.
 *      2) "spatial" must be
 *          - A point to a an object which had the function
 *            "CPhidgetSpatial_create" called upon it.
 *      3) "userptr" can be null
 * @Postcondition:
 *      1) Detaches the device from the program through software library.
 *
 * @Notes:
 *      - Must be called after "AttachHandler" function used.
 */
int CCONV phidgetSpatialReaderDetachHandler(CPhidgetHandle spatial, void *userptr)
{
    assert(userptr); // Defensive Code
    
    phidgetSpatialReader_t * ptrReader = (phidgetSpatialReader_t*)userptr;
    
    // Indicate that we are no longer operational.
    ptrReader->isOperational = 0;
    
	return 0;
}

/**
 * @Precondition:
 *      1) "Phidget Spatial 3/3/3 High Res." must be connected to computer.
 *      2) "spatial" must be
 *          - A point to a an object which had the function
 *            "CPhidgetSpatial_create" called upon it.
 *      3) "userptr" can be null
 * @Postcondition:
 *      1) Attaches error handling to the  device through the software library.
 *
 * @Notes:
 *      - Must be called after "DetachHandler" function used.
 */
int CCONV phidgetSpatialReaderErrorHandler(CPhidgetHandle spatial,
                                           void *userptr,
                                           int ErrorCode,
                                           const char *unknown)
{
    phidgetSpatialReader_t * ptrReader = (phidgetSpatialReader_t*)userptr;
    
	printf("Error handled. %d - %s \n", ErrorCode, unknown);
    ptrReader->isOperational = 0; // Indicate we've encountered an error.
	return 0;
}

//callback that will run at datarate
//data - array of spatial event data structures that holds the spatial data packets that were sent in this event
//count - the number of spatial data event packets included in this event
int CCONV SpatialDataHandler(CPhidgetSpatialHandle spatial, void *userptr, CPhidgetSpatial_SpatialEventDataHandle *data, int count)
{
    assert(userptr); // Defensive Code.
    assert(spatial);
    assert(data);
    
    phidgetSpatialReader_t * ptrReader = (phidgetSpatialReader_t*)userptr;
    
	int i;
	for( i = 0; i < count; i++ ) {
        lpdfAdd(ptrReader->acc_filter,
                data[i]->acceleration[0],
                data[i]->acceleration[1],
                data[i]->acceleration[2]);
        
        lpdfAdd(ptrReader->ang_filter,
                data[i]->angularRate[0],
                data[i]->angularRate[1],
                data[i]->angularRate[2]);
        
        // Only update if there is a magnetic field.
        if (data[i]->magneticField[0] != PUNK_DBL) {
            lpdfAdd(ptrReader->mag_filter,
                    data[i]->magneticField[0],
                    data[i]->magneticField[1],
                    data[i]->magneticField[2]);
        }
        
        ptrReader->timestamp = data[i]->timestamp.seconds;
        ptrReader->utimestamp= data[i]->timestamp.microseconds;
	}
    
	return 0;
}

//Display the properties of the attached phidget to the screen.
//We will be displaying the name, serial number, version of the attached device, the number of accelerometer, gyro, and compass Axes, and the current data rate
// of the attached Spatial.
int phidgetSpatialReaderSetup(CPhidgetHandle phid, phidgetSpatialReader_t * ptrReader)
{
    assert(phid); // Defensive Code
    assert(ptrReader);
    
	int serialNo, version;
	const char* ptr;
	int numAccelAxes, numGyroAxes, numCompassAxes, dataRateMax, dataRateMin;
    
	CPhidget_getDeviceType(phid, &ptr);
	CPhidget_getSerialNumber(phid, &serialNo);
	CPhidget_getDeviceVersion(phid, &version);
	CPhidgetSpatial_getAccelerationAxisCount((CPhidgetSpatialHandle)phid, &numAccelAxes);
	CPhidgetSpatial_getGyroAxisCount((CPhidgetSpatialHandle)phid, &numGyroAxes);
	CPhidgetSpatial_getCompassAxisCount((CPhidgetSpatialHandle)phid, &numCompassAxes);
	CPhidgetSpatial_getDataRateMax((CPhidgetSpatialHandle)phid, &dataRateMax);
	CPhidgetSpatial_getDataRateMin((CPhidgetSpatialHandle)phid, &dataRateMin);
    
    ptrReader->ptr = ptr;;
    ptrReader->serialNo = serialNo;
    ptrReader->version = version;
    ptrReader->numAccelAxes = numAccelAxes;
    ptrReader->numGyroAxes = numGyroAxes;
    ptrReader->numCompassAxes = numGyroAxes;
    ptrReader->dataRateMax = dataRateMax;
    ptrReader->dataRateMin = dataRateMin;
    
	return 0;
}

spatialData_t spatialReaderGetZero(){
    spatialData_t data = {};
    return data;
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

phidgetSpatialReader_t * phidgetSpatialReaderInit(){
    // Alloc
    //-------
    phidgetSpatialReader_t * ptrReader = (phidgetSpatialReader_t*)
    malloc(sizeof(phidgetSpatialReader_t));
    
    if (ptrReader==NULL) {
        perror("malloc");
        exit(EXIT_FAILURE);
    } else {
        memset(ptrReader, 0, sizeof(phidgetSpatialReader_t));
    }
    
    // Init
    //-------
	// Create the objects which will communicate with the hardware.
    // This object communicates with the onboard 3 spatial devices
	CPhidgetSpatial_create(&(ptrReader->spatial));
    // This object provides more generic communication with the usb device.
    ptrReader->handler = (CPhidgetHandle)ptrReader->spatial;
    
    // Callback that will run if the Spatial is attached to the computer
	CPhidget_set_OnAttach_Handler(ptrReader->handler,
                                  phidgetSpatialReaderAttachHandler,
                                  ptrReader);
	
    // Callback that will run if the Spatial is detached from the computer
    CPhidget_set_OnDetach_Handler(ptrReader->handler,
                                  phidgetSpatialReaderDetachHandler,
                                  ptrReader);
	
    // Callback that will run if the Spatial generates an error
    CPhidget_set_OnError_Handler(ptrReader->handler,
                                 phidgetSpatialReaderErrorHandler,
                                 ptrReader);
    
    //Registers a callback that will run according to the set data rate that will return the spatial data changes
	//Requires the handle for the Spatial, the callback handler function that will be called,
	//and an arbitrary pointer that will be supplied to the callback function (may be NULL)
	CPhidgetSpatial_set_OnSpatialData_Handler(ptrReader->spatial,
                                              SpatialDataHandler,
                                              ptrReader);
    
    //open the spatial object for device connections
	CPhidget_open(ptrReader->handler, -1);
    
    // Wait until the device is connected
    ptrReader->result =
    CPhidget_waitForAttachment(ptrReader->handler, 10000);
	
    if(ptrReader->result) // If anything bad happend when we wher waiting...
	{
		CPhidget_getErrorDescription(ptrReader->result,
                                     &(ptrReader->err));
		printf("SPATIAL: Problem waiting for attachment: %s\n", ptrReader->err);
		
        free(ptrReader);
        ptrReader = NULL;
        return NULL;
	}
    
    //Set the data rate for the spatial events
	CPhidgetSpatial_setDataRate(ptrReader->spatial, 16);
    
    //Display the properties of the attached spatial device
	phidgetSpatialReaderSetup(ptrReader->handler, ptrReader);
    
    sleep(2);
    ptrReader->isOperational = 1; // Indicating our device is running.
    
    // If we are to do filtering
    ptrReader->acc_filter = lpdfInit(1000.0/dataRate, 7.5);
    ptrReader->ang_filter = lpdfInit(1000.0/dataRate, 7.5);
    ptrReader->mag_filter = lpdfInit(1000.0/dataRate, 7.5);
    ptrReader->bearing = compassBearingInit(1000.00/dataRate, 15);
    
    sleep(1); // Give time for numbers to build up.
    
    return ptrReader;
}


void phidgetSpatialReaderDealloc(phidgetSpatialReader_t * ptrReader){
    if ( ptrReader ) {
        lpdfDealloc(ptrReader->acc_filter);
        ptrReader->acc_filter = NULL;
        lpdfDealloc(ptrReader->mag_filter);
        ptrReader->mag_filter = NULL;
        lpdfDealloc(ptrReader->ang_filter);
        ptrReader->ang_filter = NULL;
        compassBearingDealloc(ptrReader->bearing);
        ptrReader->bearing = NULL;
        
        // Stops the device.
        CPhidget_close(ptrReader->handler);
        
        // Terimates the connection.
        CPhidget_delete(ptrReader->handler);
        
        free(ptrReader); ptrReader = NULL;
    }
}


spatialData_t phidgetSpatialReaderGetData(phidgetSpatialReader_t * ptrReader){
    // Defensive Code: Prevent non-instantiated object function calls.
    if ( ptrReader == NULL ) { return spatialReaderGetZero(); }
    
    spatialData_t data = {};
    
    // Return our low pass filter results.
    data.acc.x = ptrReader->acc_filter->x;
    data.acc.y = ptrReader->acc_filter->y;
    data.acc.z = ptrReader->acc_filter->z;
    data.ang.x = ptrReader->ang_filter->x;
    data.ang.y = ptrReader->ang_filter->y;
    data.ang.z = ptrReader->ang_filter->z;
    data.mag.x = ptrReader->mag_filter->x;
    data.mag.y = ptrReader->mag_filter->y;
    data.mag.z = ptrReader->mag_filter->z;
    
    data.timestamp = ptrReader->timestamp;
    data.utimestamp= ptrReader->utimestamp;
    
    // Set our variables for the compass.
    compassBearingSetData(ptrReader->bearing,
                          data.acc.x,
                          data.acc.y,
                          data.acc.z,
                          data.mag.x,
                          data.mag.y,
                          data.mag.z);
    
    // Generate our compass bearing from the data.
    compassBearingCompute(ptrReader->bearing);
    data.compassHeading = ptrReader->bearing->bearingDegrees;
    
    //data.rot = ptrReader->bearing->
    return data;
}


const unsigned int phidgetSpatialReaderIsOperationial(phidgetSpatialReader_t * ptrReader){
    if ( ptrReader ) { // Defensive Code
        return ptrReader->isOperational;
    } else {
        return 0;
    }
}

acceleration_t phidgetSpatialReaderGetAccelerameter(const phidgetSpatialReader_t * ptrReader) {
    acceleration_t acc = {ptrReader->acc_filter->x, ptrReader->acc_filter->y, ptrReader->acc_filter->z};
    return acc;
}

angularRotation_t phidgetSpatialReaderGetGyroscope(const phidgetSpatialReader_t * ptrReader) {
    angularRotation_t ang = {ptrReader->ang_filter->x, ptrReader->ang_filter->y, ptrReader->ang_filter->z};
    return ang;
}

magneticField_t phidgetSpatialReaderGetCompass(const phidgetSpatialReader_t * ptrReader) {
    magneticField_t mag = {ptrReader->mag_filter->x, ptrReader->mag_filter->y, ptrReader->mag_filter->z};
    return mag;
}

float phidgetSpatialReaderGetTimestamp(const phidgetSpatialReader_t * ptrReader) {
    return ptrReader->timestamp;
}

float phidgetSpatialReaderGetUTimestamp(const phidgetSpatialReader_t * ptrReader) {
    return ptrReader->utimestamp;
}

float phidgetSpatialReaderGetCompassBearing(const phidgetSpatialReader_t * ptrReader){
    return ptrReader->bearing->bearingDegrees;
}

rotation_t phidgetSpatialReaderGetAnglesOfRotation(const phidgetSpatialReader_t * ptrReader){
    rotation_t rot = {0,0,0};
    rot.pitch = ( ptrReader->bearing->pitchAngle * 180 ) / M_PI;
    rot.roll = ( ptrReader->bearing->rollAngle * 180 ) / M_PI;
    rot.yaw = ( ptrReader->bearing->yawAngle * 180 ) / M_PI;
    return rot;
}

