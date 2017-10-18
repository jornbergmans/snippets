#!/bin/bash

IFS=$'\n'

echo "Please input file"
	read inFile
	inVid=$(echo "$inFile" | sed 's/^[ \t]*//;s/[ \t]*$//')
if [[ -f ${inVid} ]]; then
	echo "Thank You. Reading from file $inVid"
	echo " "
	echo "Please input desired thumbnail interval in seconds"
	read inRate
	echo "Setting interval to 1 frame every $inRate seconds."
	echo " "
	echo "Creating thumbnail image..."

	bdIn=$(dirname "$inVid")
	baseIn=$(basename "$inVid")

	inFrames=$(	ffprobe -hide_banner -loglevel panic -pretty \
							-select_streams v:0 -show_entries stream=nb_frames \
							-of default=noprint_wrappers=1:nokey=1 -i $inVid)
	outToGrab=$(echo "$inFrames/$inRate" | bc)
	outFrames=$(echo "$outToGrab/25" | bc)
	tileHeight=$(echo "scale=2;$outFrames/4" | bc | xargs printf %.0f )

	mkdir -p "$bdIn/.ff_thumb"

	ffmpeg 	-hide_banner -loglevel panic \
					-i $inVid -vf fps="1/$inRate",scale='320:-1' \
					"$bdIn/.ff_thumb/$baseIn-%03d.png"
	ffmpeg 	-hide_banner -loglevel panic \
					-pattern_type glob -y -i "$bdIn/.ff_thumb/$baseIn-*.png" \
					-frames 1 \
					-vf tile=4x$tileHeight:margin=4:padding=4 \
					$bdIn/$baseIn-thumb.png
	rm -Rf "$bdIn/.ff_thumb"

	echo " "
	echo "Thumbnail output file created at $bdIn/$baseIn-thumb.png"
else
	echo "$inVid is not a valid file. Please restart and input a valid source video file."
	exit 1
fi
