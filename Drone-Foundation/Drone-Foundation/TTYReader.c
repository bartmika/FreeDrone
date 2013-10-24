//
//  TTYReader.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#include "TTYReader.h"

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                     PRIVATE VARIABLES / FUNCTIONS                          //
//----------------------------------------------------------------------------//

/**
 * @Precondition:
 *      1) "ttyr" must be a properly instantiated object of type "TTYReader".
 *      2) "output" must be a pointer to the memory block that can store
 *         string values. Must be at minimum 256 characters in size.
 * @Postcondition:
 *      1) Reads a line from the tty device.
 */
ssize_t ttyrGet(ttyReader_t* ptrTTYReader,
                char * ptrOutput,
                const size_t outputLen){
    // Precondition
    assert(ptrTTYReader);
    assert(ptrOutput);
    assert(outputLen > 0);
    
    memset(ptrOutput, 0, outputLen); // Clear the memory of the previous data.
    
    // The character we get returned from the serial device.
    unsigned char byte = '\0';
    
    // The character pointer we'll be using.
    char c = '\0';
    
    // Index position of the two arrays: output & terminator
    ssize_t i = 0, j = 0;
    
    // Keep track of what got read.
    ssize_t len;
    
    // Keep track how many items we are suppose to match
    ssize_t match = strlen(ptrTTYReader->terminator);
    
    // Unlimited loop
    for( ;; ) {
        len = read( ptrTTYReader->fd, &byte, 1 ); //8192
        c = (char)byte;
        
        // If a character was read.
        if ( len > 0 ){
            
            // Check if the read character is in sequence with the terminator
            // string.
            if ( c == ptrTTYReader->terminator[j] ) {
                j++; // Increment position.
                
                // Go through the next series of character inputs from the
                // terminal and see if they match the pattern of our terminator.
                // If they do, then we are finished!
                for ( j=1; j < match; j++ ) {
                    len = read( ptrTTYReader->fd, &c, 1 ); // Read char from serial
                    
                    if ( c == ptrTTYReader->terminator[j] ) { // If pattern matched
                        j++;
                    } else {  // Else no pattern exists - restart everything.
                        j = 0;
                        i = 0;
                        memset(ptrOutput, 0, outputLen);
                    }
                }
            } else { // Else we can store our results.
                ptrOutput[i++] = c;
            }
        }
        
        // If we found a match, then exit the loop which in turn exits the
        // current function.
        if ( j > match ) {
            break;
        }
    }
    return len;
}

/**
 * @Precondition:
 *      1) "threadid" must be a properly instantiated object of type "TTYReader"
 * @Postcondition:
 *      1) Runs a service loop which extracts a single line from the tty device
 *         every few seconds and stores the extracted result in a buffer.
 */
