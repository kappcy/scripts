#!/bin/sh
conf=$HOME/.cache/screensaver
video=( "youtube\|vimeo\|twitch" "bomi" )
video2=( "Vivaldi" "bomi" )
NL='
'
screenoff() {
	sleep 2
	if xset -q  | grep -i "monitor is on"; then
			xset dpms force off
	fi
	if ! grep -o 'AutoSuspend.*off' $conf && [ "$(xprintidle)" -ge '3600000' ]; then
			systemctl suspend
			xdotool keydown Shift_L keyup Shift_L
	fi
}
if [ ! -e $conf ];then
	echo "Screensaver is off" > $conf
	echo "AutoSuspend is on" >> $conf
fi
if [ -z $1 ]; then
	case $(pgrep screensaver.sh) in
		*"$NL"*)
			pkill -o screensaver.sh
			if grep -o 'Screensaver.*on' $conf; then		
				notify-send "Screensaver Disabled"
				sed -i "1s/on/off/" $conf
			fi
			exit 1
			;;
		*)
			if grep -o 'Screensaver.*off' $conf; then
				notify-send "Screensaver Enabled"
				sed -i "1s/off/on/" $conf
			fi
			;;
	esac
else
	case "$1" in
		-t | --toggle)
			if grep -o 'AutoSuspend.*on' $conf; then
				notify-send "AutoSuspend Disabled"
				sed -i "2s/on/off/" $conf
			else
				notify-send "AutoSuspend Enabled"
				sed -i "2s/off/on/" $conf
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
	until [ "$(xprintidle)" -le "600000" ]; do screenoff; done
	sleep 5
	for i in ${!video[*]}; do
		while wmctrl -l | grep -i "${video[i]}" && \
		pacmd list-sink-inputs | grep -B12 ${video2[i]} | grep RUNNING; do
			sleep 5
			if ! pacmd list-sink-inputs | grep -B12 ${video2[i]} | grep RUNNING; then
				xdotool keydown Shift_L keyup Shift_L
			elif pgrep i3lock; then
				break
			fi
		done
	done
	while pgrep i3lock; do
		until [ "$(xprintidle)" -le "30000" ]; do screenoff; done
		sleep 2
	done
done
