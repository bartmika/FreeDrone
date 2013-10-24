//
//  TestNMEA183.m
//  Drone-Foundation
//
//  Created by Bartlomiej Mika on 2013-07-14.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

#import "TestNMEA183.h"

@implementation TestNMEA183

static NSAutoreleasePool *pool = nil;

+(void)setUp
{
    // Set-up code here.
    pool = [NSAutoreleasePool new];
}

+(void)tearDown
{
    // Tear-down code here.
    [pool drain]; pool = nil;
}

+(void) testNMEA183RMC {
    nmea183_t *protocol = nmea183Init();
    
    // TODO
    
    nmea183Dealloc(protocol);
    protocol = NULL;
}

+(void) testNMEA183GetMessageType {
    // Initialize our object and verify it worked
    nmea183_t *protocol = nmea183Init();
    assert(protocol);
    
    nmea183Decode(protocol, "$GPGGA,152735.000,4257.6609,N,08116.2048,W,1,08,1.0,257.7,M,-34.5,M,,0000*65");
    assert(GGA == nmea183GetMessageTypeOfCurrentDecode(protocol));
    nmea183Decode(protocol, "$GPGLL,4257.6609,N,08116.2048,W,152736.000,A,A*42");
    assert(GLL == nmea183GetMessageTypeOfCurrentDecode(protocol));
    nmea183Decode(protocol, "$GPGSA,A,protocol, ,,,,,1.7,1.0,1.4*33");
    assert(GSA == nmea183GetMessageTypeOfCurrentDecode(protocol));
    nmea183Decode(protocol, "$GPGSV,3,1,12,07,74,176,36,08,57,309,,19,52,053,38,11,48,137,42*74");
    assert(GSV == nmea183GetMessageTypeOfCurrentDecode(protocol));
    nmea183Decode(protocol, "$GPMSS,3,1,12,07,74,176,36,08,57,309,,19,52,053,38,11,48,137,42*74");
    assert(MSS == nmea183GetMessageTypeOfCurrentDecode(protocol));
    nmea183Decode(protocol, "$GPRMC,152734.000,A,4257.6609,N,08116.2048,W,0.18,53.53,150912,,,A*40");
    assert(RMC == nmea183GetMessageTypeOfCurrentDecode(protocol));
    nmea183Decode(protocol, "$GPVTG,27.98,T,,M,0.09,N,0.2,K,A*32");
    assert(VTG == nmea183GetMessageTypeOfCurrentDecode(protocol));
    nmea183Decode(protocol, "$GPZDA,27.98,T,,M,0.09,N,0.2,K,A*32");
    assert(ZDA == nmea183GetMessageTypeOfCurrentDecode(protocol));
    
    nmea183Dealloc(protocol); protocol = NULL;
}

+(void) testNMEA183GGA {
    // Initialize our object and verify it worked
    nmea183_t *protocol = nmea183Init();
    assert(protocol);
    
    nmea183Decode(protocol, "$GPGGA,152735.000,4257.6609,N,08116.2048,W,1,08,1.0,257.7,M,-34.5,M,,0000*65");
    
    sdd_t coords = nmea183ToSDDCoords(protocol);
    assert(coords.latitude != 0 && coords.longitude != 0);
    
    gps_t gps_coords = nmea183ToGPSCoords(protocol);
    assert(gps_coords.lat != 0 || gps_coords.lon != 0);
    assert(gps_coords.lon_dir == 'W' || gps_coords.lat_dir == 'N');
    assert(protocol->gga.Latitude != 0.0f && protocol->gga.Longitude != 0.0f);
    assert(protocol->gga.NS_Indicator == 'N' && protocol->gga.EW_Indicator == 'W');
    
    // Run various samples.
    nmea183Decode(protocol, "$GPGGA,224632.000,4257.6613,N,08116.2034,W,1,07,1.5,263.2,M,-34.5,M,,0000*69");
    nmea183Decode(protocol, "$GPGGA,152736.000,4257.6609,N,08116.2048,W,1,08,1.0,257.7,M,-34.5,M,,0000*66");
    nmea183Decode(protocol, "$GPGGA,152737.000,4257.6609,N,08116.2047,W,1,08,1.0,257.7,M,-34.5,M,,0000*68");
    nmea183Decode(protocol, "$GPGGA,152738.000,4257.6609,N,08116.2047,W,1,07,1.1,257.6,M,-34.5,M,,0000*68");
    nmea183Decode(protocol, "$GPGGA,152739.000,4257.6609,N,08116.2047,W,1,09,0.8,257.5,M,-34.5,M,,0000*6C");
    nmea183Decode(protocol, "$GPGGA,152740.000,4257.6608,N,08116.2048,W,1,09,0.8,257.4,M,-34.5,M,,0000*6D");
    
    nmea183Dealloc(protocol); protocol = NULL;
}

