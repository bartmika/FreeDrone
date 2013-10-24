//
//  GPSNavigation.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "GPSCoordinate.h"

@interface GPSNavigation : NSObject

+(float)distanceBetweenOriginCoord: (GPSCoordinate*) originCoordinate
                   destinationCoord: (GPSCoordinate*) destinationCoordinate;

+(float) bearingBetweenOriginCoord: (GPSCoordinate*) originCoordinate
                   destinationCoord: (GPSCoordinate*) destinationCoordinate;

+(GPSCoordinate*) midpointBetweenOriginCoord: (GPSCoordinate*) originCoordinate
                            destinationCoord: (GPSCoordinate*) destinationCoordinate;

+(char) turningDirectionFromCurrentBearing: (const float) currentBearing
                            towardsBearing: (const float) towardsBearing
                                 precision: (const float) precision;

+(GPSCoordinate*) findDestinationCoordFromCoord: (GPSCoordinate*) initialCoord
                                 bearingDegrees: (float) initBearing
                             distanceKilometers: (float) distance;

+(BOOL) nearByCoord: (GPSCoordinate*) originCoordinate
          withCoord: (GPSCoordinate*) destinationCoord
   distanceInMetres: (float) minDistance;

@end
