//
//  GPSCoordinate.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "GPSFormatter.h"

@interface GPSCoordinate : NSObject {
    float latitudeDegrees;
    float longitudeDegrees;
}

@property (atomic) float latitudeDegrees;
@property (atomic) float longitudeDegrees;
-(float) latitudeRadians;
-(float) longitudeRadians;
-(void) setLatitudeRadians: (float) rad;
-(void) setLongitudeRadians: (float) rad;

-(id) init;

-(id) initWithLatitudeDegrees: (float) latitudeDegrees
             longitudeDegrees: (float) longitudeDegrees;

-(id) initWithLatitudeDegreesMinuteSeconds: (dms_t) latdms
            longitudeDegreesMinutesSeconds: (dms_t) londms;

-(id) initWithLatitudeRadians: (float) latitudeRadians
             longitudeRadians: (float) longitudeRadians;

-(void) dealloc;

-(BOOL) equalsGPSCoordinate: (GPSCoordinate *) gpsCoordinate;

-(dms_t) latitudeDegreesMinutesSeconds;

-(dms_t) longitudeDegreesMinutesSeconds;

@end
