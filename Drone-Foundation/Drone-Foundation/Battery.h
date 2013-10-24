//
//  Battery.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Battery : NSObject {
    float powerRating;
    float amps;
}

@property (atomic) float powerRating;
@property (atomic) float amps;

-(id)init;
-(id)initWithAmps: (float) theAmps;
-(id)initWithPowerRating: (float) thePowerRating;
-(id)initWithPowerRating: (float) thePowerRating amps: (float) theAmps;
-(void)dealloc;

@end
