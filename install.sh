#!/bin/bash

# Use this script after cloning the repo, this will install all dependencies. 
# This script needs superuser privileges

sudo apt install gphoto2
sudo apt install libgphoto2-6
sudo apt install gtkam
git submodule update --init --recursive