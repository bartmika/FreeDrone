//
//  GPSReceiverData.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-17.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_GPSReceiverData_h
#define Drone_Foundation_GPSReceiverData_h

// Portablility:
//      If we are not running a Apple Mac computer, then we will have to
//      get our Phidget library in a manner that is acceptiable for a UNIX-like
//      operating system.Else, we will load up for a mac computer.
#ifndef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
#include <phidget21.h>
#else
#ifndef PHIDGET_LIBRARY_INCLUDE
#include <Phidget21/phidget21.h>
#define PHIDGET_LIBRARY_INCLUDE
#endif
#endif

// Structure to hold all usefull GPS data we plan on using throughout the
// application and returned by all the GPS devices.
#ifndef GPS_DATA_TYPE_EXISTS
#define GPS_DATA_TYPE_EXISTS
typedef struct _GPSRECEIVERDATA_T{
    GPSDate date;
	GPSTime time;
	float longitude, latitude;
	float heading, speed, altitude;
}gpsReceiverData_t;
#endif

#endif
