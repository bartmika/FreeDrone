//
//  NSMutableArray+Stack.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-05-26.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Stack)

- (void) push: (id) item;
- (id) pop;

@end
