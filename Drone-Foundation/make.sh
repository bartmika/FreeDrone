#!/bin/sh

#  make.sh
#  Drone-Foundation
#
#  Created by Bartlomiej Mika on 2013-06-08.
#  Copyright (c) 2013 Bartlomiej Mika. All rights reserved.

# Generate our app
mkdir ~/Drone-Foundation/tmp
cp ~/Drone-Foundation/src/* ~/Drone-Foundation/tmp
cp ~/Drone-Foundation/test/* ~/Drone-Foundation/tmp

cd ~/Drone-Foundation/tmp
sudo make
sudo mv obj ../bin/obj
sudo mv TestDroneFoundation.app ../bin/TestDroneFoundation.app

cd ~/Drone-Foundation/bin
sudo openapp ./TestDroneFoundation.app