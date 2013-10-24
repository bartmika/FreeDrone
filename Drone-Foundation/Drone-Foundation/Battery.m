//
//  Battery.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "Battery.h"

@implementation Battery

@synthesize powerRating;
@synthesize amps;

-(id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

-(id)initWithAmps: (float) theAmps {
    // Use default initializer
    self = [self init];
    
    // Set the amps.
    [self setAmps: theAmps];
    
    return self;
}

-(id)initWithPowerRating: (float) thePowerRating {
    // Use default initializer
    self = [self init];
    
    [self setPowerRating: thePowerRating];

    return self;
}

-(id)initWithPowerRating: (float) thePowerRating amps: (float) theAmps {
    // Use default initializer
    self = [self init];
    
    [self setAmps: theAmps];
    [self setPowerRating: thePowerRating];
    
    return self;
}

-(void)dealloc {
    [super dealloc];
}

@end
