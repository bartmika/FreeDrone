//
//  TestDetachedThread.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-15.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestDetachedThread.h"

@implementation TestDetachedThread

static NSAutoreleasePool *pool = nil;

+(void)setUp
{
    // Set-up code here.
    pool = [NSAutoreleasePool new];
}

+(void)tearDown
{
    // Tear-down code here.
    [pool drain]; pool = nil;
}

void * primaryServiceLoop(void * threadid) {
#ifdef __APPLE__ // Load ONLY if the computer is a Apple Macintosh.
    pthread_setname_np("ThreadOne");
#endif

    int i;
    
    for (i = 0; i <= 10; i++) {
        printf("P: %i\n", i);
        detachedThreadNanoSleep(1, 0);
    }
    
    pthread_exit((void *)threadid); // Terminate our thread
}

void secondaryServiceLoop(void * threadid) {
#ifdef __APPLE__ // Load ONLY if the computer is a Apple Macintosh.
    pthread_setname_np("ThreadTwo");
#endif
    int i;
    
    for (i = 0; i <= 10; i++) {
        printf("S: %i\n", i);
        detachedThreadNanoSleep(2, 0);
    }
    
    pthread_exit((void *)threadid);
}
void tertiaryServiceLoop(void * threadid) {
#ifdef __APPLE__ // Load ONLY if the computer is a Apple Macintosh.
    pthread_setname_np("ThreadThree");
#endif
    int i;
    
    for (i = 0; i <= 1000; i++) {
        printf("T: %i\n", i);
        detachedThreadNanoSleep(3, 0);
    }
    
    pthread_exit((void *)threadid);
}


+(void) unitTestDetachedThread {
    printf("Thread\n");
    printf("\tInit\n");
    detachedThread_t *ptrThreadOne = detachedThreadInit(primaryServiceLoop, NULL);
    assert(ptrThreadOne);
    detachedThread_t *ptrThreadTwo = detachedThreadInit(secondaryServiceLoop, NULL);
    assert(ptrThreadTwo);
    detachedThread_t *ptrThreadThree = detachedThreadInit(tertiaryServiceLoop, NULL);
    assert(ptrThreadThree);
    
    detachedThreadStart(ptrThreadOne); // Start the thread.
    detachedThreadStart(ptrThreadTwo);
    detachedThreadStart(ptrThreadThree);
    
    // Attempt to lock & unlock
    detachedThreadLock(ptrThreadOne);
    detachedThreadLock(ptrThreadTwo);
    detachedThreadNanoSleep(1, 0);
    detachedThreadUnlock(ptrThreadTwo);
    detachedThreadUnlock(ptrThreadOne);
    
    // Attempt to sleep
    detachedThreadNanoSleep(5, 0);
    detachedThreadPOSIXSleep(5, 0);
    
    printf("\tDealloc\n");
    detachedThreadDealloc(ptrThreadOne);
    detachedThreadDealloc(ptrThreadTwo);
    detachedThreadDealloc(ptrThreadThree);
    ptrThreadOne = NULL;
    ptrThreadTwo = NULL;
    ptrThreadThree = NULL;
    printf("Thread: Successful\n");
}


+(void) performUnitTests {
    [self setUp];
    [self unitTestDetachedThread];
    [self tearDown];
}

@end
