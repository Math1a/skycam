#!/bin/bash

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
    IMFILE=($(find -maxdepth 1 -name "capt**.nef" -print))
    # Wait until new file is found
    WAITTIME=0
    until test -f "$IMFILE"; do
	sleep 0.1
	((WAITTIME++))
	# Check if new file exists
	IMFILE=($(find -maxdepth 1 -name "capt**.nef" -print))
	# Set a timeout for the function
	if test $WAITTIME -gt 1200; then
		exit
	fi
    done

    # Rename the newly found file
    mv -f $IMFILE "./SkyImage_$(printf '%(%Y-%m-%d_%H:%M:%S)T\n' -1).nef"

    ((LOOP++))
done

