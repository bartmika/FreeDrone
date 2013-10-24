#!/bin/sh

#  package.sh
#  Probe-Application
#
#  Created by Bartlomiej Mika on 2013-06-06.
#  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
#
#  This script takes all the necessary code for the probe and places it
#  in a specific directory structure.
#
#  Note: This script is to be run on your mac computer!
#

# Create the directory structure
echo "Generating Drone-Foundation...\n"
mkdir /tmp/Drone-Foundation
mkdir /tmp/Drone-Foundation/src
mkdir /tmp/Drone-Foundation/test
mkdir /tmp/Drone-Foundation/bin

# Copy 'objective-c' code
cp /Users/bartlomiejmika/Eurasiasoft/Development/Drone/Drone-Foundation/Drone-Foundation/* \
/tmp/Drone-Foundation/src
cp /Users/bartlomiejmika/Eurasiasoft/Development/Drone/Drone-Foundation/Drone-Foundation-Testing/* \
/tmp/Drone-Foundation/test

# Copy Misc things...
cp /Users/bartlomiejmika/Eurasiasoft/Development/Drone/Drone-Foundation/make.sh \
/tmp/Drone-Foundation

# Clean up the 'src' folder
rm /tmp/Drone-Foundation/src/*.1
rm /tmp/Drone-Foundation/test/*.1

# Compress our file locally
cd /tmp
tar -zcvf Drone.tar.gz /tmp/Drone-Foundation

# Send file to the 'pi' users 'home' directory.
scp /tmp/Drone.tar.gz pi@raspberrypi: # "raspberrypi" is the hostname of the computer

# Delete the tmp file locally.
rm /tmp/Drone.tar.gz
rm -r /tmp/Drone-Foundation

# Developers Note:
# To unzip the 'Drone.tar.gz' file, use the following command:
# tar -zxvf Drone.tar.gz -C ~/Drone
