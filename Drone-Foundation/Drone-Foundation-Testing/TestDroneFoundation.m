//
//  TestDroneFoundation.m
//  Drone-Foundation-Testing
//
//  Created by Bartlomiej Mika on 2013-06-08.
//  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
//

// Standard
#import <Foundation/Foundation.h>

// Custom
#import "TestNSMutableArray+Queue.h"
#import "TestNSMutableArray+Stack.h"
#import "TestNSArray+CSV.h"
#import "TestLowPassDataFilter.h"
#import "TestHighPassDataFilter.h"
#import "TestCompassBearing.h"
#import "TestDetachedThread.h"
#import "TestTTYReader.h"
#import "TestGPS.h"
#import "TestNMEA183.h"
#import "TestGlobalSatBU353GPSReader.h"
#import "TestGPSFormatter.h"
#import "TestGPSCoordinate.h"
#import "TestGPSNavigation.h"
#import "TestPhidgetGPSReader.h"
#import "TestGPSReader.h"
#import "TestPhidgetSpatialReader.h"
#import "TestSpatialReader.h"
#import "TestPhidgetSingleServoController.h"
#import "TestServoController.h"
#import "TestPhidgetSingleDCMotorController.h"
#import "TestMotorController.h"
#import "TestBattery.h"
#import "TestBatteryMonitor.h"
#import "TestVirtualGPSReader.h"
#import "TestVirtualSpatialReader.h"
#import "TestVirtualMotorController.h"
#import "TestVirtualServoController.h"
#import "TestVirtualBatteryMonitor.h"
#import "TestVirtualHardwareOperation.h"
#import "TestDroneLoggerOperation.h"
#import "TestAutoPilotOperation.h"
#import "TestReliableSocket.h"
#import "TestUnreliableSocket.h"
#import "TestRemoteControlOperation.h"
#import "TestRemoteMonitorOperation.h"

// Note:
// cd ~/Drone-Foundation/bin
// openapp ./TestDroneFoundation

int main(int argc, const char * argv[])
{
    // Main function always must have an autorelease object at the beginning.
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    
//    [TestNSMutableArray_Queue performUnitTests];
//    [TestNSMutableArray_Stack performUnitTests];
//    [TestNSArray_CSV performUnitTests];
//    [TestLowPassDataFilter performUnitTests];
//    [TestHighPassDataFilter performUnitTests];
//    [TestCompassBearing performUnitTests];
//    [TestDetachedThread performUnitTests];
//    [TestGPS performUnitTests];
    [TestNMEA183 performUnitTests];
//    [TestTTYReader performUnitTests];
    [TestGlobalSatBU353GPSReader performUnitTests];
//    [TestGPSFormatter performUnitTests];
//    [TestGPSCoordinate performUnitTests];
//    [TestGPSNavigation performUnitTests];
//    [TestPhidgetGPSReader performUnitTests];
//    [TestGPSReader performUnitTests];
//    [TestPhidgetSpatialReader performUnitTests];
//    [TestSpatialReader performUnitTests];
//    [TestPhidgetSingleServoController performUnitTests]; 
//    [TestServoController performUnitTests]; 
//    [TestPhidgetSingleDCMotorController performUnitTests];
//    [TestMotorController performUnitTests];
//    [TestBattery performUnitTests];
//    [TestBatteryMonitor performUnitTests];
//    [TestVirtualGPSReader performUnitTests];
//    [TestVirtualSpatialReader performUnitTests];
//    [TestVirtualMotorController performUnitTests];
//    [TestVirtualServoController performUnitTests];
//    [TestVirtualBatteryMonitor performUnitTests];
//    [TestVirtualHardwareOperation performUnitTests];
//    [TestDroneLoggerOperation performUnitTests];
//    [TestAutoPilotOperation performUnitTests];
//    [TestReliableSocket performUnitTests];
//    [TestUnreliableSocket performUnitTests];
//    [TestRemoteAccessService performUnitTests];
//    [TestRemoteControlOperation performUnitTests];
//    [TestRemoteMonitorOperation performUnitTests];
    
    [pool drain]; pool = nil;
    return EXIT_SUCCESS;
}

