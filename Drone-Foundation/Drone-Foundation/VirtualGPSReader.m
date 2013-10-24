//
//  VirtualGPSReader.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "VirtualGPSReader.h"

@implementation VirtualGPSReader

@synthesize latitudeValue;
@synthesize longitudeValue;
@synthesize altitudeValue;
@synthesize headingValue;
@synthesize speedValue;

@synthesize keepUsageLog;
@synthesize usageLog;

static VirtualGPSReader * sharedGPSReader = nil;

+(VirtualGPSReader*) sharedInstance {
    @synchronized([VirtualGPSReader class]) {
        if (sharedGPSReader == nil) {
            sharedGPSReader = [[VirtualGPSReader alloc] init];
        }
    }
    
    return sharedGPSReader;
}

+(id) alloc
{
    @synchronized([VirtualGPSReader class]) {
        sharedGPSReader = [super alloc];
    }
    
    return sharedGPSReader;
}

-(id)init
{
    self = [super init];
    if (self) {
        latitude = [[NSMutableArray alloc] initWithCapacity: 500];
        longitude = [[NSMutableArray alloc] initWithCapacity: 500];
        heading = [[NSMutableArray alloc] initWithCapacity: 500];
        altitude = [[NSMutableArray alloc] initWithCapacity: 500];
        speed = [[NSMutableArray alloc] initWithCapacity: 500];
        keepUsageLog = NO;
        usageLog = [[NSMutableArray alloc] initWithCapacity: 500];
        date = [[NSMutableArray alloc] initWithCapacity: 500];
        time = [[NSMutableArray alloc] initWithCapacity: 500];
    }
    
    return self;
}

-(void) dealloc
{
    [latitude removeAllObjects];
    [latitude release]; latitude = nil;
    [longitude removeAllObjects];
    [longitude release]; latitude = nil;
    [heading removeAllObjects];
    [heading release]; heading = nil;
    [altitude removeAllObjects];
    [altitude release]; altitude = nil;
    [speed removeAllObjects];
    [speed release]; speed = nil;
    [usageLog removeAllObjects];
    [usageLog release]; usageLog = nil;
    [date removeAllObjects];
    [date release]; date = nil;
    [time removeAllObjects];
    [time release]; time = nil;
    sharedGPSReader = nil;
    [super dealloc];
}

-(GPSCoordinate*) coordinate {
    NSNumber * latitudeReading = latitudeValue ? [NSNumber numberWithFloat: latitudeValue] : [latitude dequeue];
    NSNumber * longitudeReading = longitudeValue ? [NSNumber numberWithFloat: longitudeValue] : [longitude dequeue];
    
    if (keepUsageLog) {
        NSString * coordinate = [NSString stringWithFormat:
                                 @"Coordinate: Lat: %@, Lon: %@",
                                 latitudeReading,
                                 longitudeReading];
        [usageLog addObject: coordinate];
    }
    
    GPSCoordinate* coorindate = [[GPSCoordinate alloc]
                                 initWithLatitudeDegrees: [latitudeReading floatValue]
                                 longitudeDegrees: [longitudeReading floatValue]];
    return [coorindate autorelease];
}

-(const float) heading {
    NSNumber * headingReading = headingValue ? [NSNumber numberWithFloat: headingValue] : [heading dequeue];
    
    if (keepUsageLog) {
        NSString * head = [NSString stringWithFormat: @"Heading: %@", headingReading];
        [usageLog addObject: head];
    }
    
    return [headingReading floatValue];
}

-(const float) speed {
    NSNumber * speedReading = speedValue ? [NSNumber numberWithFloat: speedValue] : [speed dequeue];
    
    if (keepUsageLog) {
        NSString * speedStr = [NSString stringWithFormat: @"Speed: %@", speedReading];
        [usageLog addObject: speedStr];
    }
    
    return [speedReading floatValue];
}

