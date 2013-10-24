//
//  UnreliableSocket.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-22.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "UnreliableSocket.h"

#define kBufferMaxSize 65507
#define kUDPServerConfiguration 1
#define kUDPClientConfiguration 2

@implementation UnreliableSocket

-(void) listeningServiceLoop {
    NSAutoreleasePool * listenServiceLoopPool = [NSAutoreleasePool new];
   
    [[NSThread currentThread] setName:@"UnreliableSocket-ListeningServiceLoop"];
    
    slen=sizeof(cli_addr);
    
    if ((sockfd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP))==-1) {
        NSLog(@"Failed starting up socket");
        exit(EXIT_FAILURE);
    }
    
    bzero(&my_addr, sizeof(my_addr));
    my_addr.sin_family = PF_INET;
    my_addr.sin_port = htons(portno);
    my_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    if (bind(sockfd, (struct sockaddr* ) &my_addr, sizeof(my_addr))==-1) {
        NSLog(@"Failed binding socket\n");
        exit(EXIT_FAILURE);
    } else {
        connected = YES;
    }
    
    [listenServiceLoopPool drain]; listenServiceLoopPool = nil;
}

-(id)init {
    if (self = [super init]) {
        udpSocketMutex = [NSLock new];
    }
    return self;
}

-(void) dealloc {
    [udpSocketMutex release]; udpSocketMutex = nil;
    [super dealloc];
}

-(void) startListeningOnPort: (NSUInteger) hostPort {
    portno = (unsigned int)hostPort;
    
    type = kUDPServerConfiguration;
    
    // Branch out from the current thread a seperate thread responsible for
    // checking if a client connected to our server.
    [NSThread detachNewThreadSelector:@selector(listeningServiceLoop) toTarget:self withObject: nil];
}

-(void) connectToServerAtIPAddress: (NSString*) ipAddress port: (NSUInteger) hostPort {
    type = kUDPClientConfiguration;
    
    slen=sizeof(serv_addr);
    
    if ((sockfd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP))==-1) {
        NSLog(@"Failed to initialize socket\n");
        exit(EXIT_FAILURE);
    }
    
    bzero(&serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = PF_INET;
    serv_addr.sin_port = htons(hostPort);
    if (inet_aton([ipAddress UTF8String], &serv_addr.sin_addr)==0)
    {
        fprintf(stderr, "inet_aton() failed\n");
        exit(1);
    } 
    
    connected = YES;    
}

-(NSData*) blockingReceiveData {
    [udpSocketMutex lock];
    
    NSData * data = nil;
    
    unsigned char buffer[kBufferMaxSize];
    memset(buffer, 0, kBufferMaxSize);
    
    if (type == kUDPServerConfiguration) {
        if (recvfrom(sockfd, buffer, kBufferMaxSize, 0, (struct sockaddr*)&cli_addr, &slen) == -1) {
            NSLog(@"Failed from recvfrom\n");
        }
    }
    if (type == kUDPClientConfiguration) {
        if (recvfrom(sockfd, buffer, kBufferMaxSize, 0, (struct sockaddr*)&serv_addr, &slen) == -1) {
            NSLog(@"Failed from recvfrom\n");
        }
    }
    
    if (slen > 0) {
        data = [[NSData alloc] initWithBytes: (const void*)buffer
                                       length: slen];
    }

    [udpSocketMutex unlock];
    return [data autorelease];
}

-(void) sendData: (NSData*) data {
    [udpSocketMutex lock];
    
    if (type == kUDPClientConfiguration) {
        if (sendto(sockfd, (char*)[data bytes], [data length], 0, (struct sockaddr*)&serv_addr, slen) == -1) {
            NSLog(@"Failed to sendto\n");
        }
    }
    if (type == kUDPServerConfiguration) {
        if (sendto(sockfd, [data bytes], [data length], 0, (struct sockaddr*)&cli_addr, slen) == -1) {
            NSLog(@"Failed to sendto\n");
        }
    }
    
    [udpSocketMutex unlock];
}

-(BOOL) isServer {
    return (type == kUDPServerConfiguration);
}

-(BOOL) isClient {
    return (type == kUDPClientConfiguration);
}

-(BOOL) isConnected {
    return connected;
}

-(BOOL) disconnect {
    close(sockfd);
    connected = NO;
    return connected;
}

@end
