//
//  GPSReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "GPSReader.h"

@implementation GPSReader

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

static GPSReader * sharedGPSReader = nil;

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

+(GPSReader*) sharedInstance {
    @synchronized([GPSReader class])
    {
        if (!sharedGPSReader) {
            sharedGPSReader = [[GPSReader alloc] init];
        }
    }
    
    return sharedGPSReader;
}

+(id) alloc
{
    @synchronized([GPSReader class]){
        sharedGPSReader = [super alloc];
    }
    
    return sharedGPSReader;
}

-(id) init
{
    if (self = [super init]) {
        // Attempt to load up phidgets GPS device, if it fails loading then
        // load up the GlobalSat BU353 GPS device.
        gpsReader = (id)phidgetGPSReaderInit();
        gpsDevice = PHIDGET_GPS_READER;
        
        // Secondly, attempt to load up the BU353 GPS if it didn't load up.
        if (gpsReader == NULL) {
            gpsReader = (id)globalSatBU353GPSReaderInit();
            gpsDevice = GLOBALSAT_BU353_GPS_READER;
        }
        
        // Thirdly, indicate we failed loading a device.
        if (gpsReader == NULL) {
            gpsDevice = NULL_GPS_DEVICE;
        }
        
        return self;
    } else {
        return nil;
    }
}

-(void) dealloc {
    switch (gpsDevice) {
        case PHIDGET_GPS_READER:
            // If our GPS device is a "Phidget" device, then deallocate it.
            phidgetGPSReaderDealloc((phidgetGPSReader_t*)gpsReader);
            break;
        case GLOBALSAT_BU353_GPS_READER:
            globalSatBU353GPSReaderDealloc((globalSatBU353GPSReader_t*)gpsReader);
        default:
            break;
    }
   
    gpsReader = nil;
    [super dealloc];
}

-(GPSCoordinate*) coordinate {
    GPSCoordinate* coordinate=nil;
    @synchronized([GPSReader class])
    {
        // If the device is connected and working then get the coordinate
        // from the hardware. If device is not connected/working, then a
        // default zero coordinates will be returned.
        sdd_t tmp = {};
        
        // Get the GPS coordinate according to the device we're running.
        switch (gpsDevice) {
            case PHIDGET_GPS_READER:
                tmp = gpsReader ? phidgetGPSReaderGetCoordinate((phidgetGPSReader_t*)gpsReader) : tmp;
                break;
            case GLOBALSAT_BU353_GPS_READER:
                tmp = gpsReader ? globalSatBU353GPSReaderGetCoordinate((globalSatBU353GPSReader_t*)gpsReader) : tmp;
                break;
            default:
                NSLog(@"WARNING: Unsupported Device detected\n");
                break;
        }
        
        // Convert the gps coordinate to an objective-c object.
        coordinate = [[GPSCoordinate alloc] initWithLatitudeDegrees: tmp.latitude
                                                   longitudeDegrees: tmp.longitude];
    }
    
    return [coordinate autorelease];
}

-(const float) altitude
{
    // If the device is connected and working then get the altitude
    // from the hardware. If device is not connected/working, then a
    // default zero altitude will be returned.
    float altitude;
    @synchronized([GPSReader class])
    {
        // Get the altitude according to the device we have connected.
        switch (gpsDevice) {
            case PHIDGET_GPS_READER:
                altitude = gpsReader ? phidgetGPSReaderGetAltitude((phidgetGPSReader_t*)gpsReader) : 0.0f;
                break;
            case GLOBALSAT_BU353_GPS_READER:
                altitude = gpsReader ? globalSatBU353GPSReaderGetAltitude((globalSatBU353GPSReader_t*)gpsReader) : 0.0f;
                break;
            default:
                altitude = 0.0f;
                break;
        }
    }
    return altitude;
}

-(const float) heading {
    // If the device is connected and working then get the heading
    // from the hardware. If device is not connected/working, then a
    // default zero heading will be returned.
    float heading;
    @synchronized([GPSReader class])
    {
        switch (gpsDevice) {
            case PHIDGET_GPS_READER:
                heading = gpsReader ? phidgetGPSReaderGetHeading((phidgetGPSReader_t*)gpsReader) : 0.0f;
                break;
            case GLOBALSAT_BU353_GPS_READER:
                heading = gpsReader ? globalSatBU353GPSReaderGetHeading((globalSatBU353GPSReader_t*)gpsReader) : 0.0f;
                break;
            default:
                heading = 0.0f;
                break;
        }
    }
    return heading;
}


