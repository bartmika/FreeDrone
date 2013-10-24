//
//  NMEA183.c
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//
#include "NMEA183.h"

#pragma mark -
#pragma mark Private
//----------------------------------------------------------------------------//
//                     PRIVATE VARIABLES / FUNCTIONS                          //
//----------------------------------------------------------------------------//

#define kDefaultBufferLength 127
#define kDefaultParserIndex 32
#define kDefaultParserLength 255

enum nmea183TalkerID_t nmea183GetTalkerID(const char * ptrSentence){
    assert(ptrSentence);
    
    if ( ptrSentence[1] == 'G' && ptrSentence[2] == 'P' ) {
        return GP;
    } else if ( ptrSentence[1] == 'G' && ptrSentence[2] == 'S' ) {
        return GS;
    } else {
        return NU;
    }
}

/**
 * @Precondition:
 *      1) "sentence" myst be:
 *          - A pointer to dynamically allocated string
 *          - A non-null, nor empty string
 *          - String data formatted using the NMEA 183 protocol
 * @Postcondition:
 *      1) Intializes the object.
 */
enum nmea183MessageType_t nmea183GetMessageType(const char * ptrSentence) {
    if ( ptrSentence == NUL ) { // Defensive Code: Prevent Nulls.
        return NUL;
    }
    
    if ( ptrSentence[3] == 'G' ) { // GGA, GLL, GSA, GSV
        if ( ptrSentence[4] == 'G' && ptrSentence[5] == 'A' ) {
            return GGA;
        } if ( ptrSentence[4] == 'L' && ptrSentence[5] == 'L' ) {
            return GLL;
        } if ( ptrSentence[4] == 'S' && ptrSentence[5] == 'A' ) {
            return GSA;
        } if ( ptrSentence[4] == 'S' && ptrSentence[5] == 'V' ) {
            return GSV;
        }
    }
    
    if ( ptrSentence[3] == 'M' && ptrSentence[4] == 'S' && ptrSentence[5] == 'S' ) {
        return MSS;
    } if ( ptrSentence[3] == 'R' && ptrSentence[4] == 'M' && ptrSentence[5] == 'C' ) {
        return RMC;
    } if ( ptrSentence[3] == 'V' && ptrSentence[4] == 'T' && ptrSentence[5] == 'G' ) {
        return VTG;
    } if ( ptrSentence[3] == 'Z' && ptrSentence[4] == 'D' && ptrSentence[5] == 'A' ) {
        return ZDA;
    }
    
    return NUL;
}

/**
 * @Precondition:
 *      in: Value must be of degrees-minutes-seconds type.
 * @Postcondition:
 *      Returns the full signed decimal degrees of the coordinate.
 */
float nmea183ConvertDMS2Degrees(float in){
    int degrees = in / 100; // Makes first two digits integer.
    float decDegrees = (in - (100 * degrees)) / 60.0;
    return degrees + decDegrees; // Return the full degrees
}

void nmea183SplitByChar(const char * ptrSentence,
                        char target,
                        char ptrSplit[kDefaultParserIndex][kDefaultParserLength]) {
    char buffer[kDefaultParserLength] = {0};
    size_t i = 0, j = 0;
    char c = 'a';
    size_t index = 0;
    // Go through and populate our array.
    while ( c != '\0' ) {
        // Get the character
        c = ptrSentence[i++];
        
        // If our character matches the target, or we've found a null
        // then store our string into the array.
        if ( c == target || c == '\0' ) {
            size_t k ;
            for (k = 0; k < strlen(buffer); k++) {
                ptrSplit[index][k] = buffer[k];
            }
            index++;
            
            // Defensive Code: Ensure we don't cross over the limit
            assert(index < kDefaultParserIndex);
            
            memset(buffer, 0, kDefaultParserLength);
            j=0;
            
            // Else keep track of all the characters which we will use to populate
            // our string for the array.
        }else{
            buffer[j++] = c;
        }
    }    
}

