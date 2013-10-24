#!/bin/sh

#  unpackage.sh
#  Drone-Application
#
#  Created by Bartlomiej Mika on 2013-06-21.
#  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.

# Place this file in the ~/ user in your raspberry pi.

# Delete old directory and Unzip new code.
echo "Unzipping"
sudo rm -R ~/Drone-Application > /dev/null 2>&1
mkdir ~/Drone-Application
tar -zxvf DroneApp.tar.gz -C ~/Drone-Application > /dev/null 2>&1

# Delete old zip file.
rm ~/DroneApp.tar.gz

# Re-organize the directory structure.
cp -R ~/Drone-Application/tmp/Drone-Application ~/
rm -R ~/Drone-Application/tmp

# Generate our app
mkdir ~/Drone-Application/tmp
cp ~/Drone-Application/test/* ~/Drone-Application/tmp
cp ~/Drone-Application/src/* ~/Drone-Application/tmp

echo "Beginning to make...";
cd ~/Drone-Application/tmp
sudo make
sudo mv obj ../bin/obj
sudo mv Drone.app ../bin/Drone.app

cd ~/Drone-Application/bin
sudo openapp ./Drone.app -l -a -n