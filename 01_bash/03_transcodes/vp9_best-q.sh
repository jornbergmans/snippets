#!/bin/bash

IFS=$'\n'

ffmpeg -y -i "$1" -c:v libvpx-vp9 -pass 1 -b:v 250k -threads 1 -speed 4 \
  -tile-columns 0 -frame-parallel 0 \
  -g 100 -aq-mode 0 -an -f webm /dev/null

ffmpeg -y -i "$1" -c:v libvpx-vp9 -pass 2 -b:v 2500k -threads 1 -speed 0 \
  -tile-columns 0 -frame-parallel 0 -auto-alt-ref 1 -lag-in-frames 25 \
  -pix_fmt yuva420p -g 100 -aq-mode 0 -c:a opus -strict -2 -b:a 128k \
  -f webm ${1%.*}-vp9.webm