+(void) testNMEA183GLL {
    // Initialize our object and verify it worked
    nmea183_t *protocol = nmea183Init();
    assert(protocol);
    
    nmea183Decode(protocol, "$GPGLL,4257.6609,N,08116.2048,W,152736.000,A,A*42");
    assert((int)protocol->gll.Latitude ==42);
    assert((int)protocol->gll.Longitude == 81);
    assert(protocol->gll.NS_Indicator == 'N');
    assert(protocol->gll.EW_Indicator == 'W');
    assert(protocol->gll.UTC_Time == 152736);
    assert(protocol->gll.Status == 'A');
    assert(strcmp(protocol->gll.Checksum, "A*42") == 0);
    
    nmea183Dealloc(protocol); protocol = NULL;
}

+(void) testNMEA183GSA {
    // Initialize our object and verify it worked
    nmea183_t *protocol = nmea183Init();
    assert(protocol);
    
    nmea183Decode(protocol, "$GPGSA,A,3,10,02,04,17,28,,,,,,,,4.6,2.7,3.7*3A");
    
    assert(protocol->gsa.Mode1 == 'A');
    assert(protocol->gsa.Mode2 == 3);
    assert(protocol->gsa.SatelliteUsed[0] == 10);
    assert(protocol->gsa.SatelliteUsed[1] == 2);
    assert(protocol->gsa.SatelliteUsed[2] == 4);
    assert(protocol->gsa.PDOP == 0.0f);
    assert(protocol->gsa.HDOP == 4.6f);
    assert(protocol->gsa.VDOP == 2.7f);
    assert(strcmp(protocol->gsa.Checksum, "3.7*3A") == 0);
    
    nmea183Dealloc(protocol); protocol = NULL;
}

+(void) testNMEA183GSV {
    // Initialize our object and verify it worked
    nmea183_t *protocol = nmea183Init();
    assert(protocol);
    
    nmea183Decode(protocol, "$GPGSV,3,1,12,07,74,176,36,08,57,309,,19,52,053,38,11,48,137,42*74");

    assert(protocol->gsv.Numb_Of_Messages == 3);
    assert(protocol->gsv.Message_Number== 1);
    assert(protocol->gsv.SatallitesInView == 12);
    assert(protocol->gsv.satellite[0].SatelliteID == 7);
    assert(protocol->gsv.satellite[1].SatelliteID == 8);
    assert(protocol->gsv.satellite[2].SatelliteID == 19);
    assert(strcmp(protocol->gsv.Checksum, "42*74") == 0);
    
    nmea183Decode(protocol, "$GPGSV,2,1,07,07,79,048,42,02,51,062,43,26,36,256,42,27,27,138,42*71");
    nmea183Decode(protocol, "$GPGSV,2,2,07,09,23,313,42,04,19,159,41,15,12,041,42*41");
    
    nmea183Dealloc(protocol); protocol = NULL;
}

+(void) testNMEA183VTG {
    // TODO: Impl.
}

+ (void) testNMEA183GetSpeed {
    //TODO: Impl.
}

