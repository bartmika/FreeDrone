#!/bin/sh

#  package.sh
#  Drone-Application
#
#  Created by Bartlomiej Mika on 2013-06-21.
#  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.

# Create the directory structure
echo "Generating Drone-Application...\n"
mkdir /tmp/Drone-Application
mkdir /tmp/Drone-Application/src
mkdir /tmp/Drone-Application/test
mkdir /tmp/Drone-Application/bin

# Copy 'objective-c' code
cp /Users/bartlomiejmika/Eurasiasoft/Development/Drone/Drone-Foundation/Drone-Foundation/* \
/tmp/Drone-Application/src
cp /Users/bartlomiejmika/Eurasiasoft/Development/Drone/Drone-Application/Drone-Application/* \
/tmp/Drone-Application/src
cp /Users/bartlomiejmika/Eurasiasoft/Development/Drone/Drone-Application/Drone-Application-Testing/* \
/tmp/Drone-Application/test

# Copy Misc things...
# cp /Users/bartlomiejmika/Eurasiasoft/Development/Drone/Drone-Foundation/make.sh \
# /tmp/Drone-Foundation

# Clean up the 'src' folder
rm /tmp/Drone-Application/src/*.1
rm /tmp/Drone-Application/test/*.1

# Compress our file locally
cd /tmp
tar -zcvf DroneApp.tar.gz /tmp/Drone-Application > /dev/null 2>&1

# Send file to the 'pi' users 'home' directory.
scp /tmp/DroneApp.tar.gz pi@192.168.0.35:

# Delete the tmp file locally.
rm /tmp/DroneApp.tar.gz
rm -r /tmp/Drone-Application

# Developers Note:
# To unzip the 'Drone.tar.gz' file, use the following command:
# tar -zxvf Drone.tar.gz -C ~/Drone
