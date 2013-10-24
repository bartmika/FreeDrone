//
//  NSArray+CSV.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-25.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

@interface NSArray (CSV)

+ (NSArray*) stringArrayOfCsvFile: (NSString*) csvFilePath
                         encoding: (NSStringEncoding) encodingString
                            error: (NSError**)errorObject;

+ (NSArray*) stringArrayOfCsvString: (NSString*) string;

-(BOOL) writeToCsvFile: (NSString*) csvFilePath
              encoding: (NSStringEncoding) stringEncoding
        fieldSeperator: (NSString*) fieldSeperator
        fieldEnclosure: (NSString*) fieldEnclosure
         lineSeperator: (NSString*) lineSeperator
                 error: (NSError**) error;

-(BOOL) appendToCsvFile: (NSString*) csvFilePath
               encoding: (NSStringEncoding) stringEncoding
         fieldSeperator: (NSString*) fieldSeperator
         fieldEnclosure: (NSString*) fieldEnclosure
          lineSeperator: (NSString*) lineSeperator
                  error: (NSError**) error;

@end
