#!/bin/bash

# Procces invalid files (that are not named)
# Set the delimiter
IFS=$'\n'
OLDFILES=($(find -maxdepth 1 -name "capt**.nef" -print))
# Make a new directory for old images, and put them in
if test ${#OLDFILES[@]} -gt 0; then
	NEWDIR=OldImages_$(printf '%(%Y-%m-%d_%H:%M:%S)T\n' -1)
	mkdir $NEWDIR
	LOOP=0
	for i in "${OLDFILES[@]}"; do
    		mv -f $i "./$NEWDIR${i:1}"
    		((LOOP++))
	done
fi

# Check if there were other captures today
TODAY=($(find -maxdepth 1 -name "LAST.dslr1.in**.nef" -print))

# Infinite loop, basically a for loop for every new file
LOOP=0
while true; do
    IMFILE="capt$(printf %04d $LOOP).nef"
    # Wait until new file is found
    WAITTIME=0
    until test -f "$IMFILE"; do
	sleep 0.1
	((WAITTIME++))
	# Set a timeout for the function
	if test $WAITTIME -gt 1200; then
		exit
	fi
    done
	
((LOOP++))
# Rename the newly found file
SEQ=$(expr $LOOP + ${#TODAY[@]})
mv -f $IMFILE "./LAST.dslr1.in_$(date +%Y%m%d.%H%M%S.%3N)_clear__$(printf %03d $SEQ)___sci_raw_Image_1.nef"

done

