//
//  VirtualSpatialReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "VirtualSpatialReader.h"

@implementation VirtualSpatialReader

@synthesize compassHeading;
@synthesize usageLog;
@synthesize keepUsageLog;

static VirtualSpatialReader * sharedMotionReader = nil;

+(VirtualSpatialReader*) sharedInstance {
    @synchronized([VirtualSpatialReader class]) {
        if (sharedMotionReader == nil) {
            sharedMotionReader = [[VirtualSpatialReader alloc] init];
        }
    }
    
    return sharedMotionReader;
}

+(id) alloc{
    @synchronized([VirtualSpatialReader class]) {
        sharedMotionReader = [super alloc];
    }
    
    return sharedMotionReader;
}

-(id) init
{
    self = [super init];
    if (self) {
        compass = [NSMutableArray new];
        acc = [NSMutableArray new];
        ang = [NSMutableArray new];
        mag = [NSMutableArray new];
        angles = [NSMutableArray new];
        keepUsageLog = NO;
        usageLog = [[NSMutableArray alloc] initWithCapacity:500];
    }
    
    return self;
}

-(void)dealloc {
    [usageLog removeAllObjects];
    [usageLog release]; usageLog = nil;
    
    [compass release]; compass= nil;
    [acc release];
    [ang release];
    [mag release];
    [angles release];
    
    sharedMotionReader = nil;
    [super dealloc];
}

- (rotation_t) anglesOfRotationInDegrees {
    if (keepUsageLog) {
        [usageLog addObject: @"AnglesOfRotationInDegrees"];
    }
    
    NSArray * arr = [angles dequeue];
    rotation_t rot = {0};
    rot.pitch = [[arr objectAtIndex:0] floatValue];
    rot.roll = [[arr objectAtIndex:1] floatValue];
    rot.yaw = [[arr objectAtIndex: 2] floatValue];
    return rot;
}

- (float) compassHeadingInDegrees {
    if (keepUsageLog) {
        [usageLog addObject: @"CompassHeadingInDegrees"];
    }
    
    return compassHeading ? compassHeading : [[compass dequeue] floatValue];
}

-(acceleration_t) acceleration {
    if (keepUsageLog) {
        [usageLog addObject: @"Acceleration"];
    }
    
    NSArray * accel = [acc dequeue];
    acceleration_t cAcc = {0};
    cAcc.x = [[accel objectAtIndex:0] floatValue];
    cAcc.y = [[accel objectAtIndex:1] floatValue];
    cAcc.z = [[accel objectAtIndex:2] floatValue];
    return cAcc;
}

-(angularRotation_t) angularRotation {
    if (keepUsageLog) {
        [usageLog addObject: @"AngularRotation"];
    }
    
    NSArray * angular = [ang dequeue];
    angularRotation_t cAng = {0};
    cAng.x = [[angular objectAtIndex:0] floatValue];
    cAng.y = [[angular objectAtIndex:1] floatValue];
    cAng.z = [[angular objectAtIndex:2] floatValue];
    return cAng;
}

-(magneticField_t) magneticField {
    if (keepUsageLog) {
        [usageLog addObject: @"MagneticField"];
    }
    
    NSArray * mangnetic = [mag dequeue];
    magneticField_t cMag = {0};
    cMag.x = [[mangnetic objectAtIndex:0] floatValue];
    cMag.y = [[mangnetic objectAtIndex:1] floatValue];
    cMag.z = [[mangnetic objectAtIndex:2] floatValue];
    return cMag;
}

