//
//  GlobalSatBU353GPSReader.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#include "GlobalSatBU353GPSReader.h"

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                     PRIVATE VARIABLES / FUNCTIONS                          //
//----------------------------------------------------------------------------//

// Define
#ifdef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
#define kGlobalSatBU353GPSReceiverDevice "/dev/cu.usbserial" // Mac
#else
#define kGlobalSatBU353GPSReceiverDevice "/dev/ttyUSB0"      // Raspberry Pi
#endif
#define kGlobalSatBU353GPSReceiverBaud 4800

void * decoderServiceLoopThread(void* threadid) {
    // Give a name to this thread if we are using the mac computer.
    // (Note: Reason is because it makes debugging easier)
#ifdef __APPLE__
    pthread_setname_np("GPSDecodingServiceLoop"); // For GDB.
#endif
    
    // Convert the parameter into an access point into our object.
    globalSatBU353GPSReader_t * ptrDriver = (globalSatBU353GPSReader_t*)threadid;
    
    // Variables used for storing our strings.
    const size_t bufferLen = 255; // Maximum string length size.
    char buffer[bufferLen] = {}; // Variable where we'll store our temporary string.
    
    // Keep polling our GPS hardware until it produces results which
    // we can process, then store it and keep processing.
    while (!ptrDriver->shutdown) {
        // Get our string data.
        ttyrRead(ptrDriver->gpsReader, buffer, bufferLen);
        
        // Apply the NMEA183 protocol to the NMEA183 string and convert it into a
        // readable form for our application.
        nmea183Decode(ptrDriver->protocol, buffer);
        
        // Detect Longitude & Latitude decoder
        if (nmea183GetMessageTypeOfCurrentDecode(ptrDriver->protocol) == GGA) {
            // Lock the current service loop and store the gps coordinate
            // and then unlock it.
            detachedThreadLock(ptrDriver->gpsDecoderServiceLoopThread);
            ptrDriver->coordinate = nmea183ToGPSCoords(ptrDriver->protocol);
            detachedThreadUnlock(ptrDriver->gpsDecoderServiceLoopThread);
        }
        //TODO: Add more decoders!
        
        // Defensive Code:
        // Artifically delay the current thread so our get coordinates function
        // doesn't get hammered by the outside function.
        detachedThreadPOSIXSleep(1, 0);
    }
    
    
    pthread_exit((void *)threadid); // Terminate our thread
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//
globalSatBU353GPSReader_t * globalSatBU353GPSReaderInit(){
    // Allocate Memory
    globalSatBU353GPSReader_t * ptrDriver =
        (globalSatBU353GPSReader_t*)malloc(sizeof(globalSatBU353GPSReader_t));
    
    // Initialize Object.
    if ( ptrDriver ) {
        memset(ptrDriver, 0, sizeof(globalSatBU353GPSReader_t));
        
        // Initialize the hardware abstraction layer which will communicate
        // with the BU353 GPS device.
        ptrDriver->gpsReader = ttyrInit(kGlobalSatBU353GPSReceiverDevice,
                                        kGlobalSatBU353GPSReceiverBaud,
                                        "\r\n");
        
        // Load up the interpreter that will decode the GPS signal and
        // convert them to a readable form.
        ptrDriver->protocol = nmea183Init();
                
        // Create the thread which will run in the background reading string
        // entries passed to it by the serial console and decoding the data
        // to be used for our purposes.
        ptrDriver->gpsDecoderServiceLoopThread =
                detachedThreadInit(decoderServiceLoopThread, ptrDriver);
        detachedThreadStart(ptrDriver->gpsDecoderServiceLoopThread);
        
        // Warm up the GPS device by attempting to keep get a few results until
        // the GPS finally returns valid data.
        detachedThreadPOSIXSleep(5, 0);
        
        return ptrDriver;
    } else {
        perror("malloc");
        return NULL;
    }
}

sdd_t globalSatBU353GPSReaderGetCoordinate(globalSatBU353GPSReader_t * ptrDriver){
    assert(ptrDriver);
    assert(ptrDriver->gpsReader);
    assert(ptrDriver->protocol);
    
    detachedThreadLock(ptrDriver->gpsDecoderServiceLoopThread);
    gps_t gps = ptrDriver->coordinate;
    detachedThreadUnlock(ptrDriver->gpsDecoderServiceLoopThread);
    
    // Convert into SDD format and return the results.
    return gps2sdd(&gps);
}


float globalSatBU353GPSReaderGetAltitude(globalSatBU353GPSReader_t * ptrDriver) {
    assert(ptrDriver);
    detachedThreadLock(ptrDriver->gpsDecoderServiceLoopThread);
    float altitude = ptrDriver->altitude;
    detachedThreadUnlock(ptrDriver->gpsDecoderServiceLoopThread);
    return altitude;
}

float globalSatBU353GPSReaderGetHeading(globalSatBU353GPSReader_t * ptrDriver) {
    assert(ptrDriver);
    detachedThreadLock(ptrDriver->gpsDecoderServiceLoopThread);
    float heading = ptrDriver->heading;
    detachedThreadUnlock(ptrDriver->gpsDecoderServiceLoopThread);
    return heading;
}

float globalSatBU353GPSReaderGetSpeed(globalSatBU353GPSReader_t * ptrDriver) {
    assert(ptrDriver);
    detachedThreadLock(ptrDriver->gpsDecoderServiceLoopThread);
    float speed = ptrDriver->speed;
    detachedThreadUnlock(ptrDriver->gpsDecoderServiceLoopThread);
    return speed;
}

unsigned int globalSatBU353GPSReaderIsOperational(globalSatBU353GPSReader_t * ptrDriver) {
    assert(ptrDriver);
    detachedThreadLock(ptrDriver->gpsDecoderServiceLoopThread);
    unsigned int operational = ptrDriver->operational && !ptrDriver->shutdown;
    detachedThreadUnlock(ptrDriver->gpsDecoderServiceLoopThread);
    return operational;
}


gpsReceiverData_t globalSatBU353GPSReaderGetData(globalSatBU353GPSReader_t * ptrDriver) {
    assert(ptrDriver);
    detachedThreadLock(ptrDriver->gpsDecoderServiceLoopThread);
    gpsReceiverData_t data = {};
    
    //TODO: Impl.
    
    detachedThreadUnlock(ptrDriver->gpsDecoderServiceLoopThread);
    return data;
}

void globalSatBU353GPSReaderDealloc(globalSatBU353GPSReader_t * ptrDriver){
    assert(ptrDriver);
    
    // Stop, shutdown and dealloc the running thread.
    ptrDriver->shutdown = 1; // Indicate we are shutting down.
    detachedThreadLock(ptrDriver->gpsDecoderServiceLoopThread);
    detachedThreadUnlock(ptrDriver->gpsDecoderServiceLoopThread);
    detachedThreadDealloc(ptrDriver->gpsDecoderServiceLoopThread);
    ptrDriver->gpsDecoderServiceLoopThread = NULL;
    
    // Perform the remainder of the memory management.
    ttyrDealloc(ptrDriver->gpsReader);
    ptrDriver->gpsReader = NULL;
    nmea183Dealloc(ptrDriver->protocol);
    ptrDriver->protocol = NULL;
    free(ptrDriver);
    ptrDriver = NULL;
}
