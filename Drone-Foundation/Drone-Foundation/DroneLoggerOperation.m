//
//  DroneLoggerOperation.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "DroneLoggerOperation.h"
@implementation DroneLoggerOperation

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

-(BOOL) setup {
    NSAutoreleasePool * setupMemoryPool = [NSAutoreleasePool new];
    
    if ([gpsReader deviceIsOperational]) {
        // Configure file:
        // Write the header we will be using in our file. This array
        // will hold all the columns.
        NSArray * csvCols = [NSArray arrayWithObjects:
                             @"id", @"latitude", @"longitude",@"heading",
                             @"altitude", @"speed", @"day", @"month", @"year",
                             @"hour", @"minute", @"millisecond", @"second", nil];
        
        // Create array to store all the rows, since we are only populating
        // the header, just make one row.
        NSArray * csvRows = [NSArray arrayWithObjects: csvCols, nil];
        
        // Write the header to our file.
        if ([csvRows writeToCsvFile: gpsReaderLoggingFileLocation
                           encoding: NSASCIIStringEncoding
                     fieldSeperator: @","
                     fieldEnclosure: @"\""
                      lineSeperator: @"\n"
                              error: &error] == NO) {
            [setupMemoryPool drain]; setupMemoryPool = nil;
            return NO;
        }
    }
    
    if ([spatialReader deviceIsOperational]) {
        NSArray * csvCols = [NSArray arrayWithObjects: @"id", @"accX", @"accY", @"accZ", @"angX",
                             @"angY", @"angZ", @"magX", @"magY", @"magZ",
                             @"compass", @"pitch", @"yaw", @"roll", nil];
        
        NSArray * csvRows = [NSArray arrayWithObjects: csvCols, nil];
        
        if([csvRows writeToCsvFile: SpatialReaderLoggingFileLocation
                          encoding: NSASCIIStringEncoding
                    fieldSeperator: @","
                    fieldEnclosure: @"\""
                     lineSeperator: @"\n"
                             error: &error] == NO) {
            [setupMemoryPool drain]; setupMemoryPool = nil;
            return NO;
        }
    }
    
    if ([servoController deviceIsOperational]) {
        NSArray * csvCols = [NSArray arrayWithObjects: @"position", nil];
        
        NSArray * csvRows = [NSArray arrayWithObjects: csvCols, nil];
        
        if([csvRows writeToCsvFile: servoControllerLoggingFileLocation
                          encoding: NSASCIIStringEncoding
                    fieldSeperator: @","
                    fieldEnclosure: @"\""
                     lineSeperator: @"\n"
                             error: &error] == NO) {
            [setupMemoryPool drain]; setupMemoryPool = nil;
            return NO;
        }
    }
    
    if ([motorController deviceIsOperational]) {
        NSArray * csvCols = [NSArray arrayWithObjects: @"acceleration", @"velocity", nil];
        
        NSArray * csvRows = [NSArray arrayWithObjects: csvCols, nil];
        
        if([csvRows writeToCsvFile: motorControllerLoggingFileLocation
                          encoding: NSASCIIStringEncoding
                    fieldSeperator: @","
                    fieldEnclosure: @"\""
                     lineSeperator: @"\n"
                             error: &error] == NO) {
            [setupMemoryPool drain]; setupMemoryPool = nil;
            return NO;
        }
    }
    
    // Close the memory pool associated with creating the file.
    [setupMemoryPool drain]; setupMemoryPool = nil;
    
    // As long as a single device is detected to be operational, then we have
    // successfully setup, else we failed setting up.
    if ([gpsReader deviceIsOperational] ||
        [spatialReader deviceIsOperational] ||
        [servoController deviceIsOperational] ||
        [motorController deviceIsOperational]) {
        return YES;
    } else {
        return NO;
    }
}

