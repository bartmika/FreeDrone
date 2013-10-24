#!/bin/sh

#  unpackage+run.sh
#  Drone-Foundation
#
#  Created by Bartlomiej Mika on 2013-06-08.
#  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.
#
#  Note:
#   1) This file is to be run in your raspberry pi
#   2) This file is to be placed in your home folder (~/)
#
# Delete old directory and Unzip new code.
sudo rm -R ~/Drone-Foundation
mkdir ~/Drone-Foundation
tar -zxvf Drone.tar.gz -C ~/Drone-Foundation

# Delete old zip file.
rm ~/Drone.tar.gz

# Re-organize the directory structure.
cp -R ~/Drone-Foundation/tmp/Drone-Foundation ~/
rm -R ~/Drone-Foundation/tmp

# Enable our make script to be run in the system.
chmod u+x ~/Drone-Foundation/make.sh

# Run our make
~/Drone-Foundation/make.sh