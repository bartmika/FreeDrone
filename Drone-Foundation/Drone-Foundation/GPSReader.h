//
//  GPSReader.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "GPSReading.h"
#import "PhidgetGPSReader.h"
#import "GlobalSatBU353GPSReader.h"
#import "HardwareLogging.h"

enum gpsDeviceRunning_t {
    PHIDGET_GPS_READER,
    GLOBALSAT_BU353_GPS_READER,
    NULL_GPS_DEVICE
};

@interface GPSReader : NSObject <GPSReading, HardwareLogging> {
    id gpsReader;
    enum gpsDeviceRunning_t gpsDevice;
}

+(GPSReader*) sharedInstance;

-(void) dealloc;

-(GPSCoordinate*) coordinate;

-(const float) altitude;

-(const float) heading;

-(const float) speed;

-(BOOL) deviceIsOperational;

-(NSDictionary*) pollDeviceForData;

@end
