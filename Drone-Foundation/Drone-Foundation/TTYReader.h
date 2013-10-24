//
//  TTYReader.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_TTYReader_h
#define Drone_Foundation_TTYReader_h

// Standard
#include <assert.h>
#include <termios.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/ioctl.h>

// Custom
#include "DetachedThread.h"

typedef struct _TTYREADER_T{
    // Serial Interface communication variables.
    //------------------------------
    // Configuration variables for accessing UNIX 'tty' services.
    char * deviceName;
    int fd;
    int fdflags;
    struct termios tty;
    
    unsigned int running;
    
    pthread_mutex_t bufferIO;
    
    char buffer[255];
    char terminator[32];
    
    // The thread running in the background
    detachedThread_t * serviceLoopThread;
}ttyReader_t;

/**
 * @Precondition:
 *      1) Enough memory available in our computer.
 *      2) /dev file writes ANSI code
 *      3) "device" must be:
 *              - A UNIX filepath
 *              - A valid formatted filepath
 *              - Non-null, nor empty filepath
 *              - Filepath points to an existing /dev file.
 *      4) "baud_rate" must be the value 4800
 *      5) "terminator_string" must be:
 *              - Non-null, nor empty string value
 *              - Must not be longer then 32 characters
 * @Postcondition:
 *      1) Initializes and instantiates the object for usage
 *      2) Object creates a thread which immediatly starts recording results
 *         from the tty device.
 *      3) Delays main thread for a few seconds while the object loads up.
 */
ttyReader_t * ttyrInit(const char * device,
                       const int baud_rate,
                       const char * terminator_string);

/**
 * @Precondition:
 *      1) "ttyr" must be a properly instantiated object of type "TTYReader".
 *      2) "buffer" must be a pointer to some block of EMPTY memory which
 *         is able to hold a string value. It must at minumum be able to store
 *         256 characters.
 *      3) "bufferLen" is a positive whole number. (Again, must be greater then
 *         or equal to 256).
 *      4) "ttyr" must be set to be in 'buffered_mode',
 * @Postcondition:
 */
const unsigned int ttyrRead(ttyReader_t* ttyr,
                                    char * buffer,
                                    const size_t bufferLen);

/**
 * @Precondition:
 *      1) "ttyr" must be a properly instantiated object of type "TTYReader".
 * @Postcondition:
 *      1) Terminates connection with tty device.
 *      2) Stops the thread running because of this object.
 *      3) Deallocates and frees the memory associated with this object.
 */
void ttyrDealloc(ttyReader_t * tty);

#endif
