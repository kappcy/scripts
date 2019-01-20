#!/bin/sh
conf=$HOME/.cache/screensaver
if [ -z $1 ]; then
	true
	elif [ $1 == toggle ]; then
	if [ "$(awk '{if (NR ==2) print $3}' $conf)" == "1" ]; then
		notify-send "AutoSuspend Disabled"
		sed -i 's/^\(suspend\s*=\s*\).*$/\10/' $conf
	else
		notify-send "AutoSuspend Enabled"
		sed -i 's/^\(suspend\s*=\s*\).*$/\11/' $conf
	fi
	else
	exit 1
fi
if [ "$(awk '{if (NR ==1) print $3}' $conf)" == "1" ]; then
NL='
'
case $(pgrep -u $UID -x screensaver.sh) in
  *"$NL"*)
	kill -9 $(pgrep -u $UID -x screensaver.sh | head -n1)
	if [ -z $1 ];then
	notify-send "Screensaver Disabled"
	sed -i 's/^\(state\s*=\s*\).*$/\10/' $conf
	exit 1
	fi
	;;
esac
else
	notify-send "Screensaver Enabled"
	sed -i 's/^\(state\s*=\s*\).*$/\11/' $conf
fi
while true; do
	until [ "$(xprintidle)" -le "600000" ]; do
		if xset -q  | grep -i "monitor is on" >/dev/null; then
			xset dpms force off
		fi
		if [ "$(awk '{if (NR ==2) print $3}' $conf)" == "1" ] && [ "$(xprintidle)" -ge '3600000' ]; then
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
			if [ "$(awk '{if (NR ==2) print $3}' $conf)" == "1" ] && [ "$(xprintidle)" -ge '3600000' ]; then
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
