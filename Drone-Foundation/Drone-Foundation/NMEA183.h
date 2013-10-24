//
//  NMEA183.h
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#ifndef Drone_Foundation_NMEA183_h
#define Drone_Foundation_NMEA183_h

// Standard
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Custom
#include "GPS.h"

enum nmea183TalkerID_t {
    NU, // NU for Null value
    GP, // GP for GPS
    GS  // GS for GLONASS
};

/**
 * The following enum is responsible for providing identification for the
 * serial command received from the service.
 */
enum nmea183MessageType_t {
    NUL,  // Null value
    GGA,  // Time, position and fix type data
    GLL,  // Latitude, longitude, UTC time of position fix and status
    GSA,  // GPS receiver operating mode, satellites used in the position
    // solution, and DOP values
    
    GSV,  // Number of GPS satellites in view satellite ID numbers, elevation,
    // azimuth, & SNR values
    
    MSS,  // Signal-to-noise ratio, signal strength, frequency, and bit rate
    // from a radio-beacon receiver
    
    RMC,  // Time, date, position, course and speed data
    VTG,  // Course and speed information relative to the ground
    ZDA,  // PPS timing message (synchronized to PPS)
    //e150, // OK to send message
    //e151, // GPS Data and Extended Ephemeris Mask
    //e152, // Extended Ephemeris Integrity
    //e154  //   Extended Ephemeris ACK
};

/**
 * The following struct will hold the raw data passed from the GPS receiver that
 * is formatted using the NMEA183 protocol.
 */
typedef struct _NMEA183GGA_T{
    float UTC_Time;
    float Latitude;
    char NS_Indicator;
    float Longitude;
    char EW_Indicator;
    unsigned int PositionFix;
    unsigned int SatallitesUsed;
    float HDOP;
    float MSLAltitude;
    char MSLAltitudeUnit;
    float GeoidSeperation;
    char GeoidSeperationUnit;
    float AgeOfDiffCorr;
    float DiffRefStationID;
    char Checksum [8];
}nmea183gga_t;

typedef struct _NMEA183GLL_T{
    float Latitude;
    char NS_Indicator;
    float Longitude;
    char EW_Indicator;
    float UTC_Time;
    char Status;
    char Mode; // NMEA version 2.3 or greater
    char Checksum [8];
}nmea183gll_t;

typedef struct _NMEA183GSA {
    unsigned int MessageID;
    char Mode1;
    int Mode2;
    unsigned int SatelliteUsed[11]; // Support up to 12 satellites.
    float PDOP;
    float HDOP;
    float VDOP;
    char Checksum[8];
}nmea183gsa_t;

typedef struct _NMEA183GSV_SAT_T {
    unsigned int SatelliteID;
    float Elevation;
    float Azimuth;
    float SNR;
}nmea183_satellite_t;

typedef struct _NMEA183GSV_T {
    size_t Numb_Of_Messages;
    size_t Message_Number;
    size_t SatallitesInView;
    nmea183_satellite_t satellite[11]; // Track up to 11 Satellites at a time.
    char Checksum[8];
}nmea183gsv_t;

typedef struct _NMEA183MSS_T {
    //TODO: Impl.
}nmea183mss_t;

typedef struct _NMEA183RMC_T {
    float UTC_Time;
    char Status;
    float Latitude;
    char NS_Indicator;
    float Longitude;
    char EW_Indicator;
    float SpeedOverGround;
    float CourseOverGround;
    float Date;
    float MagneticVariation;
    char EW_Indicator2;
    char Mode; // NMEA version 2.3 or greater
    char Checksum [8];
}nmea183rmc_t;

typedef struct _NMEA183VTG_T {
    float Course;
    char Reference;
    float Course2;
    char Reference2;
    float Speed;
    char Units;
    char checksum [8];
}nmea183vtg_t;

typedef struct _NMEA183ZDA_T {
    //TODO: Impl.
}nmea183zda_t;

/**
 * The following struct is responsible for holding a NMEA183 object responsible
 * for decoding and encoding commands.
 */
typedef struct _NMEA183_t{
    enum nmea183TalkerID_t talkerID;
    enum nmea183MessageType_t messageType;
    
    nmea183gga_t gga;
    nmea183gll_t gll;
    nmea183gsa_t gsa;
    nmea183gsv_t gsv;
    nmea183mss_t mss;
    nmea183rmc_t rmc;
    nmea183vtg_t vtg;
    nmea183zda_t zda;
}nmea183_t;

/**
 * @Precondition:
 *      1) Enough memory available in our computer.
 * @Postcondition:
 *      1) Intializes the object.
 */
nmea183_t * nmea183Init();

/**
 * @Precondition:
 *      1) "protocol" must be an instantiated object.
 * @Postcondition:
 *      1) Deallocates our object.
 */
void nmea183Dealloc(nmea183_t * protocol);

/**
 * @Precondition:
 *      1) "sentence" myst be:
 *          - A pointer to dynamically allocated string
 *          - A non-null, nor empty string
 *          - String data formatted using the NMEA 183 protocol
 * @Postcondition:
 *      1) Returns a "nmea183MessageType_t" type value indicating the type of 
 *         command of the the current decode.
 */
enum nmea183MessageType_t nmea183GetMessageTypeOfCurrentDecode(nmea183_t * protocol);

/**
 * @Precondition:
 *      1) "protocol" must be an instantiated object.
 * @Postcondition:
 *      1) Returns a pointer to the string which contains our encoded
 *         NMEA 183 data.
 */
char * nmea183Encode(nmea183_t * protocol);

/**
 * @Precondition:
 *      1) "protocol" must be an instantiated object.
 *      2) "sentence" myst be:
 *          - A pointer to dynamically allocated string
 *          - A non-null, nor empty string
 *          - String data formatted using the NMEA 183 protocol
 * @Postcondition:
 *      1) Takes the data, decodes it, and saves it to our object.
 */
void nmea183Decode(nmea183_t * protocol, const char * sentence);

/**
 * @Precondition:
 *      1) "protocol" must be an instantiated object.
 * @Postcondition:
 *      1) Returns GPS coordinates of the decoded date in our object.
 */
gps_t nmea183ToGPSCoords(nmea183_t * protocol);

/**
 * @Precondition:
 *      1) "protocol" must be an instantiated object.
 * @Postcondition:
 *      1) Returns signed decimal degree coorindates of the decoded data in
 *         our object.
 */
sdd_t nmea183ToSDDCoords(nmea183_t * protocol);

/**
 * @Precondition:
 *      1) "protocol" must be an instantiated object.
 * @Postcondition:
 *      1) Returns a value of:
 *          - "1" if the object has no decoded data
 *          - "0" if the object has decoded data
 */
unsigned int nmea183IsEmpty(nmea183_t * protocol);

float nmea183ToHeading(nmea183_t * protocol);
float nmea183ToAltitude(nmea183_t * protocol);
float nmea184ToSpeed(nmea183_t * protocol);

#endif