- (void) performGPSLoggingWithRecordIndex: (NSNumber*) rowIndex {
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    
    // Get data from connected hardware devices.
    NSDictionary * gpsData = [gpsReader pollDeviceForData];
    
    // Generate our col of data by combining all the polled data.
    NSArray * cols = [NSArray arrayWithObjects:
                      rowIndex,                                     // id
                      [gpsData objectForKey: @"Latitude"],          // latitude
                      [gpsData objectForKey: @"Longitude"],         // longitude
                      [gpsData objectForKey: @"Heading"],           // heading
                      [gpsData objectForKey: @"Altitude"],          // altitude
                      [gpsData objectForKey: @"Speed"],
                      [gpsData objectForKey: @"Day"],
                      [gpsData objectForKey: @"Month"],
                      [gpsData objectForKey: @"Year"],
                      [gpsData objectForKey: @"Hour"],
                      [gpsData objectForKey: @"Minute"],
                      [gpsData objectForKey: @"Millisecond"],
                      [gpsData objectForKey: @"Second"],
                      nil];
    
    // Generate a rows array to hold all the data for this current
    // row.
    NSArray * rows = [NSArray arrayWithObjects: cols, nil];
    
    // Write the row to the file
    [rows appendToCsvFile: gpsReaderLoggingFileLocation
                 encoding: encoding
           fieldSeperator: @","
           fieldEnclosure: @"\""
            lineSeperator: @"\n"
                    error: &error];
    
    [pool drain]; pool = nil;
}

- (void) performSpatialReaderLoggingWithRecordIndex: (NSNumber*) rowIndex
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    NSDictionary * motionData = [spatialReader pollDeviceForData];
    
    // Generate our col of data by combining all the polled data.
    NSArray * cols = [NSArray arrayWithObjects:
                      rowIndex,
                      [motionData objectForKey: @"AccX"],
                      [motionData objectForKey: @"AccY"],
                      [motionData objectForKey: @"AccZ"],
                      [motionData objectForKey: @"AngX"],
                      [motionData objectForKey: @"AngY"],
                      [motionData objectForKey: @"AngZ"],
                      [motionData objectForKey: @"MagX"],
                      [motionData objectForKey: @"MagY"],
                      [motionData objectForKey: @"MagZ"],
                      [motionData objectForKey: @"Compass"],
                      [motionData objectForKey: @"Pitch"],
                      [motionData objectForKey: @"Yaw"],
                      [motionData objectForKey: @"Roll"],
                      nil];
    
    // Generate a rows array to hold all the data for this current
    // row.
    NSArray * rows = [NSArray arrayWithObjects: cols, nil];
    
    // Write the row to the file
    [rows appendToCsvFile: SpatialReaderLoggingFileLocation
                 encoding: encoding
           fieldSeperator: @","
           fieldEnclosure: @"\""
            lineSeperator: @"\n"
                    error: &error];
    [pool drain]; pool = nil;
}

- (void) performServoControllerLoggingWithRecordIndex: (NSNumber*) rowIndex
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    
    NSDictionary * servoData = [servoController pollDeviceForData];
    
    // Generate our col of data by combining all the polled data.
    NSArray * cols = [NSArray arrayWithObjects:
                      rowIndex,
                      [servoData objectForKey: @"Position"],
                      nil];
    
    // Generate a rows array to hold all the data for this current
    // row.
    NSArray * rows = [NSArray arrayWithObjects: cols, nil];
    
    // Write the row to the file
    [rows appendToCsvFile: servoControllerLoggingFileLocation
                 encoding: encoding
           fieldSeperator: @","
           fieldEnclosure: @"\""
            lineSeperator: @"\n"
                    error: &error];
    [pool drain]; pool = nil;
}

- (void) performMotorControllerLoggingWithRecordIndex: (NSNumber*) rowIndex
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    NSDictionary * motorData = [motorController pollDeviceForData];
    
    // Generate our col of data by combining all the polled data.
    NSArray * cols = [NSArray arrayWithObjects:
                      rowIndex,                         // id
                      [motorData objectForKey: @"Acceleration"],
                      [motorData objectForKey: @"Velocity"],
                      nil];
    
    // Generate a rows array to hold all the data for this current
    // row.
    NSArray * rows = [NSArray arrayWithObjects: cols, nil];
    
    // Write the row to the file
    [rows appendToCsvFile: motorControllerLoggingFileLocation
                 encoding: encoding
           fieldSeperator: @","
           fieldEnclosure: @"\""
            lineSeperator: @"\n"
                    error: &error];
    [pool drain]; pool = nil;
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

