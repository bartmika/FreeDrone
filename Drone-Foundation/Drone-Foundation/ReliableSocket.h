//
//  ReliableSocket.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard Objective-C Libraries
#import <Foundation/Foundation.h>

// Custom
#import "NSMutableArray+Queue.h"

// Standard C Libraries
#include <assert.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <pthread.h>

#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

// http://stackoverflow.com/questions/3261965/so-reuseport-on-linux
#ifndef SO_REUSEPORT
    #define SO_REUSEPORT 15
#endif

@interface ReliableSocket : NSObject {
    // Networking
    //----------------
    unsigned int type;              // Store the type of transportation.
    unsigned int connected;         // Indicates we are connected.
    NSLock *receiveIO;        // Used to synchronize out threads
    unsigned running;               // Used to indicate whether to run loop.
    unsigned int endian;            // Remember what byte-order encoding to use.
    const char * hostname;       // Remember who we are / connect to.
    
    int ipv4_socket;                     // Reference to the SERVERS socket
    int newsockfd;                  // Reference to the CLIENTS socket
    int portno;                     // Port number
    int n;                          // Buffer size
    
    // Server configuration
    struct sockaddr_in serv_addr;
    
    // Client configuration
    struct sockaddr_in cli_addr;
    socklen_t clilen;
    struct hostent *server;
}

-(id)init;

-(void) dealloc;

-(void) startListeningOnPort: (NSUInteger) hostPort;

-(void) connectToServerAtHostname: (NSString*) hostnameString port: (NSUInteger) hostPort;

-(BOOL) isConnected;

-(BOOL) disconnect;

-(NSData*) receiveData;

-(void) sendData: (NSData*) data;

-(BOOL) isServer;

-(BOOL) isClient;

@end
