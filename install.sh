#!/bin/bash

# Use this script after cloning the repo, this will install all dependencies. 
# This script needs superuser privileges

sudo apt install digitemp
sudo apt install gphoto2
sudo apt install libgphoto2-6
sudo apt install gtkam
sudo apt install geeqie
sudo apt install dcraw
git config --global --add safe.directory /home/ocs/matlab/skycam
git config --global --add safe.directory /home/ocs/matlab/skycam/matlab-gphoto
git config --global --add safe.directory /home/ocs/matlab/skycam/matlab-process
git submodule update --init --recursive