@synthesize timeDelayInterval;

- (id)init
{
    self = [super init];
    if (self) {
        encoding = NSASCIIStringEncoding;
        gpsReaderLoggingFileLocation = [[NSString alloc] initWithString: @"/tmp/DroneLoggerGPSReader.csv"];
        SpatialReaderLoggingFileLocation = [[NSString alloc] initWithString: @"/tmp/DroneLoggerSpatialReader.csv"];
        servoControllerLoggingFileLocation = [[NSString alloc] initWithString: @"/tmp/DroneLoggerServoController.csv"];
        motorControllerLoggingFileLocation = [[NSString alloc] initWithString: @"/tmp/DroneLoggerMotorController.csv"];
        
        // Set interval.
        timeDelayInterval = 1.0f;
        
        // Configure States
        executing = NO;
        finished = NO;
        
        // Setup connection with hardware.
        gpsReader = [GPSReader sharedInstance];
        spatialReader = [SpatialReader sharedInstance];
        motorController = [MotorController sharedInstance];
        servoController = [ServoController sharedInstance];
        spatialReader = [SpatialReader sharedInstance];
        
        // Once the hardware is connected, generate the columns according
        // to what device is connected.
        if ( [self setup] == NO) {
            NSLog(@"Error: Could not setup logger.\n");
            exit(EXIT_FAILURE);
        }
    }
    
    return self;
}

-(void) dealloc
{
    [gpsReaderLoggingFileLocation release]; gpsReaderLoggingFileLocation = nil;
    [SpatialReaderLoggingFileLocation release]; SpatialReaderLoggingFileLocation = nil;
    [servoControllerLoggingFileLocation release]; servoControllerLoggingFileLocation = nil;
    [motorControllerLoggingFileLocation release]; motorControllerLoggingFileLocation = nil;
    
    gpsReader = nil;
    spatialReader = nil;
    motorController = nil;
    servoController = nil;
    [super dealloc];
}

-(BOOL) isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

-(BOOL)isFinished {
    return finished;
}

- (void)start {
    //TODO: FIX
    // Add defensive code if user selected "init" instead of initWith...
    
    // Always check for cancelation before launching the task.
    if ([self isCancelled]) {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    } else {
        // If the operation is not cancled, being executing the task.
        [self willChangeValueForKey:@"isExecuting"];
        [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
        executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (void)main {
    // New threads ALWAYS must start with an autorelease pool object.
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    
    // Name our thread to aid in debugging purposes.
    [[NSThread currentThread] setName:@"DroneLoggerOperation"];
    
    @try {
        NSUInteger index = 1;
        
        // Keep running until the user has cancelled this operation.
        while (![self isCancelled]) {            
            // Generate row index, increment index for every new record.
            NSNumber * rowIndex = [NSNumber numberWithInteger: index];
            
            if ([gpsReader deviceIsOperational]) {
                [self performGPSLoggingWithRecordIndex: rowIndex];
            }
            if ([spatialReader deviceIsOperational]) {
                [self performSpatialReaderLoggingWithRecordIndex: rowIndex];
            }
            if ([servoController deviceIsOperational]) {
                [self performServoControllerLoggingWithRecordIndex: rowIndex];
            }
            if ([motorController deviceIsOperational]) {
                [self performMotorControllerLoggingWithRecordIndex: rowIndex];
            }
            
            // Once we have written our log for the particular time interval
            // then pause the current writer with our time delay interval.
            [NSThread sleepForTimeInterval: timeDelayInterval];
            
            index++; // Increment
        }
    }
    @catch (NSException *exception) {
        //TODO: Add error handling.
        NSLog(@"Exception occured in DroneLoggerOperation with error %@\n", exception);
    }
    @finally {
        [self completeOperation]; // Terminate our operation.
    }
    
    [pool drain]; pool = nil;
}

-(void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
