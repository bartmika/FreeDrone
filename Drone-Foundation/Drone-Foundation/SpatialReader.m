//
//  SpatialReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "SpatialReader.h"

@implementation SpatialReader
//
//@synthesize pitch;
//@synthesize roll;
//@synthesize yaw;

static SpatialReader * sharedSpatialReader = nil;

+(SpatialReader*) sharedInstance
{
    @synchronized([SpatialReader class]) {
        if (sharedSpatialReader == nil) {
            sharedSpatialReader = [[SpatialReader alloc] init];
        }
    }
    
    return sharedSpatialReader;
}

+(id) alloc{
    @synchronized([SpatialReader class]){
        sharedSpatialReader = [super alloc];
    }
    
    return sharedSpatialReader;
}

-(id) init{
    self = [super init];
    if (self) {
        reader = (id)phidgetSpatialReaderInit();
    }
    return self;
}

-(void) dealloc
{
    phidgetSpatialReaderDealloc((phidgetSpatialReader_t*)reader);
    reader = NULL;
    
    sharedSpatialReader = nil;
    [super dealloc];
}

- (rotation_t) anglesOfRotationInDegrees {
    rotation_t rot = {};
    
    @synchronized([SpatialReader class]) {
        rot = sharedSpatialReader ? [reader anglesOfRotationInDegrees] : rot;
    }
    
    return rot;
}

- (float) compassHeadingInDegrees {
    float compassHeading;
    
    @synchronized([SpatialReader class]) {
        compassHeading = sharedSpatialReader ? phidgetSpatialReaderGetCompassBearing((phidgetSpatialReader_t*)reader) : 0.0f;
    }
    
    return compassHeading;
}

-(acceleration_t) acceleration {
    acceleration_t acc = {};
    
    @synchronized([SpatialReader class]) {
        acc = sharedSpatialReader ? phidgetSpatialReaderGetAccelerameter((phidgetSpatialReader_t*)reader) : acc;
    }
    
    return acc;
}

-(angularRotation_t) angularRotation {
    angularRotation_t ang = {};
    
    @synchronized([SpatialReader class]) {
        ang = sharedSpatialReader ? phidgetSpatialReaderGetGyroscope((phidgetSpatialReader_t*)reader): ang;
    }
    
    return ang;
}

-(magneticField_t) magneticField {
    magneticField_t mag = {0};
    
    @synchronized([SpatialReader class]) {
        mag = sharedSpatialReader ? phidgetSpatialReaderGetCompass((phidgetSpatialReader_t*)reader) : mag;
    }
    
    return mag;
}


-(BOOL) deviceIsOperational {
    return sharedSpatialReader ? phidgetSpatialReaderIsOperationial((phidgetSpatialReader_t*)reader) : NO;
}

-(NSDictionary*) pollDeviceForData
{
    NSDictionary * data;
    
    if (reader == NULL) {
        return NULL;
    }
    
    @synchronized([SpatialReader class]) {
        spatialData_t spatialData = phidgetSpatialReaderGetData((phidgetSpatialReader_t*)reader);
        
        // Convert the data from the C langauge to Objective-C string types.
        NSNumber * pitchNumber = [NSNumber numberWithDouble: spatialData.rot.pitch];
        NSNumber * rollNumber = [NSNumber numberWithDouble: spatialData.rot.roll];
        NSNumber * yawNumber = [NSNumber numberWithDouble: spatialData.rot.yaw];
        NSNumber * compassHeading = [NSNumber numberWithDouble: spatialData.compassHeading];
        NSNumber * accX = [NSNumber numberWithDouble: spatialData.acc.x];
        NSNumber * accY = [NSNumber numberWithDouble: spatialData.acc.y];
        NSNumber * accZ = [NSNumber numberWithDouble: spatialData.acc.z];
        NSNumber * angX = [NSNumber numberWithDouble: spatialData.ang.x];
        NSNumber * angY = [NSNumber numberWithDouble: spatialData.ang.y];
        NSNumber * angZ = [NSNumber numberWithDouble: spatialData.ang.z];
        NSNumber * magX = [NSNumber numberWithDouble: spatialData.mag.x];
        NSNumber * magY = [NSNumber numberWithDouble: spatialData.mag.y];
        NSNumber * magZ = [NSNumber numberWithDouble: spatialData.mag.z];
        
        
        // Generate our column data for the spatial reader and return them.
        data = [NSDictionary dictionaryWithObjectsAndKeys:
                pitchNumber, @"Pitch",
                rollNumber, @"Roll",
                yawNumber, @"Yaw",
                compassHeading, @"Compass",
                accX, @"AccX", accY, @"AccY", accZ, @"AccZ",
                angX, @"AngX", angY, @"AngY", angZ, @"AngZ",
                magX, @"MagX", magY, @"MagY", magZ, @"MagZ",
                nil];
    }
    
    return data;
}

@end