-(const float) speed {
    // If the device is connected and working then get the speed
    // from the hardware. If device is not connected/working, then a
    // default zero heading will be returned.
    float speed;
    
    @synchronized([GPSReader class])
    {
        switch (gpsDevice) {
            case PHIDGET_GPS_READER:
                speed = gpsReader ? phidgetGPSReaderGetVelocity((phidgetGPSReader_t*)gpsReader) : 0.0f;
                break;
            case GLOBALSAT_BU353_GPS_READER:
                speed = gpsReader ? globalSatBU353GPSReaderGetSpeed((globalSatBU353GPSReader_t*)gpsReader) : 0.0f;
                break;
            default:
                speed = 0.0f;
                break;
        }
    }
    return speed;
}

-(BOOL) deviceIsOperational {
    BOOL isOperational;
    @synchronized([GPSReader class])
    {
        switch (gpsDevice) {
            case PHIDGET_GPS_READER:
                isOperational = gpsReader ? phidgetGPSReaderIsOperational((phidgetGPSReader_t*)gpsReader) : NO;
                break;
            case GLOBALSAT_BU353_GPS_READER:
                isOperational = gpsReader ? globalSatBU353GPSReaderIsOperational((globalSatBU353GPSReader_t*)gpsReader) : NO;
                break;
            default:
                isOperational = NO;
                break;
        }
    }
    
    return isOperational;
}

-(NSDictionary*) pollDeviceForData {
    NSDictionary * gpsData = nil;
    
    // If the device is connected and working then get the data
    // from the hardware. If device is not connected/working, then a
    // default nill will be returned.
    if (gpsReader == NULL) {
        return nil;
    }
    
    @synchronized([GPSReader class])
    {
        gpsReceiverData_t pollData = {};
        
        // Poll the devices
        switch (gpsDevice) {
            case PHIDGET_GPS_READER:
                pollData = phidgetGPSReaderGetData((phidgetGPSReader_t*)gpsReader);
                break;
            case GLOBALSAT_BU353_GPS_READER:
                pollData = globalSatBU353GPSReaderGetData((globalSatBU353GPSReader_t*)gpsReader);
                break;
            default:
                NSLog(@"Unsupported Device\n");
                break;
        }
        
        // Convert the data from the C langauge to Objective-C type which
        // will be held in memory.
        NSNumber * nsLatitude = [NSNumber numberWithFloat: pollData.latitude];
        NSNumber * nsLongitude = [NSNumber numberWithFloat: pollData.longitude];
        NSNumber * nsHeading = [NSNumber numberWithFloat: pollData.heading];
        NSNumber * nsAltitude = [NSNumber numberWithFloat: pollData.altitude];
        NSNumber * nsSpeed = [NSNumber numberWithFloat: pollData.speed];
        NSNumber * nsDay = [NSNumber numberWithInt: pollData.date.tm_mday];
        NSNumber * nsMonth = [NSNumber numberWithInt: pollData.date.tm_mon];
        NSNumber * nsYear = [NSNumber numberWithInt: pollData.date.tm_year];
        NSNumber * nsHour = [NSNumber numberWithInt: pollData.time.tm_hour];
        NSNumber * nsMin = [NSNumber numberWithInt: pollData.time.tm_min];
        NSNumber * nsMSec = [NSNumber numberWithInt: pollData.time.tm_ms];
        NSNumber * nsSec = [NSNumber numberWithInt: pollData.time.tm_sec];
        
        // Create a array of data and return it.
        //NSArray * gpsData = @[strLatitude, strLongitude, strHeading, strAltitude];
        gpsData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  nsLatitude, @"Latitude",
                                  nsLongitude, @"Longitude",
                                  nsHeading, @"Heading",
                                  nsAltitude, @"Altitude",
                                  nsSpeed, @"Speed",
                                  nsDay, @"Day",
                                  nsMonth, @"Month",
                                  nsYear, @"Year",
                                  nsHour, @"Hour",
                                  nsMin, @"Minute",
                                  nsMSec, @"Millisecond",
                                  nsSec, @"Second",
                                  nil];
    }
    
    return gpsData;
}

@end