void * ttyrServiceLoop(void * threadid){
    // Give a name to this thread if we are using the mac computer.
    // (Note: Reason is because it makes debugging easier)
#ifdef __APPLE__
    pthread_setname_np("TTYReaderServiceLoop"); // For GDB.
#endif
    
    // Convert the parameter into an access point into our object.
    ttyReader_t * ptrTTYReader = (ttyReader_t*)threadid;
    
    const size_t bufferLen = 255;
    char buffer[bufferLen] = {0};
    
    while ( ptrTTYReader->running ) { // While our reader is running.
        memset(buffer, 0, bufferLen); // Clear the contents of our buffer.
        
        // Poll the serial device and get our result string.
        ttyrGet(ptrTTYReader, buffer, bufferLen);
        
        pthread_mutex_lock(&(ptrTTYReader->bufferIO)); // Unlock this object
        if ( buffer ) { // Defenive Code: Prevent nulls from entering this section
            strcpy(ptrTTYReader->buffer, buffer); // Make a copy of it to our buffer.
        }
        pthread_mutex_unlock(&(ptrTTYReader->bufferIO)); // Unlock this object.
        
        detachedThreadPOSIXSleep(1, 0); // Temporarily sleep
    }
    
    pthread_exit((void *)threadid); // Terminate our thread
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

ttyReader_t * ttyrInit(const char * ptrDeviceID,
                       const int baudRate,
                       const char * ptrTerminator){
    assert(ptrDeviceID); // Defensive Code.
    assert(baudRate);
    assert(ptrTerminator);
    
    // Alloc
    //--------
    ttyReader_t * ptrTTYReader = (ttyReader_t*)malloc(sizeof(ttyReader_t));
    if ( ptrTTYReader == NULL ) {
        perror("malloc");
        return NULL;
    } else {
        memset(ptrTTYReader, 0, sizeof(ttyReader_t));
    }
    
    // Init
    //-------
    // Initialize the variable which we'll use to sync between our thread
    // and the current thread.
    pthread_mutex_init(&(ptrTTYReader->bufferIO), NULL);
    
    int fd; // Identification number of the file-handler resource
    
    struct termios tio; // Our terminal Input/Output system.
    memset(&tio, 0, sizeof(struct termios));
    
    // Attempt to open up our serial device.
    fd = open(ptrDeviceID , O_RDONLY | O_NOCTTY | O_NONBLOCK);
    if ( fd == -1 ) {
        free(ptrTTYReader); ptrTTYReader = NULL;
        perror("open");
        return NULL;
    }
    
    // Attempt to connect.
    int fdflags;
    if ( (fdflags = fcntl (fd, F_GETFL)) == -1 ) {
        printf("Could not connect to device... is it connected?\n");
        perror("fcntl");
        exit(EXIT_FAILURE);
    } if ( tcgetattr (fd, &tio) ) {
        printf("screwed up serial port!\n");
        perror("tcgetattr");
        exit(EXIT_FAILURE);
    }
    
    cfmakeraw(&tio); // Make Raw Mode
    
    switch (baudRate) { // Adjust the TTY reader according to the baud rate.
        case 4800:
            cfsetispeed(&tio,B4800);
            cfsetospeed(&tio,B4800);
            break;
        default:
            printf("Only supported baud rate is 4800.\n");
            exit(EXIT_FAILURE);
            break;
    }
    tcsetattr(fd,TCSANOW,&tio);
    
    //    tio.c_cflag = CREAD | CLOCAL;     // turn on READ
    //    tio.c_cflag |= CS8;
    //    tio.c_cc[VMIN] = 0;
    //    tio.c_cc[VTIME] = 10;     // 1 sec timeout
    //    ioctl(fd, TIOCSETA, &tio);
    
    // Assign
    ptrTTYReader->fd = fd;
    ptrTTYReader->deviceName = strdup(ptrDeviceID);
    ptrTTYReader->tty = tio;
    ptrTTYReader->fdflags = fdflags;
    ptrTTYReader->running = 1;
    strcpy(ptrTTYReader->terminator, ptrTerminator);
    
    // Start the service loop which is responsible for running in the background
    // and polling every sentance that arrives from the serial device.
    ptrTTYReader->serviceLoopThread = detachedThreadInit(ttyrServiceLoop, ptrTTYReader);
    detachedThreadStart(ptrTTYReader->serviceLoopThread);
    
    detachedThreadPOSIXSleep(3, 0); // Give some time for our service loop to start up.
    
    return ptrTTYReader; // Return pointer to our object.
}

const unsigned int ttyrRead(ttyReader_t* ptrTTYReader,
                      char * ptrBuffer,
                      const size_t bufferLen){
    // Defensive Code: Ensure non-nulls and valid size are detected.
    assert(ptrTTYReader);
    assert(ptrBuffer);
    assert(bufferLen > 0);
    
    pthread_mutex_lock(&(ptrTTYReader->bufferIO)); // Lock this object
        
    // Copy the contents in the object's buffer.
    strcpy(ptrBuffer, ptrTTYReader->buffer);
        
    pthread_mutex_unlock(&(ptrTTYReader->bufferIO)); // Unlock this object
    return 1;
}


void ttyrDealloc(ttyReader_t * ptrTTYReader){
    assert(ptrTTYReader);
    
    // Sync with the running thread by turning it off and wait until
    // it is finished.
    ptrTTYReader->running = 0;
    pthread_mutex_destroy(&(ptrTTYReader->bufferIO));
    
    // Close the thread
    detachedThreadUnlock(ptrTTYReader->serviceLoopThread);
    detachedThreadDealloc(ptrTTYReader->serviceLoopThread);
    ptrTTYReader->serviceLoopThread = NULL;
    
    // Close the device.
    close(ptrTTYReader->fd);
    
    // Free the name of the device.
    free(ptrTTYReader->deviceName); ptrTTYReader->deviceName = NULL;
    
    // Free the memory used by our object.
    free(ptrTTYReader); ptrTTYReader = NULL;
}

// Special Thanks:
// http://en.wikibooks.org/wiki/Serial_Programming:Serial_Linux
// http://en.wikibooks.org/wiki/Serial_Programming:Unix/termios
// http://electronics.stackexchange.com/questions/5167/set-rs232-port-options-from-macos-x-cli
// http://stackoverflow.com/questions/2504714/reading-serial-data-from-c-osx-dev-tty
// http://wiring.org.co/learning/tutorials/C++/
//
