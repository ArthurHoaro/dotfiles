#!/bin/bash

cd ~/installs/calcurse
./autogen.sh
./configure
make
sudo make install
