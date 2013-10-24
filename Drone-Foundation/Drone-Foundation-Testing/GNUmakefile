GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
include $(GNUSTEP_MAKEFILES)/common.make

CC = clang
APP_NAME = TestDroneFoundation
TestDroneFoundation_OBJC_FILES = NSMutableArray+Stack.m TestNSMutableArray+Stack.m NSMutableArray+Queue.m TestNSMutableArray+Queue.m NSArray+CSV.m TestNSArray+CSV.m TestLowPassDataFilter.m TestHighPassDataFilter.m TestCompassBearing.m TestDetachedThread.m TestGPS.m TestNMEA183.m TestTTYReader.m TestGlobalSatBU353GPSReader.m GPSFormatter.m TestGPSFormatter.m GPSCoordinate.m TestGPSCoordinate.m GPSNavigation.m TestGPSNavigation.m TestPhidgetGPSReader.m GPSReader.m TestGPSReader.m TestPhidgetSpatialReader.m SpatialReader.m TestSpatialReader.m TestPhidgetSingleServoController.m ServoController.m TestServoController.m TestPhidgetSingleDCMotorController.m MotorController.m TestMotorController.m Battery.m TestBattery.m BatteryMonitor.m TestBatteryMonitor.m VirtualGPSReader.m TestVirtualGPSReader.m VirtualSpatialReader.m TestVirtualSpatialReader.m VirtualMotorController.m TestVirtualMotorController.m VirtualServoController.m TestVirtualServoController.m VirtualHardwareOperation.m VirtualBatteryMonitor.m TestVirtualBatteryMonitor.m TestVirtualHardwareOperation.m DroneLoggerOperation.m TestDroneLoggerOperation.m AutoPilotOperation.m TestAutoPilotOperation.m ReliableSocket.m TestReliableSocket.m UnreliableSocket.m TestUnreliableSocket.m RemoteControlOperation.m TestRemoteControlOperation.m RemoteMonitorOperation.m TestRemoteMonitorOperation.m TestDroneFoundation.m
TestDroneFoundation_C_FILES = LowPassDataFilter.c HighPassDataFilter.c CompassBearing.c DetachedThread.c GPS.c NMEA183.c TTYReader.c GlobalSatBU353GPSReader.c SpatialData.c PhidgetSpatialReader.c  PhidgetGPSReader.c PhidgetSingleServoController.c PhidgetSingleDCMotorController.c
TestDroneFoundation__OBJC_PRECOMPILED_HEADERS = Drone-Foundation-Testing-Prefix.pch
ADDITIONAL_CPPFLAGS += -I/usr/include/GNUstep -I/usr/lib/x86_64-linux-gnu/gcc/x86_64-linux-gnu/4.5.2/include -I/usr/include/x86_64-linux-gnu
ADDITIONAL_TOOL_LIB += -pthread -lm -lphidget21 -ldispatch
ADDITIONAL_OBJC_LIBS += -lphidget21

include $(GNUSTEP_MAKEFILES)/application.make

# Note: Currently gnustep does not successfully compile. The following error
#       is returend. Please investigate why?
#       
# pi@raspberrypi ~/tmp/Probe-Application/src $ openapp ./Probe.app
# Could not find /home/pi/tmp/Probe-Application/src/Probe.app/Probe executable/script