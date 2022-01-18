#!/bin/bash
#convert all heic files in $SOURCE folder and subfolders to jpg and save them to $DESTINATION
#please remeber the final / in source name and dest name the script might break otherwise

#to deal with spaces in filenames:
OIFS="$IFS"
IFS=$'\n'

# to prevent option from leaking in git
source ./convert.conf

mkdir -p $DESTINATION
images=$(find "$SOURCE" | grep -E ".HEIC")
for i in $images
do
	echo "$i"
	dest="${i/"$SOURCE"/}"
	dest=${dest/.HEIC/.jpg}
	dest="$DESTINATION""$dest"
	mkdir -p "$(dirname "$dest")"
	magick convert "$i" "$dest"
done

IFS="$OIFS"