-(const float)latitude {
    NSNumber * latitudeReading = latitudeValue ? [NSNumber numberWithFloat: latitudeValue] : [latitude dequeue];
    
    if (keepUsageLog) {
        NSString * lat = [NSString stringWithFormat: @"Latitude: %@", latitudeReading];
        [usageLog addObject: lat];
    }
    
    return [latitudeReading floatValue];
}

-(const float)longitude {
    NSNumber * longitudeReading = longitudeValue ? [NSNumber numberWithFloat: longitudeValue] : [longitude dequeue];
    
    if (keepUsageLog) {
        NSString * lon = [NSString stringWithFormat: @"Longitude: %@", longitudeReading];
        [usageLog addObject: lon];
    }
    
    return [longitudeReading floatValue];
}

-(const float) altitude {
    NSNumber *altitudeReading = altitudeValue ? [NSNumber numberWithFloat: altitudeValue] : [altitude dequeue] ;
    
    if (keepUsageLog) {
        NSString * alt = [NSString stringWithFormat: @"Altitude: %@", altitudeReading];
        [usageLog addObject: alt];
    }
    
    return [altitudeReading floatValue] ;
}

-(GPSTime) time {
    GPSTime t = {0}; // Variable we'll be returning.
    
    NSArray * timeReading = [time dequeue];
    NSNumber * hour = [timeReading objectAtIndex: 0];
    NSNumber * min = [timeReading objectAtIndex: 1];
    NSNumber * mSec = [timeReading objectAtIndex: 2];
    NSNumber * sec = [timeReading objectAtIndex: 3];
    
    if (keepUsageLog) {
        NSString * timeStr =
        [NSString stringWithFormat: @"Time: Hour: %@ Min: %@ MSec: %@ Sec: %@\n",
         hour, min, mSec, sec];
        [usageLog addObject: timeStr];
    }
    
    t.tm_hour = [hour integerValue];
    t.tm_min = [min integerValue];
    t.tm_ms = [mSec integerValue];
    t.tm_sec = [sec integerValue];
    
    return t;
}

-(GPSDate) date {
    GPSDate d = {0};
    
    NSArray * dateReading = [date dequeue];
    NSNumber * day = [dateReading objectAtIndex:0];
    NSNumber * month = [dateReading objectAtIndex:1];
    NSNumber * year = [dateReading objectAtIndex:2];
    
    if (keepUsageLog) {
        NSString * dateStr =
        [NSString stringWithFormat: @"Date: Day: %@ Month: %@ Year: %@\n", day, month, year];
        [usageLog addObject: dateStr];
    }
    
    d.tm_mday = [day integerValue];
    d.tm_mon = [month integerValue];
    d.tm_year = [year integerValue];
    
    return d;
}

-(NSDictionary*) pollDeviceForData {
    NSNumber * latitudeReading = [latitude dequeue];
    NSNumber * longitudeReading = [longitude dequeue];
    NSNumber *altitudeReading = [altitude dequeue];
    NSNumber * headingReading = [heading dequeue];
    NSNumber * speedReading = [speed dequeue];
    
    if (keepUsageLog) {
        NSString * log = [NSString stringWithFormat: @"PollDeviceForData: %@ %@ %@ %@ %@",
                          latitudeReading,
                          longitudeReading,
                          altitudeReading,
                          headingReading,
                          speedReading];
        [usageLog addObject: log];
    }
    
    if (latitudeReading && longitudeReading && altitudeReading && headingReading) {
        NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     latitudeReading, @"Latitude",
                                     longitudeReading, @"Longitude",
                                     altitudeReading, @"Altitude",
                                     headingReading, @"Heading",
                                     speedReading, @"Speed",
                                     nil];
        return dictionary;
        
    } else if (latitudeValue && longitudeValue) {
        NSNumber * lat = [NSNumber numberWithFloat: latitudeValue];
        NSNumber * lon = [NSNumber numberWithFloat: longitudeValue];
        NSNumber * alt = [NSNumber numberWithFloat: altitudeValue];
        NSNumber * hdg = [NSNumber numberWithFloat: headingValue];
        NSNumber * spd = [NSNumber numberWithFloat: speedValue];
        NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     lat, @"Latitude",
                                     lon, @"Longitude",
                                     alt, @"Altitude",
                                     hdg, @"Heading",
                                     spd, @"Speed",
                                     nil];
        return dictionary;
    } else {
        return nil;
    }
    
}


