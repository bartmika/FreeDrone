//
//  DetachedThread.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-15.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#include "DetachedThread.h"

#pragma mark -
#pragma mark PRIVATE
//----------------------------------------------------------------------------//
//                               PRIVATE                                      //
//----------------------------------------------------------------------------//

detachedThread_t * threadInit(const void * function,
                      void * parameter,
                      const size_t threadStackSize,
                      const unsigned int isJoinable) {
    assert(function);
    assert(isJoinable >= 0 && isJoinable <= 1);
    detachedThread_t * ptrThread = (detachedThread_t*) malloc(sizeof(detachedThread_t));
    if (ptrThread) {
        memset(ptrThread, 0, sizeof(detachedThread_t));
        
        // Initialize the variable which will handle mutexs for our unit tests.
        pthread_mutex_init(&ptrThread->mutex, NULL);
        
        pthread_attr_t attr;                    // Threads attributes
        pthread_attr_init(&attr); // Initialize our thread's attributes.
        
        if (isJoinable) {
            //TODO: Impl.
            ptrThread->isJoinable = 1;
        } else {
            // Configure the attributes of the threads to be joinable.
            pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
            ptrThread->isJoinable = 0;
        }
        
        // Default stack size is too small, let's increase the pthreads stacksize
        // from the small default value, to a larger value!
        if (threadStackSize) {
            pthread_attr_setstacksize (&attr, threadStackSize);
        }
        
        //ptrThread->thread = runningSessionThread;
        ptrThread->attribute = attr;
        ptrThread->function = (void*)function;
        ptrThread->parameters = parameter;
        
        return ptrThread;
    } else {
        perror("malloc");
        exit(EXIT_FAILURE);
    }
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                               PUBLIC                                       //
//----------------------------------------------------------------------------//

detachedThread_t * detachedThreadInit(const void * ptrFunction,
                                      void * ptrParameters) {
    assert(ptrFunction);
    return threadInit(ptrFunction, ptrParameters, THREAD_DEFAULT_STACK_SIZE, 0);
}

const int detachedThreadStart(detachedThread_t * ptrThread) {
    if (ptrThread) {
        int rc = 0;
        rc = pthread_create(&ptrThread->thread,     // The thread reference
                            &ptrThread->attribute,  // Thread's attribute reference
                            ptrThread->function,    // Our function to run.
                            ptrThread->parameters); // Function parameters
        
        if (rc) { // Defensive Code: Prevent errors in thread creation.
            printf("ERROR; return code from pthread_create() is %d\n", rc);
            exit(EXIT_FAILURE);
        }
        
        return rc;
    }
    
    return -1;
}

void detachedThreadDealloc(detachedThread_t * ptrThread) {
    if (ptrThread) {
        // Close the mutex
        pthread_mutex_lock(&ptrThread->mutex);
        pthread_mutex_unlock(&ptrThread->mutex);
        pthread_mutex_destroy(&ptrThread->mutex);
        
        // Cancel the thread if it already hasn't been
        pthread_cancel(ptrThread->thread);
        ptrThread->thread = 0;
        
        // Free attribue and wait for the other threads
        pthread_attr_destroy(&ptrThread->attribute);
        
        free(ptrThread);
        ptrThread = NULL;
    }
}

void detachedThreadPOSIXSleep(unsigned int sec, unsigned int usec){
    // Sleep for 1.5 sec
    struct timeval tv;
    tv.tv_sec = 1 * sec;
    tv.tv_usec = 1 * usec;
    select(0, NULL, NULL, NULL, &tv);
}

void detachedThreadNanoSleep(const unsigned int seconds, const unsigned int nanoseconds){
    struct timespec tim, tim2;
    tim.tv_sec = 1 * seconds;
    tim.tv_nsec = 1 * nanoseconds;
    
    if ( nanosleep(&tim , &tim2) < 0 ) {
        printf("Nano sleep system call failed \n");
        return;
    }
}

void detachedThreadLock(detachedThread_t * ptrThread) {
    if (ptrThread) {
        pthread_mutex_lock(&ptrThread->mutex);
    }
}

void detachedThreadUnlock(detachedThread_t * ptrThread) {
    if (ptrThread) {
        pthread_mutex_unlock(&ptrThread->mutex);
    }
}
