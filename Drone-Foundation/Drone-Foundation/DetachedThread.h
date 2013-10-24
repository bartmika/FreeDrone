//
//  DetachedThread.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-15.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_DetachedThread_h
#define Drone_Foundation_DetachedThread_h

// Standard Libaries
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

#define THREAD_DEFAULT_STACK_SIZE 0

typedef struct _DETACHEDTHREAD_T{
    // This variable is used to control synchronisity.
    pthread_mutex_t mutex;
    
    // This variable holds our current pointer to the thread we're running.
    pthread_t thread;
    
    // This variable holds our threads attributes
    pthread_attr_t attribute;
    
    // Indicates whether we are an attached or detached thread.
    unsigned int isJoinable;
    
    // Pointer to the function we are running
    void * function;
    
    // Pointer to the parameters of the function
    void * parameters;
} detachedThread_t;

detachedThread_t * detachedThreadInit(const void * ptrFunction, void * ptrParameters);

const int detachedThreadStart(detachedThread_t * ptrThread);

void detachedThreadDealloc(detachedThread_t * ptrThread);

void detachedThreadLock(detachedThread_t * ptrThread);

void detachedThreadUnlock(detachedThread_t * ptrThread);

void detachedThreadPOSIXSleep(unsigned int sec, unsigned int usec);

/**
 * @Precondition:
 *      1) "seconds" must be a non-negative, whole number.
 *      2) "nanoseconds" must be a non-negative, whole number.
 * @Postcondition:
 *      1) Makes the thread that called this function sleep for the specified
 *         durration of time.
 *
 * @Note:
 *      - Most efficient method, lease portable
 */
void detachedThreadNanoSleep(const unsigned int seconds, const unsigned int nanoseconds);

#endif