-(BOOL)deviceIsOperational
{
    return YES;
}

-(void) populateFromCsvFile: (NSString*) csvFilePathURL
{
    NSError * error = nil;
    NSArray * csvRows = [NSArray stringArrayOfCsvFile: csvFilePathURL
                                             encoding: NSUTF8StringEncoding
                                                error: &error];
    
    // Declare the variable which will convert the numbers from
    // string to decimal.
    NSNumberFormatter * numberFormater = [[NSNumberFormatter alloc] init];
    [numberFormater setNumberStyle:NSNumberFormatterDecimalStyle];
    
    // Go through the entire CSV file.
    for (NSArray * csvColumn in csvRows) {
        NSString * latitudeString = [csvColumn objectAtIndex:1];
        NSString * longitudeString = [csvColumn objectAtIndex:2];
        NSString * headingString = [csvColumn objectAtIndex:3];
        NSString * altitudeString = [csvColumn objectAtIndex:4];
        NSString * speedString = [csvColumn objectAtIndex: 5];
        NSString * dayString = [csvColumn objectAtIndex: 6];
        NSString * monthString = [csvColumn objectAtIndex: 7];
        NSString * yearString = [csvColumn objectAtIndex: 8];
        NSString * hourString = [csvColumn objectAtIndex: 9];
        NSString * minString = [csvColumn objectAtIndex: 10];
        NSString * mSecString = [csvColumn objectAtIndex: 11];
        NSString * secString = [csvColumn objectAtIndex: 12];
        
        NSNumber *latitudeNumber = [numberFormater numberFromString: latitudeString];
        NSNumber *longitudeNumber = [numberFormater numberFromString: longitudeString];
        NSNumber * headingNumber = [numberFormater numberFromString: headingString];
        NSNumber * altitudeNumber = [numberFormater numberFromString: altitudeString];
        NSNumber * speedNumber = [numberFormater numberFromString: speedString];
        NSNumber * dayNumber = [numberFormater numberFromString: dayString];
        NSNumber * monthNumber = [numberFormater numberFromString: monthString];
        NSNumber * yearNumber = [numberFormater numberFromString: yearString];
        NSNumber * hourNumber = [numberFormater numberFromString: hourString];
        NSNumber * minNumber = [numberFormater numberFromString: minString];
        NSNumber * mSecNumber = [numberFormater numberFromString: mSecString];
        NSNumber * secNumber = [numberFormater numberFromString: secString];
        
        if (latitudeNumber) {
            [latitude addObject: latitudeNumber];
        }
        if (longitudeNumber) {
            [longitude addObject: longitudeNumber];
        }
        if (headingNumber) {
            [heading addObject: headingNumber];
        }
        if (altitudeNumber) {
            [altitude addObject: altitudeNumber];
        }
        if (speedNumber) {
            [speed addObject: speedNumber];
        }
        if (dayNumber && monthNumber && yearNumber) {
            NSArray * row = [NSArray arrayWithObjects: dayNumber, monthNumber, yearNumber, nil];
            [date addObject: row];
        }
        if (hourNumber && minNumber && mSecNumber && secNumber) {
            NSArray * row = [NSArray arrayWithObjects: hourNumber, minNumber, mSecNumber, secNumber, nil];
            [time addObject: row];
        }
    }
    
    [numberFormater release]; numberFormater = nil;
}


-(void) setCoordinate: (GPSCoordinate*) destinationCoord
{
    latitudeValue = [destinationCoord latitudeDegrees];
    longitudeValue = [destinationCoord longitudeDegrees];
}

@end
