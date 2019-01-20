#!/bin/sh
conf=$HOME/.cache/screensaver
if [ ! -e $conf ];then
	echo "state = 0" > $conf
	echo "suspend = 1" >> $conf
fi
if [ -z $1 ]; then
	if grep -o 'state.*1' $conf; then
		if (( $(grep -c . <<<"$(pgrep screensaver.sh)") > 1 )); then
			pkill -o screensaver.sh
			notify-send "Screensaver Disabled"
			sed -i 's/^\(state\s*=\s*\).*$/\10/' $conf
			exit 1
		fi
		else
		notify-send "Screensaver Enabled"
		sed -i 's/^\(state\s*=\s*\).*$/\11/' $conf
	fi
	elif [ $1 == toggle ]; then
		if grep -o 'suspend.*1' $conf; then
			notify-send "AutoSuspend Disabled"
			sed -i 's/^\(suspend\s*=\s*\).*$/\10/' $conf
			else
			notify-send "AutoSuspend Enabled"
			sed -i 's/^\(suspend\s*=\s*\).*$/\11/' $conf
		fi
	exit 1
	elif [ $1 == status ]; then
		notify-send "$(cat $conf)"
		exit 1
	else
	exit 1
fi
while true; do
	until [ "$(xprintidle)" -le "600000" ]; do
		if xset -q  | grep -i "monitor is on" >/dev/null; then
			xset dpms force off
		fi
		if ! grep -o 'suspend.*0' $conf && [ "$(xprintidle)" -ge '3600000' ]; then
			systemctl suspend
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
					xdotool keydown Shift_L keyup Shift_L
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
			if ! grep -o 'suspend.*0' $conf && [ "$(xprintidle)" -ge '3600000' ]; then
				systemctl suspend
			fi
			sleep 2
		done
		sleep 2
		if ! pgrep -u $UID -x i3lock >/dev/null; then
			break
		fi
	done
done
