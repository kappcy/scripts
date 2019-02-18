#!/bin/bash
LMonitor="$HOME/gif-wallpapers/pixels3.gif"
RMonitor="$HOME/gif-wallpapers/pixels1.gif"

opts="--no-osc --no-osd-bar --loop-file --player-operation-mode=cplayer --no-audio --panscan=1.0 --no-stop-screensaver"

while true; do
	xwinwrap -g 1920x1080+1920+0 -ni -ov -- mpv -wid WID $RMonitor $opts &
	xwinwrap -g 1922x1080-2+0 -ni -ov -- mpv -wid WID $LMonitor $opts &
	until pgrep i3lock; do sleep 5; done
	killall xwinwrap
	while pgrep i3lock; do sleep 1; done
done
