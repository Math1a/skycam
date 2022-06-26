#!/bin/bash
cd ~/skycam

LOOP=0
while true; do
    IMFILE="capt$(printf %04d $LOOP).nef"

    # Wait until 
    until test -f "$IMFILE"; do; done

    # Rename the newly found file
    mv -f $IMFILE "SkyImage_$(printf '%(%Y-%m-%d_%H:%M:%S)T\n' -1).nef"
    
    ((LOOP++))
done
