#!/bin/sh
while true; do
	until [ "$(xprintidle)" -le "600000" ]; do
		if xset -q  | grep -i "monitor is on" >/dev/null; then
			xset dpms force off
		fi
		sleep 20
	done
	sleep 5
	array=( "youtube\|vimeo\|twitch" "bomi" )
	array2=( "Vivaldi" "bomi" )
	for i in ${!array[*]}; do
		while wmctrl -l | grep -i "${array[i]}" >/dev/null && \
		pacmd list-sink-inputs | grep -B12 ${array2[i]} | grep RUNNING >/dev/null; do
			sleep 20
				if ! pacmd list-sink-inputs | grep -B12 ${array2[i]} | grep RUNNING >/dev/null; then
					sleep 5
					break
				elif pgrep -u $UID -x i3lock >/dev/null; then
					break
				fi
		done
	done
	while pgrep -u $UID -x i3lock >/dev/null; do
		until [ "$(xprintidle)" -le "30000" ]; do
			if xset -q  | grep -i "monitor is on" >/dev/null; then
				xset dpms force off
			fi
			sleep 2
		done
		sleep 2
		if ! pgrep -u $UID -x i3lock >/dev/null; then
			pulseaudio -k
			~/.config/polybar/launch.sh &>/dev/null &
			break
		fi
	done
done
