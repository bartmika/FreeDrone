//
//  NSMutableArray+Queue.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-05.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

- (void) enqueue: (id) item;
- (id) dequeue;
@end
