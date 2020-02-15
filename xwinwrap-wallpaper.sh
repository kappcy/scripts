#!/bin/bash

killall -q xwinwrap

Screen=( "1922x1080-2+0" "1920x1080+1920+0" )
Screen1=( "$HOME/Pictures/Wallpapers/gif-wallpapers/pixels4.gif" "$HOME/Pictures/Wallpapers/gif-wallpapers/pixels6.gif" )

[[ $(nvidia-settings --query CurrentMetaMode) = *DPY-2* ]] && \
Screen=( "1922x1080+4096+0" "1920x1080+6016+0" )

for i in ${!Screen[*]}; do
	xwinwrap -g ${Screen[i]} -ni -ov -- mpv -wid WID ${Screen1[i]} --no-osc --no-osd-bar --loop-file \
	--player-operation-mode=cplayer --no-audio --panscan=1.0 --no-stop-screensaver &
done
