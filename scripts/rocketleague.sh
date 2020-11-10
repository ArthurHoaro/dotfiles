#!/usr/bin/bash
sudo modprobe -r xpad &&
sudo xboxdrv --quiet --silent --detach-kernel-driver --trigger-as-button --ui-axismap x2=ABS_Z,y2=ABS_RZ --ui-buttonmap A=BTN_B,B=BTN_X,X=BTN_A,TR=BTN_THUMBL,TL=BTN_MODE,GUIDE=BTN_THUMBR &

wine ~/.wine/drive_c/Program\ Files\ \(x86\)/Steam/Steam.exe -no-dwrite
