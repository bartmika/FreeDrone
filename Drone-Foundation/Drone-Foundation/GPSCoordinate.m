//
//  GPSCoordinate.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "GPSCoordinate.h"

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

@implementation GPSCoordinate

@synthesize latitudeDegrees;
@synthesize longitudeDegrees;


-(void) setLatitudeRadians: (float) longitudeRadians
{
    latitudeDegrees = [GPSFormatter radiansToDegrees: &longitudeRadians];
}
-(void) setLongitudeRadians: (float) longitudeRadians
{
    longitudeDegrees = [GPSFormatter radiansToDegrees: &longitudeRadians];
}

-(id) init {
    self = [super init];
    if (self) {
        latitudeDegrees = 0.0f;
        longitudeDegrees = 0.0f;
    }
    
    return self;
}

-(id) initWithLatitudeDegrees: (float) inputlatitudeDegrees
             longitudeDegrees: (float) inputlongitudeDegrees
{
    self = [super init];
    if (self) {
        latitudeDegrees = inputlatitudeDegrees;
        longitudeDegrees = inputlongitudeDegrees;
    }
    
    return self;
}

-(id) initWithLatitudeDegreesMinuteSeconds:(dms_t)latdms
            longitudeDegreesMinutesSeconds:(dms_t)londms
{
    self = [super init];
    
    if (self) {
        latitudeDegrees = [GPSFormatter degreesMinutesSecondsToDegrees: &latdms];
        longitudeDegrees = [GPSFormatter degreesMinutesSecondsToDegrees: &londms];
    }
    
    return self;
}


-(id) initWithLatitudeRadians: (float) latitudeRadians
             longitudeRadians: (float) longitudeRadians
{
    self = [super self];
    if (self) {
        latitudeDegrees = [GPSFormatter radiansToDegrees: &latitudeRadians];
        longitudeDegrees = [GPSFormatter radiansToDegrees: &longitudeRadians];
    }
    
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(BOOL) equalsGPSCoordinate: (GPSCoordinate *) gpsCoordinate {
    if (gpsCoordinate) {
        if ( [gpsCoordinate latitudeDegrees] == latitudeDegrees && [gpsCoordinate longitudeDegrees] == longitudeDegrees ) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}


-(dms_t) latitudeDegreesMinutesSeconds {
    return [GPSFormatter degreesToDegreesMinutesSeconds: &latitudeDegrees];
}

-(dms_t) longitudeDegreesMinutesSeconds
{
    return [GPSFormatter degreesToDegreesMinutesSeconds: &longitudeDegrees];
}

-(float) latitudeRadians
{
    return [GPSFormatter degreesToRadians: &latitudeDegrees];
}

-(float) longitudeRadians
{
    return [GPSFormatter degreesToRadians: &longitudeDegrees];
}

@end
