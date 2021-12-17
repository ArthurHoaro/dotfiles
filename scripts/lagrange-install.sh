#!/bin/bash

git clone --recursive --branch release https://git.skyjake.fi/skyjake/lagrange /tmp/lagrange
mkdir /tmp/lagrange/build
cd /tmp/lagrange/build
cmake ../ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=~/installs/lagrange
cmake --build . --target install
