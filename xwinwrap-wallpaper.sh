#!/bin/bash
Screen=( "1922x1080-2+0" "1920x1080+1920+0" )
Screen1=( "$HOME/gif-wallpapers/pixels3.gif" "$HOME/gif-wallpapers/pixels1.gif" )
for i in ${!Screen[*]}; do
	xwinwrap -g ${Screen[i]} -ni -ov -- mpv -wid WID ${Screen1[i]} --no-osc --no-osd-bar --loop-file \
	--player-operation-mode=cplayer --no-audio --panscan=1.0 --no-stop-screensaver &
done