// $GPGGA,152735.000,4257.6609,N,08116.2048,W,1,08,1.0,257.7,M,-34.5,M,,0000*65"
nmea183gga_t nmea183GetGGA(const char * ptrSentence){
    assert(ptrSentence);
    
    // Define the object which will hold our raw reference to the data.
    nmea183gga_t gga = {};
    
    // Multi-dimensional array responsible for holding our parsed items.
    char decodedArray[kDefaultParserIndex][kDefaultParserLength] = {};
    
    // Split into our items.
    nmea183SplitByChar(ptrSentence, ',', decodedArray);
    
    gga.UTC_Time = atof(decodedArray[1]);
    gga.Latitude = atof(decodedArray[2]);
    gga.Latitude = nmea183ConvertDMS2Degrees(gga.Latitude);
    gga.NS_Indicator = decodedArray[3][0];
    gga.Longitude = atof(decodedArray[4]);
    gga.Longitude = nmea183ConvertDMS2Degrees(gga.Longitude);
    gga.EW_Indicator = decodedArray[5][0];
    gga.PositionFix = atoi(decodedArray[6]);
    gga.SatallitesUsed = atoi(decodedArray[7]);
    gga.HDOP = atof(decodedArray[8]);
    gga.MSLAltitude = atof(decodedArray[9]);
    gga.MSLAltitudeUnit = decodedArray[10][0];
    gga.GeoidSeperation = atof(decodedArray[11]);
    gga.GeoidSeperationUnit = decodedArray[12][0];
    gga.AgeOfDiffCorr = atof(decodedArray[14]);
    
    return gga;
}

nmea183gll_t nmea183GetGLL(const char * ptrSentence){
    assert(ptrSentence);
    
    nmea183gll_t gll = {};
    
    // Multi-dimensional array responsible for holding our parsed items.
    char decodedArray[kDefaultParserIndex][kDefaultParserLength] = {};
    
    // Split into our items.
    nmea183SplitByChar(ptrSentence, ',', decodedArray);
    
    gll.Latitude = atof(decodedArray[1]);
    gll.Latitude = nmea183ConvertDMS2Degrees(gll.Latitude);
    gll.NS_Indicator = decodedArray[2][0];
    gll.Longitude = atof(decodedArray[3]);
    gll.Longitude = nmea183ConvertDMS2Degrees(gll.Longitude);
    gll.EW_Indicator = decodedArray[4][0];
    gll.UTC_Time = atof(decodedArray[5]);
    gll.Status = decodedArray[6][0];
    gll.Mode = '\0'; // UNSUPPORTED in NMEA183
    strcpy(gll.Checksum, decodedArray[7]);
    return gll;
}

nmea183gsa_t nmea183GetGSA(const char * ptrSentence) {
    assert(ptrSentence);
    
    nmea183gsa_t gsa = {};
    
    // Multi-dimensional array responsible for holding our parsed items.
    char decodedArray[kDefaultParserIndex][kDefaultParserLength] = {};
    
    // Split into our items.
    nmea183SplitByChar(ptrSentence, ',', decodedArray);
    
    gsa.Mode1 = decodedArray[1][0];
    gsa.Mode2 = atoi(decodedArray[2]);
    gsa.SatelliteUsed[0] = atoi(decodedArray[3]);
    gsa.SatelliteUsed[1] = atoi(decodedArray[4]);
    gsa.SatelliteUsed[2] = atoi(decodedArray[5]);
    gsa.SatelliteUsed[3] = atoi(decodedArray[6]);
    gsa.SatelliteUsed[4] = atoi(decodedArray[7]);
    gsa.SatelliteUsed[5] = atoi(decodedArray[8]);
    gsa.SatelliteUsed[6] = atoi(decodedArray[9]);
    gsa.SatelliteUsed[7] = atoi(decodedArray[10]);
    gsa.SatelliteUsed[8] = atoi(decodedArray[11]);
    gsa.SatelliteUsed[9] = atoi(decodedArray[12]);
    gsa.SatelliteUsed[10] = atoi(decodedArray[13]);
    gsa.PDOP = atof(decodedArray[14]);
    gsa.HDOP = atof(decodedArray[15]);
    gsa.VDOP = atof(decodedArray[16]);
    strcpy(gsa.Checksum, decodedArray[17]);
    return gsa;
}

