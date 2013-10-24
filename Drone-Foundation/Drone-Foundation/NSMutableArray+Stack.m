//
//  NSMutableArray+Stack.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

- (void) push:(id)item
{
    [self addObject: item];
}

- (id) pop
{
    id item = nil;
    if ([self count] != 0) {
        item = [[[self lastObject] retain] autorelease];
        [self removeLastObject];
    }
    
    return item;
}


@end
