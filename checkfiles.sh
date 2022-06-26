#!/bin/bash
cd ~/skycam

# Procces old files (rename them)
# Set the delimiter
IFS=$'\n'
OLDFILES=($(find -maxdepth 1 -name "capt**.nef" -print))
# Make a new directory for old images
if test ${#OLDFILES[@]} -gt 0; then
	NEWDIR=OldImages_$(printf '%(%Y-%m-%d_%H:%M:%S)T\n' -1)
	mkdir $NEWDIR
	LOOP=0
	for i in "${OLDFILES[@]}"; do
    		mv -f $i "./$NEWDIR${i:1}"
    		((LOOP++))
	done
fi

# Infinite loop, basically a for loop for every new file
LOOP=0
while true; do
    IMFILE="capt$(printf %04d $LOOP).nef"
    # Wait until new file is found
    until test -f "$IMFILE"; do
	sleep 0.1
    done

    # Rename the newly found file
    mv -f $IMFILE "./SkyImage_$(printf '%(%Y-%m-%d_%H:%M:%S)T\n' -1).nef"

    ((LOOP++))
done