nmea183gsv_t nmea183GetGSV(const char * ptrSentence){
    assert(ptrSentence);
    
    nmea183gsv_t gsv = {};
    
    // Multi-dimensional array responsible for holding our parsed items.
    char decodedArray[kDefaultParserIndex][kDefaultParserLength] = {};
    
    // Split into our items.
    nmea183SplitByChar(ptrSentence, ',', decodedArray);
    
    gsv.Numb_Of_Messages = atoi(decodedArray[1]);
    gsv.Message_Number = atoi(decodedArray[2]);
    gsv.SatallitesInView = atoi(decodedArray[3]);

    gsv.satellite[0].SatelliteID = atof(decodedArray[4]);
    gsv.satellite[0].Elevation = atof(decodedArray[5]);
    gsv.satellite[0].Azimuth = atof(decodedArray[6]);
    gsv.satellite[0].SNR = atof(decodedArray[7]);
    
    gsv.satellite[1].SatelliteID = atof(decodedArray[8]);
    gsv.satellite[1].Elevation = atof(decodedArray[8]);
    gsv.satellite[1].Azimuth = atof(decodedArray[10]);
    gsv.satellite[1].SNR = atof(decodedArray[11]);
    
    gsv.satellite[2].SatelliteID = atof(decodedArray[12]);
    gsv.satellite[2].Elevation = atof(decodedArray[13]);
    gsv.satellite[2].Azimuth = atof(decodedArray[14]);
    gsv.satellite[2].SNR = atof(decodedArray[15]);
    
    gsv.satellite[3].SatelliteID = atof(decodedArray[16]);
    gsv.satellite[3].Elevation = atof(decodedArray[17]);
    gsv.satellite[3].Azimuth = atof(decodedArray[18]);
    gsv.satellite[3].SNR = ' ';
    
    strcpy(gsv.Checksum, decodedArray[19]);
    
    // TODO: Implement
    return gsv;
}

nmea183mss_t nmea183GetMSS(const char * ptrSentence){
    assert(ptrSentence);
    
    printf("%s\n", ptrSentence);
    
    nmea183mss_t vtg = {};
    // TODO: Implement
    return vtg;
}


nmea183rmc_t nmea183GetRMC(const char * ptrSentence){
    assert(ptrSentence);
    
    nmea183rmc_t rmc = {};
    
    // Multi-dimensional array responsible for holding our parsed items.
    char decodedArray[kDefaultParserIndex][kDefaultParserLength] = {};
    
    // Split into our items.
    nmea183SplitByChar(ptrSentence, ',', decodedArray);

    rmc.UTC_Time = atof(decodedArray[1]);
    rmc.Status = decodedArray[2][0];
    rmc.Latitude = atof(decodedArray[3]);
    rmc.Latitude = nmea183ConvertDMS2Degrees(rmc.Latitude);
    rmc.NS_Indicator = decodedArray[4][0];
    rmc.Longitude = atof(decodedArray[5]);
    rmc.Longitude = nmea183ConvertDMS2Degrees(rmc.Longitude);
    rmc.EW_Indicator = decodedArray[6][0];
    rmc.SpeedOverGround = atof(decodedArray[7]); // Knots
    rmc.CourseOverGround = atof(decodedArray[8]); // Degrees
    //rmc.Date = decodedArray[9];
    rmc.MagneticVariation = atof(decodedArray[10]);
    rmc.EW_Indicator2 = atof(decodedArray[11]);
    rmc.Mode = '\0'; // UNSUPPORTED
    strcpy(rmc.Checksum, decodedArray[12]);
    // TODO: Implement
    return rmc;
}

nmea183vtg_t nmea183GetVTG(const char * ptrSentence){
    assert(ptrSentence);
    
    printf("%s\n", ptrSentence);
    
    nmea183vtg_t vtg = {};
    // TODO: Implement
    return vtg;
}

nmea183zda_t nmea183GetZDA(const char * ptrSentence){
    assert(ptrSentence);
    
    printf("%s\n", ptrSentence);
    
    nmea183zda_t vtg = {};
    // TODO: Implement
    return vtg;
}

#pragma mark -
#pragma mark Public
//----------------------------------------------------------------------------//
//                            PUBLIC FUNCTIONS                                //
//----------------------------------------------------------------------------//

nmea183_t * nmea183Init(){
    // Alloc
    nmea183_t * ptrNMEA = (nmea183_t*)malloc(sizeof(nmea183_t));
    if ( ptrNMEA == NULL ) {
        perror("malloc");
        return NULL;
    } else {
        memset(ptrNMEA, 0, sizeof(nmea183_t));
    }
    
    return ptrNMEA;
}

void nmea183Dealloc(nmea183_t * ptrProtocol){
    assert(ptrProtocol);
    free(ptrProtocol);
    ptrProtocol = NULL;
}

