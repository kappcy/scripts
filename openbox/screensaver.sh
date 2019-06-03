#!/bin/bash
conf=$HOME/.cache/screensaver
NL='
'

# Default timings in minutes
Default_blank="10"
Default_lockblank=".5"
Default_suspend="60"

check_conf() {
	if [ ! -e $conf ];then
		if [ $(pgrep -c screensaver.sh) == "2" ]; then
		echo "Screensaver is on" > $conf
		else
		echo "Screensaver is off" > $conf
		fi
		echo "AutoSuspend is on" >> $conf
		echo "-----------------------" >> $conf
		echo "Blank Screen at $Default_blank Mins" >> $conf
		echo "Blank LockScreen at $Default_lockblank Mins" >> $conf
		echo "Suspend at $Default_suspend Mins" >> $conf
	fi
	# Disable xset blanking
	if ! xset -q | grep "Standby: 0    Suspend: 0    Off: 0" &> /dev/null; then
		xset s 0 0
		xset s noblank
		xset s noexpose
		xset dpms 0 0 0
	fi
}

check_times() {
	blank=$(sed -n '4,4p' $conf | awk '{print $4}')
	lockblank=$(sed -n '5,5p' $conf | awk '{print $4}')
	suspend=$(sed -n '6,6p' $conf | awk '{print $3}')
	times=( "$blank" "$lockblank" "$suspend" )
	A=${times[@]}
	B=${timesCHK[@]}
	if [ ! "$A" == "$B" ]; then
		timesMS=()
		timesCHK=()
		for i in ${!times[*]}; do
			MS=$(echo "${times[i]}*60000" | bc -l)
			timesMS+=(${MS%.*})
			timesCHK+=(${times[i]})
		done
	fi
}

resetidle() {
	xdotool mousemove_relative --sync -- 25 25 
	xdotool mousemove_relative --sync -- -25 -25
}

Auto_suspend() {
	if grep -o "AutoSuspend.*on" $conf && \
	[ "$(xprintidle)" -ge "${timesMS[2]}" ]; then
		systemctl suspend && sleep 10
		until xset -q  | grep -i "monitor is on"; do xset dpms force on; done
		resetidle
	fi
}

screensleep() {
	while xset -q  | grep -i "monitor is off"; do
	sleep 2
	Auto_suspend
	done
}

screenoff() {
	if ! pgrep i3lock && [ "$(xprintidle)" -ge "${timesMS[0]}" ]; then
		xset dpms force off
		screensleep
	elif pgrep i3lock && [ "$(xprintidle)" -ge "${timesMS[1]}" ]; then
		xset dpms force off
		screensleep
	else
	sleep 2
	fi
}

check_vid() {
	video=( "youtube\|vimeo\|twitch" "bomi" "mpv")
	video2=( "Vivaldi" "bomi" "mpv")
		for i in ${!video[*]}; do
			while wmctrl -l | grep -i "${video[i]}" && \
			pacmd list-sink-inputs | grep -B12 ${video2[i]} | grep RUNNING; do
				sleep 10
				if ! pacmd list-sink-inputs | grep -B12 ${video2[i]} | grep RUNNING; then
					resetidle
				elif pgrep i3lock; then
					break
				fi
			done
		done
}

check_lock() {
	while pgrep i3lock; do
	screenoff
	sleep 2
	done
}

check_conf

# Options
if [ -z $1 ]; then
	case $(pgrep screensaver.sh) in
		*"$NL"*)
			pkill -o screensaver.sh
			if grep -o 'Screensaver.*on' $conf &> /dev/null; then		
				notify-send "Screensaver Disabled"
				sed -i "1s/on/off/" $conf
			fi
			exit 1
			;;
		*)
			if grep -o 'Screensaver.*off' $conf &> /dev/null; then
				notify-send "Screensaver Enabled"
				sed -i "1s/off/on/" $conf
			fi
			;;
	esac
elif [ $# -ge 3 ];then
	echo "too many arguments" && exit 1
elif [ $# == 2 ];then
	check_times
	if ! [[ $2 =~ ^[.0-9]+$ ]] ; then
		echo "error: Not a number" && exit 1
	fi
	case "$1" in
		-ab | --adjust_blank)
			if echo "$2 >= $suspend" | bc -l | grep -q 1; then
			echo "Can't be set higher than Suspend time"
			exit 1
			else
			notify-send "Screen blank set at $2 mins"
			sed -i "4s/at.*Mins/at $2 Mins/" $conf
			fi
			;;
		-al | --adjust_lockblank)
			if echo "$2 >= $suspend" | bc -l | grep -q 1; then
			echo "Can't be set higher than Suspend time"
			exit 1
			else
			notify-send "LockScreen blank set at $2 mins"
			sed -i "5s/at.*Mins/at $2 Mins/" $conf
			fi
			;;
		-as | --adjust_suspend)
			notify-send "Suspend set at $2 mins"
			sed -i "6s/at.*Mins/at $2 Mins/" $conf
			;;
		*)
			echo "invalid argument"
			;;
	esac
	exit 1
elif [ $# == 1 ];then
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
		-r | --reset)
			rm $conf
			check_conf
			echo "conf reset"
			exit 1
			;;
		*)
			echo "invalid argument"
			exit 1
			;;
	esac
fi

# Run Screensaver
while true; do
	check_conf; check_times; screenoff
	sleep 5; check_vid; check_lock
done
