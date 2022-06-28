#!/bin/bash

cd /home/ocs/skycam

gphoto2 --auto-detect
name=SkyImage_`date +"%Y:%m:%d-%H:%M:%S"`.nef

gphoto2 --capture-preview
gphoto2 --capture-image

new=`ls -t | head -1`
mv $new $name