enum nmea183MessageType_t nmea183GetMessageTypeOfCurrentDecode(nmea183_t * protocol) {
    assert(protocol);
    return protocol->messageType;
}

char * nmea183encode(nmea183_t * ptrProtocol){
    assert(ptrProtocol);
    
    return NULL; // TODO: Implement
}

void nmea183Decode(nmea183_t * ptrProtocol, const char * ptrSentence){
    // Defensive Code: Prevent nulls and ordinary string sentences.
    assert(ptrProtocol);
    assert(ptrSentence);
    
    if ( ptrSentence[0] != '$' ) {
        return;
    }
    
    ptrProtocol->talkerID = nmea183GetTalkerID(ptrSentence);       // Get Talker ID
    ptrProtocol->messageType = nmea183GetMessageType(ptrSentence); // Get Message Type
    
    switch (ptrProtocol->messageType) { // Process NMEA data according to msg type.
        case NUL: // Unsupported Format / Proprietery Format.
            break; 
        case GGA: // Global Positioning System Fixed Data
            ptrProtocol->gga = nmea183GetGGA(ptrSentence);
            break;
        case GLL: // Geographic Position - Latitude/Longitude
            ptrProtocol->gll = nmea183GetGLL(ptrSentence);
            break;
        case GSA: // GNSS DOP and Active Satellites
            ptrProtocol->gsa = nmea183GetGSA(ptrSentence);
            break;
        case GSV: // GNSS Satellites in View
            ptrProtocol->gsv = nmea183GetGSV(ptrSentence);
            break;
        case MSS: // MSK Receiver Signal
            ptrProtocol->mss = nmea183GetMSS(ptrSentence);
            break;
        case RMC: // Recommended Minimum Specific GNSS Data
            ptrProtocol->rmc = nmea183GetRMC(ptrSentence);
            break;
        case VTG: // Course Over Ground and Ground Speed
            ptrProtocol->vtg = nmea183GetVTG(ptrSentence);
            break;
        case ZDA: // Time & Date
            ptrProtocol->zda = nmea183GetZDA(ptrSentence);
            break;
            //case e150:
            //    break;
            //case e151:
            //    break;
            //case e152:
            //    break;
            //case e154:
            //    break;
        default:
            break;
    }
}

gps_t nmea183ToGPSCoords(nmea183_t * ptrProtocol){
    assert(ptrProtocol);
    
    gps_t gps = {ptrProtocol->gga.Latitude,
        ptrProtocol->gga.NS_Indicator,
        ptrProtocol->gga.Longitude,
        ptrProtocol->gga.EW_Indicator};
    
    return gps;
}

sdd_t nmea183ToSDDCoords(nmea183_t * ptrProtocol){
    assert(ptrProtocol);
    
    gps_t gps = nmea183ToGPSCoords(ptrProtocol);
    sdd_t gps_coords = gps2sdd(&gps);
    
    return gps_coords;
}


unsigned int nmea183IsEmpty(nmea183_t * ptrProtocol){
    assert(ptrProtocol);
    
    // Grab out GGA value and check
    nmea183gga_t gga = ptrProtocol->gga;
    
    // Check if all the fields look empty.
    if (gga.AgeOfDiffCorr == 0 &&
        gga.DiffRefStationID == 0 &&
        gga.GeoidSeperation == 0 &&
        gga.GeoidSeperationUnit == '\0' &&
        gga.UTC_Time == 0 &&
        gga.Latitude == 0 &&
        gga.Longitude == 0 &&
        gga.NS_Indicator == '\0' &&
        gga.EW_Indicator == '\0' &&
        gga.PositionFix == 0 &&
        gga.SatallitesUsed == 0 &&
        gga.HDOP == 0 &&
        gga.MSLAltitude == 0 &&
        gga.MSLAltitudeUnit == '\0') {
        return 1;
    } else {
        return 0;
    }
}

float nmea183ToHeading(nmea183_t * protocol) {
    return 0;
}

float nmea183ToAltitude(nmea183_t * protocol) {
    return 0;
}

float nmea184ToSpeed(nmea183_t * protocol) {
    return 0;
}

// Special Thanks:
//  http://www.instructables.com/id/GPS-for-Lazy-Old-Geeks/step3/My-GPS-program/
