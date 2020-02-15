#!/bin/bash
### pseudo scratchpad ###

while [[ $(pgrep -c pavucontrol) -ge "2" ]]; do
killall -q pavucontrol
done

wid=`xdotool search --onlyvisible --name "Volume Control"` 
wid1=`xdotool search --name "Volume Control"`

bspc monitor pointed -f

if [[ -n $wid ]]
then xdotool windowunmap $wid
else
	if ! pgrep pavucontrol
	then pavucontrol &
	else xdotool windowmap $wid1
	fi
fi
