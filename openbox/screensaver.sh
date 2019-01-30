#!/bin/sh
conf=$HOME/.cache/screensaver
video=( "youtube\|vimeo\|twitch" "bomi" )
video2=( "Vivaldi" "bomi" )
NL='
'
screenoff() {
	if xset -q  | grep -i "monitor is on"; then
			xset dpms force off
	fi
	if ! grep -o 'suspend.*0' $conf && [ "$(xprintidle)" -ge '3600000' ]; then
			systemctl suspend
	fi
}
if [ ! -e $conf ];then
	echo "state = 0" > $conf
	echo "suspend = 1" >> $conf
fi
if [ -z $1 ]; then
	case $(pgrep screensaver.sh) in
		*"$NL"*)
			pkill -o screensaver.sh
			if grep -o 'state.*1' $conf; then		
				notify-send "Screensaver Disabled"
				sed -i 's/^\(state\s*=\s*\).*$/\10/' $conf
			fi
			exit 1
			;;
		*)
			if grep -o 'state.*0' $conf; then
				notify-send "Screensaver Enabled"
				sed -i 's/^\(state\s*=\s*\).*$/\11/' $conf
			fi
			;;
	esac
else
	case "$1" in
		-t | --toggle)
			if grep -o 'suspend.*1' $conf; then
				notify-send "AutoSuspend Disabled"
				sed -i 's/^\(suspend\s*=\s*\).*$/\10/' $conf
			else
				notify-send "AutoSuspend Enabled"
				sed -i 's/^\(suspend\s*=\s*\).*$/\11/' $conf
			fi
			exit 1
			;;
		-b | --blank)
			sleep 2
			xset dpms force off
			exit 1
			;;
		-s | --status)
			notify-send "$(cat $conf)"
			exit 1
			;;
		*)
			echo "invalid argument: $1"
			exit 1
			;;
	esac
fi
while true; do
	until [ "$(xprintidle)" -le "600000" ]; do
		screenoff
		sleep 5
	done
	sleep 5
	for i in ${!video[*]}; do
		while wmctrl -l | grep -i "${video[i]}" && \
		pacmd list-sink-inputs | grep -B12 ${video2[i]} | grep RUNNING; do
			sleep 5
				if ! pacmd list-sink-inputs | grep -B12 ${video2[i]} | grep RUNNING; then
					xdotool keydown Shift_L keyup Shift_L
					break
				elif pgrep -u $UID -x i3lock; then
					break
				fi
		done
	done
	while pgrep -u $UID -x i3lock; do
		until [ "$(xprintidle)" -le "30000" ]; do
			screenoff
			sleep 2
		done
		sleep 2
	done
done