-(NSDictionary*) pollDeviceForData {
    if (keepUsageLog) {
        [usageLog addObject: @"PollDeviceForData"];
    }
    
    NSArray * anglesRow = [angles dequeue];
    NSNumber * compassRow = [compass dequeue];
    NSArray * accRow = [acc dequeue];
    NSArray * angRow = [ang dequeue];
    NSArray * magRow = [mag dequeue];
    
    // Create a array of data and return it.
    //NSArray * gpsData = @[strLatitude, strLongitude, strHeading, strAltitude];
    NSDictionary * motionData = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [anglesRow objectAtIndex: 0], @"Pitch",
                                 [anglesRow objectAtIndex: 1], @"Roll",
                                 [anglesRow objectAtIndex: 2], @"Yaw",
                                 compassRow, @"Compass",
                                 [accRow objectAtIndex: 0], @"AccX",
                                 [accRow objectAtIndex: 1], @"AccY",
                                 [accRow objectAtIndex: 2], @"AccZ",
                                 [angRow objectAtIndex: 0], @"AngX",
                                 [angRow objectAtIndex: 1], @"AngY",
                                 [angRow objectAtIndex: 2], @"AngZ",
                                 [magRow objectAtIndex: 0], @"MagX",
                                 [magRow objectAtIndex: 1], @"MagY",
                                 [magRow objectAtIndex: 2], @"MagZ",
                                 nil];
    return motionData;
}

-(BOOL)deviceIsOperational
{
    return YES; //TODO: Impl.
}

-(void) populateFromCsvFile: (NSString*) csvFilePathURL {
    NSError * error = nil;
    NSArray * csvRows = [NSArray stringArrayOfCsvFile: csvFilePathURL
                                             encoding: NSUTF8StringEncoding
                                                error:&error];
    
    // Declare the variable which will convert the numbers from
    // string to decimal.
    NSNumberFormatter * numberFormater = [[NSNumberFormatter alloc] init];
    [numberFormater setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormater setFormat:@"###.00"];
    
    // Go through the entire CSV file.
    for (NSArray * csvColumn in csvRows) {
        NSString * accXString = [csvColumn objectAtIndex: 1];
        NSString * accYString = [csvColumn objectAtIndex: 2];
        NSString * accZString = [csvColumn objectAtIndex: 3];
        NSString * angXString = [csvColumn objectAtIndex: 4];
        NSString * angYString = [csvColumn objectAtIndex: 5];
        NSString * angZString = [csvColumn objectAtIndex: 6];
        NSString * magXString = [csvColumn objectAtIndex: 7];
        NSString * magYString = [csvColumn objectAtIndex: 8];
        NSString * magZString = [csvColumn objectAtIndex: 9];
        NSString * compassString = [csvColumn objectAtIndex: 10];
        NSString * pitchString =[csvColumn objectAtIndex: 11];
        NSString * rollString = [csvColumn objectAtIndex: 12];
        NSString * yawString = [csvColumn objectAtIndex: 13];
        
        NSNumber * pitchNum = [numberFormater numberFromString: pitchString];
        NSNumber * rollNum = [numberFormater numberFromString: rollString];
        NSNumber * yawNum = [numberFormater numberFromString: yawString];
        NSNumber * compassNum = [numberFormater numberFromString: compassString];
        NSNumber * accXNum = [numberFormater numberFromString: accXString];
        NSNumber * accYNum = [numberFormater numberFromString: accYString];
        NSNumber * accZNum = [numberFormater numberFromString: accZString];
        NSNumber * angXNum = [numberFormater numberFromString: angXString];
        NSNumber * angYNum = [numberFormater numberFromString: angYString];
        NSNumber * angZNum = [numberFormater numberFromString: angZString];
        NSNumber * magXNum = [numberFormater numberFromString: magXString];
        NSNumber * magYNum = [numberFormater numberFromString: magYString];
        NSNumber * magZNum = [numberFormater numberFromString: magZString];
        
        if (pitchNum && rollNum && yawNum) {
            NSArray * arr = [NSArray arrayWithObjects: pitchNum, rollNum, yawNum, nil];
            [angles addObject: arr];
        }
        
        if (compassNum) {
            [compass addObject: compassNum];
        }
        
        if (accXNum && accYNum && accZNum) {
            NSArray * arr = [NSArray arrayWithObjects: accXNum, accYNum, accZNum, nil];
            [acc addObject: arr];
        }
        
        if (angXNum && angYNum && angZNum) {
            NSArray * arr = [NSArray arrayWithObjects: angXNum, angYNum, angZNum, nil];
            [ang addObject: arr];
        }
        
        if (magXNum && magYNum && magZNum) {
            NSArray * arr = [NSArray arrayWithObjects: magXNum, magYNum, magZNum, nil];
            [mag addObject: arr];
        }
    }
    
    [numberFormater release]; numberFormater = nil;
}

@end
