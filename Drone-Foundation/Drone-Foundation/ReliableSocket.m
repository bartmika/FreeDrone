//
//  ReliableSocket.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-06-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "ReliableSocket.h"

@implementation ReliableSocket

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                           PRIVATE FUNCTIONS                                //
//----------------------------------------------------------------------------//

#define kBufferMaxSize 65507
#define kTCPServerConfiguration 1
#define kTCPClientConfiguration 2

-(void) listeningServiceLoop{
    NSAutoreleasePool * listenServiceLoopPool = [NSAutoreleasePool new];
    
    [[NSThread currentThread] setName:@"ReliableSocket-ListeningServiceLoop"];
    
    while (connected == NO) {
               
        ipv4_socket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        
        if (ipv4_socket < 0){
            printf("TCP SERVER ERROR: opening socket\n");
            exit(EXIT_FAILURE);
        }
        bzero((char *) &(serv_addr), sizeof(serv_addr));
        
        serv_addr.sin_family = PF_INET;
        serv_addr.sin_addr.s_addr = INADDR_ANY;
        serv_addr.sin_port = htons(portno);
        
        // Bind the socket to the layer.
        if (bind( ipv4_socket, (struct sockaddr *) &(serv_addr),
                 sizeof(serv_addr)) < 0){
            printf("TCP SERVER ERROR: on binding\n");
            exit(EXIT_FAILURE);
        }
        
        listen(ipv4_socket, 5);
        
        clilen = sizeof(cli_addr);
        
        // WAIT AND ACCEPT COMMUNICATION FROM CLIENT HERE!
        newsockfd = accept(ipv4_socket,
                                      (struct sockaddr *) &(cli_addr),
                                      &(clilen));
                
        if (newsockfd < 0){ // Defensive code
            connected = NO;
        } else {
            connected = YES; // Tells our layer we are connected.
        }
    }
    [listenServiceLoopPool drain]; listenServiceLoopPool = nil;
}


#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

-(id)init {
    if (self = [super init]) {
        portno = 12345;
        receiveIO = [NSLock new];
    }
    
    return self;
}

-(void) dealloc {
    // Set the status of connected to 'NO' and give time for the service
    // loops to close before deallocating this object.
    connected = NO;
    [receiveIO release]; receiveIO = nil;
    [NSThread sleepForTimeInterval: 1.0f];
    
    [super dealloc];
}

-(void) startListeningOnPort: (NSUInteger) hostPort {
    portno = (unsigned int)hostPort;
    
    type = kTCPServerConfiguration;
    
    // Branch out from the current thread a seperate thread responsible for
    // checking if a client connected to our server.
    [NSThread detachNewThreadSelector:@selector(listeningServiceLoop) toTarget:self withObject: nil];
}

-(void) connectToServerAtHostname: (NSString*) hostnameString port: (NSUInteger) hostPort
{
    portno = (unsigned int)hostPort;
    hostname = (const char*)[hostnameString UTF8String];
    ipv4_socket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    if (ipv4_socket < 0){ // Defensive Code: Sockets not connect
        printf("TCP CLIENT ERROR: opening socket\n");
        exit(EXIT_FAILURE);
    }
    server = gethostbyname(hostname);
    if (server == NULL) {
        printf("TCP CLIENT ERROR: no such host\n");
        exit(EXIT_FAILURE);
    }
    bzero((char *) &(serv_addr), sizeof(serv_addr));
    
    serv_addr.sin_family = PF_INET;
    bcopy((char *)server->h_addr,
          (char *)&(serv_addr.sin_addr.s_addr),
          server->h_length);
    serv_addr.sin_port = htons(portno);
    
    if (connect(ipv4_socket,
                (struct sockaddr *) &(serv_addr),
                sizeof(serv_addr)) < 0){
        printf("TCP CLIENT ERROR: connecting\n");
        exit(EXIT_FAILURE);
    }
    
    connected = YES;
    type = kTCPClientConfiguration;
}

-(BOOL) isConnected {
    return connected;
}

-(BOOL) disconnect {
    close(newsockfd);
    close(ipv4_socket);
    
    connected = NO;
    return YES;
}

-(NSData*) receiveData {
    NSAssert(connected, @"Not connected\n");
    
    [receiveIO lock];
    
    NSData * data = nil;
    
    ssize_t bufferLen = 0;
    unsigned char buffer[kBufferMaxSize];
    memset(buffer, 0, kBufferMaxSize);
    
    switch (type) {
        case kTCPServerConfiguration:
            bufferLen = read(newsockfd, buffer, kBufferMaxSize);
            break;
        case kTCPClientConfiguration:
            bufferLen = read(ipv4_socket, buffer, kBufferMaxSize);
            break;
        default:
            break;
    }
    
    if (bufferLen > 0) {
        data = [[NSData alloc] initWithBytes: buffer
                                      length: bufferLen];
    }
    [receiveIO unlock];
    
    return [data autorelease];
}

-(void) sendData: (NSData*) data {
    NSAssert(data, @"Missing Data to Send\n");
    NSAssert(connected, @"Not connected\n");
    
    [receiveIO lock];
    
    // Send the data according to configuration.
    switch (type) {
        case kTCPServerConfiguration:
            write(newsockfd, [data bytes], [data length]);
            break;
        case kTCPClientConfiguration:
            write(ipv4_socket,[data bytes], [data length]);
            break;
        default:
            printf("ERROR OCCURED DURRING ATTEMPT AT SENDING RTSP DATA\n");
            break;
    }
    
    [receiveIO unlock];
}

-(BOOL) isServer {
    return type == kTCPServerConfiguration;
}

-(BOOL) isClient {
    return type == kTCPClientConfiguration;
}

@end
