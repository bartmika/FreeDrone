//
//  VirtualGPSReader.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>
#ifndef __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__
    #import <phidget21.h>
#else
    #import <Phidget21/phidget21.h>
#endif

// Customer
#import "GPSReading.h"
#import "NSMutableArray+Queue.h"
#import "NSArray+CSV.h"

@interface VirtualGPSReader : NSObject <GPSReading> {
    NSMutableArray * latitude;
    NSMutableArray * longitude;
    NSMutableArray * altitude;
    NSMutableArray * heading;
    NSMutableArray * speed;
    NSMutableArray * date;
    NSMutableArray * time;
    
    BOOL keepUsageLog;
    NSMutableArray * usageLog;
    
    float latitudeValue;
    float longitudeValue;
    float altitudeValue;
    float headingValue;
    float speedValue;
}

// Manual Mode
@property (atomic) float latitudeValue;
@property (atomic) float longitudeValue;
@property (atomic) float altitudeValue;
@property (atomic) float headingValue;
@property (atomic) float speedValue;
-(void) setCoordinate: (GPSCoordinate*) destinationCoord;

@property (atomic) BOOL keepUsageLog;
@property (atomic, retain) NSMutableArray * usageLog;

+(VirtualGPSReader*) sharedInstance;

-(void) dealloc;

-(GPSCoordinate*) coordinate;

-(const float) heading;

-(const float) speed;

-(const float) latitude;

-(const float) longitude;

-(const float) altitude;

-(GPSTime) time;

-(GPSDate) date;

-(NSDictionary*) pollDeviceForData;

// Automatic mode
-(void) populateFromCsvFile: (NSString*) csvFilePathURL;

@end
