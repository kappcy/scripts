#!/bin/sh
: '
/etc/systemd/system/beforesuspend.service
[Unit]
Description=run before suspend
Before=sleep.target

Service]
User=kappcy
Type=forking
Environment=DISPLAY=:0
ExecStart=/home/kappcy/scripts/openbox/lock.sh

Install]
WantedBy=sleep.target
'

killtv () {
	DVI="DPY-0: nvidia-auto-select +1920+0 {ForceCompositionPipeline=On}"
	HDMI="DPY-1: nvidia-auto-select +0+0 {ForceCompositionPipeline=On}"
	if nvidia-settings --query CurrentMetaMode | grep +3840 > /dev/null; then
	   nvidia-settings --assign CurrentMetaMode="$DVI, $HDMI"
	   sleep 1
	fi
}

killtv
scrot /tmp/screen.png
betterlockscreen -u /tmp/screen.png
betterlockscreen -l dimblur &
sleep 1