+ (void) testNMEA183GetHeading {
    //TODO: Impl.
}

+(void) testNMEA183GetAltitude {
    //TODO: Impl.
}

+(void) testNMEA183{
    // Load up the object we'll be testing and verify it loaded.
    nmea183_t *protocol = nmea183Init();
    assert(protocol);
    
    nmea183Decode(protocol, "$GPRMC,152734.000,A,4257.6609,N,08116.2048,W,0.18,53.53,150912,,,A*40");
    nmea183Decode(protocol, "$GPVTG,53.53,T,,M,0.18,N,0.3,K,A*37");
    nmea183Decode(protocol, "$GPGLL,4257.6609,N,08116.2048,W,152735.000,A,A*41");
    nmea183Decode(protocol, "$GPRMC,152735.000,A,4257.6609,N,08116.2048,W,0.09,27.98,150912,,,A*45");
    nmea183Decode(protocol, "$GPVTG,27.98,T,,M,0.09,N,0.2,K,A*32");
    nmea183Decode(protocol, "$GPGLL,4257.6609,N,08116.2048,W,152736.000,A,A*42");
    nmea183Decode(protocol, "$GPGSA,A,3,07,02,26,27,09,04,15, , , , , ,1.8,1.0,1.5*3");
    nmea183Decode(protocol, "$GPGSV,3,1,12,07,74,176,36,08,57,309,,19,52,053,38,11,48,137,42*74");
    nmea183Decode(protocol, "$GPGSV,3,2,12,28,30,284,33,01,29,148,41,03,23,054,27,26,16,316,08*77");
    nmea183Decode(protocol, "$GPGSV,3,3,12,13,13,199,26,06,09,051,23,17,04,225,,16,02,088,*77");
    nmea183Decode(protocol, "$GPRMC,152736.000,A,4257.6609,N,08116.2048,W,0.10,253.40,150912,,,A*7A");
    nmea183Decode(protocol, "$GPVTG,253.40,T,,M,0.10,N,0.2,K,A*0E");
    nmea183Decode(protocol, "$GPGLL,4257.6609,N,08116.2047,W,152737.000,A,A*4C");
    nmea183Decode(protocol, "$GPRMC,152737.000,A,4257.6609,N,08116.2047,W,0.09,27.29,150912,,,A*42");
    nmea183Decode(protocol, "$GPVTG,27.29,T,,M,0.09,N,0.2,K,A*38");
    nmea183Decode(protocol, "$GPGLL,4257.6609,N,08116.2047,W,152738.000,A,A*43");
    nmea183Decode(protocol, "$GPRMC,152738.000,A,4257.6609,N,08116.2047,W,0.15,39.96,150912,,,A*4B");
    nmea183Decode(protocol, "$GPVTG,39.96,T,,M,0.15,N,0.3,K,A*3F");
    nmea183Decode(protocol, "$GPGLL,4257.6609,N,08116.2047,W,152739.000,A,A*42");
    nmea183Decode(protocol, "$GPRMC,152739.000,A,4257.6609,N,08116.2047,W,0.16,254.80,150912,,,A*77");
    nmea183Decode(protocol, "$GPVTG,254.80,T,,M,0.16,N,0.3,K,A*02");
    nmea183Decode(protocol, "$GPGLL,4257.6608,N,08116.2048,W,152740.000,A,A*42");
    nmea183Decode(protocol, "$GPRMC,152740.000,A,4257.6608,N,08116.2048,W,0.24,237.67,150912,,,A*7A");
    
    nmea183Dealloc(protocol); protocol = NULL;
}

+(void) performUnitTests {
    NSLog(@"NMEA183\n");
    [self setUp];
    [self testNMEA183];
    [self testNMEA183GetMessageType];
    [self testNMEA183GGA];
    [self testNMEA183GLL];
    [self testNMEA183GSA];
    [self testNMEA183GSV];
    [self testNMEA183RMC];
    [self tearDown];
    NSLog(@"NMEA183: Successful\n\n");
}

@end
