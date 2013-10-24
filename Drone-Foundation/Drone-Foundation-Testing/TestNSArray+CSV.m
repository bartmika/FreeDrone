//
//  TestNSArray+CSV.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import "TestNSArray+CSV.h"

// Custom
#import "NSArray+CSV.h"

@implementation TestNSArray_CSV

+(void)testStringArrayOfCsvString
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    // Set-up code here.
    NSError * fileHandlerError = nil;
    NSString * nonDoubleQuoteCSVData = [NSString stringWithContentsOfFile: kAustralianPostcodesFileURL
                                                                 encoding: NSUTF8StringEncoding
                                                                    error: &fileHandlerError];
    NSAssert(nonDoubleQuoteCSVData, @"Failed loading file");
    
    NSArray * nonDoubleQuoteCsvRows = [NSArray stringArrayOfCsvString: nonDoubleQuoteCSVData];
    NSAssert(nonDoubleQuoteCsvRows, @"Failed parsing file");
    
    [pool drain]; pool = nil;
}

+(void)testStringArrayOfCsvFile
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSError * error = nil;
    
    // Test Positive
    NSArray * csvRows1 = [NSArray stringArrayOfCsvFile: kAustralianPostcodesFileURL
                                              encoding: NSUTF8StringEncoding
                                                 error: &error];
    NSAssert(csvRows1, @"Failed to prase file\n");
    
    // Test Negative
//    NSArray * csvRows2 = [NSArray stringArrayOfCsvFile: @"/tmp/blah.csv"
//                                              encoding: NSUTF8StringEncoding
//                                                 error: &error];
//    NSAssert((csvRows2 == nil), @"Failed handling opening non-existent file\n");
    
    [pool drain]; pool = nil;
}

+(void)testWriteToCsvFile
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    // Import a CSV file already parsed (assume the funciton works).
    NSError * error = nil;
    NSArray * csvRows1 = [NSArray stringArrayOfCsvFile: kAustralianPostcodesFileURL
                                              encoding: NSUTF8StringEncoding
                                                 error: &error];
    // Attempt to write to a location
    BOOL success = [csvRows1 writeToCsvFile: kAustralianPostcodesFileSaveURL
                                   encoding: NSUTF8StringEncoding
                             fieldSeperator: @","
                             fieldEnclosure: nil
                              lineSeperator: @"\n"
                                      error: &error];
    
    NSAssert(success, @"Failed to write CSV file.");
    [pool drain]; pool = nil;
}

+(void)testAppendToCsvFile
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    // Append to empty file
    NSArray * array = [NSArray stringArrayOfCsvString: @"ID,Buy,Sell"];
    
    NSError * error = nil;
    BOOL wasSuccessful = NO;
    
    // Attempt to append a empty / non-existent csv file.
    wasSuccessful = [array appendToCsvFile: kAppendFileSaveURL
                                  encoding: NSUTF8StringEncoding
                            fieldSeperator: @","
                            fieldEnclosure: nil
                             lineSeperator: @"\n"
                                     error: &error];
    
    // Verify the write was successful.
    NSAssert(wasSuccessful, @"1 of 2:Failed appending CSV file\n");
    
    
    // Attempt to append an already populated csv file.
    NSArray * row1 = [NSArray stringArrayOfCsvString: @"1, 4000, 6000"];
    wasSuccessful = [row1 appendToCsvFile: kAppendFileSaveURL
                                 encoding: NSUTF8StringEncoding
                           fieldSeperator: @","
                           fieldEnclosure: nil
                            lineSeperator: @"\n"
                                    error: &error];
    NSAssert(wasSuccessful, @"2 of 2:Failed appending CSV file\n");
    [pool drain]; pool = nil;
}

+(void)testWriteToFileWithMultiTypeData
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Generate an array with NSNumber & NSString data for the columns.
    NSError * error = nil;
    NSNumber * index = [NSNumber numberWithInt: 01];
    NSNumber * latitude = [NSNumber numberWithFloat: 42.9837];
    NSNumber * longitude = [NSNumber numberWithFloat: -81.2497];
    NSString * locationFormat = @"%@ %@ %@";
    NSString * comment = [NSString stringWithFormat: locationFormat, @"London", @"Ontario", @"Canada"];
    NSArray * columns = [NSArray arrayWithObjects: index, latitude, longitude, comment, nil];
    NSArray * rows = [NSArray arrayWithObjects: columns, nil];
    
    // Attempt to write to the file using the array with multi-data types.
    BOOL wasSuccessful = [rows writeToCsvFile: kAustralianPostcodesFileSaveURL
                                     encoding: NSUTF8StringEncoding
                               fieldSeperator: @","
                               fieldEnclosure: nil
                                lineSeperator: @"\n"
                                        error: &error];
    
    // Verify the write was successful.
    NSAssert(wasSuccessful, @"Failed writing CSV file\n");
    [pool drain]; pool = nil;
}

+(void) performUnitTests
{
    NSLog(@"NSArray+CSV\n");
    [self testStringArrayOfCsvString];
    [self testStringArrayOfCsvFile];
    [self testWriteToCsvFile];
    [self testAppendToCsvFile];
    [self testWriteToFileWithMultiTypeData];
    NSLog(@"NSArray+CSV: Successful\n\n");
}

@end
