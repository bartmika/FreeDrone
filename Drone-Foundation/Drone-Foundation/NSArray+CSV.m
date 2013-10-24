//
//  NSArray+CSV.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-25.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "NSArray+CSV.h"

@implementation NSArray (CSV)

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

-(void) secureAppendCsvFieldColumn: (NSObject*) col toCsvRowString: (NSMutableString*) line
{
    // Write to the string according to the data type.
    if ( [col isKindOfClass: [NSString class]] ) {
        [line appendString: (NSString*)col];
    } else if ( [col isKindOfClass: [NSNumber class]] ) {
        [line appendString: [(NSNumber*)col stringValue]];
    } else {
        [NSException raise: @"Not Supported Data Type" format: @"%@ is not supported.", col, nil];
    }
    
    //TODO: Add code to 'escape' and comma or double quote characters.
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

+ (NSArray*) stringArrayOfCsvFile: (NSString*) csvFilePath
                         encoding: (NSStringEncoding) encodingString
                            error: (NSError**)errorObject
{
    NSString * csvString = [NSString stringWithContentsOfFile: csvFilePath
                                                     encoding: encodingString
                                                        error: errorObject];
    // Detect any errors that occured.
    if ( [[*errorObject domain] isEqualToString: NSCocoaErrorDomain] ) {
        return nil;
    } else {
        return [NSArray stringArrayOfCsvString: csvString];
    }
}

+ (NSArray*) stringArrayOfCsvString: (NSString*) stringData
{
    NSMutableArray *rows = [NSMutableArray array];
    
    // Get newline character set
    NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
    
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@",\""];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
    
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:stringData];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) {
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
        NSMutableString *currentColumn = [NSMutableString string];
        while ( !finishedRow ) {
            NSString *tempString;
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
                [currentColumn appendString:tempString];
            }
            
            if ( [scanner isAtEnd] ) {
                if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) {
                if ( insideQuotes ) {
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
                else {
                    // End of row
                    if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ( [scanner scanString:@"\"" intoString:NULL] ) {
                if ( insideQuotes && [scanner scanString:@"\"" intoString:NULL] ) {
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""];
                }
                else {
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
                }
            }
            else if ( [scanner scanString:@"," intoString:NULL] ) {
                if ( insideQuotes ) {
                    [currentColumn appendString:@","];
                }
                else {
                    // This is a column separating comma
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                }
            }
        }
        if ( [columns count] > 0 ) [rows addObject:columns];
    }
    
    return rows;
}

-(BOOL) writeToCsvFile: (NSString*) csvFilePath
              encoding: (NSStringEncoding) stringEncoding
        fieldSeperator: (NSString*) fieldSeperator
        fieldEnclosure: (NSString*) fieldEnclosure
         lineSeperator: (NSString*) lineSeperator
                 error: (NSError**) error
{
    NSFileHandle *file = nil;
    BOOL successfulWriteOperation = YES;
    
    // Defensive Code: Encapsulate all our file I/O with exception handling
    //                 just in case something terrible wrong happens.
    @try
    {
        [[NSFileManager defaultManager] createFileAtPath: csvFilePath
                                                contents: [@"" dataUsingEncoding: stringEncoding]
                                              attributes: nil];
        file = [NSFileHandle fileHandleForWritingAtPath: csvFilePath];
        [file seekToEndOfFile];
        
        // Go through all the rows by column and append the file with a comma
        // seperated value.
        for ( NSArray *rows in self ){
            
            // Create an empty line string which we will populate.
            // Note: We have no responsibility of the object outside this block.
            NSMutableString * line = [NSMutableString string];
            
            // Go through the columns
            for ( NSObject * col in rows ) {
                
                // If we are to add enclosures, then do the the following...
                if (fieldEnclosure != nil) {
                    [line appendString: fieldEnclosure];
                    [self secureAppendCsvFieldColumn: col toCsvRowString: line];
                    [line appendString: fieldEnclosure];
                    
                    // Else if no enclosures are to be added, do the following.
                } else {
                    [self secureAppendCsvFieldColumn: col toCsvRowString: line];
                }
                
                [line appendString: fieldSeperator]; // Add field seperator
            }
            
            // Remove the last comma from the string.
            [line deleteCharactersInRange: NSMakeRange([line length]-1, 1)];
            
            [line appendString: lineSeperator]; // Add a new line sperator
            
            // Write the line to file
            [file writeData: [line dataUsingEncoding: stringEncoding]];
        }
    }
    @catch (NSException *exeption) {
        successfulWriteOperation = NO;
    }
    @finally {
        [file closeFile];
        file = nil;
    }
    
    return successfulWriteOperation;
}

-(BOOL) appendToCsvFile: (NSString*) csvFilePath
               encoding: (NSStringEncoding) stringEncoding
         fieldSeperator: (NSString*) fieldSeperator
         fieldEnclosure: (NSString*) fieldEnclosure
          lineSeperator: (NSString*) lineSeperator
                  error: (NSError**) error {
    BOOL successfulWriteOperation = YES;
    NSFileHandle * fh = nil;
    
    // Defensive Code: Encapsulate all our file I/O with exception handling
    //                 just in case something terrible wrong happens.
    @try {
        NSFileHandle * fh = [NSFileHandle fileHandleForWritingAtPath: csvFilePath];
        if ( !fh ) {
            [[NSFileManager defaultManager] createFileAtPath: csvFilePath
                                                    contents: nil
                                                  attributes:nil];
            fh = [NSFileHandle fileHandleForWritingAtPath: csvFilePath];
        }
        
        // Defensive Code: If we are not able to access the file handler.
        if ( !fh) {
            return NO;
        }
        
        // Go to the very end of the file.
        [fh seekToEndOfFile];
        
        // Go through all the rows by column and append the file with a comma
        // seperated value.
        for ( NSArray *rows in self ){
            
            // Create an empty line string which we will populate.
            // Note: We have no responsibility of the object outside this block.
            NSMutableString * line = [NSMutableString string];
            
            // Go through
            for ( NSString * col in rows ) {
                if (fieldEnclosure != nil) {
                    [line appendString: fieldEnclosure];
                    [self secureAppendCsvFieldColumn: col toCsvRowString: line];
                    [line appendString: fieldEnclosure];
                } else {
                    [self secureAppendCsvFieldColumn: col toCsvRowString: line];
                }
                
                [line appendString: fieldSeperator]; // Add field seperator
            }
            
            // Remove the last comma from the string.
            [line deleteCharactersInRange: NSMakeRange([line length]-1, 1)];
            
            [line appendString: lineSeperator]; // Add a new line sperator
            
            // Write the line to file
            [fh writeData: [line dataUsingEncoding: stringEncoding]];
        }
    }
    @catch (NSException *exception) {
        successfulWriteOperation = NO;
    }
    @finally {
        [fh closeFile];
        fh = nil;
    }
    
    return successfulWriteOperation;
}

@end
