//
//  UnreliableSocket.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

@interface UnreliableSocket : NSObject {
    unsigned int type;              // Store the type of transportation.
    unsigned int connected;         // Indicates we are connected.
    NSLock *udpSocketMutex;        // Used to synchronize out threads
   
    struct sockaddr_in serv_addr;
    struct sockaddr_in my_addr, cli_addr;
    NSInteger portno;
    int sockfd;
    socklen_t slen;
}

-(id)init;

-(void) dealloc;

-(void) startListeningOnPort: (NSUInteger) hostPort;

-(void) connectToServerAtIPAddress: (NSString*) ipAddress port: (NSUInteger) hostPort;

-(NSData*) blockingReceiveData;

-(void) sendData: (NSData*) data;

-(BOOL) isServer;

-(BOOL) isClient;

-(BOOL) isConnected;

-(BOOL) disconnect;

@end
