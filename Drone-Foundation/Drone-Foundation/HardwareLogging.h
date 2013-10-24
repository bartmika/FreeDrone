//
//  HardwareLogging.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Interface to implement among hardware abstraction code to allow checking
 * of issues pertaining to the hardware running or any problems that it
 * might have.
 */
@protocol HardwareLogging <NSObject>

-(BOOL) deviceIsOperational;

/**
 * Note: Every device has a unique key and value pair associated with it.
 *       The hardware interface will tell you the key/value pair.
 */
-(NSDictionary*) pollDeviceForData;

@end
