#!/bin/bash

pacman -Q | awk '{ print $1 }' | sort > /tmp/pacman-installed.tmp
pacman -Qm | awk '{ print $1 }' | sort | comm -3 /tmp/pacman-installed.tmp - > /tmp/pacman-to-reinstall.tmp

pacman -S --noconfirm --force $(cat /tmp/pacman-to-reinstall.tmp)
rm /tmp/pacman-{to-reinstall,installed}.tmp
