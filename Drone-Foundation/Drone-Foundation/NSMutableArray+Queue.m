//
//  NSMutableArray+Queue.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-05.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

- (void) enqueue:(id)item {
    [self addObject: item];
}

- (id) dequeue {
    id item = nil;
    if ([self count] != 0) {
        item = [[[self objectAtIndex:0] retain] autorelease];
        [self removeObjectAtIndex:0];
    }
    return item;
}

@end
