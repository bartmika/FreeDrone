//
//  TestPhidgetSpatialReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestPhidgetSpatialReader.h"

@implementation TestPhidgetSpatialReader

static id spatialReader = NULL;

const unsigned int isPhidgetSpatialReaderDataInvalid(spatialData_t data){
    if (data.acc.x == 0 && data.acc.y == 0 && data.acc.z == 0) {
        //printf("Failed reading acceleration for x/y/z \n");
        return 1;
    }
    if (data.ang.x == 0 && data.ang.y == 0 && data.ang.z == 0) {
        //printf("Failed reading angular rotation for x/y/z \n");
        return 1;
    }
    if (data.mag.x == 0 && data.mag.y == 0 && data.mag.z == 0) {
        //printf("Failed reading magnetic field for x/y/z \n");
        return 1;
    }
    
    return 0;
}

void TestPhidgetSpatialPrint(spatialData_t data){
    printf("\t\tAcc: X: %f Y: %f Z:%f\n", data.acc.x, data.acc.y, data.acc.z);
    printf("\t\tAng: X: %f Y: %f Z:%f\n", data.ang.x, data.ang.y, data.ang.z);
    printf("\t\tMag: X: %f Y: %f Z:%f\n", data.mag.x, data.mag.y, data.mag.z);
    printf("\t\tCompass: %f Degrees\n", data.compassHeading);
    printf("\t\tTime: %zd sec\n", data.timestamp);
    printf("\t\tTime: %zd microsec\n", data.utimestamp);
}

+ (void)setUp
{    
    // Set-up code here.
    spatialReader = (id)phidgetSpatialReaderInit();
    NSAssert(spatialReader, @"Failed to alloc+init\n");
}

+ (void)tearDown
{
    // Tear-down code here.
    phidgetSpatialReaderDealloc((phidgetSpatialReader_t*)spatialReader);
    spatialReader = NULL;
    
}

+ (void)testGetData
{
    size_t i;
    size_t max = 10;
    for ( i = 1; i <= max; i++ ) {
        if (phidgetSpatialReaderIsOperationial((phidgetSpatialReader_t*)spatialReader)) {
            printf("Poll %zd / %zd\tGetData\n",i,max);
            spatialData_t data= phidgetSpatialReaderGetData((phidgetSpatialReader_t*)spatialReader); // Read data from device.
            
            NSAssert(isPhidgetSpatialReaderDataInvalid(data) == 0, @"Invalid results detected\n");
            TestPhidgetSpatialPrint(data); // Print the contents.
            
            [NSThread sleepForTimeInterval: 0.5f]; // Add artifical delay.
        }
    }
}

+ (void)testGetAcceleration
{
    // Variable to hold our spatial data.
    acceleration_t data = {};
    
    size_t i;
    size_t max = 10;
    for ( i = 1; i <= max; i++ ) {
        if (phidgetSpatialReaderIsOperationial((phidgetSpatialReader_t*)spatialReader)) {
            printf("Poll %zd / %zd\tAcc: X: %f Y: %f Z: %f\n",i,max, data.x, data.y, data.z);
            data = phidgetSpatialReaderGetAccelerameter((phidgetSpatialReader_t*)spatialReader); // Read data from device.
            
            [NSThread sleepForTimeInterval: 0.5f]; // Add artifical delay.
        }
    }
}

+ (void)testGetGyroscope
{
    // Variable to hold our spatial data.
    angularRotation_t data = {};
    
    size_t i;
    size_t max = 10;
    for ( i = 1; i <= max; i++ ) {
        if (phidgetSpatialReaderIsOperationial((phidgetSpatialReader_t*)spatialReader)) {
            printf("Poll %zd / %zd\tAng: X: %f Y: %f Z: %f\n",i,max, data.x, data.y, data.z);
            data = phidgetSpatialReaderGetGyroscope((phidgetSpatialReader_t*)spatialReader); // Read data from device.
            
            [NSThread sleepForTimeInterval: 0.5f]; // Add artifical delay.
        }
    }
}

+ (void)testGetCompass
{
    // Variable to hold our spatial data.
    magneticField_t data = {};
    
    size_t i;
    size_t max = 10;
    for ( i = 1; i <= max; i++ ) {
        if (phidgetSpatialReaderIsOperationial((phidgetSpatialReader_t*)spatialReader)) {
            printf("Poll %zd / %zd\tMag: X: %f Y: %f Z: %f\n",i,max, data.x, data.y, data.z);
            data = phidgetSpatialReaderGetCompass((phidgetSpatialReader_t*)spatialReader); // Read data from device.
            
            [NSThread sleepForTimeInterval: 0.5f]; // Add artifical delay.
        }
    }
}

+ (void)testGetTimestamp
{
    // Variable to hold our spatial data.
    float data = 0.0f;
    
    size_t i;
    size_t max = 10;
    for ( i = 1; i <= max; i++ ) {
        if (phidgetSpatialReaderIsOperationial((phidgetSpatialReader_t*)spatialReader)) {
            printf("Poll %zd / %zd\tTime: %f\n",i,max, data);
            data = phidgetSpatialReaderGetTimestamp((phidgetSpatialReader_t*)spatialReader); // Read data from device.
            
            [NSThread sleepForTimeInterval: 0.5f]; // Add artifical delay.
        }
    }
}

+ (void)testGetUTimestamp
{
    // Variable to hold our spatial data.
    float data = 0.0f;
    
    size_t i;
    size_t max = 10;
    for ( i = 1; i <= max; i++ ) {
        if (phidgetSpatialReaderIsOperationial((phidgetSpatialReader_t*)spatialReader)) {
            printf("Poll %zd / %zd\tUTime: %f\n",i,max, data);
            data = phidgetSpatialReaderGetUTimestamp((phidgetSpatialReader_t*)spatialReader); // Read data from device.
            
            [NSThread sleepForTimeInterval: 0.5f]; // Add artifical delay.
        }
    }
}

+ (void)testGetCompassBearing
{
    // Variable to hold our spatial data.
    float data = 0;
    
    size_t i;
    size_t max = 10;
    for ( i = 1; i <= max; i++ ) {
        if (phidgetSpatialReaderIsOperationial((phidgetSpatialReader_t*)spatialReader)) {
            printf("Poll %zd / %zd\tCompassBearing: %f\n",i,max, data);
            data = phidgetSpatialReaderGetCompassBearing((phidgetSpatialReader_t*)spatialReader); // Read data from device.
            
            [NSThread sleepForTimeInterval: 0.5f]; // Add artifical delay.
        }
    }
}

+ (void)testGetAnglesOfRotation
{
    // Variable to hold our spatial data.
    rotation_t data = {};
    
    size_t i;
    size_t max = 10;
    for ( i = 1; i <= max; i++ ) {
        if (phidgetSpatialReaderIsOperationial((phidgetSpatialReader_t*)spatialReader)) {
            printf("Poll %zd / %zd\tPitch: %f Roll: %f Yaw: %f\n",i,max, data.pitch, data.roll, data.yaw);
            data = phidgetSpatialReaderGetAnglesOfRotation((phidgetSpatialReader_t*)spatialReader); // Read data from device.
            
            [NSThread sleepForTimeInterval: 0.5f]; // Add artifical delay.
        }
    }
}

+(void) performUnitTests
{
    [self setUp];
    [self testGetData];
    [self testGetAcceleration];
    [self testGetGyroscope];
    [self testGetCompass];
    [self testGetTimestamp];
    [self testGetUTimestamp];
    [self testGetCompassBearing];
    [self testGetAnglesOfRotation];
    [self tearDown];
}



@end
