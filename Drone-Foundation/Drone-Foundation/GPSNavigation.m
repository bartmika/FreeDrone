//
//  GPSNavigation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "GPSNavigation.h"

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

@implementation GPSNavigation
+(float)distanceBetweenOriginCoord: (GPSCoordinate*) start
                   destinationCoord: (GPSCoordinate*) finish {
    // Algorithm:
    //  Use mathematical formula: "Spherical Law of Cosines"
    
    // Extract the values
    double lat1 = (double)[start latitudeRadians];
    double lat2 = (double)[finish latitudeRadians];
    double lon1 = (double)[start longitudeRadians];
    double lon2 = (double)[finish longitudeRadians];
    
    double R = 6371; // km
    double d = 0, d1, d2;
    d1 = sin(lat1) * sin(lat2);
    d2 = cos(lat1) * cos(lat2) * cos(lon2 - lon1);
    d = d1 + d2;
    d = acos(d) * R;
    
    return (float)d;
}

+(float) bearingBetweenOriginCoord: (GPSCoordinate*) originCoordinate
                   destinationCoord: (GPSCoordinate*) finalCoordinate
{
    // Extract the values
    double lat2 = (double)[originCoordinate latitudeRadians];
    double lat1 = (double)[finalCoordinate latitudeRadians];
    double lon2 = (double)[originCoordinate longitudeRadians];
    double lon1 = (double)[finalCoordinate longitudeRadians];
    float b = 0;
    
    double dLon = lon2 - lon1;
    double y = sin(dLon) * cos(lat2);
    double x = ( cos(lat1) * sin(lat2) ) - ( sin(lat1) * cos(lat2) * cos(dLon) );
    
    b = (float)atan2(y, x);
    b = [GPSFormatter radiansToDegrees: &b];
    
    // Return the reversed.
    return (float)fmod((b + 180.0f), 360.0f); // Degrees
}

+(GPSCoordinate*) midpointBetweenOriginCoord: (GPSCoordinate*) start
                            destinationCoord: (GPSCoordinate*) finish
{
    GPSCoordinate * midpoint = [GPSCoordinate new];
    
    // Extract the values
    double lat1 = (double)[start latitudeRadians];
    double lat2 = (double)[finish latitudeRadians];
    double lon1 = (double)[start longitudeRadians];
    double lon2 = (double)[finish longitudeRadians];
    
    // Make all positive
    lat1 = fabs(lat1);
    lat2 = fabs(lat2);
    lon1 = fabs(lon1);
    lon2 = fabs(lon2);
    
    double Bx = cos(lat2) * cos(lon2 -lon1);
    double By = cos(lat2) * sin(lon2 -lon1);
    
    double lat3a = sin(lat1) + sin(lat2);
    double lat3b = sqrt( (cos(lat1)+Bx)*(cos(lat1)+Bx)+By*By );
    double lat3 = atan2(lat3a, lat3b);
    double lon3 = lon1 + atan2(By, cos(lat1) + Bx);
    
//    midpoint.latitudeDegrees = lat3;
//    midpoint.longitudeDegrees= lon3;
    
    [midpoint setLatitudeRadians: (float)lat3];
    [midpoint setLongitudeRadians: (float)lon3];
    
    return [midpoint autorelease];
}



+(char) turningDirectionFromCurrentBearing: (const float) currentBearing
                            towardsBearing: (const float) bearing
                                 precision: (const float) precision
{
    // This will be the value we return for the function.
    char direction;
    
    double diff = (double)(bearing - currentBearing);
    diff = fabs(diff);
    
    // If the direction we are to turn is a complete 180.0 degrees
    // behind us then we need to either choose left or right and
    // start movig towards the direction.
    if ( diff == 180.0f ) {
        return 'R';
    }
    
    // If the difference between the two angles is lower then the precision
    // then we can simply return 'S' indicating they are similar so go
    // 'straight' for a direction.
    if ( diff <= precision ) {
        return 'S';
    }
    
    // Find the shortest distance between the angles.
    //    if ( diff < 180 ) {
    //        Ds = diff;
    //    } else {
    //        Ds = 360.0f - diff;
    //    }
    
    // Discover which direction to turn
    if ( ( diff < 180 ) && ( bearing > currentBearing ) ) {
        direction = 'R'; // Turn right
    } else if ( ( diff < 180 ) && ( bearing < currentBearing ) ) {
        direction = 'L'; // Turn left
    } else if ( ( diff > 180 ) && ( bearing > currentBearing ) ){
        direction = 'L';
    } else if ( ( diff > 180 ) && ( bearing < currentBearing ) ){
        direction = 'R';
    } else {
        direction = 'S';
    }
    
    return direction;
}

+(GPSCoordinate*) findDestinationCoordFromCoord: (GPSCoordinate*) initialCoord
                                 bearingDegrees: (float) bearing
                             distanceKilometers: (float) distance
{
    double lat1 = (double)[initialCoord latitudeRadians];
    double lon1 = (double)[initialCoord longitudeRadians];
    double angDistance = distance / 6371; // Divide km distance by radius of earth
    bearing = [GPSFormatter degreesToRadians: &bearing];
    
    double tmp = ( sin(lat1) * cos(angDistance) );
    tmp += ( cos(lat1) * sin(angDistance) * cos(bearing) );
    double lat2 = asin( tmp );
    
    double y = sin(bearing) * sin(angDistance) * cos(lat1);
    double x = cos(angDistance) - ( sin(lat1)*sin(lat2) );
    double lon2 = lon1 + atan2(y, x);
    
    // Return our object.
    return [[[GPSCoordinate alloc] initWithLatitudeRadians: (float)lat2
                                         longitudeRadians: (float)lon2] autorelease];
}


+(BOOL) nearByCoord: (GPSCoordinate*) originCoordinate
          withCoord: (GPSCoordinate*) destinationCoord
   distanceInMetres: (float) minDistance
{
    const double distanceInKm = (double)[GPSNavigation distanceBetweenOriginCoord: originCoordinate
                                                                destinationCoord: destinationCoord];
    const double distanceInMetres = distanceInKm * 1000.0f;
    
    if ( distanceInMetres <= minDistance ) {
        return YES;
    } else {
        return NO;
    }
}

@end
