GNUSTEP_MAKEFILES=/usr/share/GNUstep/Makefiles
include $(GNUSTEP_MAKEFILES)/common.make

CC = clang
APP_NAME = Drone
Drone_HEADERS = Drone-Application-Prefix.pch
Drone_OBJC_FILES = NSMutableArray+Stack.m NSMutableArray+Queue.m NSArray+CSV.m GPSFormatter.m GPSCoordinate.m GPSNavigation.m GPSReader.m SpatialReader.m ServoController.m MotorController.m Battery.m BatteryMonitor.m DroneLoggerOperation.m AutoPilotOperation.m ReliableSocket.m RemoteControlOperation.m RemoteMonitorOperation.m DroneController.m main.m
Drone_C_FILES = LowPassDataFilter.c HighPassDataFilter.c CompassBearing.c SpatialData.c PhidgetSpatialReader.c  PhidgetGPSReader.c PhidgetSingleServoController.c PhidgetSingleDCMotorController.c DetachedThread.c NMEA183.c TTYReader.c GlobalSatBU353GPSReader.c
ADDITIONAL_CPPFLAGS += -I/usr/include/GNUstep -I/usr/lib/x86_64-linux-gnu/gcc/x86_64-linux-gnu/4.5.2/include -I/usr/include/x86_64-linux-gnu
ADDITIONAL_TOOL_LIB += -pthread -lm -lphidget21 -ldispatch
ADDITIONAL_OBJC_LIBS += -lphidget21

include $(GNUSTEP_MAKEFILES)/application.make
